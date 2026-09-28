//
//  NativeCollapseResizingView.swift
//  FidraAds
//
//  Created by HoaTD on 17/3/26.
//

//
//  AdsNativeMedium1.swift
//  FidraCore
//
//  Created by HoaTD on 28/2/25.
//

import GoogleMobileAds
import SwiftUI

// Start of Selection
public struct NativeCollapseResizingView: View {
    var isSelectOption: Binding<Bool>?
    let onAdLoaded: ((Bool) -> Void)?
    let onDismiss: (() -> Void)?
    var isCollapsible: Bool
    @State private var adSize: CGSize = .zero
    @StateObject private var viewModel = NativeCollapseResizingViewModel()
    
    private var background: Color = .white
    private var layoutType: NativeAdLayoutType = .mediumWithMedia
    private var adChoicesPosition: AdChoicesPosition = .topRight
    private var adViewCornerRadius: CGFloat = 8
    private var headlineStyle: HeadlineStyle = HeadlineStyle()
    private var bodyStyle: BodyStyle = BodyStyle()
    private var adBadgeStyle: AdBadgeStyle = AdBadgeStyle()
    private var callActionStyle: CallActionStyle = CallActionStyle()
    private var iconSize: CGSize = CGSize(width: Utils.dp(48) , height: Utils.dp(48) )
    private var mediaSize: CGSize = CGSize(width: Utils.dp(152), height: Utils.dp(180))
    private var borderWidth: CGFloat = 0
    private var borderColor: Color = .clear
    private var adUnitId: String
    private var refreshTimeInSeconds: Double
    private var enableAutoRefresh: Bool
    private var currentScreen: String
    private var adsMediumType: NativeAdLayoutType?
    private var heightMediumAd: CGFloat
    
    public init(
        adUnitId: String,
        isSelectOption: Binding<Bool>? = nil,
        collapsible: Bool = false,
        currentScreen: String = "",
        onAdLoaded: ((Bool) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
        refreshTimeInSeconds: Double = 30,
        enableAutoRefresh: Bool = false,
        adsMediumType: NativeAdLayoutType? = nil,
        heightMediumAd: CGFloat = 130
    ) {
        self.adUnitId = adUnitId
        self.isSelectOption = isSelectOption
        self.onAdLoaded = onAdLoaded
        self.isCollapsible = collapsible
        self.onDismiss = onDismiss
        self.refreshTimeInSeconds = refreshTimeInSeconds
        self.enableAutoRefresh = enableAutoRefresh
        self.currentScreen = currentScreen
        self.adsMediumType = adsMediumType
        self.heightMediumAd = heightMediumAd
    }
    
    private var configuration: NativeAdConfiguration {
        NativeAdConfiguration(
            adChoicesPosition: adChoicesPosition,
            background: background,
            adViewCornerRadius: adViewCornerRadius,
            iconSize: iconSize,
            layoutType: viewModel.adsLayoutType,
            adBadgeStyle: adBadgeStyle,
            headlineStyle: headlineStyle,
            bodyStyle: bodyStyle,
            callActionStyle: callActionStyle,
            mediaSize: mediaSize
        )
    }
    
    public var body: some View {
        ZStack {
            if let nativeAd = viewModel.nativeAd,
                      let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController {
                NativeAdViewRepresentable(
                    nativeAd: nativeAd,
                    viewController: rootViewController,
                    configuration: configuration,
                    layoutType: viewModel.adsLayoutType,
                    isSelectOption: isSelectOption,
                    onSizeChange: { newSize in
                        print("HOT HOT ON SIZE CHAGE : \(newSize)")
                        adSize = newSize
                    },
                    collapsibleHeight: isCollapsible ? viewModel.adHeight : nil
                )
                .frame(maxWidth: .infinity, maxHeight: ((viewModel.adsLayoutType == .mediumWithMedia2) && !isCollapsible) ? adSize.height : viewModel.adHeight)
                .id(isCollapsible ? "\(viewModel.adsLayoutType)-\(Int(viewModel.adHeight))" : "static")
                .background(configuration.background)
                .overlay(
                    RoundedRectangle(cornerRadius: configuration.adViewCornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .overlay(
                    ZStack(){
                        if isCollapsible == true {
                            if !viewModel.isCollapsedIntoMedium {
                                Button(action: {
                                    if let adsMediumType = adsMediumType {
                                        viewModel.isCollapsedIntoMedium = true
                                        viewModel.adsLayoutType = adsMediumType
                                        viewModel.adHeight = heightMediumAd
                                    } else {
                                        viewModel.adHeight = 0
                                    }
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
        .onAppear {
            viewModel.adsLayoutType = layoutType
            viewModel.isCollapsible = isCollapsible
            viewModel.isCollapsedIntoMedium = false
            viewModel.isAppear = true
            viewModel.isAutoRefreshEnabled(isRefreshEnabled: enableAutoRefresh)
            viewModel.refreshTime(refreshTimeInSeconds: refreshTimeInSeconds)
            viewModel.setCurrentScreen(currentScreen)
            if viewModel.shouldLoadOnAppear {
                viewModel.loadNativeAd(adUnitId: adUnitId,
                                       layoutType: layoutType,
                                       configuration: configuration,
                                       isCollapsible: isCollapsible,
                                       onAdLoaded: onAdLoaded)
            }
        }.onDisappear {
            viewModel.isAppear = false
            viewModel.cleanup()
        }
    }
}

extension NativeCollapseResizingView {
    public func adBackground(_ color: Color) -> NativeCollapseResizingView {
        var view = self
        view.background = color
        return view
    }
    
    public func adLayoutType(_ type: NativeAdLayoutType) -> NativeCollapseResizingView {
        var view = self
        view.layoutType = type
        return view
    }
    
    public func adChoicesPosition(_ position: AdChoicesPosition) -> NativeCollapseResizingView {
        var view = self
        view.adChoicesPosition = position
        return view
    }
    
    public func adCornerRadius(_ radius: CGFloat) -> NativeCollapseResizingView {
        var view = self
        view.adViewCornerRadius = radius
        return view
    }
    
    public func adHeadlineStyle(_ style: HeadlineStyle) -> NativeCollapseResizingView {
        var view = self
        view.headlineStyle = style
        return view
    }
    
    public func adBodyStyle(_ style: BodyStyle) -> NativeCollapseResizingView {
        var view = self
        view.bodyStyle = style
        return view
    }
    
    public func adBadgeStyle(_ style: AdBadgeStyle) -> NativeCollapseResizingView {
        var view = self
        view.adBadgeStyle = style
        return view
    }
    
    public func adCallActionStyle(_ style: CallActionStyle) -> NativeCollapseResizingView {
        var view = self
        view.callActionStyle = style
        return view
    }
    
    public func adIconSize(_ size: CGSize) -> NativeCollapseResizingView {
        var view = self
        view.iconSize = size
        return view
    }
    
    public func adMediaSize(_ size: CGSize) -> NativeCollapseResizingView {
        var view = self
        view.mediaSize = size
        return view
    }
    
    public func adBorder(width: CGFloat, color: Color) -> NativeCollapseResizingView {
        var view = self
        view.borderWidth = width
        view.borderColor = color
        return view
    }
}

