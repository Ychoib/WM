package com.example.wm.asset;

public record AssetRecentItem(
    long id,
    String name,
    String type,
    String expiresAt
) {}
