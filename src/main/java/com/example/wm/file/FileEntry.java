package com.example.wm.file;

public record FileEntry(
    String name,
    String relativePath,
    boolean directory,
    long size,
    String modifiedAt
) {
}
