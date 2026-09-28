//
//  AdsOpen.swift
//  FidraCore
//
//  Created by HoaTD on 3/3/25.
//

import GoogleMobileAds

public class AdsOpen: NSObject, FullScreenContentDelegate {
    public static let shared = AdsOpen()
    
    private var appOpenAd: AppOpenAd?
    private var adUnitId: String?
    private var adStatus: AdsFullScreenModel.AdStatusEnum = .notLoaded
    /// Recovers state if the SDK never calls back after `present(from:)`
    /// (observed on iPad iOS 26/27). Cancelled by the first delegate callback.
    private var presentWatchdog: DispatchWorkItem?
    
    public static var isShowing: Bool {
        return shared.adStatus == .showing
    }
    
    public var onResultFinally: (() -> Void)?
    private var adLoadTimeInMsec: Date = Date()
    private var adDurationWatchAd: Date = Date()
    public var context: String = ""
    private var adSourceName: String = ""
    
    public override init() {
        super.init()
    }
    
    public func loadAdAndShow(adUnitId: String, enableAds: Bool? = true) async {
        
        if enableAds == false || adUnitId.isEmpty {
            onResultFinally?()
            return
        }
        
        if adUnitId.isEmpty {
            onResultFinally?()
            return
        }
        
        // Kiểm tra nếu Open Ad, Interstitial hoặc Reward đang hiển thị
        if adStatus == .showing || AdsPresentationHelper.isAnyFullScreenAdShowing {
            onResultFinally?()
            return
        }
        
        if adStatus == .loaded {
            self.showAd()
            return
        }
        
        self.adUnitId = adUnitId
        adStatus = .loading
        
        // Bắt đầu đo thời gian load
        let startTime = CFAbsoluteTimeGetCurrent()
        print("🚀 Bắt đầu load App Open Ad - AdUnit: \(adUnitId)")
        
        do {
            // Sử dụng withThrowingTaskGroup để quản lý timeout và load ad
            let result: AppOpenAd? = try await withThrowingTaskGroup(of: AppOpenAd.self) { group in
                // Task tải quảng cáo
                group.addTask {
                    self.adLoadTimeInMsec = Date()
                    let request = Request()
                    // Size for the CURRENT window (iPad Split View / Slide Over /
                    // Stage Manager) so present(from:) isn't refused with "ad too
                    // large for the scene" (code 16).
                    await MainActor.run { request.scene = AdsPresentationHelper.activeWindowScene() }
                    return try await AppOpenAd.load(with: adUnitId, request: request)
                }
                
                // Task timeout 10 giây
                group.addTask {
                    try await Task.sleep(nanoseconds: 10_000_000_000)
                    throw AdLoadTimeoutError()
                }
                
                // Lấy kết quả đầu tiên (hoặc ad load thành công hoặc timeout)
                let ad = try await group.next()
                group.cancelAll() // Hủy task còn lại
                return ad
            }
            
            // Tính thời gian load
            let loadTime = CFAbsoluteTimeGetCurrent() - startTime
            
            // Kiểm tra trạng thái trước khi tiếp tục (tránh race condition)
            guard adStatus == .loading else {
                print("⚠️ App Open Ad load bị hủy sau \(String(format: "%.2f", loadTime))s")
                onResultFinally?()
                return
            }
            
            let adSourceName = result?.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
            
            self.adSourceName = adSourceName
            
            // Thiết lập ad và hiển thị
            if let ad = result {
                appOpenAd = ad
                appOpenAd?.fullScreenContentDelegate = self
                adStatus = .loaded
                print("✅ App Open Ad load thành công trong \(String(format: "%.2f", loadTime))s")
                self.showAd()
                
                AdTrackingEventBus.shared.emitRequest(
                    adFormat: "open",
                    adNetwork: adSourceName,
                    adUnitId: adUnitId,
                    isLoad: 1,
                    errorCode: nil,
                    retryCount: 0,
                    loadTime: self.getLoadTime(),
                    impressionId: AdTrackingEventBus.impressionId(from: ad.responseInfo)
                )
                
            } else {
                
                adStatus = .failed
                print("❌ App Open Ad load thất bại (null result) sau \(String(format: "%.2f", loadTime))s")
                AdTrackingEventBus.shared.emitRequest(
                    adFormat: "open",
                    adNetwork: adSourceName,
                    adUnitId: adUnitId,
                    isLoad: 0,
                    errorCode: nil,
                    retryCount: 0,
                    loadTime: self.getLoadTime()
                )
                
                onResultFinally?()
            }
            
        } catch {
            // Tính thời gian khi có lỗi
            let loadTime = CFAbsoluteTimeGetCurrent() - startTime
            
            // Xử lý lỗi (timeout hoặc load failed)
            guard adStatus == .loading else { return }
            
            if error is AdLoadTimeoutError {
                print("⏰ App Open Ad timeout sau \(String(format: "%.2f", loadTime))s")
            } else {
                print("❌ App Open Ad load thất bại sau \(String(format: "%.2f", loadTime))s - Error: \(error.localizedDescription)")
            }
            
            adStatus = .failed
            onResultFinally?()
        }
    }
    
