package com.example.wm.policy;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class PolicyController {
    private final PolicyRepository policyRepository;

    public PolicyController(PolicyRepository policyRepository) {
        this.policyRepository = policyRepository;
    }

    @GetMapping("/api/policies")
    // 알림 정책 목록 API: 등록/수정 화면에서 정책 리스트를 사용한다.
    public List<PolicyItem> listPolicies() {
        return policyRepository.findAll();
    }

    @PostMapping("/api/policies")
    // 알림 정책 등록 API: 정책 이름과 스케줄을 저장한다.
    public PolicyItem createPolicy(@RequestBody PolicyCreateRequest request) {
        if (request == null
            || request.name() == null || request.name().isBlank()
            || request.schedule() == null || request.schedule().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "필수 값이 누락되었습니다.");
        }
        long id = policyRepository.insert(request);
        return new PolicyItem(id, request.name(), request.schedule());
    }
}
