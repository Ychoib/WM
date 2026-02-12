package com.example.wm.part;

public record PartCreateRequest(
    String code,
    String name,
    Integer displayOrder,
    Boolean active
) {}