    private func getLoadTime() -> Int {
        return Int(Date().timeIntervalSince(self.adLoadTimeInMsec)) * 1000
    }
    private func getWatchTime() -> Int {
        return Int(Date().timeIntervalSince(self.adDurationWatchAd)) * 1000
    }
    
    
    public func showAd(remoteConfigEnable: Bool? = true) {
        if remoteConfigEnable == false {
            onResultFinally?()
            return
        }
        
        guard let ad = appOpenAd else {
            print("App Open Ad wasn't ready")
            onResultFinally?()
            return
        }
        
        if AdsPresentationHelper.isAnyFullScreenAdShowing {
            print("⚠️ AdsOpen: Another full-screen ad is already showing")
            onResultFinally?()
            return
        }
        
        AdsPresentationHelper.presentWhenReady { [weak self] viewController in
            guard let self else { return }

            // The loaded creative may still not fit the live window. Google's
            // sanctioned pre-flight check: bail cleanly + logged instead of
            // hanging on the present watchdog for 5s.
            do {
                _ = try ad.canPresent(from: viewController)
            } catch {
                print("⚠️ AdsOpen: cannot present in current window — code \((error as NSError).code): \(error.localizedDescription)")
                self.appOpenAd = nil
                self.adStatus = .failed
                self.onResultFinally?()
                return
            }

            self.adStatus = .showing
            self.presentWatchdog?.cancel()
            self.presentWatchdog = AdsPresentationHelper.makePresentWatchdog { [weak self] in
                guard let self, self.adStatus == .showing else { return }
                print("⚠️ AdsOpen: present watchdog fired — no SDK callback, recovering")
                self.presentWatchdog = nil
                self.appOpenAd = nil
                self.adStatus = .failed
                self.onResultFinally?()
            }
            ad.present(from: viewController)
        }
    }

    private func cancelPresentWatchdog() {
        presentWatchdog?.cancel()
        presentWatchdog = nil
    }
    
    // MARK: - FullScreenContentDelegate
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        cancelPresentWatchdog()
        print("Failed to present app open ad: \(error.localizedDescription)")
        let adSourceName = self.appOpenAd?.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
        let impressionId = self.appOpenAd?.responseInfo.responseIdentifier
        AdTrackingEventBus.shared.emitImpression(
            adFormat: "open",
            adNetwork: adSourceName,
            adUnitId: self.adUnitId ?? "",
            placement: self.context,
            isShow: 0,
            errorCode: String((error as NSError).code),
            value: 0,
            currency: "USD",
            precision: nil,
            impressionId: impressionId
        )
        
        appOpenAd = nil
        
        
        
        adStatus = .failed
        onResultFinally?()
    }
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        cancelPresentWatchdog()
        self.adDurationWatchAd = Date()
        if let ad = appOpenAd {
            ad.paidEventHandler = { adValue in
                let adSourceName = ad.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
                let impressionId = ad.responseInfo.responseIdentifier
                
                AdTrackingEventBus.shared.emitImpression(
                    adFormat: "open",
                    adNetwork: adSourceName,
                    adUnitId: self.adUnitId ?? "",
                    placement: self.context,
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
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        cancelPresentWatchdog()
        appOpenAd = nil
        adStatus = .notLoaded
        
        AdTrackingEventBus.shared.emitComplete(
            adFormat: "open",
            adNetwork: adSourceName,
            adUnitId: self.adUnitId ?? "",
            adDuration: getWatchTime(),
            placement: self.context,
            endType: nil
        ) { [weak self] in
            self?.onResultFinally?()
        }
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("App Open Ad clicked")
        let impressionId = AdTrackingEventBus.impressionId(from: appOpenAd?.responseInfo)
        AdTrackingEventBus.shared.emitClick(
            adFormat: "open",
            adNetwork: adSourceName,
            adUnitId: self.adUnitId ?? "",
            placement: self.context,
            impressionId: impressionId
        )
    }
}

// Custom error cho timeout
private struct AdLoadTimeoutError: Error {}
