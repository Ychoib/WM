package com.example.wm.org;

import java.sql.Types;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameterValue;
import org.springframework.stereotype.Repository;

@Repository
public class OrgUnitRepository {
    private final JdbcTemplate jdbcTemplate;

    public OrgUnitRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<OrgUnitItem> findAll(boolean activeOnly) {
        return jdbcTemplate.query(
            """
            SELECT id, parent_id, part_id, unit_name, role_name, pos_x, pos_y, is_active, sort_order
            FROM dbo.org_units
            WHERE (? = 0 OR is_active = 1)
            ORDER BY COALESCE(parent_id, 0), sort_order ASC, unit_name ASC
            """,
            (rs, rowNum) -> new OrgUnitItem(
                rs.getLong("id"),
                (Long) rs.getObject("parent_id"),
                (Long) rs.getObject("part_id"),
                rs.getString("unit_name"),
                rs.getString("role_name"),
                (Integer) rs.getObject("pos_x"),
                (Integer) rs.getObject("pos_y"),
                rs.getBoolean("is_active"),
                rs.getInt("sort_order")
            ),
            activeOnly ? 1 : 0
        );
    }

    public long insert(OrgUnitCreateRequest request) {
        return jdbcTemplate.queryForObject(
            """
            INSERT INTO dbo.org_units (parent_id, part_id, unit_name, role_name, pos_x, pos_y, sort_order, is_active, updated_at)
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, ?, ?, ?, 1, SYSUTCDATETIME())
            """,
            Long.class,
            nullableBigInt(request.parentId()),
            nullableBigInt(request.partId()),
            request.name(),
            nullableNvarchar(request.roleName()),
            nullableInt(request.posX()),
            nullableInt(request.posY()),
            request.sortOrder()
        );
    }

    public int update(long id, OrgUnitUpdateRequest request) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.org_units
            SET parent_id = ?,
                part_id = ?,
                unit_name = ?,
                role_name = ?,
                pos_x = ?,
                pos_y = ?,
                sort_order = ?,
                updated_at = SYSUTCDATETIME()
            WHERE id = ? AND is_active = 1
            """,
            nullableBigInt(request.parentId()),
            nullableBigInt(request.partId()),
            request.name(),
            nullableNvarchar(request.roleName()),
            nullableInt(request.posX()),
            nullableInt(request.posY()),
            request.sortOrder(),
            id
        );
    }

    public int deactivate(long id) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.org_units
            SET is_active = 0,
                updated_at = SYSUTCDATETIME()
            WHERE id = ?
            """,
            id
        );
    }

    public int updateMove(OrgUnitMoveItem item) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.org_units
            SET parent_id = ?,
                sort_order = ?,
                updated_at = SYSUTCDATETIME()
            WHERE id = ? AND is_active = 1
            """,
            nullableBigInt(item.parentId()),
            item.sortOrder(),
            item.id()
        );
    }

    public int updatePosition(long id, Integer posX, Integer posY) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.org_units
            SET pos_x = ?,
                pos_y = ?,
                updated_at = SYSUTCDATETIME()
            WHERE id = ? AND is_active = 1
            """,
            nullableInt(posX),
            nullableInt(posY),
            id
        );
    }

    private SqlParameterValue nullableBigInt(Long value) {
        return new SqlParameterValue(Types.BIGINT, value);
    }

    private SqlParameterValue nullableNvarchar(String value) {
        return new SqlParameterValue(Types.NVARCHAR, value);
    }

    private SqlParameterValue nullableInt(Integer value) {
        return new SqlParameterValue(Types.INTEGER, value);
    }
}
