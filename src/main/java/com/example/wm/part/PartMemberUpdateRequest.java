package com.example.wm.part;

public record PartMemberUpdateRequest(
    Long memberId,
    String roleInPart,
    Integer sortOrder,
    Boolean primary,
    Boolean active
) {}
