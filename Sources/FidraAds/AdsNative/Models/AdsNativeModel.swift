//
//  AdsNativeModel.swift
//  FidraCore
//
//  Created by HoaTD on 28/2/25.
//

import SwiftUI
import GoogleMobileAds

public struct AdNativeModel{
    public enum AdNativeTypeEnum: String {
        case large
        case medium
        case small
        case medium1
    }
    
    public enum CornerMask {
        case all
        case none
        case custom(CACornerMask)
        
        var maskValue: CACornerMask {
            switch self {
            case .all:
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            case .none:
                return []
            case .custom(let mask):
                return mask
            }
        }
    }
}

enum AdState: Equatable {
    case loading
    case loaded(ad: NativeAd)
    case failed
    case initial
}
