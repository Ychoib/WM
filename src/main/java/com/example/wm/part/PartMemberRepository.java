package com.example.wm.part;

import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class PartMemberRepository {
    private final JdbcTemplate jdbcTemplate;

    public PartMemberRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<PartMemberItem> findByPartId(long partId, boolean activeOnly) {
        return jdbcTemplate.query(
            """
            SELECT pm.id,
                   pm.part_id,
                   pm.member_id,
                   m.member_name,
                   m.title,
                   pm.role_in_part,
                   pm.sort_order,
                   pm.is_primary,
                   pm.is_active
            FROM dbo.part_members pm
            JOIN dbo.members m ON m.id = pm.member_id
            WHERE pm.part_id = ?
              AND (? = 0 OR pm.is_active = 1)
            ORDER BY pm.sort_order ASC, m.member_name ASC
            """,
            (rs, rowNum) -> new PartMemberItem(
                rs.getLong("id"),
                rs.getLong("part_id"),
                rs.getLong("member_id"),
                rs.getString("member_name"),
                rs.getString("title"),
                rs.getString("role_in_part"),
                rs.getInt("sort_order"),
                rs.getBoolean("is_primary"),
                rs.getBoolean("is_active")
            ),
            partId,
            activeOnly ? 1 : 0
        );
    }

    public long insert(long partId, PartMemberCreateRequest request) {
        return jdbcTemplate.queryForObject(
            """
            INSERT INTO dbo.part_members (part_id, member_id, role_in_part, sort_order, is_primary, is_active, updated_at)
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, ?, ?, SYSUTCDATETIME())
            """,
            Long.class,
            partId,
            request.memberId(),
            request.roleInPart(),
            request.sortOrder(),
            request.primary(),
            request.active()
        );
    }

    public int update(long id, PartMemberUpdateRequest request) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.part_members
            SET member_id = ?,
                role_in_part = ?,
                sort_order = ?,
                is_primary = ?,
                is_active = ?,
                updated_at = SYSUTCDATETIME()
            WHERE id = ?
            """,
            request.memberId(),
            request.roleInPart(),
            request.sortOrder(),
            request.primary(),
            request.active(),
            id
        );
    }

    public int deactivate(long id) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.part_members
            SET is_active = 0,
                updated_at = SYSUTCDATETIME()
            WHERE id = ?
            """,
            id
        );
    }

    public int deleteHard(long id) {
        return jdbcTemplate.update(
            """
            DELETE FROM dbo.part_members
            WHERE id = ?
            """,
            id
        );
    }
}
