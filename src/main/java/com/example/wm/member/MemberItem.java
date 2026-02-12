package com.example.wm.member;

public record MemberItem(
    long id,
    String empNo,
    String name,
    String title,
    String phone,
    String email,
    boolean active
) {}
