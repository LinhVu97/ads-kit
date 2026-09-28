//
//  File.swift
//  
//
//  Created by hi on 14/02/2025.
//

import GoogleMobileAds
import SwiftUI

public struct AdsBannerView: View {
    private let config: BannerConfig
    @State private var isLoading = true
    var timeRefresh: Double
    var endLoading : ((Error?) -> Void)?
    @State var isAdsLoaded: Bool = true
    
    public init(adUnitID: String, typeBannerAd: AdsBannerModel.AdsBannerTypeEnum = .adaptiveBanner, positionBannerCollapse: String = "bottom", currentScreen: String = "", isEnabledShowLoading: Bool = false, timeRefresh: Double = 30, handleShowLoading: (() -> ())? = nil, endLoading: ((Error?) -> Void)?) {
        self.config = BannerConfig(adUnitID: adUnitID, typeBannerAd: typeBannerAd, positionBannerCollapse: positionBannerCollapse, currentScreen: currentScreen, isEnabledShowLoading: isEnabledShowLoading, handleShowLoading: handleShowLoading)
        self.endLoading = endLoading
        self.timeRefresh = timeRefresh
    }
    
    public var body: some View {
        ZStack {
            Color.white
            AdsBannerRepresentable(config: config, isLoading: $isLoading, adState: .loading, timeRefresh: timeRefresh, endLoading: { error in
                if let _ = error {
                    isAdsLoaded = false
                } else {
                    isAdsLoaded = true
                }
                self.endLoading?(error)
            })
            .frame(height: isAdsLoaded ? config.typeBannerAd == .largeBanner ? 250 : UIDevice().userInterfaceIdiom == .pad ? 90 : 70 : 0)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }.frame(height: isAdsLoaded ? config.typeBannerAd == .largeBanner ? 250 : UIDevice().userInterfaceIdiom == .pad ? 90 : 70 : 0)
    }
}

public struct AdsBannerRepresentable: UIViewControllerRepresentable {
    let config: BannerConfig
    @Binding var isLoading: Bool
    @State var adState: AdsBannerModel.AdsBannerStateEnum = .loading
    var timeRefresh: Double
    var endLoading : ((Error?) -> Void)?
    
    init(config: BannerConfig, isLoading: Binding<Bool>, adState: AdsBannerModel.AdsBannerStateEnum = .loading, timeRefresh: Double, endLoading: ((Error?) -> Void)? = nil) {
        self.config = config
        self._isLoading = isLoading
        self.adState = adState
        self.timeRefresh = timeRefresh
        self.endLoading = endLoading
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        return BannerViewController(config: config, timeRefresh: timeRefresh, isLoading: $isLoading,endLoading: endLoading)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class BannerViewController: UIViewController{
    private let config: BannerConfig
    private var bannerView: BannerView?
    private var refreshTimer: Timer?
    @Binding var isLoading: Bool
    private var shouldLoadOnAppear: Bool = true
    private var isAppear = false
    private var endLoading : ((Error?) -> Void)?
    private var timeRefresh: Double
    private var adLoadTimeInMsec: Date = Date()
    private var adSourceName: String = ""
    
    init(config: BannerConfig, timeRefresh: Double, isLoading: Binding<Bool>, endLoading : ((Error?) -> Void)?) {
        self.config = config
        self._isLoading = isLoading
        self.endLoading = endLoading
        self.timeRefresh = timeRefresh
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterstitialShown), name: NSNotification.Name("InterstitialShown"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterstitialDismissed), name: NSNotification.Name("InterstitialDismissed"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isAppear = true
        print("🎯 viewDidAppear banner")
        if shouldLoadOnAppear {
            loadBannerAd()
            startRefreshTimer()
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        stopRefreshTimer()
//        view.removeFromSuperview()
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("🎯 viewDidDisappear banner")
        self.isAppear = false
        super.viewWillDisappear(animated)
        stopRefreshTimer()
        view.removeFromSuperview()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("🎯 viewWillTransition banner")
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self = self else {return}
            self.loadBannerAd()
        }
    }
    
    @objc private func willResignActive() {
        stopRefreshTimer()
    }
    
    @objc private func didBecomeActive() {
        if isAppear {
            startRefreshTimer()
        }
    }
    
    @objc private func handleInterstitialShown() {
        shouldLoadOnAppear = false
    }
    
    @objc private func handleInterstitialDismissed() {
        shouldLoadOnAppear = true
    }
    
    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: timeRefresh, repeats: true) { [weak self] _ in
            print("🎯 Refresh banner timer")
            if AdsInterstitial.isShowing || AdsOpen.isShowing || AdsReward.isShowing {
                print("🎯 Skip refresh banner because other ads are showing")
                return
            }
            self?.loadBannerAd()
        }
    }
    
