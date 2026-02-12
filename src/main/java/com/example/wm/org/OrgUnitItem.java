package com.example.wm.org;

public record OrgUnitItem(
    long id,
    Long parentId,
    Long partId,
    String name,
    String roleName,
    Integer posX,
    Integer posY,
    boolean active,
    int sortOrder
) {}
