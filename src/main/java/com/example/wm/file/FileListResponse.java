package com.example.wm.file;

import java.util.List;

public record FileListResponse(
    String rootPath,
    String currentPath,
    String parentPath,
    List<FileEntry> entries
) {
}
