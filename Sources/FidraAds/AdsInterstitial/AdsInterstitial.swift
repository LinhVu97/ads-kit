//
//  InterstitialAd.swift
//  FidraCore
//
//  Created by hi on 27/2/25.
//
import Foundation
import SwiftUI
import GoogleMobileAds

public class AdsInterstitial: NSObject, FullScreenContentDelegate {
    public static let shared = AdsInterstitial()
    
    public var timeRefreshInterstitial: Int = 30
    public var adsInterstitial: [String: InterstitialAd] = [:]
    private var autoLoad: [String: Bool] = [:]
    public var timer: Timer?
    private var adStatus: AdsFullScreenModel.AdStatusEnum = .notLoaded
    public static var isShowing: Bool {
        return shared.adStatus == .showing
    }
    public var onAdLoadSuccess: (() -> Void)?
    public var onResultFinally: (() -> Void)?
    public var onAdDismiss: (() -> Void)?
    public var onAdShowing: (() -> Void)?
    public var onAdError: (() -> Void)?
    
    private var currentAdUnitId: String?
    private var adLoadTimeInMsec: Date = Date()
    private var adDurationWatchAd: Date = Date()
    public var context: String = ""
    public var pendingShow: Bool = false
    /// Recovers state if the SDK never calls back after `present(from:)`
    /// (observed on iPad iOS 26/27). Cancelled by the first delegate callback.
    private var presentWatchdog: DispatchWorkItem?
    
    
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func willResignActive() {
        print("[SDK ADS Interstitial] 🎯 interstitial timer stop")
        timer?.invalidate()
        timer = nil
    }
    
    public func setTimeRefreshInterstitial(_ timeRefreshInterstitial: Int) {
        self.timeRefreshInterstitial = timeRefreshInterstitial
    }
    
