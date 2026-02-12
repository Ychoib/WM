package com.example.wm.doc;

public record PartDocumentStoredItem(
    long id,
    long partId,
    String docType,
    String title,
    String originalFileName,
    String storedPath,
    String fileExt,
    String contentType,
    long fileSize
) {}
