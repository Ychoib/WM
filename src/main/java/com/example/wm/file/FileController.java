package com.example.wm.file;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.FileTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.stream.Stream;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class FileController {
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private final Path rootPath;

    public FileController(@Value("${wm.file.root-path:D:\\\\Study}") String rootPath) {
        this.rootPath = Path.of(rootPath).toAbsolutePath().normalize();
    }

    @GetMapping("/api/files")
    public FileListResponse listFiles(
        @RequestParam(defaultValue = "") String path,
        @RequestParam(defaultValue = "") String keyword
    ) {
        Path targetPath = resolvePath(path);
        if (!Files.exists(targetPath) || !Files.isDirectory(targetPath)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Directory not found.");
        }

        String normalizedKeyword = keyword == null ? "" : keyword.trim().toLowerCase(Locale.ROOT);
        List<FileEntry> entries;
        try (Stream<Path> stream = Files.list(targetPath)) {
            entries = stream
                .map(this::toEntry)
                .filter(entry -> normalizedKeyword.isBlank()
                    || entry.name().toLowerCase(Locale.ROOT).contains(normalizedKeyword))
                .sorted(
                    Comparator.comparing(FileEntry::directory).reversed()
                        .thenComparing(FileEntry::name, String.CASE_INSENSITIVE_ORDER)
                )
                .toList();
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to list files.", e);
        }

        String currentPath = toRelativePath(targetPath);
        Path parent = targetPath.equals(rootPath) ? null : targetPath.getParent();
        String parentPath = parent == null ? null : toRelativePath(parent);

        return new FileListResponse(
            rootPath.toString(),
            currentPath,
            parentPath,
            entries
        );
    }

    private FileEntry toEntry(Path path) {
        try {
            boolean isDirectory = Files.isDirectory(path);
            long size = isDirectory ? 0L : Files.size(path);
            FileTime lastModifiedTime = Files.getLastModifiedTime(path);
            String modifiedAt = TIME_FORMATTER.format(lastModifiedTime.toInstant().atZone(ZoneId.systemDefault()));
            return new FileEntry(
                path.getFileName().toString(),
                toRelativePath(path),
                isDirectory,
                size,
                modifiedAt
            );
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to read file metadata.", e);
        }
    }

    private Path resolvePath(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) {
            return rootPath;
        }

        Path resolved = rootPath.resolve(relativePath).normalize();
        if (!resolved.startsWith(rootPath)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid path.");
        }
        return resolved;
    }

    private String toRelativePath(Path path) {
        if (path.equals(rootPath)) {
            return "";
        }
        return rootPath.relativize(path).toString().replace("\\", "/");
    }
}
