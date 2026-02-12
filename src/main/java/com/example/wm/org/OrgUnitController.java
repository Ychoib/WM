package com.example.wm.org;

import java.util.List;
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
public class OrgUnitController {
    private final OrgUnitRepository orgUnitRepository;

    public OrgUnitController(OrgUnitRepository orgUnitRepository) {
        this.orgUnitRepository = orgUnitRepository;
    }

    @GetMapping("/api/org/units")
    public List<OrgUnitItem> list(@RequestParam(defaultValue = "true") boolean activeOnly) {
        return orgUnitRepository.findAll(activeOnly);
    }

    @PostMapping("/api/org/units")
    public OrgUnitItem create(@RequestBody OrgUnitCreateRequest request) {
        OrgUnitCreateRequest normalized = normalizeCreate(request);
        long id = orgUnitRepository.insert(normalized);
        return new OrgUnitItem(
            id,
            normalized.parentId(),
            normalized.partId(),
            normalized.name(),
            normalized.roleName(),
            normalized.posX(),
            normalized.posY(),
            true,
            normalized.sortOrder()
        );
    }

    @PutMapping("/api/org/units/{id}")
    public OrgUnitItem update(@PathVariable long id, @RequestBody OrgUnitUpdateRequest request) {
        OrgUnitUpdateRequest normalized = normalizeUpdate(request);
        int updated = orgUnitRepository.update(id, normalized);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "조직 노드를 찾을 수 없습니다.");
        }
        return new OrgUnitItem(
            id,
            normalized.parentId(),
            normalized.partId(),
            normalized.name(),
            normalized.roleName(),
            normalized.posX(),
            normalized.posY(),
            true,
            normalized.sortOrder()
        );
    }

    @PutMapping("/api/org/units/{id}/position")
    public void updatePosition(@PathVariable long id, @RequestBody OrgUnitPositionRequest request) {
        if (request == null || request.posX() == null || request.posY() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "좌표 값이 필요합니다.");
        }
        int updated = orgUnitRepository.updatePosition(id, request.posX(), request.posY());
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "조직 노드를 찾을 수 없습니다.");
        }
    }

    @DeleteMapping("/api/org/units/{id}")
    public void deactivate(@PathVariable long id) {
        int updated = orgUnitRepository.deactivate(id);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "조직 노드를 찾을 수 없습니다.");
        }
    }

    @PostMapping("/api/org/units/reorder")
    @Transactional
    public void reorder(@RequestBody OrgUnitReorderRequest request) {
        if (request == null || request.items() == null || request.items().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "수정할 대상이 없습니다.");
        }
        for (OrgUnitMoveItem item : request.items()) {
            orgUnitRepository.updateMove(item);
        }
    }

    private OrgUnitCreateRequest normalizeCreate(OrgUnitCreateRequest request) {
        if (request == null || request.name() == null || request.name().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "조직명은 필수입니다.");
        }
        int sortOrder = request.sortOrder() == null ? 0 : request.sortOrder();
        String roleName = normalizeRole(request.roleName());
        return new OrgUnitCreateRequest(
            request.parentId(),
            request.partId(),
            request.name().trim(),
            roleName,
            request.posX(),
            request.posY(),
            sortOrder
        );
    }

    private OrgUnitUpdateRequest normalizeUpdate(OrgUnitUpdateRequest request) {
        if (request == null || request.name() == null || request.name().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "조직명은 필수입니다.");
        }
        int sortOrder = request.sortOrder() == null ? 0 : request.sortOrder();
        String roleName = normalizeRole(request.roleName());
        return new OrgUnitUpdateRequest(
            request.parentId(),
            request.partId(),
            request.name().trim(),
            roleName,
            request.posX(),
            request.posY(),
            sortOrder
        );
    }

    private String normalizeRole(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
