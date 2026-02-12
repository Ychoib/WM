package com.example.wm.part;

public record PartMemberItem(
    long id,
    long partId,
    long memberId,
    String memberName,
    String memberTitle,
    String roleInPart,
    int sortOrder,
    boolean primary,
    boolean active
) {}
