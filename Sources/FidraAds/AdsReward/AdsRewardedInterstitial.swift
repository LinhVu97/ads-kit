//
//  AdsRewardedInterstitial.swift
//  FidraCore
//
//  Created by HoaTD on 3/3/25.
//

import Foundation
import GoogleMobileAds

@available(iOS 14.0, *)
public class AdsRewardedInterstitial: NSObject, FullScreenContentDelegate {
    
    public static let shared = AdsRewardedInterstitial()
    
    private var rewardedInterAds: [String: RewardedInterstitialAd] = [:]
    private var adStatusMap: [String: AdsFullScreenModel.AdStatusEnum] = [:]
    private var loadTimer: Timer?
    private var isWaitingToShow: Bool = true
    private var adLoadTimeInMsec: [String: Date] = [:]
    private var adDurationWatchAd: [String: Date] = [:]
    private var adSourceName: [String: String] = [:]
    private var adWasRewarded: [String: Bool] = [:]
    public var context: String = ""
    /// Recovers state if the SDK never calls back after `present(from:)`
    /// (observed on iPad iOS 26/27). Cancelled by the first delegate callback.
    private var presentWatchdog: DispatchWorkItem?
    
    
    public static var isShowing: Bool {
        get {
            return shared.adStatusMap.values.contains(.showing)
        }
    }
    
    public var onAdLoadSuccess: (() -> Void)?
    public var onAdRewarded: ((Int) -> Void)?
    public var onResultFinally: (() -> Void)?
    public var onLoadFailed: (() -> Void)?
    public var onAdCompleted: ((Bool) -> Void)?
    
    public override init() {
        super.init()
    }
    
    public func loadAd(adUnitId: String, timeout: TimeInterval = 10) async {
        if adUnitId.isEmpty {
            onResultFinally?()
            return
        }
        
        if rewardedInterAds[adUnitId] != nil, adStatusMap[adUnitId] == .loaded {
            showAd(adUnitId: adUnitId)
            return
        }
        
        if adStatusMap[adUnitId] == .loading {
            return
        }
        
        adStatusMap[adUnitId] = .loading
        adLoadTimeInMsec[adUnitId] = Date()

        startLoadTimer(timeout: timeout, adUnitId: adUnitId)

        do {
            let request = Request()
            // Size the creative for the CURRENT window (iPad Split View / Slide
            // Over / Stage Manager) so present(from:) isn't refused with "ad too
            // large for the scene" (code 16).
            await MainActor.run { request.scene = AdsPresentationHelper.activeWindowScene() }
            let newAd = try await RewardedInterstitialAd.load(with: adUnitId, request: request)
            newAd.fullScreenContentDelegate = self
            
            loadTimer?.invalidate()
            loadTimer = nil
            
            let adSourceName = newAd.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
            self.adSourceName[adUnitId] = adSourceName
            
            rewardedInterAds[adUnitId] = newAd
            adStatusMap[adUnitId] = .loaded
            print("[SDK ADS RewardedInterstitial] ✅ Load success \(adUnitId) - loadTime: \(getLoadTime(adUnitId: adUnitId))ms")
            AdTrackingEventBus.shared.emitRequest(
                adFormat: "rewarded",
                adNetwork: adSourceName,
                adUnitId: adUnitId,
                isLoad: 1,
                errorCode: nil,
                retryCount: 0,
                loadTime: getLoadTime(adUnitId: adUnitId),
                impressionId: AdTrackingEventBus.impressionId(from: newAd.responseInfo)
            )
            
            onAdLoadSuccess?()
            
            if isWaitingToShow {
                showAd(adUnitId: adUnitId)
            }
        } catch {
            print("[SDK ADS RewardedInterstitial] ❌ Load failed \(adUnitId) - loadTime: \(getLoadTime(adUnitId: adUnitId))ms - error: \(error.localizedDescription)")
            loadTimer?.invalidate()
            loadTimer = nil
            adStatusMap[adUnitId] = .failed
            
            let adSourceName = self.adSourceName[adUnitId] ?? ""
            AdTrackingEventBus.shared.emitRequest(
                adFormat: "rewarded",
                adNetwork: adSourceName,
                adUnitId: adUnitId,
                isLoad: 0,
                errorCode: String((error as NSError).code),
                retryCount: 0,
                loadTime: getLoadTime(adUnitId: adUnitId)
            )
            
            onLoadFailed?()
            onResultFinally?()
        }
    }
    
