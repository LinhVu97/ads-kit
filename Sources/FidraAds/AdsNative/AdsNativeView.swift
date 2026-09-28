//
//  AdsNativeMedium1.swift
//  FidraCore
//
//  Created by HoaTD on 28/2/25.
//

import GoogleMobileAds
import UIKit
import SwiftUI

// Start of Selection
public struct AdsNativeView: View {
    var isSelectOption: Binding<Bool>?
    let onAdLoaded: ((Bool) -> Void)?
    let onDismiss: (() -> Void)?
    var isCollapsible: Bool
    @State private var adSize: CGSize = .zero
    @StateObject private var viewModel = AdsNativeViewModel()

    // Fullscreen native ad: countdown + close button
    @State private var isFullscreenAdClosed: Bool = false
    @State private var fullscreenCountdownSeconds: Int = 6
    @State private var isFullscreenCloseVisible: Bool = false
    @State private var hasStartedFullscreenCountdown: Bool = false
    @State private var fullscreenCountdownTimer: Timer?
    
    private var background: Color = .white
    private var layoutType: NativeAdLayoutType = .mediumWithMedia
    private var adChoicesPosition: AdChoicesPosition = .topRight
    private var adViewCornerRadius: CGFloat = 8
    private var headlineStyle: HeadlineStyle = HeadlineStyle()
    private var bodyStyle: BodyStyle = BodyStyle()
    private var adBadgeStyle: AdBadgeStyle = AdBadgeStyle()
    private var callActionStyle: CallActionStyle = CallActionStyle()
    private var iconSize: CGSize = CGSize(width: Utils.dp(48) , height: Utils.dp(48))
    private var mediaSize: CGSize = CGSize(width: Utils.dp(152), height: Utils.dp(180))
    private var borderWidth: CGFloat = 0
    private var borderColor: Color = .clear
    private var adUnitId: String
    private var refreshTimeInSeconds: Double 
    private var enableAutoRefresh: Bool
    private var currentScreen: String
    
    public init(adUnitId: String, isSelectOption: Binding<Bool>? = nil, collapsible: Bool = false, 
    currentScreen: String = "", onAdLoaded: ((Bool) -> Void)? = nil, onDismiss: (() -> Void)? = nil, refreshTimeInSeconds: Double = 30, enableAutoRefresh: Bool = false) {
        self.adUnitId = adUnitId
        self.isSelectOption = isSelectOption
        self.onAdLoaded = onAdLoaded
        self.isCollapsible = collapsible
        self.onDismiss = onDismiss
        self.refreshTimeInSeconds = refreshTimeInSeconds
        self.enableAutoRefresh = enableAutoRefresh
        self.currentScreen = currentScreen
    }
    
    private var configuration: NativeAdConfiguration {
        let effectiveBackground: Color = layoutType == .fullscreenVideo ? .clear : background
        let effectiveCornerRadius: CGFloat = layoutType == .fullscreenVideo ? 0 : adViewCornerRadius
        return NativeAdConfiguration(
            adChoicesPosition: adChoicesPosition,
            background: effectiveBackground,
            adViewCornerRadius: effectiveCornerRadius,
            iconSize: iconSize,
            layoutType: layoutType,
            adBadgeStyle: adBadgeStyle,
            headlineStyle: headlineStyle,
            bodyStyle: bodyStyle,
            callActionStyle: callActionStyle,
            mediaSize: mediaSize
        )
    }
    