    public func loadAd(adUnitId: String, enableAds: Bool? = true, isAutoLoad: Bool? = false, timeout: TimeInterval = 10) async {
        
        if enableAds == false || adUnitId.isEmpty {
            await MainActor.run { self.onResultFinally?() }
            return
        }
        
        await MainActor.run {
            self.currentAdUnitId = adUnitId
            self.adStatus = .loading
        }
        
        print("[SDK ADS Interstitial] 🚀 Bắt đầu load - AdUnit: \(adUnitId), timeout: \(timeout)s, isAutoLoad: \(isAutoLoad ?? false)")
        
        do {
            let result: InterstitialAd? = try await withThrowingTaskGroup(of: InterstitialAd.self) { group in
                group.addTask {
                    let request = Request()
                    await MainActor.run {
                        self.adLoadTimeInMsec = Date()
                        // Size the creative for the CURRENT window (iPad Split View /
                        // Slide Over / Stage Manager) so present(from:) isn't refused
                        // with "ad too large for the scene" (code 16).
                        request.scene = AdsPresentationHelper.activeWindowScene()
                    }
                    return try await InterstitialAd.load(with: adUnitId, request: request)
                }
                
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    throw AdLoadTimeoutError()
                }
                
                let ad = try await group.next()
                group.cancelAll()
                return ad
            }
            
            if let result = result {
                await MainActor.run {
                    self.adsInterstitial[adUnitId] = result
                    self.adsInterstitial[adUnitId]?.fullScreenContentDelegate = self
                    self.adStatus = .loaded
                }
                print("[SDK ADS Interstitial] ✅ Load success \(adUnitId) - loadTime: \(getLoadTime())ms")
                let adSourceName = await MainActor.run {
                    self.adsInterstitial[adUnitId]?.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
                }
                
                AdTrackingEventBus.shared.emitRequest(
                    adFormat: "interstitial",
                    adNetwork: adSourceName,
                    adUnitId: self.currentAdUnitId ?? "",
                    isLoad: 1,
                    errorCode: nil,
                    retryCount: 0,
                    loadTime: getLoadTime(),
                    impressionId: AdTrackingEventBus.impressionId(from: result.responseInfo)
                )
                
                if isAutoLoad != true {
                    await MainActor.run {
                        self.onAdLoadSuccess?()
                    }
                }
                
            } else {
                print("[SDK ADS Interstitial] ❌ Load failed \(adUnitId) - loadTime: \(getLoadTime())ms - error: null result")
                await MainActor.run {
                    self.adStatus = .failed
                    self.onAdError?()
                    self.onResultFinally?()
                }
            }
            
            
            
            
        } catch {
            let errorMessage: String
            if error is AdLoadTimeoutError {
                errorMessage = "Ad load timeout after \(timeout) seconds"
            } else {
                errorMessage = error.localizedDescription
            }
            print("[SDK ADS Interstitial] ❌ Load failed \(adUnitId) - loadTime: \(getLoadTime())ms - error: \(errorMessage)")
            let adSourceName = await MainActor.run {
                self.adsInterstitial[adUnitId]?.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
            }
            
            AdTrackingEventBus.shared.emitRequest(
                adFormat: "interstitial",
                adNetwork: adSourceName,
                adUnitId: adUnitId,
                isLoad: 0,
                errorCode: String((error as NSError).code),
                retryCount: 0,
                loadTime: getLoadTime()
            )
            
            await MainActor.run {
                self.adStatus = .failed
                self.onAdError?()
                self.onResultFinally?()
            }
        }
    }
    
    private func getLoadTime() -> Int {
        return Int(Date().timeIntervalSince(self.adLoadTimeInMsec)) * 1000
    }
    private func getWatchTime() -> Int {
        return Int(Date().timeIntervalSince(self.adDurationWatchAd)) * 1000
    }
    
    
    public func showAd(adUnitId: String, enableAds: Bool? = true, isAutoLoad: Bool? = true) {
        if enableAds == false || adUnitId.isEmpty {
            onResultFinally?()
            return
        }
        
        if adUnitId.isEmpty {
            onResultFinally?()
            return
        }
        self.autoLoad[adUnitId] = isAutoLoad
        self.currentAdUnitId = adUnitId
        
        if AdsPresentationHelper.isAnyFullScreenAdShowing {
            onResultFinally?()
            return
        }
        
        print("[SDK ADS Interstitial] 🎯 showAd interstitial ad \(adUnitId)")
        guard let interstitialAd = adsInterstitial[adUnitId] else {
            if isAutoLoad == true {
                startTimer(adUnitId)
            }
            onResultFinally?()
            return
        }
        
        
        AdsPresentationHelper.presentWhenReady { [weak self] viewController in
            guard let self else { return }

            // The loaded creative may still not fit the live window (e.g. it was
            // preloaded full-screen, user then entered Split View). Google's
            // sanctioned pre-flight check: bail cleanly + logged instead of
            // hanging on the present watchdog for 5s.
            do {
                _ = try interstitialAd.canPresent(from: viewController)
            } catch {
                print("[SDK ADS Interstitial] ⚠️ cannot present in current window — code \((error as NSError).code): \(error.localizedDescription)")
                self.adsInterstitial.removeValue(forKey: adUnitId)
                self.adStatus = .failed
                self.onAdError?()
                self.onResultFinally?()
                return
            }

            self.adStatus = .showing
            NotificationCenter.default.post(name: NSNotification.Name("InterstitialShown"), object: nil)
            self.presentWatchdog?.cancel()
            self.presentWatchdog = AdsPresentationHelper.makePresentWatchdog { [weak self] in
                guard let self, self.adStatus == .showing else { return }
                print("[SDK ADS Interstitial] ⚠️ present watchdog fired — no SDK callback, recovering \(adUnitId)")
                self.presentWatchdog = nil
                self.adsInterstitial.removeValue(forKey: adUnitId)
                self.adStatus = .failed
                self.onAdError?()
                self.onResultFinally?()
            }
            interstitialAd.present(from: viewController)
        }
    }

    private func cancelPresentWatchdog() {
        presentWatchdog?.cancel()
        presentWatchdog = nil
    }
    
    // MARK: - GADFullScreenContentDelegate methods
    
    // [START ad_events]
    public func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("[SDK ADS Interstitial] 🎉 \(#function) called")
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("[SDK ADS Interstitial] 🎉 \(#function) called")
        let adSourceName = self.adsInterstitial[self.currentAdUnitId ?? ""]?.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
        let impressionId = AdTrackingEventBus.impressionId(from: self.adsInterstitial[self.currentAdUnitId ?? ""]?.responseInfo)
        AdTrackingEventBus.shared.emitClick(
            adFormat: "interstitial",
            adNetwork: adSourceName,
            adUnitId: self.currentAdUnitId ?? "",
            placement: self.context,
            impressionId: impressionId
        )
    }
    
    public func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        cancelPresentWatchdog()
        print("[SDK ADS Interstitial] 🎉 \(#function) called")
        if let failedAdId = adsInterstitial.first(where: { $0.value === ad })?.key {
            let adSourceName = self.adsInterstitial[failedAdId]?.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
            let impressionId = self.adsInterstitial[failedAdId]?
                   .responseInfo
                   .responseIdentifier
            
            AdTrackingEventBus.shared.emitImpression(
                adFormat: "interstitial",
                adNetwork: adSourceName,
                adUnitId: failedAdId,
                placement: self.context,
                isShow: 0,
                errorCode: String((error as NSError).code),
                value: 0,
                currency: "USD",
                precision: nil,
                impressionId: impressionId
            )
            adsInterstitial.removeValue(forKey: failedAdId)
        }
        Task { @MainActor in
            self.adStatus = .failed
            self.onAdError?()
            self.onResultFinally?()
        }
    }
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        cancelPresentWatchdog()
        print("[SDK ADS Interstitial] 🎉 \(#function) called")
        print("[SDK ADS Interstitial] Ad ID: \(currentAdUnitId ?? "unknown")")
        self.adDurationWatchAd = Date()
        adStatus = .showing
        self.onAdShowing?()
        if let adUnitId = currentAdUnitId, !adUnitId.isEmpty,
           let interstitialAd = adsInterstitial[adUnitId] {
            interstitialAd.paidEventHandler = { [weak self] adValue in
                guard let self = self else { return }
                let adSourceName = self.adsInterstitial[adUnitId]?.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
                
                let impressionId = interstitialAd
                       .responseInfo
                       .responseIdentifier

                
                AdTrackingEventBus.shared.emitImpression(
                    adFormat: "interstitial",
                    adNetwork: adSourceName,
                    adUnitId: adUnitId,
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
        print("[SDK ADS Interstitial] 🎉 \(#function) called")
        //adDidDismissFullScreenContent
        
        NotificationCenter.default.post(name: NSNotification.Name("InterstitialDismissed"), object: nil)
        guard let adUnitId = currentAdUnitId, !adUnitId.isEmpty else {
            return
        }
        let adSourceName = self.adsInterstitial[adUnitId]?.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
        self.pendingShow = false
        AdTrackingEventBus.shared.emitComplete(
            adFormat: "interstitial",
            adNetwork: adSourceName,
            adUnitId: adUnitId,
            adDuration: getWatchTime(),
            placement: self.context,
            endType: nil
        ) { [weak self] in
            guard let self = self else { return }
            self.adsInterstitial[adUnitId] = nil
            if self.autoLoad[adUnitId] == true {
                print("[SDK ADS Interstitial] 🎯 Begin call start timer")
                self.startTimer(adUnitId)
            }
            self.adStatus = .notLoaded
            self.onResultFinally?()
            self.onAdDismiss?()
        }
    }
    // [END ad_events]
    private func startTimer(_ adUnitId: String) {
        guard let adUnitId = currentAdUnitId, !adUnitId.isEmpty, !pendingShow else {
            return
        }
        print("[SDK ADS Interstitial] 🎯 Call Start timer inter \(timeRefreshInterstitial)")
        if timer != nil {
            print("[SDK ADS Interstitial] 🎯 Call Start timer inter exits")
            return
        }
        timer?.invalidate()
        timer = nil
        var timeToCompare = 0;
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            timeToCompare += 1
            if timeToCompare >= self.timeRefreshInterstitial {
                if adsInterstitial[adUnitId] == nil {
                    print("[SDK ADS Interstitial] 🎯 Start timer inter loadAd \(timeRefreshInterstitial)")
                    Task {
                        await self.loadAd(adUnitId: adUnitId, isAutoLoad: true)
                    }
                    self.pendingShow = true
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
}

private struct AdLoadTimeoutError: Error {}