    private func getLoadTime(adUnitId: String) -> Int {
        guard let loadTime = adLoadTimeInMsec[adUnitId] else { return 0 }
        return Int(Date().timeIntervalSince(loadTime)) * 1000
    }
    
    private func getWatchTime(adUnitId: String) -> Int {
        guard let watchTime = adDurationWatchAd[adUnitId] else { return 0 }
        return Int(Date().timeIntervalSince(watchTime)) * 1000
    }
    
    private func startLoadTimer(timeout: TimeInterval, adUnitId: String) {
        loadTimer?.invalidate()
        loadTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            if self.rewardedInterAds[adUnitId] == nil {
                print("[SDK ADS RewardedInterstitial] ⏰ Load timeout \(adUnitId) - loadTime: \(self.getLoadTime(adUnitId: adUnitId))ms")
                self.onResultFinally?()
                self.onLoadFailed?()
                self.adStatusMap[adUnitId] = .failed
            }
            self.loadTimer = nil
        }
    }
    
    public func showAd(adUnitId: String, remoteConfigEnable: Bool? = true) {
        if remoteConfigEnable == false {
            onResultFinally?()
            return
        }
        
        guard let ad = rewardedInterAds[adUnitId] else {
            print("Rewarded interstitial ad wasn't ready")
            onResultFinally?()
            return
        }
        
        if AdsPresentationHelper.isAnyFullScreenAdShowing {
            print("⚠️ AdsRewardedInterstitial: Another full-screen ad is already showing")
            onResultFinally?()
            return
        }
        
        AdsPresentationHelper.presentWhenReady { [weak self] viewController in
            guard let self else { return }

            // The loaded creative may still not fit the live window (preloaded
            // full-screen, then user entered Split View). Google's sanctioned
            // pre-flight check: bail cleanly + logged instead of hanging on the
            // present watchdog for 5s.
            do {
                _ = try ad.canPresent(from: viewController)
            } catch {
                print("⚠️ AdsRewardedInterstitial: cannot present in current window — code \((error as NSError).code): \(error.localizedDescription)")
                self.rewardedInterAds.removeValue(forKey: adUnitId)
                self.adStatusMap[adUnitId] = .failed
                self.onLoadFailed?()
                self.onResultFinally?()
                return
            }

            self.adStatusMap[adUnitId] = .showing
            self.adDurationWatchAd[adUnitId] = Date()
            self.presentWatchdog?.cancel()
            self.presentWatchdog = AdsPresentationHelper.makePresentWatchdog { [weak self] in
                guard let self, self.adStatusMap[adUnitId] == .showing else { return }
                print("⚠️ AdsRewardedInterstitial: present watchdog fired — no SDK callback, recovering \(adUnitId)")
                self.presentWatchdog = nil
                self.rewardedInterAds.removeValue(forKey: adUnitId)
                self.adStatusMap[adUnitId] = .failed
                self.onLoadFailed?()
                self.onResultFinally?()
            }

            ad.present(from: viewController) { [weak self] in
                self?.adWasRewarded[adUnitId] = true
                self?.onAdRewarded?(ad.adReward.amount.intValue)
            }
        }
    }

    private func cancelPresentWatchdog() {
        presentWatchdog?.cancel()
        presentWatchdog = nil
    }
    
    public func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    public func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
        if let adUnitId = rewardedInterAds.first(where: { $0.value === ad })?.key {
            let adSourceName = self.adSourceName[adUnitId] ?? ""
            let impressionId = AdTrackingEventBus.impressionId(from: rewardedInterAds[adUnitId]?.responseInfo)
            AdTrackingEventBus.shared.emitClick(
                adFormat: "rewarded",
                adNetwork: adSourceName,
                adUnitId: adUnitId,
                placement: self.context,
                impressionId: impressionId
            )
        }
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        cancelPresentWatchdog()
        let errorCode = (error as NSError).code
        print("❌ AdsRewardedInterstitial didFailToPresentFullScreenContentWithError called")
        print("❌ Error: \(error.localizedDescription)")
        print("❌ Error code: \(errorCode)")
        print("❌ Current ad status: \(adStatusMap)")
        print("❌ Available ads: \(rewardedInterAds.keys)")
        
        if let failedAdId = rewardedInterAds.first(where: { $0.value === ad })?.key {
            print("❌ Found failed ad ID: \(failedAdId)")
            
            let currentStatus = adStatusMap[failedAdId]
            
            if errorCode == 18 && currentStatus == .showing {
                print("⚠️ IGNORING error code 18 - Ad was already showing successfully (Google AdMob SDK bug)")
                return
            }
            
            if currentStatus == .showing {
                print("⚠️ WARNING: Ad was showing but still got failure callback - possible Google AdMob SDK bug")
            }
            
            let adSourceName = self.adSourceName[failedAdId] ?? ""
            let impressionId = rewardedInterAds[failedAdId]?.responseInfo.responseIdentifier
            AdTrackingEventBus.shared.emitImpression(
                adFormat: "rewarded",
                adNetwork: adSourceName,
                adUnitId: failedAdId,
                placement: self.context,
                isShow: 0,
                errorCode: String(errorCode),
                value: 0,
                currency: "USD",
                precision: nil,
                impressionId: impressionId
            )
            
            rewardedInterAds.removeValue(forKey: failedAdId)
            adStatusMap[failedAdId] = .failed
        } else {
            print("❌ No matching ad found in rewardedInterAds dictionary")
        }
        
        onLoadFailed?()
        onResultFinally?()
    }
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        cancelPresentWatchdog()
        print("✅ AdsRewardedInterstitial adWillPresentFullScreenContent called - Ad is about to show")
        if let adUnitId = rewardedInterAds.first(where: { $0.value === ad })?.key,
           let ad = rewardedInterAds[adUnitId] {
            print("✅ Found ad ID in adWillPresentFullScreenContent: \(adUnitId)")
            ad.paidEventHandler = { adValue in
                let adSourceName = ad.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? ""
                let impressionId = ad.responseInfo.responseIdentifier
                
                AdTrackingEventBus.shared.emitImpression(
                    adFormat: "rewarded",
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
        if let dismissedAdId = rewardedInterAds.first(where: { $0.value === ad })?.key {
            let adSourceName = self.adSourceName[dismissedAdId] ?? ""
            
            let wasRewarded = adWasRewarded[dismissedAdId] ?? false
            
            if wasRewarded {
                print("✅ DONE - User watched complete video and got reward")
            } else {
                print("❌ QUIT - User closed ad before completing video")
            }
            
            AdTrackingEventBus.shared.emitComplete(
                adFormat: "rewarded",
                adNetwork: adSourceName,
                adUnitId: dismissedAdId,
                adDuration: getWatchTime(adUnitId: dismissedAdId),
                placement: self.context,
                endType: wasRewarded ? "done" : "quit"
            ) { [weak self] in
                guard let self = self else { return }
                self.rewardedInterAds.removeValue(forKey: dismissedAdId)
                self.adStatusMap[dismissedAdId] = .notLoaded
                self.adLoadTimeInMsec.removeValue(forKey: dismissedAdId)
                self.adDurationWatchAd.removeValue(forKey: dismissedAdId)
                self.adWasRewarded.removeValue(forKey: dismissedAdId)
                self.onResultFinally?()
            }
        }
    }
}
