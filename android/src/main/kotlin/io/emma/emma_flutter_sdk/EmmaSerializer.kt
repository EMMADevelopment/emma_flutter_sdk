package io.emma.emma_flutter_sdk

import io.emma.android.enums.CommunicationTypes
import io.emma.android.model.EMMACampaign
import io.emma.android.model.EMMANativeAd
import io.emma.android.model.EMMANativeAdField
import io.emma.android.utils.EMMALog
import org.json.JSONArray

import org.json.JSONException





object EmmaSerializer {

    fun nativeAdToMap(nativeAd: EMMANativeAd): Map<String, Any>? {
        val nativeAdMap = HashMap<String, Any>()
        try {
            nativeAdMap["id"] = nativeAd.campaignID.toInt()
            nativeAdMap["templateId"] = nativeAd.templateId
            nativeAdMap["times"] = nativeAd.times.toInt()
            nativeAdMap["tag"] = nativeAd.tag
            nativeAdMap["cta"] = nativeAd.campaignUrl
            nativeAdMap["showOn"] = if(nativeAd.showOnWebView()) "inapp" else "browser"
            nativeAdMap["params"] = nativeAd.params
            nativeAdMap["fields"] = nativeAdFieldsToMap(nativeAd.nativeAdContent)
        } catch (e: Exception) {
            EMMALog.e("Error parsing native ad", e)
            return null
        }
        return nativeAdMap
    }

    private fun processNativeAdContainer(fieldsContainer: List<Map<String, EMMANativeAdField>>):
            ArrayList<Map<String, Any>> {
        val processFieldsContainer = ArrayList<Map<String, Any>>()
        for (fields in fieldsContainer) {
            processFieldsContainer.add(nativeAdFieldsToMap(fields))
        }
        return processFieldsContainer
    }

    private fun nativeAdFieldsToMap(fields: Map<String, EMMANativeAdField>): Map<String, Any> {
        val fieldsMap = HashMap<String, Any>()
        for ((_, value) in fields.entries) {
            fieldsMap[value.fieldName] =
                    if(value.fieldContainer != null) processNativeAdContainer(value.fieldContainer!!) else value.fieldValue!!
        }
        return fieldsMap
    }

    fun getInAppRequestTypeFromString(type: String): EMMACampaign.Type? {
        when(type) {
            "startview" -> {
                return EMMACampaign.Type.STARTVIEW
            }
            "nativeAd" -> {
                return EMMACampaign.Type.NATIVEAD
            }
            else -> {
                return null
            }
        }
    }

    fun inAppTypeToCommType(type: EMMACampaign.Type?): CommunicationTypes? {
        if (type == null) {
            return null
        }

        when(type) {
            EMMACampaign.Type.STARTVIEW -> {
                return CommunicationTypes.STARTVIEW
            }
            EMMACampaign.Type.NATIVEAD -> {
                return CommunicationTypes.NATIVE_AD
            }
            else -> {
                return null
            }
        }
    }

}