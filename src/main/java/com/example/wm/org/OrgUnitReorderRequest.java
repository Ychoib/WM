package com.example.wm.org;

import java.util.List;

public record OrgUnitReorderRequest(List<OrgUnitMoveItem> items) {}
