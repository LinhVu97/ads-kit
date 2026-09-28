import UIKit
import GoogleMobileAds

class SmallNativeAdLayout3: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        _ = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        
        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        
        if let iconView = iconView {
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = 8
            iconView.clipsToBounds = true
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(6)),
                iconView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(6)),
                iconView.widthAnchor.constraint(equalToConstant: configuration.iconSize.width),
                iconView.heightAnchor.constraint(equalToConstant: configuration.iconSize.width)
            ])
        }
        
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.textColor = configuration.headlineStyle.textColor.toUIColor()
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: (iconView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: 12),
                headlineView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(6)),
                headlineView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-12))
            ])
        }
        
        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
            
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: (iconView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(12)),
                bodyView.topAnchor.constraint(equalTo: (headlineView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(5)),
                bodyView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-12)),
                bodyView.bottomAnchor.constraint(lessThanOrEqualTo: nativeAdView.bottomAnchor, constant: Utils.dp(-6))
            ])
        }
        
        if let callToActionView = callToActionView {
            let title = (nativeAd.callToAction?.prefix(1).uppercased() ?? "") + (nativeAd.callToAction?.dropFirst().lowercased() ?? "")
            callToActionView.setTitle(title, for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = configuration.callActionStyle.textColor.toUIColor()
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2)
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-6)),
                callToActionView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(6)),
                callToActionView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-11)),
                callToActionView.heightAnchor.constraint(equalToConstant: configuration.callActionStyle.height)
            ])
        }
    }
}