    public var body: some View {
        ZStack {
            if !isFullscreenAdClosed {
                if viewModel.isLoading && !(layoutType == .collapsible || layoutType == .collapsible4 || layoutType == .collapsible3 || layoutType == .collapsible2) {
                } else if let nativeAd = viewModel.nativeAd,
                          let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let rootViewController = windowScene.windows.first?.rootViewController {
                    NativeAdViewRepresentable(
                        nativeAd: nativeAd,
                        viewController: rootViewController,
                        configuration: configuration,
                        layoutType: configuration.layoutType,
                        isSelectOption: isSelectOption,
                        onSizeChange: { newSize in
                            print("HOT HOT ON SIZE CHAGE : \(newSize)")
                            adSize = newSize
                        }
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: layoutType == .fullscreenVideo ? UIScreen.main.bounds.height : 0,
                        maxHeight: layoutType == .fullscreenVideo ? UIScreen.main.bounds.height : (((layoutType == .mediumWithMedia2) && !isCollapsible) ? adSize.height : viewModel.adHeight)
                    )
                    .background(configuration.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: configuration.adViewCornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                    .overlay(
                        ZStack(){
                            if layoutType == .fullscreenVideo {
                                VStack {
                                    HStack {
                                        Spacer()
                                        if !isFullscreenCloseVisible {
                                            Text("\(fullscreenCountdownSeconds) seconds remaining")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, Utils.dp(12))
                                                .padding(.vertical, Utils.dp(8))
                                                .background(Color.black.opacity(0.35))
                                                .clipShape(RoundedRectangle(cornerRadius: Utils.dp(100)))
                                                .padding(.top, Utils.dp(24))
                                                .padding(.trailing, Utils.dp(16))
                                        } else {
                                            Button {
                                                viewModel.adHeight = 0
                                                isFullscreenAdClosed = true
                                                fullscreenCountdownTimer?.invalidate()
                                                fullscreenCountdownTimer = nil
                                                viewModel.cleanup()
                                                onDismiss?()
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .resizable()
                                                    .frame(width: Utils.dp(28), height: Utils.dp(28))
                                                    .foregroundColor(.white)
                                                    .shadow(color: .black.opacity(0.2), radius: Utils.dp(4), x: 0, y: Utils.dp(2))
                                                    .padding(.top, Utils.dp(18))
                                                    .padding(.trailing, Utils.dp(14))
                                            }
                                        }
                                    }
                                    .padding(.top, Utils.dp(40))
                                    Spacer()
                                }
                            } else {
                                if isCollapsible == true {
                                    Button(action: {
                                        viewModel.adHeight = 0
                                        onDismiss?()
                                    }) {
                                        Image(systemName: "chevron.down.circle.fill")
                                            .resizable()
                                            .frame(width: Utils.dp(24), height: Utils.dp(24))
                                            .foregroundColor(.gray.opacity(0.8))
                                            .padding(Utils.dp(8))
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    .padding(.trailing, Utils.dp(8))
                                    .padding(.top, Utils.dp(4))
                                }
                            }
                        }
                    )
                    .cornerRadius(configuration.adViewCornerRadius)
                }
            }
        }
        .onAppear {
            viewModel.isCollapsible = isCollapsible
            viewModel.isAppear = true
            viewModel.isAutoRefreshEnabled(isRefreshEnabled: enableAutoRefresh)
            viewModel.refreshTime(refreshTimeInSeconds: refreshTimeInSeconds)
            viewModel.setCurrentScreen(currentScreen)

            // Reset fullscreen countdown states
            if layoutType == .fullscreenVideo {
                isFullscreenAdClosed = false
                fullscreenCountdownSeconds = 8
                isFullscreenCloseVisible = false
                hasStartedFullscreenCountdown = false
                fullscreenCountdownTimer?.invalidate()
                fullscreenCountdownTimer = nil
            }
            if viewModel.shouldLoadOnAppear {
                viewModel.loadNativeAd(adUnitId: adUnitId,
                                       layoutType: layoutType,
                                       configuration: configuration,
                                       isCollapsible: isCollapsible,
                                       onAdLoaded: onAdLoaded)
            }
        }
        .onChange(of: viewModel.state) { newState in
            guard layoutType == .fullscreenVideo else { return }
            guard !hasStartedFullscreenCountdown else { return }
            if case .loaded = newState {
                hasStartedFullscreenCountdown = true
                fullscreenCountdownSeconds = 8
                isFullscreenCloseVisible = false

                fullscreenCountdownTimer?.invalidate()
                fullscreenCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    if fullscreenCountdownSeconds > 1 {
                        fullscreenCountdownSeconds -= 1
                    } else {
                        fullscreenCountdownSeconds = 0
                        timer.invalidate()
                        fullscreenCountdownTimer = nil
                        isFullscreenCloseVisible = true
                    }
                }
            }
        }
        .onDisappear {
            fullscreenCountdownTimer?.invalidate()
            fullscreenCountdownTimer = nil
            viewModel.isAppear = false
            viewModel.cleanup()
        }
    }
}

extension AdsNativeView {
    public func adBackground(_ color: Color) -> AdsNativeView {
        var view = self
        view.background = color
        return view
    }
    
    public func adLayoutType(_ type: NativeAdLayoutType) -> AdsNativeView {
        var view = self
        view.layoutType = type
        return view
    }
    
    public func adChoicesPosition(_ position: AdChoicesPosition) -> AdsNativeView {
        var view = self
        view.adChoicesPosition = position
        return view
    }
    
    public func adCornerRadius(_ radius: CGFloat) -> AdsNativeView {
        var view = self
        view.adViewCornerRadius = radius
        return view
    }
    
    public func adHeadlineStyle(_ style: HeadlineStyle) -> AdsNativeView {
        var view = self
        view.headlineStyle = style
        return view
    }
    
    public func adBodyStyle(_ style: BodyStyle) -> AdsNativeView {
        var view = self
        view.bodyStyle = style
        return view
    }
    
    public func adBadgeStyle(_ style: AdBadgeStyle) -> AdsNativeView {
        var view = self
        view.adBadgeStyle = style
        return view
    }
    
    public func adCallActionStyle(_ style: CallActionStyle) -> AdsNativeView {
        var view = self
        view.callActionStyle = style
        return view
    }
    
    public func adIconSize(_ size: CGSize) -> AdsNativeView {
        var view = self
        view.iconSize = size
        return view
    }
    
    public func adMediaSize(_ size: CGSize) -> AdsNativeView {
        var view = self
        view.mediaSize = size
        return view
    }
    
    public func adBorder(width: CGFloat, color: Color) -> AdsNativeView {
        var view = self
        view.borderWidth = width
        view.borderColor = color
        return view
    }
}

#Preview {
    AdsNativeView(adUnitId: "ca-app-pub-3940256099942544/2521693316")
                .adBackground(Color.white)
                .adLayoutType(.small3)
                .adBorder(width: 1, color: Color.black)
}
