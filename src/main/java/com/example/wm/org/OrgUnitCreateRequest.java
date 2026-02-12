package com.example.wm.org;

public record OrgUnitCreateRequest(
    Long parentId,
    Long partId,
    String name,
    String roleName,
    Integer posX,
    Integer posY,
    Integer sortOrder
) {}
