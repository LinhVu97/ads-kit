import GoogleMobileAds

protocol NativeAdComponentProtocol {
    var nativeAdView: NativeAdView { get }
    var nativeAd: NativeAd { get }
    var configuration: NativeAdConfiguration { get }
}

struct NativeAdComponent: NativeAdComponentProtocol {
    let nativeAdView: NativeAdView
    let nativeAd: NativeAd
    let configuration: NativeAdConfiguration
} 
