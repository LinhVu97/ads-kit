import UIKit
import GoogleMobileAds

class MediumWithMediaNativeAdLayout3: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        setupMediaView(nativeAdView: nativeAdView)
        let textView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        
        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        let mediaView = nativeAdView.mediaView
        
        if let mediaView = mediaView {
            mediaView.layer.cornerRadius = 8
            mediaView.clipsToBounds = true
            mediaView.mediaContent = nativeAd.mediaContent
            
            if !nativeAd.mediaContent.hasVideoContent {
                mediaView.contentMode = .scaleAspectFit
                mediaView.clipsToBounds = true
            }
            
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
                mediaView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),
                mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
                mediaView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor)
            ])
        }
        
        let uiView = UIView()
        uiView.backgroundColor = .black.withAlphaComponent(0.5)
        uiView.layer.cornerRadius = 12
        nativeAdView.addSubview(uiView)
        
        uiView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uiView.heightAnchor.constraint(equalToConstant: Utils.dp(74)),
            uiView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -Utils.dp(12)),
            uiView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(12)),
            uiView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -Utils.dp(12))
        ])
        
        if let iconView = iconView {
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = 8
            iconView.clipsToBounds = true
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(12)),
                iconView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(12)),
                iconView.widthAnchor.constraint(equalToConstant: configuration.iconSize.width),
                iconView.heightAnchor.constraint(equalToConstant: configuration.iconSize.width)
            ])
        }
        
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            uiView.addSubview(headlineView)
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor, constant: Utils.dp(10)),
                headlineView.topAnchor.constraint(equalTo: uiView.topAnchor, constant: Utils.dp(6)),
                headlineView.heightAnchor.constraint(equalToConstant: Utils.dp(34)),
                headlineView.widthAnchor.constraint(equalToConstant: Utils.dp(202))
            ])
        }
        
        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
            uiView.addSubview(bodyView)
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            var bodyConstraints: [NSLayoutConstraint] = [
                bodyView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor, constant: Utils.dp(10)),
                bodyView.heightAnchor.constraint(equalToConstant: Utils.dp(28)),
                bodyView.widthAnchor.constraint(equalToConstant: Utils.dp(202))
            ]
            if let headlineView = headlineView {
                bodyConstraints.append(bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 0))
            } else {
                bodyConstraints.append(bodyView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor, constant: Utils.dp(6)))
            }
            NSLayoutConstraint.activate(bodyConstraints)
        }
        
        if let callToActionView = callToActionView {
            callToActionView.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = configuration.callActionStyle.textColor.toUIColor()
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2)
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            uiView.addSubview(callToActionView)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor, constant: Utils.dp(-10)),
                callToActionView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor, constant: Utils.dp(-6)),
                callToActionView.heightAnchor.constraint(equalToConstant: Utils.dp(22)),
                callToActionView.widthAnchor.constraint(equalToConstant: Utils.dp(77))
            ])
        }
        
        textView.removeFromSuperview()
        nativeAdView.addSubview(textView)
        textView.text = configuration.adBadgeStyle.text
        textView.font = configuration.adBadgeStyle.font
        textView.textColor = configuration.adBadgeStyle.textColor.toUIColor()
        textView.backgroundColor = configuration.adBadgeStyle.backgroundColor.toUIColor()
        textView.clipsToBounds = true
        textView.isUserInteractionEnabled = false
        textView.textAlignment = .center
        textView.clipsToBounds = true
        textView.layer.cornerRadius = Utils.dp(4)
        textView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(20)),
            textView.heightAnchor.constraint(equalToConstant: Utils.dp(13)),
            textView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(10))
        ])
    }
}
