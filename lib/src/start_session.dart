class StartSession {
  final String sessionKey;
  final String? apiUrl;
  final int? queueTime;
  final bool? isDebug;
  final List<String>? customPowlinkDomains;
  final List<String>? customShortPowlinkDomains;
  final bool? trackScreenEvents;
  final bool? skanAttribution;
  final bool? skanCustomManagementAttribution;
  final bool? familiesPolicyTreatment;

  StartSession({
    required this.sessionKey,
    this.apiUrl,
    this.queueTime,
    this.isDebug,
    this.customPowlinkDomains,
    this.customShortPowlinkDomains,
    this.trackScreenEvents,
    this.skanAttribution,
    this.skanCustomManagementAttribution,
    this.familiesPolicyTreatment,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionKey': sessionKey,
      'apiUrl': apiUrl,
      'queueTime': queueTime,
      'isDebug': isDebug,
      'customPowlinkDomains': customPowlinkDomains,
      'customShortPowlinkDomains': customShortPowlinkDomains,
      'trackScreenEvents': trackScreenEvents,
      'skanAttribution': skanAttribution,
      'skanCustomManagementAttribution': skanCustomManagementAttribution,
      'familiesPolicyTreatment': familiesPolicyTreatment,
    };
  }
}
