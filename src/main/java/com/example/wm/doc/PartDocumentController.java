package com.example.wm.doc;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class PartDocumentController {
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(
        "pdf", "txt", "md", "jpg", "jpeg", "png", "webp"
    );

    private final PartDocumentRepository partDocumentRepository;
    private final Path uploadRootPath;

    public PartDocumentController(
        PartDocumentRepository partDocumentRepository,
        @Value("${wm.docs.root-path:D:\\\\Study\\\\wm-docs}") String uploadRootPath
    ) {
        this.partDocumentRepository = partDocumentRepository;
        this.uploadRootPath = Path.of(uploadRootPath).toAbsolutePath().normalize();
    }

    @GetMapping("/api/part-docs")
    public List<PartDocumentItem> list(@RequestParam long partId) {
        if (partId <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "유효한 파트를 선택해주세요.");
        }
        return partDocumentRepository.findByPartId(partId);
    }

    @PostMapping(value = "/api/part-docs/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public PartDocumentItem upload(
        @RequestParam long partId,
        @RequestParam String docType,
        @RequestParam(required = false) String title,
        @RequestPart("file") MultipartFile file
    ) {
        if (partId <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "유효한 파트를 선택해주세요.");
        }
        if (!StringUtils.hasText(docType)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "문서 유형은 필수입니다.");
        }
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "업로드 파일이 비어 있습니다.");
        }

        String originalFileName = normalizeOriginalName(file.getOriginalFilename());
        String fileExt = extractExtension(originalFileName);
        validateAllowedExtension(fileExt);

        String normalizedTitle = StringUtils.hasText(title)
            ? title.trim()
            : stripExtension(originalFileName);

        String storedFileName = UUID.randomUUID() + "." + fileExt;
        String relativePath = "part-" + partId + "/" + storedFileName;
        Path savePath = uploadRootPath.resolve(relativePath).normalize();
        if (!savePath.startsWith(uploadRootPath)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "잘못된 업로드 경로입니다.");
        }

        try {
            Files.createDirectories(savePath.getParent());
            Files.copy(file.getInputStream(), savePath, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "파일 저장에 실패했습니다.", e);
        }

        String contentType = StringUtils.hasText(file.getContentType()) ? file.getContentType() : guessContentType(fileExt);
        long id = partDocumentRepository.insert(
            new PartDocumentCreateRequest(
                partId,
                docType.trim(),
                normalizedTitle,
                originalFileName,
                relativePath.replace("\\", "/"),
                fileExt,
                contentType,
                file.getSize()
            )
        );
        PartDocumentItem created = partDocumentRepository.findItemById(id);
        if (created == null) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "문서 저장 결과를 조회할 수 없습니다.");
        }
        return created;
    }

    @GetMapping("/api/part-docs/{id}/content")
    public ResponseEntity<Resource> content(@PathVariable long id) {
        PartDocumentStoredItem item = partDocumentRepository.findStoredById(id);
        if (item == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "문서를 찾을 수 없습니다.");
        }

        Path filePath = uploadRootPath.resolve(item.storedPath()).normalize();
        if (!filePath.startsWith(uploadRootPath) || !Files.exists(filePath)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "문서 파일을 찾을 수 없습니다.");
        }

        Resource resource;
        try {
            resource = new UrlResource(filePath.toUri());
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "문서 로딩에 실패했습니다.", e);
        }

        MediaType mediaType = parseMediaType(item.contentType(), item.fileExt());
        String encodedFileName = URLEncoder.encode(item.originalFileName(), StandardCharsets.UTF_8).replace("+", "%20");
        ContentDisposition disposition = ContentDisposition.inline()
            .filename(item.originalFileName(), StandardCharsets.UTF_8)
            .build();

        return ResponseEntity.ok()
            .contentType(mediaType)
            .contentLength(item.fileSize())
            .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
            .header("X-File-Name", encodedFileName)
            .body(resource);
    }

    private void validateAllowedExtension(String ext) {
        if (!ALLOWED_EXTENSIONS.contains(ext.toLowerCase(Locale.ROOT))) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "허용되지 않은 파일 형식입니다. (pdf, txt, md, jpg, jpeg, png, webp)"
            );
        }
    }

    private String extractExtension(String fileName) {
        int idx = fileName.lastIndexOf('.');
        if (idx < 0 || idx == fileName.length() - 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "파일 확장자가 필요합니다.");
        }
        return fileName.substring(idx + 1).toLowerCase(Locale.ROOT);
    }

    private String stripExtension(String fileName) {
        int idx = fileName.lastIndexOf('.');
        if (idx < 0) return fileName;
        return fileName.substring(0, idx);
    }

    private String normalizeOriginalName(String originalFileName) {
        String fallback = "upload-file";
        String name = StringUtils.hasText(originalFileName) ? originalFileName.trim() : fallback;
        name = name.replace("\\", "/");
        int slashIdx = name.lastIndexOf('/');
        if (slashIdx >= 0) {
            name = name.substring(slashIdx + 1);
        }
        if (name.isBlank()) {
            return fallback;
        }
        return name;
    }

    private MediaType parseMediaType(String contentType, String fileExt) {
        if (StringUtils.hasText(contentType)) {
            try {
                return MediaType.parseMediaType(contentType);
            } catch (IllegalArgumentException ignored) {
                // Fall through to extension-based guess.
            }
        }
        return MediaType.parseMediaType(guessContentType(fileExt));
    }

    private String guessContentType(String fileExt) {
        return switch (fileExt.toLowerCase(Locale.ROOT)) {
            case "pdf" -> "application/pdf";
            case "txt" -> "text/plain; charset=UTF-8";
            case "md" -> "text/markdown; charset=UTF-8";
            case "jpg", "jpeg" -> "image/jpeg";
            case "png" -> "image/png";
            case "webp" -> "image/webp";
            default -> "application/octet-stream";
        };
    }
}
