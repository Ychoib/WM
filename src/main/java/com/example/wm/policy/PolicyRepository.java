package com.example.wm.policy;

import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class PolicyRepository {
    private final JdbcTemplate jdbcTemplate;

    public PolicyRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // 알림 정책 목록을 조회한다.
    public List<PolicyItem> findAll() {
        return jdbcTemplate.query(
            """
            SELECT id, name, schedule
            FROM dbo.policies
            ORDER BY name ASC
            """,
            (rs, rowNum) -> new PolicyItem(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("schedule")
            )
        );
    }

    // 알림 정책을 추가하고 생성된 ID를 반환한다.
    public long insert(PolicyCreateRequest request) {
        return jdbcTemplate.queryForObject(
            """
            INSERT INTO dbo.policies (name, schedule)
            OUTPUT INSERTED.id
            VALUES (?, ?)
            """,
            Long.class,
            request.name(),
            request.schedule()
        );
    }
}
