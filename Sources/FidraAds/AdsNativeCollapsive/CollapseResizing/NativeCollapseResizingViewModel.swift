//
//  NativeCollapseResizeingViewModel.swift
//  FidraAds
//
//  Created by HoaTD on 17/3/26.
//

import SwiftUI
import GoogleMobileAds

class NativeCollapseResizingViewModel: ObservableObject {
    @Published private(set) var state: AdState = .initial
    @Published var adHeight: CGFloat = Utils.dp(320)
    @Published var adsLayoutType: NativeAdLayoutType = .mediumWithMedia
    @Published var isCollapsedIntoMedium: Bool = false
    var isCollapsible: Bool = false
    var isAppear = false
    
    var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
    
    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.state = loading ? .loading : .failed
        }
    }
    
    var nativeAd: NativeAd? {
        if case .loaded(let ad) = state {
            return ad
        }
        return nil
    }
    
    
    private var adLoader: AdLoader?
    private var adLoaderDelegate: AdLoaderDelegate?
    private var nativeAdDelegate: NativeAdDelegateHandler?
    private var refreshTimer: Timer?
    private var adUnitId: String  = ""
    private var layoutType: NativeAdLayoutType?
    @Published var shouldLoadOnAppear = true
    private var adLoadStartTime: TimeInterval = 0 // Thời gian bắt đầu load quảng cáo
    private var adLoadTimeInMsec: Int = 0 // Thời gian load quảng cáo tính bằng msec
    private var currentScreen = ""
    private var enableAutoRefresh: Bool = true
    private var refreshTimeInSeconds: Double = 5
    
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterstitialShown), name: NSNotification.Name("InterstitialShown"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterstitialDismissed), name: NSNotification.Name("InterstitialDismissed"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func willResignActive() {
        print("🎯 collapsible native willResignActive")
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func setupRefreshTimer(configuration: NativeAdConfiguration) {
        refreshTimer?.invalidate()
        
        if isCollapsible && enableAutoRefresh {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: self.refreshTimeInSeconds, repeats: true) { [weak self] _ in
                print("🎯 loadNativeAd collapsible native")
                if AdsInterstitial.isShowing || AdsOpen.isShowing || AdsReward.isShowing {
                    print("🎯 Skip refresh collapsible native because other ads are showing")
                    return
                }
                self?.loadNativeAd(adUnitId: self?.adUnitId ?? "", layoutType: self?.layoutType ?? .collapsible, configuration: configuration)
            }
        }
        
    }
    
    @objc private func didBecomeActive() {
        print("🎯 collapsible native didBecomeActive")
        if !isAppear {
            return
        }
        print("🎯 Begin collapsible native refreshTimer")
        if let timer = refreshTimer, !timer.isValid {
            setupRefreshTimer(
                configuration: NativeAdConfiguration()
            )
        }
    }
    
    @objc private func handleInterstitialShown() {
        print("🎯 Begin load ad: handleInterstitialShown")
        shouldLoadOnAppear = false
    }
    
    @objc private func handleInterstitialDismissed() {
        print("Begin load ad: handleInterstitialDismissed")
        shouldLoadOnAppear = true
        if !isAppear {
            return
        }
        if !adUnitId.isEmpty {
            setupRefreshTimer( configuration: NativeAdConfiguration())
        }
    }
    
    func loadNativeAd(adUnitId: String, layoutType: NativeAdLayoutType, configuration: NativeAdConfiguration,isCollapsible: Bool = false, onAdLoaded: ((Bool) -> Void)? = nil) {
        print("Begin load ad native collapsible")
        print("🔍 isCollapsible before load: \(isCollapsible)")
        self.adUnitId = adUnitId
        self.layoutType = layoutType
        adHeight = Utils.dp(320)
        adLoadStartTime = Date().timeIntervalSince1970
        state = .loading
        
        self.adsLayoutType = layoutType
        if isCollapsedIntoMedium {
            isCollapsedIntoMedium = false
        }
        
        let nativeAdViewAdOptions = NativeAdViewAdOptions()
        
        
        switch configuration.adChoicesPosition {
        case .topLeft:
            nativeAdViewAdOptions.preferredAdChoicesPosition = .topLeftCorner
        case .bottomLeft:
            nativeAdViewAdOptions.preferredAdChoicesPosition = .bottomLeftCorner
        case .bottomRight:
            nativeAdViewAdOptions.preferredAdChoicesPosition = .bottomRightCorner
        default:
            nativeAdViewAdOptions.preferredAdChoicesPosition = .topRightCorner
        }
        
        let adDelegate = NativeAdDelegateHandler(currentScreen: self.currentScreen, adUnitId: self.adUnitId, isCollapsible: self.isCollapsible)
        self.nativeAdDelegate = adDelegate
        print("🔍 Creating new NativeAdDelegateHandler - Screen: \(self.currentScreen), AdUnit: \(self.adUnitId), isCollapsible: \(self.isCollapsible)")
        
        self.adLoaderDelegate = AdLoaderDelegate(
            onAdReceived: { [weak self] ad in
                ad.delegate = adDelegate
                print("🔍 NativeAdDelegateHandler assigned to ad.delegate")
                print("🔍 Current Screen: \(self?.currentScreen ?? "")")
                print("🔍 Ad Unit ID: \(self?.adUnitId ?? "")")
                self?.state = .loaded(ad: ad)
                onAdLoaded?(true)
                print("✅ Native Large Type 2 đã load thành công")
                
                // Tính thời gian load quảng cáo
                let currentTime = Date().timeIntervalSince1970
                self?.adLoadTimeInMsec = Int((currentTime - self!.adLoadStartTime) * 1000)
                print("⏱️ Thời gian load native large type 2: \(self!.adLoadTimeInMsec) msec")
                
                let adSourceName = ad.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? "Admob"
                let adFormat = self?.isCollapsible == true ? "collapseNative" : "native"
                
                AdTrackingEventBus.shared.emitRequest(
                    adFormat: adFormat,
                    adNetwork: adSourceName,
                    adUnitId: self?.adUnitId ?? "",
                    isLoad: 1,
                    errorCode: nil,
                    retryCount: 0,
                    loadTime: self?.adLoadTimeInMsec ?? 0,
                    impressionId: AdTrackingEventBus.impressionId(from: ad.responseInfo)
                )
                
                ad.paidEventHandler = { adValue in
                    let adSourceName = ad.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
                    let impressionId = ad.responseInfo.responseIdentifier
                    
                    AdTrackingEventBus.shared.emitImpression(
                        adFormat: adFormat,
                        adNetwork: adSourceName,
                        adUnitId: self?.adUnitId ?? "",
                        placement: self?.currentScreen ?? "",
                        isShow: 1,
                        errorCode: nil,
                        value: adValue.value.doubleValue,
                        currency: adValue.currencyCode,
                        precision: adValue.precision.rawValue,
                        impressionId: impressionId
                    )
                }
            },
            onAdFailedToLoad: { [weak self] error in
                print("Failed to load native ad: \(error)")
                onAdLoaded?(false)
                self?.state = .failed
                print("❌ Native Large Type 2 load thất bại: \(error.localizedDescription)")
                
                // Tính thời gian load quảng cáo
                let currentTime = Date().timeIntervalSince1970
                self?.adLoadTimeInMsec = Int((currentTime - self!.adLoadStartTime) * 1000)
                print("⏱️ Thời gian load native large type 2 thất bại: \(self?.adLoadTimeInMsec ?? 0) msec")
                
                let adFormat = self?.isCollapsible == true ? "collapseNative" : "native"
                AdTrackingEventBus.shared.emitRequest(
                    adFormat: adFormat,
                    adNetwork: "none",
                    adUnitId: self?.adUnitId ?? "",
                    isLoad: 0,
                    errorCode: String((error as NSError).code),
                    retryCount: 0,
                    loadTime: self!.adLoadTimeInMsec
                )
                self?.adLoadTimeInMsec = 0
            }
        )
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Cannot get rootViewController")
            self.setLoading(false)
            return
        }
        
        self.adLoader = AdLoader(
            adUnitID: adUnitId,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: [nativeAdViewAdOptions]
        )
        
        self.adLoader?.delegate = self.adLoaderDelegate
        DispatchQueue.global(qos: .userInitiated).async {
            self.adLoader?.load(Request())
        }
        
        if isCollapsible {
            setupRefreshTimer(configuration: configuration)
        }
    }
    
    func cleanup() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        adLoader?.delegate = nil
        adLoader = nil
        adLoaderDelegate = nil
        nativeAdDelegate = nil
        state = .initial
    }
    
    func nativeAdDidRecordSwipeGestureClick(_ nativeAd: NativeAd) {
      print("A swipe gesture click has occurred.")
    }

    // Called when a swipe gesture click or a tap click is recorded.
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
      print("A swipe gesture click or tap click has occurred.")
      
    }
    
    
    func isAutoRefreshEnabled(isRefreshEnabled: Bool) {
        self.enableAutoRefresh = isRefreshEnabled
    }
    
    func refreshTime(refreshTimeInSeconds: Double) {
        self.refreshTimeInSeconds = refreshTimeInSeconds
    }
    
    func setCurrentScreen(_ screen: String) {
        self.currentScreen = screen
    }
}
