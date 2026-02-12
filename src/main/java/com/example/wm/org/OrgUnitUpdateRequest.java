package com.example.wm.org;

public record OrgUnitUpdateRequest(
    Long parentId,
    Long partId,
    String name,
    String roleName,
    Integer posX,
    Integer posY,
    Integer sortOrder
) {}
