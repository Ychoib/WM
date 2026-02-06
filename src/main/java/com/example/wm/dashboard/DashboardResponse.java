package com.example.wm.dashboard;

import java.util.List;

public record DashboardResponse(
    DashboardCounts counts,
    List<DashboardItem> items,
    List<TeamRisk> teamRisks,
    List<PolicyCount> policyCounts,
    List<RecentChange> recentChanges
) {}
