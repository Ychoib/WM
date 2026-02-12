package com.example.wm.doc;

public record PartDocumentItem(
    long id,
    long partId,
    String docType,
    String title,
    String originalFileName,
    String fileExt,
    String contentType,
    long fileSize,
    String createdAt
) {}
