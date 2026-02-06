package com.example.wm.asset;

public record AssetCreateRequest(
    String name,
    String type,
    String expiresAt,
    String ownerTeam,
    String ownerName,
    String importance,
    String notifyPolicy,
    String relatedServices,
    String memo
) {}
