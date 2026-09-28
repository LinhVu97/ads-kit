//
//  AdsPresentationHelper.swift
//  FidraAds
//

import UIKit

enum AdsPresentationHelper {

    // MARK: - Ad request scene (iPad multi-window / Split View / Stage Manager)

    /// `UIWindowScene` the user is currently interacting with — assign to
    /// `Request.scene` before loading a full-screen ad.
    ///
    /// Google Mobile Ads sizes a full-screen creative for the scene bound to the
    /// ad request. On iPad, when the app runs in a resized window (Split View /
    /// Slide Over / Stage Manager), a request with no scene is sized for the
    /// whole display, so `present(from:)` is refused with
    /// `GADPresentationErrorCodeAdTooLarge` (16 — "ad is too large for the
    /// scene"). Binding the request to this scene makes the creative match the
    /// live window. Ref: AdMob "Support multiple windows on iPad".
    ///
    /// Portrait only — Google still doesn't render full-screen ads in a
    /// non-fullscreen landscape window.
    @MainActor
    static func activeWindowScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .sorted { activationRank($0.activationState) < activationRank($1.activationState) }

        return scenes.first(where: { $0.windows.contains(where: isPresentableWindow) })
            ?? scenes.first
    }

    // MARK: - View controller resolution

    /// Root view controller of the window the user is actually interacting with.
    ///
    /// iPad iOS 26/27 note: a plain `isKeyWindow` lookup frequently lands on a
    /// non-app `UIWindow` (text-effects / keyboard / system alert) whose
    /// `rootViewController` chain can't host a full-screen ad — or on a window
    /// with a `nil` root. We order the scenes by activation state and skip
    /// windows that aren't usable so the app's main window wins.
    static func rootViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .sorted { activationRank($0.activationState) < activationRank($1.activationState) }

        for scene in scenes {
            let windows = scene.windows.filter(isPresentableWindow)
            guard !windows.isEmpty else { continue }

            if let window = windows.first(where: { $0.isKeyWindow && $0.windowLevel == .normal }) {
                return window.rootViewController
            }
            if let window = windows.first(where: { $0.windowLevel == .normal }) {
                return window.rootViewController
            }
            if let window = windows.first(where: { $0.isKeyWindow }) {
                return window.rootViewController
            }
            return windows.first?.rootViewController
        }

        // Last resort: any attached window that has a root view controller.
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: { $0.rootViewController != nil })?
            .rootViewController
    }

    private static func activationRank(_ state: UIScene.ActivationState) -> Int {
        switch state {
        case .foregroundActive: return 0
        case .foregroundInactive: return 1
        case .background: return 2
        case .unattached: return 3
        @unknown default: return 4
        }
    }

    private static func isPresentableWindow(_ window: UIWindow) -> Bool {
        guard window.rootViewController != nil, !window.isHidden else { return false }
        switch String(describing: type(of: window)) {
        case "UITextEffectsWindow", "UIRemoteKeyboardWindow":
            return false
        default:
            return true
        }
    }

    static func topViewController(from base: UIViewController? = nil) -> UIViewController? {
        guard let base = base ?? rootViewController() else { return nil }

        if let navigationController = base as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController ?? navigationController)
        }

        if let tabBarController = base as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController ?? tabBarController)
        }

        if let presented = base.presentedViewController {
            return topViewController(from: presented)
        }

        return base
    }

    static func canPresentFullScreenContent(from viewController: UIViewController) -> Bool {
        viewController.presentedViewController == nil
            && !viewController.isBeingPresented
            && !viewController.isBeingDismissed
    }

    /// Top-most VC that isn't already presenting a modal — best target for a
    /// full-screen ad.
    static func viewControllerForFullScreenAd() -> UIViewController? {
        guard let top = topViewController() else { return nil }
        return canPresentFullScreenContent(from: top) ? top : nil
    }

    // MARK: - Present when ready

    /// Đợi đến khi có VC phù hợp (sheet dismiss / animation kết thúc), rồi gọi
    /// `present`.
    ///
    /// Nếu sau `timeout` vẫn chưa có VC nào rảnh, `present` **vẫn** được gọi với
    /// VC tốt nhất tìm được (có thể là `nil`). Truyền `nil` để Google Mobile Ads
    /// tự resolve root VC của key window — đây là hành vi trước 1.1.47 và là thứ
    /// giúp ad vẫn hiển thị trên iPad iOS 26/27 khi việc dò window của mình bị
    /// sai. Không bao giờ bỏ luồng show trong im lặng.
    static func presentWhenReady(
        timeout: TimeInterval = 5.0,
        interval: TimeInterval = 0.25,
        present: @escaping (UIViewController?) -> Void
    ) {
        let deadline = Date().addingTimeInterval(timeout)

        func attempt() {
            if let viewController = viewControllerForFullScreenAd() {
                present(viewController)
                return
            }

            if Date() >= deadline {
                print("⚠️ AdsPresentationHelper: no free VC after \(timeout)s — presenting best-effort")
                present(topViewController())
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                attempt()
            }
        }

        DispatchQueue.main.async {
            attempt()
        }
    }

    /// Lưới an toàn cho iPad iOS 26/27: Google Mobile Ads có thể từ chối present
    /// trong im lặng (không có callback `adWillPresent` lẫn `didFailToPresent`)
    /// khi nhận một root VC "chết". Caller arm watchdog này ngay sau `present(...)`
    /// và huỷ nó ở callback delegate đầu tiên nhận được.
    static func makePresentWatchdog(
        timeout: TimeInterval = 5.0,
        onSilentFailure: @escaping () -> Void
    ) -> DispatchWorkItem {
        let work = DispatchWorkItem(block: onSilentFailure)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: work)
        return work
    }

    static var isAnyFullScreenAdShowing: Bool {
        AdsInterstitial.isShowing
            || AdsOpen.isShowing
            || AdsReward.isShowing
            || AdsRewardedInterstitial.isShowing
            || FullScreenNativeAdsViewModel.shared.adStatus == .showing
    }
}
