package com.example.wm.asset;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class AssetController {
    private final AssetRepository assetRepository;

    public AssetController(AssetRepository assetRepository) {
        this.assetRepository = assetRepository;
    }

    @PostMapping("/api/assets")
    // 자산 등록 API: 필수값을 검사한 뒤 DB에 저장한다.
    public AssetCreateResponse createAsset(@RequestBody AssetCreateRequest request) {
        if (request == null
            || request.name() == null || request.name().isBlank()
            || request.type() == null || request.type().isBlank()
            || request.expiresAt() == null || request.expiresAt().isBlank()
            || request.partId() == null || request.partId() <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "필수 값이 누락되었습니다.");
        }
        long id = assetRepository.insert(request);
        return new AssetCreateResponse(id);
    }

    @GetMapping("/api/assets/{id}")
    // 자산 상세 조회 API: 수정 화면 로딩용으로 사용한다.
    public AssetDetail getAsset(@PathVariable long id) {
        AssetDetail detail = assetRepository.findById(id);
        if (detail == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "자산을 찾을 수 없습니다.");
        }
        return detail;
    }

    @PutMapping("/api/assets/{id}")
    // 자산 수정 API: 필수값을 검사한 뒤 DB 값을 갱신한다.
    public void updateAsset(@PathVariable long id, @RequestBody AssetUpdateRequest request) {
        if (request == null
            || request.name() == null || request.name().isBlank()
            || request.type() == null || request.type().isBlank()
            || request.expiresAt() == null || request.expiresAt().isBlank()
            || request.partId() == null || request.partId() <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "필수 값이 누락되었습니다.");
        }
        int updated = assetRepository.update(id, request);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "자산을 찾을 수 없습니다.");
        }
    }

    @GetMapping("/api/assets")
    // 만료일 전체 목록 API: 모든 자산을 만료일 순으로 반환한다.
    public java.util.List<AssetDetail> listAssets() {
        return assetRepository.findAllForExpiry();
    }

    @GetMapping("/api/assets/recent")
    // 최근 등록된 자산 목록 API: 등록 화면에서 최근 내역을 보여준다.
    public java.util.List<AssetRecentItem> listRecent(@RequestParam(defaultValue = "3") int limit) {
        int safeLimit = Math.max(1, Math.min(limit, 20));
        return assetRepository.findRecent(safeLimit);
    }
}
