package com.example.wm.member;

public record MemberUpdateRequest(
    String empNo,
    String name,
    String title,
    String phone,
    String email,
    Boolean active
) {}
