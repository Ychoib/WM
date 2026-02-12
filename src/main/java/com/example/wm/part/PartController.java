package com.example.wm.part;

import java.util.List;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class PartController {
    private final PartRepository partRepository;

    public PartController(PartRepository partRepository) {
        this.partRepository = partRepository;
    }

    @GetMapping("/api/parts")
    public List<PartItem> listParts(@RequestParam(defaultValue = "false") boolean activeOnly) {
        return partRepository.findAll(activeOnly);
    }

    @PostMapping("/api/parts")
    public PartItem createPart(@RequestBody PartCreateRequest request) {
        PartCreateRequest normalized = normalizeCreate(request);
        try {
            long id = partRepository.insert(normalized);
            return new PartItem(
                id,
                normalized.code(),
                normalized.name(),
                normalized.active(),
                normalized.displayOrder()
            );
        } catch (DataIntegrityViolationException ex) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "중복된 파트 코드입니다.");
        }
    }

    @PutMapping("/api/parts/{id}")
    public PartItem updatePart(@PathVariable long id, @RequestBody PartUpdateRequest request) {
        PartUpdateRequest normalized = normalizeUpdate(request);
        try {
            int updated = partRepository.update(id, normalized);
            if (updated == 0) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "파트를 찾을 수 없습니다.");
            }
            return new PartItem(
                id,
                normalized.code(),
                normalized.name(),
                normalized.active(),
                normalized.displayOrder()
            );
        } catch (DataIntegrityViolationException ex) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "중복된 파트 코드입니다.");
        }
    }

    @DeleteMapping("/api/parts/{id}")
    public void deactivatePart(@PathVariable long id) {
        int updated = partRepository.deactivate(id);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "파트를 찾을 수 없습니다.");
        }
    }

    @DeleteMapping("/api/parts/{id}/hard")
    @Transactional
    public void deletePartHard(@PathVariable long id) {
        int updated = partRepository.deleteHard(id);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "파트를 찾을 수 없습니다.");
        }
    }

    private PartCreateRequest normalizeCreate(PartCreateRequest request) {
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "요청 값이 없습니다.");
        }
        String code = normalizeCode(request.code());
        String name = normalizeText(request.name(), "파트명은 필수입니다.");
        int displayOrder = request.displayOrder() == null ? 100 : request.displayOrder();
        boolean active = request.active() == null || request.active();
        return new PartCreateRequest(code, name, displayOrder, active);
    }

    private PartUpdateRequest normalizeUpdate(PartUpdateRequest request) {
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "요청 값이 없습니다.");
        }
        String code = normalizeCode(request.code());
        String name = normalizeText(request.name(), "파트명은 필수입니다.");
        int displayOrder = request.displayOrder() == null ? 100 : request.displayOrder();
        boolean active = request.active() == null || request.active();
        return new PartUpdateRequest(code, name, displayOrder, active);
    }

    private String normalizeCode(String code) {
        String normalized = normalizeText(code, "파트 코드는 필수입니다.")
            .toUpperCase()
            .replaceAll("[^A-Z0-9_\\-]", "");
        if (normalized.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "파트 코드는 영문/숫자/_, - 만 사용 가능합니다.");
        }
        return normalized;
    }

    private String normalizeText(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, message);
        }
        return value.trim();
    }
}
