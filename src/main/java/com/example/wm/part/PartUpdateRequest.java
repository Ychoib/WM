package com.example.wm.part;

public record PartUpdateRequest(
    String code,
    String name,
    Integer displayOrder,
    Boolean active
) {}
