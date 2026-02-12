package com.example.wm.doc;

import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class PartDocumentRepository {
    private final JdbcTemplate jdbcTemplate;

    public PartDocumentRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<PartDocumentItem> findByPartId(long partId) {
        return jdbcTemplate.query(
            """
            SELECT id,
                   part_id,
                   doc_type,
                   doc_title,
                   original_file_name,
                   file_ext,
                   content_type,
                   file_size,
                   CONVERT(VARCHAR(19), created_at, 120) AS created_at
            FROM dbo.part_documents
            WHERE part_id = ?
              AND is_active = 1
            ORDER BY created_at DESC, id DESC
            """,
            (rs, rowNum) -> new PartDocumentItem(
                rs.getLong("id"),
                rs.getLong("part_id"),
                rs.getString("doc_type"),
                rs.getString("doc_title"),
                rs.getString("original_file_name"),
                rs.getString("file_ext"),
                rs.getString("content_type"),
                rs.getLong("file_size"),
                rs.getString("created_at")
            ),
            partId
        );
    }

    public long insert(PartDocumentCreateRequest request) {
        return jdbcTemplate.queryForObject(
            """
            INSERT INTO dbo.part_documents (
                part_id,
                doc_type,
                doc_title,
                original_file_name,
                stored_path,
                file_ext,
                content_type,
                file_size,
                is_active,
                updated_at
            )
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, SYSUTCDATETIME())
            """,
            Long.class,
            request.partId(),
            request.docType(),
            request.title(),
            request.originalFileName(),
            request.storedPath(),
            request.fileExt(),
            request.contentType(),
            request.fileSize()
        );
    }

    public PartDocumentItem findItemById(long id) {
        List<PartDocumentItem> items = jdbcTemplate.query(
            """
            SELECT id,
                   part_id,
                   doc_type,
                   doc_title,
                   original_file_name,
                   file_ext,
                   content_type,
                   file_size,
                   CONVERT(VARCHAR(19), created_at, 120) AS created_at
            FROM dbo.part_documents
            WHERE id = ?
            """,
            (rs, rowNum) -> new PartDocumentItem(
                rs.getLong("id"),
                rs.getLong("part_id"),
                rs.getString("doc_type"),
                rs.getString("doc_title"),
                rs.getString("original_file_name"),
                rs.getString("file_ext"),
                rs.getString("content_type"),
                rs.getLong("file_size"),
                rs.getString("created_at")
            ),
            id
        );
        return items.isEmpty() ? null : items.get(0);
    }

    public PartDocumentStoredItem findStoredById(long id) {
        List<PartDocumentStoredItem> items = jdbcTemplate.query(
            """
            SELECT id,
                   part_id,
                   doc_type,
                   doc_title,
                   original_file_name,
                   stored_path,
                   file_ext,
                   content_type,
                   file_size
            FROM dbo.part_documents
            WHERE id = ?
              AND is_active = 1
            """,
            (rs, rowNum) -> new PartDocumentStoredItem(
                rs.getLong("id"),
                rs.getLong("part_id"),
                rs.getString("doc_type"),
                rs.getString("doc_title"),
                rs.getString("original_file_name"),
                rs.getString("stored_path"),
                rs.getString("file_ext"),
                rs.getString("content_type"),
                rs.getLong("file_size")
            ),
            id
        );
        return items.isEmpty() ? null : items.get(0);
    }
}
