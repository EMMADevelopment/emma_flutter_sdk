
   
//
//  Utils.swift
//
//  Created by Adrián Carrera on 16/03/2021.
//  Copyright © 2021 EMMA. All rights reserved.
//

import EMMA_iOS

class EmmaSerializer {
    static func nativeAdToDictionary(_ nativeAd: EMMANativeAd) -> [String: Any?] {
        return [
            "id": nativeAd.idPromo,
            "templateId": nativeAd.nativeAdTemplateId ?? "",
            "cta": nativeAd.nativeAdContent["CTA"] ?? "",
            "times": nativeAd.times,
            "tag": nativeAd.tag ?? "",
            "params": nativeAd.params ?? [:],
            "showOn": nativeAd.openInSafari ? "browser" : "inapp",
            "fields": nativeAd.nativeAdContent as? [String: Any] ?? []
            ]
    }
    
    static func inAppTypeFromString(inAppType: String) -> InAppType? {
        switch inAppType {
            case "startview":
                return .Startview
            case "nativeAd":
                return .NativeAd
            case "adBall":
                return .Adball
            case "strip":
                return .Strip
            default:
                return nil
        }
    }
    
    static func inAppTypeToCommType(type: InAppType) -> EMMACampaignType? {
        switch type {
        case InAppType.Startview:
            return EMMACampaignType.campaignStartView
        case InAppType.NativeAd:
            return EMMACampaignType.campaignNativeAd
        case InAppType.Adball:
            return EMMACampaignType.campaignAdBall
        case InAppType.Strip:
            return EMMACampaignType.campaignStrip
        default:
            return nil
        }
    }
}
            
