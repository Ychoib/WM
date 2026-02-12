package com.example.wm.part;

public record PartMemberCreateRequest(
    Long memberId,
    String roleInPart,
    Integer sortOrder,
    Boolean primary,
    Boolean active
) {}
