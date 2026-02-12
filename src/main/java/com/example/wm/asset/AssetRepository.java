package com.example.wm.asset;

import java.sql.Date;
import java.time.LocalDate;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class AssetRepository {
    private final JdbcTemplate jdbcTemplate;

    public AssetRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // 자산 등록 요청을 DB에 저장하고 생성된 ID를 반환한다.
    public long insert(AssetCreateRequest request) {
        LocalDate expiresAt = LocalDate.parse(request.expiresAt());
        return jdbcTemplate.queryForObject(
            """
            INSERT INTO dbo.assets
              (name, asset_type, expires_at, part_id, importance, notify_policy, related_services, memo, updated_at)
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSUTCDATETIME())
            """,
            Long.class,
            request.name(),
            request.type(),
            Date.valueOf(expiresAt),
            request.partId(),
            request.importance(),
            request.notifyPolicy(),
            request.relatedServices(),
            request.memo()
        );
    }

    // 자산 ID로 상세 정보를 조회한다.
    public AssetDetail findById(long id) {
        return jdbcTemplate.queryForObject(
            """
            SELECT
              a.id,
              a.name,
              a.asset_type,
              CONVERT(varchar(10), a.expires_at, 23) AS expiresAt,
              a.part_id,
              p.part_name,
              a.importance,
              a.notify_policy,
              a.related_services,
              a.memo
            FROM dbo.assets a
            LEFT JOIN dbo.parts p ON p.id = a.part_id
            WHERE a.id = ?
            """,
            (rs, rowNum) -> new AssetDetail(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("asset_type"),
                rs.getString("expiresAt"),
                (Long) rs.getObject("part_id"),
                rs.getString("part_name"),
                rs.getString("importance"),
                rs.getString("notify_policy"),
                rs.getString("related_services"),
                rs.getString("memo")
            ),
            id
        );
    }

    // 자산 정보를 수정하고 반영된 행 수를 반환한다.
    public int update(long id, AssetUpdateRequest request) {
        LocalDate expiresAt = LocalDate.parse(request.expiresAt());
        return jdbcTemplate.update(
            """
            UPDATE dbo.assets
            SET
              name = ?,
              asset_type = ?,
              expires_at = ?,
              part_id = ?,
              importance = ?,
              notify_policy = ?,
              related_services = ?,
              memo = ?,
              updated_at = SYSUTCDATETIME()
            WHERE id = ?
            """,
            request.name(),
            request.type(),
            Date.valueOf(expiresAt),
            request.partId(),
            request.importance(),
            request.notifyPolicy(),
            request.relatedServices(),
            request.memo(),
            id
        );
    }

    // 모든 자산의 만료 현황을 조회한다.
    public java.util.List<AssetDetail> findAllForExpiry() {
        return jdbcTemplate.query(
            """
            SELECT
              a.id,
              a.name,
              a.asset_type,
              CONVERT(varchar(10), a.expires_at, 23) AS expiresAt,
              a.part_id,
              p.part_name,
              a.importance,
              a.notify_policy,
              a.related_services,
              a.memo,
              DATEDIFF(day, CONVERT(date, GETDATE()), a.expires_at) AS daysLeft
            FROM dbo.assets a
            LEFT JOIN dbo.parts p ON p.id = a.part_id
            ORDER BY a.expires_at ASC
            """,
            (rs, rowNum) -> new AssetDetail(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("asset_type"),
                rs.getString("expiresAt"),
                (Long) rs.getObject("part_id"),
                rs.getString("part_name"),
                rs.getString("importance"),
                rs.getString("notify_policy"),
                rs.getString("related_services"),
                rs.getString("memo")
            )
        );
    }

    // 최근 등록된 자산을 지정된 개수만큼 조회한다.
    public java.util.List<AssetRecentItem> findRecent(int limit) {
        return jdbcTemplate.query(
            """
            SELECT TOP (?)
              id,
              name,
              asset_type,
              CONVERT(varchar(10), expires_at, 23) AS expiresAt
            FROM dbo.assets
            ORDER BY created_at DESC
            """,
            (rs, rowNum) -> new AssetRecentItem(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("asset_type"),
                rs.getString("expiresAt")
            ),
            limit
        );
    }
}
