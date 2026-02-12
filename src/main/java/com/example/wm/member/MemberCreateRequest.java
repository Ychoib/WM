package com.example.wm.member;

public record MemberCreateRequest(
    String empNo,
    String name,
    String title,
    String phone,
    String email,
    Boolean active
) {}
