package com.example.wm.asset;

public record AssetUpdateRequest(
    String name,
    String type,
    String expiresAt,
    Long partId,
    String importance,
    String notifyPolicy,
    String relatedServices,
    String memo
) {}
