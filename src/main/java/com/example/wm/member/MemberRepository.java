package com.example.wm.member;

import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class MemberRepository {
    private final JdbcTemplate jdbcTemplate;

    public MemberRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<MemberItem> findAll(boolean activeOnly) {
        return jdbcTemplate.query(
            """
            SELECT id, emp_no, member_name, title, phone, email, is_active
            FROM dbo.members
            WHERE (? = 0 OR is_active = 1)
            ORDER BY CASE WHEN emp_no IS NULL OR emp_no = '' THEN 1 ELSE 0 END,
                     emp_no ASC,
                     member_name ASC
            """,
            (rs, rowNum) -> new MemberItem(
                rs.getLong("id"),
                rs.getString("emp_no"),
                rs.getString("member_name"),
                rs.getString("title"),
                rs.getString("phone"),
                rs.getString("email"),
                rs.getBoolean("is_active")
            ),
            activeOnly ? 1 : 0
        );
    }

    public long insert(MemberCreateRequest request) {
        return jdbcTemplate.queryForObject(
            """
            INSERT INTO dbo.members (emp_no, member_name, title, phone, email, is_active, updated_at)
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, ?, ?, SYSUTCDATETIME())
            """,
            Long.class,
            request.empNo(),
            request.name(),
            request.title(),
            request.phone(),
            request.email(),
            request.active()
        );
    }

    public boolean existsByEmpNo(String empNo) {
        Integer count = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(1)
            FROM dbo.members
            WHERE emp_no = ?
            """,
            Integer.class,
            empNo
        );
        return count != null && count > 0;
    }

    public boolean existsByEmpNoExceptId(String empNo, long id) {
        Integer count = jdbcTemplate.queryForObject(
            """
            SELECT COUNT(1)
            FROM dbo.members
            WHERE emp_no = ?
              AND id <> ?
            """,
            Integer.class,
            empNo,
            id
        );
        return count != null && count > 0;
    }

    public int update(long id, MemberUpdateRequest request) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.members
            SET emp_no = ?,
                member_name = ?,
                title = ?,
                phone = ?,
                email = ?,
                is_active = ?,
                updated_at = SYSUTCDATETIME()
            WHERE id = ?
            """,
            request.empNo(),
            request.name(),
            request.title(),
            request.phone(),
            request.email(),
            request.active(),
            id
        );
    }

    public int deactivate(long id) {
        return jdbcTemplate.update(
            """
            UPDATE dbo.members
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
            WHERE member_id = ?
            """,
            id
        );
        return jdbcTemplate.update(
            """
            DELETE FROM dbo.members
            WHERE id = ?
            """,
            id
        );
    }
}
