import UIKit
import GoogleMobileAds

class CollapsibleNativeAdLayout4: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        let textView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
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
        
        let icUIView = UIView()
        nativeAdView.addSubview(icUIView)
        icUIView.backgroundColor = .gray.withAlphaComponent(0.3)
        icUIView.layer.cornerRadius = 8
        
        icUIView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icUIView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(12)),
            icUIView.topAnchor.constraint(equalTo: (mediaView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(12)),
            icUIView.widthAnchor.constraint(equalToConstant: configuration.iconSize.width),
            icUIView.heightAnchor.constraint(equalToConstant: configuration.iconSize.width)
        ])
        
        if let iconView = iconView {
            iconView.removeFromSuperview()
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = Utils.dp(8)
            iconView.clipsToBounds = true
            icUIView.addSubview(iconView)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: icUIView.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: icUIView.bottomAnchor),
                iconView.leadingAnchor.constraint(equalTo: icUIView.leadingAnchor),
                iconView.trailingAnchor.constraint(equalTo: icUIView.trailingAnchor)
            ])
        }
        
        textView.removeFromSuperview()
        nativeAdView.addSubview(textView)
        textView.text = configuration.adBadgeStyle.text
        textView.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        textView.textColor = configuration.adBadgeStyle.textColor.toUIColor()
        textView.backgroundColor = configuration.adBadgeStyle.backgroundColor.toUIColor()
        textView.clipsToBounds = true
        textView.isUserInteractionEnabled = false
        textView.textAlignment = .center
        textView.layer.cornerRadius = Utils.dp(4)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: icUIView.trailingAnchor, constant: Utils.dp(8)),
            textView.topAnchor.constraint(equalTo: (mediaView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(12))
        ])
        
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: icUIView.trailingAnchor, constant: Utils.dp(8)),
                headlineView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: Utils.dp(4)),
                headlineView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)),
                headlineView.heightAnchor.constraint(equalToConstant: 14)
            ])
        }
        
        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
            
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: icUIView.trailingAnchor, constant: Utils.dp(8)),
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
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(16)),
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)),
                callToActionView.heightAnchor.constraint(equalToConstant: configuration.callActionStyle.height),
                callToActionView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-16))
            ])
        }
    }
}
