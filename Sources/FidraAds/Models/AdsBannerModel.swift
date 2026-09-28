//
//  AdsBannerModel.swift
//  FidraCore
//
//  Created by HoaTD on 3/3/25.
//

public class AdsBannerModel {
    public enum AdsBannerStateEnum {
        case error
        case loading
        case loaded
    }
    
    public enum AdsBannerTypeEnum: String {
        case collapsible
        case largeBanner
        case adaptiveBanner
    }
}

public struct BannerConfig {
    public let adUnitID: String
    public let typeBannerAd: AdsBannerModel.AdsBannerTypeEnum
    public let positionBannerCollapse: String
    public let currentScreen: String
    public let isEnabledShowLoading: Bool
    public let handleShowLoading: (() -> ())?
}
