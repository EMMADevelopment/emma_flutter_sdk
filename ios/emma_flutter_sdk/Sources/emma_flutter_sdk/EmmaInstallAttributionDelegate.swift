import Flutter
import EMMA_iOS

class EmmaInstallAttributionDelegate: NSObject, EMMAInstallAttributionDelegate {
    var result: FlutterResult

    init(result: @escaping FlutterResult) {
        self.result = result
    }

    func onAttributionReceived(_ attribution: EMMAInstallAttribution!) {
        EmmaFlutterSdkPlugin.installAttributionDelegate = nil
        result(EmmaSerializer.installAttributionToDictionary(attribution))
    }
}
