//
//  CollapsiveManager.swift
//  FidraAds
//
//  Created by HoaTD on 16/3/26.
//

import SwiftUI
import GoogleMobileAds

public class CollapsiveManager: ObservableObject {
    @Published private(set) var state: AdState = .initial

    private var _adHeight: CGFloat = Utils.dp(320)
    public var adHeight: CGFloat {
        get { _adHeight }
        set {
            let value = newValue
            if Thread.isMainThread {
                _adHeight = value
                objectWillChange.send()
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?._adHeight = value
                    self?.objectWillChange.send()
                }
            }
        }
    }

    public func setAdHeight(_ value: CGFloat) {
        adHeight = value
    }
    public var isAppear = false
    
    public var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }
    
    public func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.state = loading ? .loading : .failed
        }
    }
    
    public var nativeAd: NativeAd? {
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
    @Published public var shouldLoadOnAppear = true
    private var adLoadStartTime: TimeInterval = 0 // Thời gian bắt đầu load quảng cáo
    private var adLoadTimeInMsec: Int = 0 // Thời gian load quảng cáo tính bằng msec
    private var currentScreen = ""
    private var refreshTimeInSeconds: Double = 5
    private var configuration: NativeAdConfiguration = .init()
    private var isEnabledLoadAds: Bool = true
    
    
    public init() {
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
    
    func setConfiguration(config: NativeAdConfiguration) {
        self.configuration = config
    }
    
    public func setAdUnitId(_ adUnitId: String) {
        self.adUnitId = adUnitId
    }
    
    
    public func setupRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: self.refreshTimeInSeconds, repeats: false) { [weak self] _ in
            
            guard let self = self else { return }
            refreshTimer?.invalidate()
            refreshTimer = nil
            isEnabledLoadAds = true
            loadNativeAd()
        }
    }
    
    @objc private func didBecomeActive() {
        print("🎯 collapsible native didBecomeActive")
        if !isAppear {
            return
        }
        print("🎯 Begin collapsible native refreshTimer")
//        if let timer = refreshTimer, !timer.isValid {
//            setupRefreshTimer()
//        }
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
//        if !adUnitId.isEmpty {
//            setupRefreshTimer()
//        }
    }
    
    public func loadNativeAd( onAdLoaded: ((Bool) -> Void)? = nil) {
        
        if state == .loading {
            adHeight = 0
            return
        }
        
        if state == .failed {
            adHeight = 0
        } else if let ad = nativeAd, state == .loaded(ad: ad) {
            if let _ = refreshTimer {
                return
            }
            
            if isEnabledLoadAds == false {
                setupRefreshTimer()
                return
            }
        }
        
        adLoadStartTime = Date().timeIntervalSince1970
        state = .loading
        
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
        
        let adDelegate = NativeAdDelegateHandler(currentScreen: self.currentScreen, adUnitId: self.adUnitId, isCollapsible: true)
        self.nativeAdDelegate = adDelegate
        
        self.adLoaderDelegate = AdLoaderDelegate(
            onAdReceived: { [weak self] ad in
                self?.isEnabledLoadAds = false
                ad.delegate = adDelegate
                self?.state = .loaded(ad: ad)
                onAdLoaded?(true)
                
                // Tính thời gian load quảng cáo
                let currentTime = Date().timeIntervalSince1970
                self?.adLoadTimeInMsec = Int((currentTime - self!.adLoadStartTime) * 1000)
                print("⏱️ Thời gian load native large type 2: \(self!.adLoadTimeInMsec) msec")
                
                let adSourceName = ad.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? "Admob"
                let adFormat = "collapseNative"
                
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
                
                let adFormat = "collapseNative"
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
    }
    
    public func cleanup() {
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
    
    public func refreshTime(refreshTimeInSeconds: Double) {
        self.refreshTimeInSeconds = refreshTimeInSeconds
    }
    
    public func setCurrentScreen(_ screen: String) {
        self.currentScreen = screen
    }
}
