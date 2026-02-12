package com.example.wm.member;

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
public class MemberController {
    private final MemberRepository memberRepository;

    public MemberController(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    @GetMapping("/api/members")
    public List<MemberItem> list(@RequestParam(defaultValue = "false") boolean activeOnly) {
        return memberRepository.findAll(activeOnly);
    }

    @PostMapping("/api/members")
    public MemberItem create(@RequestBody MemberCreateRequest request) {
        MemberCreateRequest normalized = normalizeCreate(request);
        validateEmpNoUniqueForCreate(normalized.empNo());
        long id = memberRepository.insert(normalized);
        return new MemberItem(
            id,
            normalized.empNo(),
            normalized.name(),
            normalized.title(),
            normalized.phone(),
            normalized.email(),
            normalized.active()
        );
    }

    @PutMapping("/api/members/{id}")
    public MemberItem update(@PathVariable long id, @RequestBody MemberUpdateRequest request) {
        MemberUpdateRequest normalized = normalizeUpdate(request);
        validateEmpNoUniqueForUpdate(normalized.empNo(), id);
        int updated = memberRepository.update(id, normalized);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "구성원을 찾을 수 없습니다.");
        }
        return new MemberItem(
            id,
            normalized.empNo(),
            normalized.name(),
            normalized.title(),
            normalized.phone(),
            normalized.email(),
            normalized.active()
        );
    }

    @DeleteMapping("/api/members/{id}")
    public void deactivate(@PathVariable long id) {
        int updated = memberRepository.deactivate(id);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "구성원을 찾을 수 없습니다.");
        }
    }

    @DeleteMapping("/api/members/{id}/hard")
    @Transactional
    public void deleteHard(@PathVariable long id) {
        int updated = memberRepository.deleteHard(id);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "구성원을 찾을 수 없습니다.");
        }
    }

    private MemberCreateRequest normalizeCreate(MemberCreateRequest request) {
        if (request == null || request.name() == null || request.name().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "구성원 이름은 필수입니다.");
        }
        return new MemberCreateRequest(
            normalizeOptional(request.empNo()),
            request.name().trim(),
            normalizeOptional(request.title()),
            normalizeOptional(request.phone()),
            normalizeOptional(request.email()),
            request.active() == null || request.active()
        );
    }

    private MemberUpdateRequest normalizeUpdate(MemberUpdateRequest request) {
        if (request == null || request.name() == null || request.name().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "구성원 이름은 필수입니다.");
        }
        return new MemberUpdateRequest(
            normalizeOptional(request.empNo()),
            request.name().trim(),
            normalizeOptional(request.title()),
            normalizeOptional(request.phone()),
            normalizeOptional(request.email()),
            request.active() == null || request.active()
        );
    }

    private String normalizeOptional(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void validateEmpNoUniqueForCreate(String empNo) {
        if (empNo == null) return;
        if (memberRepository.existsByEmpNo(empNo)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 사용 중인 사번입니다.");
        }
    }

    private void validateEmpNoUniqueForUpdate(String empNo, long id) {
        if (empNo == null) return;
        if (memberRepository.existsByEmpNoExceptId(empNo, id)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 사용 중인 사번입니다.");
        }
    }
}
