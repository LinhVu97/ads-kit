//
//  UMPConsentModifier.swift
//  FidraCore
//
//  Created by HoaTD on 5/3/25.
//

import SwiftUI

public struct UMPConsentViewModifier: ViewModifier {
    @StateObject private var consentManager = UMPConsentManager.shared
    let underAge: Bool
    let debugMode: Bool
    
    public init(underAge: Bool = false, debugMode: Bool = false) {
        self.underAge = underAge
        self.debugMode = debugMode
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
//                consentManager.initialize(underAge: underAge, debugMode: debugMode)
            }
    }
}

public extension View {
    func umpConsent(underAge: Bool = false, debugMode: Bool = false) -> some View {
        modifier(UMPConsentViewModifier(underAge: underAge, debugMode: debugMode))
    }
}
