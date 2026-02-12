package com.example.wm.part;

import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class PartRepository {
    private final JdbcTemplate jdbcTemplate;

    public PartRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<PartItem> findAll(boolean activeOnly) {
        String sql = """
            SELECT id, part_code, part_name, is_active, display_order
            FROM dbo.parts
            WHERE (? = 0 OR is_active = 1)
            ORDER BY display_order ASC, part_name ASC
            """;
        return jdbcTemplate.query(
            sql,
            (rs, rowNum) -> new PartItem(
                rs.getLong("id"),
                rs.getString("part_code"),
                rs.getString("part_name"),
                rs.getBoolean("is_active"),
                rs.getInt("display_order")
            ),
            activeOnly ? 1 : 0
        );
    }

    public long insert(PartCreateRequest request) {
        return jdbcTemplate.queryForObject(
            """
            INSERT INTO dbo.parts (part_code, part_name, display_order, is_active, updated_at)
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, SYSUTCDATETIME())
            """,
            Long.class,
            request.code(),
            request.name(),
            request.displayOrder(),
            request.active()
        );
    }

    public int update(long id, PartUpdateRequest request) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.parts
            SET part_code = ?,
                part_name = ?,
                display_order = ?,
                is_active = ?,
                updated_at = SYSUTCDATETIME()
            WHERE id = ?
            """,
            request.code(),
            request.name(),
            request.displayOrder(),
            request.active(),
            id
        );
    }

    public int deactivate(long id) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.parts
            SET is_active = 0,
                updated_at = SYSUTCDATETIME()
            WHERE id = ?
            """,
            id
        );
    }

    public int deleteHard(long id) {
        jdbcTemplate.update(
            """
            DELETE FROM dbo.part_members
            WHERE part_id = ?
            """,
            id
        );
        return jdbcTemplate.update(
            """
            DELETE FROM dbo.parts
            WHERE id = ?
            """,
            id
        );
    }
}
