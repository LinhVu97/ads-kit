import UIKit
import GoogleMobileAds

class SmallNativeAdLayout6: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        let textView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        
        let headlineView = nativeAdView.headlineView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        
        textView.removeFromSuperview()
        nativeAdView.addSubview(textView)
        textView.text = configuration.adBadgeStyle.text
        textView.font = configuration.adBadgeStyle.font
        textView.textColor = configuration.adBadgeStyle.textColor.toUIColor()
        textView.backgroundColor = configuration.adBadgeStyle.backgroundColor.toUIColor()
        textView.clipsToBounds = true
        textView.isUserInteractionEnabled = false
        textView.textAlignment = .center
        textView.layer.cornerRadius = Utils.dp(configuration.adBadgeStyle.cornerRadius)
        textView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(20)),
            textView.heightAnchor.constraint(equalToConstant: Utils.dp(13)),
            textView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            textView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 2)
        ])
        
        if let callToActionView = callToActionView {
            let title = (nativeAd.callToAction?.prefix(1).uppercased() ?? "") + (nativeAd.callToAction?.dropFirst().lowercased() ?? "")
            callToActionView.setTitle(title, for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = .black
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2)
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)),
                callToActionView.heightAnchor.constraint(equalToConstant: Utils.dp(configuration.callActionStyle.height)),
                callToActionView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(16)),
                callToActionView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(16))
            ])
        }
        
        if let headlineView = headlineView, let callToActionView = callToActionView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            headlineView.textColor = configuration.headlineStyle.textColor.toUIColor()
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.topAnchor.constraint(equalTo: callToActionView.bottomAnchor, constant: 6),
                headlineView.leadingAnchor.constraint(equalTo: callToActionView.leadingAnchor, constant: Utils.dp(10)),
                headlineView.trailingAnchor.constraint(equalTo: callToActionView.trailingAnchor, constant: Utils.dp(-10))
            ])
        }
    }
}
