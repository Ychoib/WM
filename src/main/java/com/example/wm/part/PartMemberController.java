package com.example.wm.part;

import java.util.List;
import org.springframework.http.HttpStatus;
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
public class PartMemberController {
    private final PartMemberRepository partMemberRepository;

    public PartMemberController(PartMemberRepository partMemberRepository) {
        this.partMemberRepository = partMemberRepository;
    }

    @GetMapping("/api/parts/{partId}/members")
    public List<PartMemberItem> list(
        @PathVariable long partId,
        @RequestParam(defaultValue = "true") boolean activeOnly
    ) {
        return partMemberRepository.findByPartId(partId, activeOnly);
    }

    @PostMapping("/api/parts/{partId}/members")
    public PartMemberItem create(@PathVariable long partId, @RequestBody PartMemberCreateRequest request) {
        PartMemberCreateRequest normalized = normalizeCreate(request);
        long id = partMemberRepository.insert(partId, normalized);
        return new PartMemberItem(
            id,
            partId,
            normalized.memberId(),
            null,
            null,
            normalized.roleInPart(),
            normalized.sortOrder(),
            normalized.primary(),
            normalized.active()
        );
    }

    @PutMapping("/api/parts/{partId}/members/{id}")
    public PartMemberItem update(
        @PathVariable long partId,
        @PathVariable long id,
        @RequestBody PartMemberUpdateRequest request
    ) {
        PartMemberUpdateRequest normalized = normalizeUpdate(request);
        int updated = partMemberRepository.update(id, normalized);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "파트 구성원을 찾을 수 없습니다.");
        }
        return new PartMemberItem(
            id,
            partId,
            normalized.memberId(),
            null,
            null,
            normalized.roleInPart(),
            normalized.sortOrder(),
            normalized.primary(),
            normalized.active()
        );
    }

    @DeleteMapping("/api/parts/{partId}/members/{id}")
    public void deactivate(@PathVariable long partId, @PathVariable long id) {
        int updated = partMemberRepository.deactivate(id);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "파트 구성원을 찾을 수 없습니다.");
        }
    }

    @DeleteMapping("/api/parts/{partId}/members/{id}/hard")
    public void deleteHard(@PathVariable long partId, @PathVariable long id) {
        int deleted = partMemberRepository.deleteHard(id);
        if (deleted == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "파트 구성원을 찾을 수 없습니다.");
        }
    }

    private PartMemberCreateRequest normalizeCreate(PartMemberCreateRequest request) {
        if (request == null || request.memberId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "구성원 선택은 필수입니다.");
        }
        int sortOrder = request.sortOrder() == null ? 100 : request.sortOrder();
        boolean primary = request.primary() != null && request.primary();
        boolean active = request.active() == null || request.active();
        return new PartMemberCreateRequest(
            request.memberId(),
            normalizeOptional(request.roleInPart()),
            sortOrder,
            primary,
            active
        );
    }

    private PartMemberUpdateRequest normalizeUpdate(PartMemberUpdateRequest request) {
        if (request == null || request.memberId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "구성원 선택은 필수입니다.");
        }
        int sortOrder = request.sortOrder() == null ? 100 : request.sortOrder();
        boolean primary = request.primary() != null && request.primary();
        boolean active = request.active() == null || request.active();
        return new PartMemberUpdateRequest(
            request.memberId(),
            normalizeOptional(request.roleInPart()),
            sortOrder,
            primary,
            active
        );
    }

    private String normalizeOptional(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
