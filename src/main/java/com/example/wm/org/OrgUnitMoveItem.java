package com.example.wm.org;

public record OrgUnitMoveItem(
    long id,
    Long parentId,
    int sortOrder
) {}