    private func stopRefreshTimer() {
        print("🎯 Stop banner timer")
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func loadBannerAd() {
        print("🎯 Load banner")
        self.adLoadTimeInMsec = Date()
        DispatchQueue.main.async {
            self.isLoading = true
        }
        for banner in view.subviews {
            banner.removeFromSuperview()
        }
        if config.isEnabledShowLoading {
            config.handleShowLoading?()
        }
        
        let adSize: AdSize = {
            if config.typeBannerAd == .largeBanner {
                return UIDevice().userInterfaceIdiom == .pad ? AdSizeLeaderboard : AdSizeMediumRectangle
            }
            return AdSizeBanner
        }()
        
        bannerView = BannerView(adSize: adSize)
        bannerView?.adUnitID = config.adUnitID
        bannerView?.delegate = self
        bannerView?.rootViewController = self
        
        let bannerWidth = view.frame.size.width
        bannerView?.adSize = currentOrientationInlineAdaptiveBanner(width: bannerWidth)
        
        let request = Request()
        if config.typeBannerAd == .collapsible {
            let extras = Extras()
            extras.additionalParameters = ["collapsible": config.positionBannerCollapse]
            request.register(extras)
        }
        
        bannerView?.load(request)
        
        if let bannerView = bannerView {
            setAdView(bannerView)
        }
    }
    
    private func getLoadTime() -> Int {
        return Int(Date().timeIntervalSince(self.adLoadTimeInMsec)) * 1000
    }
    
    func setAdView(_ view: BannerView){
        bannerView = view
        self.view.addSubview(bannerView!)
        bannerView?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bannerView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bannerView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bannerView!.topAnchor.constraint(equalTo: self.view.topAnchor),
            bannerView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func adLogEvent(bannerView: BannerView) {
        let ad_source_name = bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adSourceName ?? ""
        self.adSourceName = ad_source_name
        
        bannerView.paidEventHandler = { adValue in
            let impressionId = bannerView.responseInfo?.responseIdentifier
            AdTrackingEventBus.shared.emitImpression(
                adFormat: "banner",
                adNetwork: ad_source_name,
                adUnitId: self.config.adUnitID,
                placement: self.config.currentScreen,
                isShow: 1,
                errorCode: nil,
                value: adValue.value.doubleValue,
                currency: adValue.currencyCode,
                precision: adValue.precision.rawValue,
                impressionId: impressionId
            )
        }
    }
}

extension BannerViewController: BannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        DispatchQueue.main.async {
            print("[SDK ADS Banner] ✅ Load success \(self.config.adUnitID) - loadTime: \(self.getLoadTime())ms")
            self.isLoading = false
            self.endLoading?(nil)
        }
        
        let adSourceName = bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adSourceName ?? ""
        self.adSourceName = adSourceName

        AdTrackingEventBus.shared.emitRequest(
            adFormat: "banner",
            adNetwork: adSourceName,
            adUnitId: self.config.adUnitID,
            isLoad: 1,
            errorCode: nil,
            retryCount: 0,
            loadTime: getLoadTime(),
            impressionId: AdTrackingEventBus.impressionId(from: bannerView.responseInfo)
        )
    }
    
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        self.adLogEvent(bannerView: bannerView)
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("[SDK ADS Banner] ❌ Load failed \(config.adUnitID) - loadTime: \(getLoadTime())ms - error: \(error.localizedDescription)")
        isLoading = false
        endLoading?(error)
        
        let adSourceName = self.adSourceName.isEmpty ? "none" : self.adSourceName
        AdTrackingEventBus.shared.emitRequest(
            adFormat: "banner",
            adNetwork: adSourceName,
            adUnitId: self.config.adUnitID,
            isLoad: 0,
            errorCode: String((error as NSError).code),
            retryCount: 0,
            loadTime: getLoadTime()
        )
    }
    
    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        let adSourceName = bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adSourceName ?? self.adSourceName
        let impressionId = AdTrackingEventBus.impressionId(from: bannerView.responseInfo)
        AdTrackingEventBus.shared.emitClick(
            adFormat: "banner",
            adNetwork: adSourceName,
            adUnitId: self.config.adUnitID,
            placement: self.config.currentScreen,
            impressionId: impressionId
        )
    }
}
