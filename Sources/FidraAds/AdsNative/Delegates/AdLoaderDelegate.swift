import Foundation
import GoogleMobileAds

public class AdLoaderDelegate: NSObject, NativeAdLoaderDelegate {
    private let onAdReceived: (NativeAd) -> Void
    private let onAdFailedToLoad: (Error) -> Void
    
    public init(onAdReceived: @escaping (NativeAd) -> Void,
         onAdFailedToLoad: @escaping (Error) -> Void) {
        self.onAdReceived = onAdReceived
        self.onAdFailedToLoad = onAdFailedToLoad
        super.init()
    }
    
    public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        onAdReceived(nativeAd)
    }
    
    public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        onAdFailedToLoad(error)
    }
}
