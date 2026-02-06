package com.example.wm.dashboard;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DashboardController {
    private final DashboardRepository dashboardRepository;

    public DashboardController(DashboardRepository dashboardRepository) {
        this.dashboardRepository = dashboardRepository;
    }

    @GetMapping("/api/dashboard")
    // 대시보드 화면에 필요한 집계/목록 데이터를 반환한다.
    public DashboardResponse getDashboard() {
        return dashboardRepository.fetchDashboard();
    }
}
