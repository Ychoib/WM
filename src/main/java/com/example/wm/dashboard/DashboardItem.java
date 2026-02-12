package com.example.wm.dashboard;

public record DashboardItem(
    long id,
    String name,
    String type,
    String expiresAt,
    String partName,
    int daysLeft
) {}
