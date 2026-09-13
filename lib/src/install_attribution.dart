class EmmaInstallAttributionProvider {
  final int id;
  final String? name;

  EmmaInstallAttributionProvider({required this.id, this.name});

  factory EmmaInstallAttributionProvider.fromMap(Map<String, dynamic> map) {
    return EmmaInstallAttributionProvider(
      id: map['id'] as int,
      name: map['name'] as String?,
    );
  }
}

class EmmaInstallAttributionSource {
  final int id;
  final String? name;
  final String? channel;
  final Map<String, String>? params;
  final EmmaInstallAttributionProvider? provider;

  EmmaInstallAttributionSource({
    required this.id,
    this.name,
    this.channel,
    this.params,
    this.provider,
  });

  factory EmmaInstallAttributionSource.fromMap(Map<String, dynamic> map) {
    final rawParams = map['params'];
    final rawProvider = map['provider'];
    return EmmaInstallAttributionSource(
      id: map['id'] as int,
      name: map['name'] as String?,
      channel: map['channel'] as String?,
      params: rawParams != null ? Map<String, String>.from(rawParams as Map) : null,
      provider: rawProvider != null
          ? EmmaInstallAttributionProvider.fromMap(Map<String, dynamic>.from(rawProvider as Map))
          : null,
    );
  }
}

class EmmaInstallAttributionCampaign {
  final int id;
  final String? name;
  final Map<String, String>? clickParams;
  final EmmaInstallAttributionSource? source;

  EmmaInstallAttributionCampaign({
    required this.id,
    this.name,
    this.clickParams,
    this.source,
  });

  factory EmmaInstallAttributionCampaign.fromMap(Map<String, dynamic> map) {
    final rawClickParams = map['clickParams'];
    final rawSource = map['source'];
    return EmmaInstallAttributionCampaign(
      id: map['id'] as int,
      name: map['name'] as String?,
      clickParams: rawClickParams != null ? Map<String, String>.from(rawClickParams as Map) : null,
      source: rawSource != null
          ? EmmaInstallAttributionSource.fromMap(Map<String, dynamic>.from(rawSource as Map))
          : null,
    );
  }
}

class EmmaInstallAttribution {
  final String status;
  final EmmaInstallAttributionCampaign? campaign;

  EmmaInstallAttribution({required this.status, this.campaign});

  factory EmmaInstallAttribution.fromMap(Map<String, dynamic> map) {
    final rawCampaign = map['campaign'];
    return EmmaInstallAttribution(
      status: map['status'] as String? ?? '',
      campaign: rawCampaign != null
          ? EmmaInstallAttributionCampaign.fromMap(Map<String, dynamic>.from(rawCampaign as Map))
          : null,
    );
  }
}
