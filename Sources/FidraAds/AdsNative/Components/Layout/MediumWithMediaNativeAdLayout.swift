import UIKit
import GoogleMobileAds

class MediumWithMediaNativeAdLayout: NativeAdLayoutBuilder {
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
            mediaView.layer.cornerRadius = Utils.dp(8)
            mediaView.clipsToBounds = true
            mediaView.mediaContent = nativeAd.mediaContent
            
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(12)),
                mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(16)),
                mediaView.widthAnchor.constraint(equalToConstant: max(Utils.dp(120), configuration.mediaSize.width)),
                mediaView.heightAnchor.constraint(equalToConstant: max(Utils.dp(120), configuration.mediaSize.height))
            ])
        }
        
        if let iconView = iconView {
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = Utils.dp(8)
            iconView.clipsToBounds = true
            
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: (mediaView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(8)),
                iconView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(12)),
                iconView.widthAnchor.constraint(equalToConstant: configuration.iconSize.width),
                iconView.heightAnchor.constraint(equalToConstant: configuration.iconSize.width)
            ])
        }
        
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: (mediaView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(8)),
                headlineView.topAnchor.constraint(equalTo: (iconView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(8)),
                headlineView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16))
            ])
        }
        
        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
            
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: (mediaView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(8)),
                bodyView.topAnchor.constraint(equalTo: (headlineView?.bottomAnchor ?? nativeAdView.topAnchor), constant: 0),
                bodyView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16))
            ])
        }
        
        if let callToActionView = callToActionView {
            callToActionView.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = configuration.callActionStyle.textColor.toUIColor()
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(16)),
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)),
                callToActionView.topAnchor.constraint(equalTo: (mediaView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(8)),
                callToActionView.heightAnchor.constraint(equalToConstant: Utils.dp(42)),
                callToActionView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-12))
            ])
        }
    }
}
