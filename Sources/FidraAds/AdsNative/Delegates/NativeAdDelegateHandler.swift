import Foundation
import GoogleMobileAds

public class NativeAdDelegateHandler: NSObject, NativeAdDelegate {
    private var currentScreen: String
    private var adUnitId: String
    private var isCollapsible: Bool
    
    public init(currentScreen: String = "", adUnitId: String = "", isCollapsible: Bool = false) {
        self.currentScreen = currentScreen
        self.adUnitId = adUnitId
        self.isCollapsible = isCollapsible
        super.init()
    }
    
    public func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        // The native ad was shown.
        print("🔍 NativeAdDelegateHandler - nativeAdDidRecordImpression called")
    }
    
    public func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        // The native ad was clicked on.
        print("🔍 NativeAdDelegateHandler - nativeAdDidRecordClick called")
        print("🔍 Current Screen: \(currentScreen)")
        print("🔍 Ad Unit ID: \(adUnitId)")
        print("🔍 This is where Google AdMob handles the click automatically")
        
        let adSourceName = nativeAd.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? "Admob"
        let adFormat = isCollapsible ? "collapseNative" : "native"
        let impressionId = AdTrackingEventBus.impressionId(from: nativeAd.responseInfo)
        AdTrackingEventBus.shared.emitClick(
            adFormat: adFormat,
            adNetwork: adSourceName,
            adUnitId: adUnitId,
            placement: "",
            impressionId: impressionId
        )
    }
    
    public func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        // The native ad will present a full screen view.
        print("🔍 NativeAdDelegateHandler - nativeAdWillPresentScreen called")
        print("🔍 This is where Google AdMob opens the ad screen")
    }
    
    public func nativeAdWillDismissScreen(_ nativeAd: NativeAd) {
        // The native ad will dismiss a full screen view.
    }
    
    public func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
        // The native ad did dismiss a full screen view.
        print("🔍 NativeAdDelegateHandler - nativeAdDidDismissScreen called")
        print("🔍 This is where Google AdMob closes the ad screen")
    }
    
    public func nativeAdWillLeaveApplication(_ nativeAd: NativeAd) {
        // The native ad will cause the app to become inactive and
        // open a new app.
    }
} 
