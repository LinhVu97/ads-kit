//
//  NativeLoadedBeforeDisplaying.swift
//  FidraAds
//
//  Created by HoaTD on 16/3/26.
//

import GoogleMobileAds
import SwiftUI

// Start of Selection
public struct NativeLoadedBeforeDisplaying: View {
    var isSelectOption: Binding<Bool>?
    let onDismiss: (() -> Void)?
    
    @ObservedObject var manager: CollapsiveManager
    
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
    
    public init(isSelectOption: Binding<Bool>? = nil,
                currentScreen: String = "", onDismiss: (() -> Void)? = nil, manager: CollapsiveManager = .init()) {
        self.isSelectOption = isSelectOption
        self.onDismiss = onDismiss
        self.manager = manager
    }
    
    private var configuration: NativeAdConfiguration {
        NativeAdConfiguration(
            adChoicesPosition: adChoicesPosition,
            background: background,
            adViewCornerRadius: adViewCornerRadius,
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
            if let nativeAd = manager.nativeAd,
                      let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController {
                NativeAdViewRepresentable(
                    nativeAd: nativeAd,
                    viewController: rootViewController,
                    configuration: configuration,
                    layoutType: configuration.layoutType,
                    isSelectOption: isSelectOption,
                    onSizeChange: nil,
                    collapsibleHeight: manager.adHeight
                )
                .frame(maxWidth: .infinity, minHeight: manager.adHeight > 0 ? manager.adHeight : 0, maxHeight: manager.adHeight)
                .id(manager.adHeight)
                .background(configuration.background)
                .overlay(
                    RoundedRectangle(cornerRadius: configuration.adViewCornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .overlay(
                    ZStack(){
                            Button(action: {
                                manager.adHeight = 0
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
                )
                .cornerRadius(configuration.adViewCornerRadius)
            }
        }
        .onAppear() {
            manager.setConfiguration(config: configuration)
        }
        
        
    }
}

extension NativeLoadedBeforeDisplaying {
    public func adBackground(_ color: Color) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.background = color
        return view
    }
    
    public func adLayoutType(_ type: NativeAdLayoutType) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.layoutType = type
        return view
    }
    
    public func adChoicesPosition(_ position: AdChoicesPosition) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.adChoicesPosition = position
        return view
    }
    
    public func adCornerRadius(_ radius: CGFloat) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.adViewCornerRadius = radius
        return view
    }
    
    public func adHeadlineStyle(_ style: HeadlineStyle) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.headlineStyle = style
        return view
    }
    
    public func adBodyStyle(_ style: BodyStyle) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.bodyStyle = style
        return view
    }
    
    public func adBadgeStyle(_ style: AdBadgeStyle) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.adBadgeStyle = style
        return view
    }
    
    public func adCallActionStyle(_ style: CallActionStyle) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.callActionStyle = style
        return view
    }
    
    public func adIconSize(_ size: CGSize) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.iconSize = size
        return view
    }
    
    public func adMediaSize(_ size: CGSize) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.mediaSize = size
        return view
    }
    
    public func adBorder(width: CGFloat, color: Color) -> NativeLoadedBeforeDisplaying {
        var view = self
        view.borderWidth = width
        view.borderColor = color
        return view
    }
}

