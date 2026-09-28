import Foundation
import GoogleMobileAds

extension AdTrackingEventBus {
    /// Lấy `responseIdentifier` từ AdMob ResponseInfo.
    /// Trả về `""` nếu SDK chưa cung cấp ID (thường gặp ngay sau load, đặc biệt banner/test ads).
    public static func impressionId(from responseInfo: ResponseInfo?) -> String {
        guard let responseInfo else { return "" }
        
        if let id = responseInfo.responseIdentifier, !id.isEmpty {
            return id
        }
        
        let dictionary = responseInfo.dictionaryRepresentation
        for key in ["response_id", "responseIdentifier", "response_identifier"] {
            if let id = dictionary[key] as? String, !id.isEmpty {
                return id
            }
        }
        
        return ""
    }
    
    public static func normalizedImpressionId(_ id: String?) -> String {
        guard let id, !id.isEmpty else { return "" }
        return id
    }
    
    public func emitRequest(
        adFormat: String,
        adNetwork: String,
        adUnitId: String,
        isLoad: Int,
        errorCode: String?,
        retryCount: Int,
        loadTime: Int,
        impressionId: String = ""
    ) {
        var event: [String: Any] = [
            "eventType": "ad_request",
            "adFormat": adFormat,
            "adNetwork": adNetwork,
            "adUnitId": adUnitId,
            "isLoad": isLoad,
            "retryCount": retryCount,
            "loadTime": loadTime,
            "errorCode": errorCode ?? "none",
        ]
        
        if isLoad == 1 {
            event["impressionId"] = impressionId
        }
        
        emit(event)
    }
    
    public func emitClick(
        adFormat: String,
        adNetwork: String,
        adUnitId: String,
        placement: String,
        impressionId: String = ""
    ) {
        let event: [String: Any] = [
            "eventType": "ad_click",
            "adFormat": adFormat,
            "adNetwork": adNetwork,
            "adUnitId": adUnitId,
            "placement": placement,
            "impressionId": impressionId,
        ]
        emit(event)
    }
    
    public func emitImpression(
        adFormat: String,
        adNetwork: String,
        adUnitId: String,
        placement: String,
        isShow: Int,
        errorCode: String?,
        value: Double,
        currency: String?,
        precision: Int?,
        impressionId: String?
    ) {
        let event: [String: Any] = [
            "eventType": "ad_revenue",
            "adFormat": adFormat,
            "adNetwork": adNetwork,
            "adUnitId": adUnitId,
            "placement": placement,
            "isShow": isShow,
            "errorCode": errorCode ?? "none",
            "value": value,
            "currency": currency ?? "USD",
            "precision": precision ?? 0,
            "impressionId": Self.normalizedImpressionId(impressionId),
        ]
        emit(event)
    }
    
    public func emitComplete(
        adFormat: String,
        adNetwork: String,
        adUnitId: String,
        adDuration: Int,
        placement: String,
        endType: String?,
        completion: (() -> Void)? = nil
    ) {
        let event: [String: Any] = [
            "eventType": "ad_complete",
            "adFormat": adFormat,
            "adNetwork": adNetwork,
            "adUnitId": adUnitId,
            "adDuration": adDuration,
            "placement": placement,
            "endType": endType ?? "none",
        ]
        emit(event, completion: completion)
    }
}

