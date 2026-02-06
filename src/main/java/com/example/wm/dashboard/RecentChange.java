package com.example.wm.dashboard;

public record RecentChange(
    String name,
    String type,
    String ownerTeam,
    String createdAt
) {}
