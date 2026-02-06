package com.example.wm.asset;

public record AssetUpdateRequest(
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
