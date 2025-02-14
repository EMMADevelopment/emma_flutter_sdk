/// Configuration for initializing an EMMA SDK session.
///
/// Required parameters:
/// - [sessionKey]: The key used to authenticate the session
///
/// Optional parameters:
/// - [apiUrl]: Custom API endpoint URL
/// - [queueTime]: Time in seconds between event batch uploads
/// - [isDebug]: Enable debug logging
/// - [customPowlinkDomains]: List of custom powlink domains
/// - [customShortPowlinkDomains]: List of custom short powlink domains
/// - [trackScreenEvents]: Enable automatic screen tracking
/// - [skanAttribution]: Enable SKAdNetwork attribution
/// - [skanCustomManagementAttribution]: Enable custom SKAdNetwork attribution management
/// - [familiesPolicyTreatment]: Enable families policy treatment

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
    if (queueTime != null && queueTime! < 0) {
      throw ArgumentError('queueTime must be non-negative');
    }

    if (apiUrl != null && !(Uri.tryParse(apiUrl!)?.isAbsolute ?? false)) {
      throw ArgumentError('apiUrl must be a valid absolute URL');
    }

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
