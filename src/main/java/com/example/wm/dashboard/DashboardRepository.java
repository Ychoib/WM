package com.example.wm.dashboard;

import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class DashboardRepository {
    private final JdbcTemplate jdbcTemplate;

    public DashboardRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // 대시보드용 집계/목록 데이터를 한 번에 조회한다.
    public DashboardResponse fetchDashboard() {
        DashboardCounts counts = jdbcTemplate.queryForObject(
            """
            SELECT
              SUM(CASE WHEN DATEDIFF(day, CONVERT(date, GETDATE()), expires_at) BETWEEN 0 AND 90 THEN 1 ELSE 0 END) AS d90,
              SUM(CASE WHEN DATEDIFF(day, CONVERT(date, GETDATE()), expires_at) BETWEEN 0 AND 30 THEN 1 ELSE 0 END) AS d30,
              SUM(CASE WHEN DATEDIFF(day, CONVERT(date, GETDATE()), expires_at) > 90 THEN 1 ELSE 0 END) AS healthy,
              SUM(CASE WHEN notify_policy IS NULL OR notify_policy = '' OR notify_policy = '미설정' THEN 1 ELSE 0 END) AS noPolicy,
              SUM(CASE WHEN created_at >= DATEADD(day, -7, GETDATE())
                        AND DATEDIFF(day, CONVERT(date, GETDATE()), expires_at) BETWEEN 0 AND 90 THEN 1 ELSE 0 END) AS d90New,
              SUM(CASE WHEN created_at >= DATEADD(day, -7, GETDATE())
                        AND DATEDIFF(day, CONVERT(date, GETDATE()), expires_at) BETWEEN 0 AND 30 THEN 1 ELSE 0 END) AS d30New,
              SUM(CASE WHEN created_at >= DATEADD(day, -7, GETDATE())
                        AND DATEDIFF(day, CONVERT(date, GETDATE()), expires_at) > 90 THEN 1 ELSE 0 END) AS healthyNew,
              SUM(CASE WHEN created_at >= DATEADD(day, -7, GETDATE())
                        AND (notify_policy IS NULL OR notify_policy = '' OR notify_policy = '미설정') THEN 1 ELSE 0 END) AS noPolicyNew
            FROM dbo.assets
            """,
            (rs, rowNum) -> new DashboardCounts(
                rs.getInt("d90"),
                rs.getInt("d30"),
                rs.getInt("healthy"),
                rs.getInt("noPolicy"),
                rs.getInt("d90New"),
                rs.getInt("d30New"),
                rs.getInt("healthyNew"),
                rs.getInt("noPolicyNew")
            )
        );

        List<DashboardItem> items = jdbcTemplate.query(
            """
            SELECT TOP 5
              id,
              name,
              asset_type,
              CONVERT(varchar(10), expires_at, 23) AS expiresAt,
              owner_team,
              DATEDIFF(day, CONVERT(date, GETDATE()), expires_at) AS daysLeft
            FROM dbo.assets
            ORDER BY expires_at ASC
            """,
            (rs, rowNum) -> new DashboardItem(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("asset_type"),
                rs.getString("expiresAt"),
                rs.getString("owner_team"),
                rs.getInt("daysLeft")
            )
        );

        List<TeamRisk> teamRisks = jdbcTemplate.query(
            """
            SELECT TOP 6
              owner_team,
              COUNT(*) AS cnt
            FROM dbo.assets
            WHERE owner_team IS NOT NULL
              AND DATEDIFF(day, CONVERT(date, GETDATE()), expires_at) BETWEEN 0 AND 90
            GROUP BY owner_team
            ORDER BY cnt DESC
            """,
            (rs, rowNum) -> new TeamRisk(
                rs.getString("owner_team"),
                rs.getInt("cnt")
            )
        );

        List<PolicyCount> policyCounts = jdbcTemplate.query(
            """
            SELECT
              COALESCE(NULLIF(notify_policy, ''), '미설정') AS policy,
              COUNT(*) AS cnt
            FROM dbo.assets
            GROUP BY COALESCE(NULLIF(notify_policy, ''), '미설정')
            ORDER BY cnt DESC
            """,
            (rs, rowNum) -> new PolicyCount(
                rs.getString("policy"),
                rs.getInt("cnt")
            )
        );

        List<RecentChange> recentChanges = jdbcTemplate.query(
            """
            SELECT TOP 3
              name,
              asset_type,
              owner_team,
              CONVERT(varchar(16), created_at, 120) AS createdAt
            FROM dbo.assets
            ORDER BY created_at DESC
            """,
            (rs, rowNum) -> new RecentChange(
                rs.getString("name"),
                rs.getString("asset_type"),
                rs.getString("owner_team"),
                rs.getString("createdAt")
            )
        );

        return new DashboardResponse(counts, items, teamRisks, policyCounts, recentChanges);
    }
}
