import UIKit
import GoogleMobileAds

class CollapsibleNativeAdLayout2: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        _ = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        setupMediaView(nativeAdView: nativeAdView)
        
        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        let mediaView = nativeAdView.mediaView
        
        if let mediaView = mediaView {
            mediaView.mediaContent = nativeAd.mediaContent
            mediaView.layer.cornerRadius = Utils.dp(8)
            mediaView.contentMode = .scaleAspectFit
            mediaView.clipsToBounds = true
            
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(8)),
                mediaView.centerXAnchor.constraint(equalTo: nativeAdView.centerXAnchor),
                mediaView.widthAnchor.constraint(equalToConstant: max(120, configuration.mediaSize.width)),
                mediaView.heightAnchor.constraint(equalToConstant: Utils.dp(190))
            ])
        }
        
        if let iconView = iconView {
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = Utils.dp(8)
            iconView.clipsToBounds = true
            
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(12)),
                iconView.topAnchor.constraint(equalTo: (mediaView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(12)),
                iconView.widthAnchor.constraint(equalToConstant: configuration.iconSize.width),
                iconView.heightAnchor.constraint(equalToConstant: configuration.iconSize.width),
                iconView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-12))
            ])
        }
        
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: (iconView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(8)),
                headlineView.topAnchor.constraint(equalTo: (mediaView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(14)),
                headlineView.trailingAnchor.constraint(equalTo: (callToActionView?.leadingAnchor ?? nativeAdView.trailingAnchor), constant: -12)
            ])
        }
        
        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
            
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: (iconView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(8)),
                bodyView.topAnchor.constraint(equalTo: (headlineView?.bottomAnchor ?? nativeAdView.topAnchor), constant: 0),
                bodyView.trailingAnchor.constraint(equalTo: (callToActionView?.leadingAnchor ?? nativeAdView.trailingAnchor), constant: -12)
            ])
        }
        
        if let callToActionView = callToActionView {
            callToActionView.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = configuration.callActionStyle.textColor.toUIColor()
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2)
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.leadingAnchor.constraint(equalTo: (headlineView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(8)),
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
                callToActionView.topAnchor.constraint(equalTo: (mediaView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(14)),
                callToActionView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(96)),
                callToActionView.heightAnchor.constraint(equalToConstant: configuration.callActionStyle.height)
            ])
        }
    }
}
