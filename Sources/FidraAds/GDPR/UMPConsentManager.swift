//
//  UMPConsentManager.swift
//  FidraCore
//
//  Created by HoaTD on 5/3/25.
//

import SwiftUI
import UserMessagingPlatform

public class UMPConsentManager: ObservableObject {
    public static let shared = UMPConsentManager()
    
    @Published public private(set) var consentStatus: ConsentStatus = .unknown
    private let initialFormKey = "UMPConsentManager.initialFormShown"
    
    private init() {}
    
    public var hasShownInitialForm: Bool {
        UserDefaults.standard.bool(forKey: initialFormKey)
    }
    
    private func markInitialFormAsShown() {
        UserDefaults.standard.set(true, forKey: initialFormKey)
    }
    
    public func initialize(underAge: Bool = false, debugMode: Bool = false, completion: @escaping (Bool) -> Void) {
        
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = underAge
        
        if debugMode {
            let debugSettings = DebugSettings()
            debugSettings.geography = .EEA
            parameters.debugSettings = debugSettings
        }
        
        ConsentInformation.shared.requestConsentInfoUpdate(
            with: parameters,
            completionHandler: { [weak self] error in
                if let error = error {
                    print("UMP Error: \(error.localizedDescription)")
                    completion(true)
                    return
                }
                self?.updateConsentStatus()
                
                if self?.isCountryInEEA == true && self?.isConsentRequired == true {
                    UMPConsentManager.shared.showForm() { result in
                        switch result {
                        case .success:
                            if self?.canShowAds == false {
                                completion(false)
                                return
                            } else {
                                completion(true)
                            }
                        case .loadFailed, .presentFailed, .formClosed, .timeout:
                            completion(true)
                        }
                    }
                } else {
                    completion(true)
                }
            }
        )
    }
    
    public enum FormResult {
        case success
        case loadFailed(Error)
        case presentFailed(Error)
        case formClosed
        case timeout
    }

    public func showForm(complete: @escaping (FormResult) -> Void) {
        // Timeout sau 10 giây
        let timeoutInterval: TimeInterval = 10.0
        var didComplete = false
        
        // Thiết lập timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutInterval) {
            guard !didComplete else { return }
            didComplete = true
            complete(.timeout)
        }
        
        // Load form mới mỗi lần show
        ConsentForm.load { [weak self] form, loadError in
            // Đánh dấu hoàn tất để tránh gọi timeout
            guard !didComplete else { return }
            didComplete = true
            
            if let loadError = loadError {
                print("Form Load Error: \(loadError.localizedDescription)")
                complete(.loadFailed(loadError))
                return
            }
            
            guard let form = form else {
                complete(.formClosed)
                return
            }
            
            // Tìm root view controller để present
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                complete(.formClosed)
                return
            }
            
            // Present form
            form.present(
                from: rootViewController,
                completionHandler: { [weak self] presentError in
                    if let presentError = presentError {
                        print("Form Present Error: \(presentError.localizedDescription)")
                        complete(.presentFailed(presentError))
                        return
                    }
                    self?.markInitialFormAsShown()
                    self?.updateConsentStatus()
                    complete(.success)
                }
            )
        }
    }
    private func updateConsentStatus() {
        consentStatus = ConsentInformation.shared.consentStatus
    }
    
    public func reset() {
        ConsentInformation.shared.reset()
        consentStatus = .unknown
        UserDefaults.standard.removeObject(forKey: initialFormKey)
    }
    
    public var canShowAds: Bool {
        guard let purposeConsents = UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") else {
            return true
        }
        
        return !purposeConsents.contains("0")
    }
    
    public var isConsentRequired: Bool {
        consentStatus == .required
    }
    
    public var isCountryInEEA: Bool {
        guard let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String else {
            return false
        }
        let eeaCountries = "AT,BE,BG,HR,CY,CZ,DK,EE,FI,FR,DE,GR,HU,IE,IT,LV,LT,LU,MT,NL,PL,PT,RO,SK,SI,ES,SE,GB,IS,LI,NO"
        return eeaCountries.contains(countryCode)
    }
    
    public func handleCheckShowAdsF0(complete: @escaping (Bool) -> Void) {
        
    }
}
