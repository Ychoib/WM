package com.example.wm.part;

public record PartItem(
    long id,
    String code,
    String name,
    boolean active,
    int displayOrder
) {}
