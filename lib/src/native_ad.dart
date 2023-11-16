class EmmaNativeAd {
  late int id;
  late String templateId;
  late Map<String, String> fields;
  late int times;
  late String showOn;
  late String cta;
  late String tag;
  Map<String, dynamic>? params;

  EmmaNativeAd();

  EmmaNativeAd.fromMap(Map<String, dynamic> json) {
    this.id = json["id"];
    this.templateId = json["templateId"];
    this.cta = json["cta"];
    this.times = json["times"];
    this.tag = json["tag"];
    this.showOn = json['showOn'];
    this.params = json["params"] != null ? Map.from(json["params"]) : null;
    this.fields = Map.from(json["fields"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "templateId": templateId,
      "cta": cta,
      "times": times,
      "showOn": showOn,
      "tag": tag,
      "params": params,
      "fields": fields
    };
  }
}
