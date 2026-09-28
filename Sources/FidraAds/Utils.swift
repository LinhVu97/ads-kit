//
//  Utils.swift
//  FidraAds
//
//  Created by Nguyen anh tuan on 11/8/25.
//

import Foundation
import SwiftUI

let Utils = UtilsFidraAds.shared

class UtilsFidraAds {
    
    public static var shared = UtilsFidraAds()
    
    private init() {
        
    }
    
    public func dp(_ size: CGFloat) -> CGFloat {
        return resizeNormal(size)
    }
    
    func resize(size: CGFloat = 0, multi: Float = 1.4) -> CGFloat {
        // Always use portrait width for consistent scaling regardless of orientation
        let screenBounds = UIScreen.main.bounds
        let portraitWidth = Swift.min(screenBounds.width, screenBounds.height)
        
        let referenceWidth: CGFloat
        let sizeR: CGFloat
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            referenceWidth = 834
            sizeR = size * CGFloat(multi)
        } else {
            referenceWidth = 375
            sizeR = size
        }
        
        return sizeR * (portraitWidth / referenceWidth)
    }
    
    func resizeNormal(_ size: CGFloat = 0, _ multi: Float = 1.4) -> CGFloat {
        return resize(size: size, multi: multi)
    }
}
