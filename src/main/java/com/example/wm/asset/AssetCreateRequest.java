package com.example.wm.asset;

public record AssetCreateRequest(
    String name,
    String type,
    String expiresAt,
    Long partId,
    String importance,
    String notifyPolicy,
    String relatedServices,
    String memo
) {}
