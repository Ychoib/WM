package com.example.wm.asset;

public record AssetDetail(
    long id,
    String name,
    String type,
    String expiresAt,
    Long partId,
    String partName,
    String importance,
    String notifyPolicy,
    String relatedServices,
    String memo
) {}
