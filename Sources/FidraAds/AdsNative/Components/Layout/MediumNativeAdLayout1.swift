import UIKit
import GoogleMobileAds

class MediumNativeAdLayout1: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        let textView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        setupMediaView(nativeAdView: nativeAdView)
        
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        let mediaView = nativeAdView.mediaView
        
        if let mediaView = mediaView {
            mediaView.layer.cornerRadius = 4
            mediaView.clipsToBounds = true
            mediaView.mediaContent = nativeAd.mediaContent
            
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            var mediaConstraints = [
                mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 4),
                mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 6),
                mediaView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -4),
                mediaView.widthAnchor.constraint(equalToConstant: max(120, 0))
            ]

            if nativeAd.mediaContent.aspectRatio > 0 {
                mediaConstraints.append(
                    mediaView.heightAnchor.constraint(equalToConstant: 120 * (1 / nativeAd.mediaContent.aspectRatio))
                )
            }
            NSLayoutConstraint.activate(mediaConstraints)
            
            mediaView.contentMode = .scaleAspectFill
            mediaView.clipsToBounds = true
        }
        
        if let callToActionView = callToActionView {
            callToActionView.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = .black
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = 16
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
                callToActionView.heightAnchor.constraint(equalToConstant: 28),
                callToActionView.widthAnchor.constraint(equalToConstant: 88),
                callToActionView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 20)
            ])
        }
        
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.textAlignment = .left
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: (mediaView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: 12),
                headlineView.topAnchor.constraint(equalTo: (callToActionView?.bottomAnchor ?? nativeAdView.topAnchor), constant: 18),
                headlineView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16)
            ])
        }
        
        textView.removeFromSuperview()
        nativeAdView.addSubview(textView)
        textView.text = configuration.adBadgeStyle.text
        textView.font = configuration.adBadgeStyle.font
        textView.textColor = configuration.adBadgeStyle.textColor.toUIColor()
        textView.backgroundColor = configuration.adBadgeStyle.backgroundColor.toUIColor()
        textView.layer.cornerRadius = configuration.adBadgeStyle.cornerRadius
        textView.clipsToBounds = true
        textView.isUserInteractionEnabled = false
        textView.textAlignment = .center
        textView.layoutMargins = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)

        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: 18),
            textView.heightAnchor.constraint(equalToConstant: 12),
            textView.leadingAnchor.constraint(equalTo: (mediaView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: 12),
            textView.topAnchor.constraint(equalTo: (headlineView?.bottomAnchor ?? nativeAdView.topAnchor), constant: 4)
        ])
        
        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.textAlignment = .left
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
            
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: (mediaView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: 12),
                bodyView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
                bodyView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
                bodyView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -16)
            ])
        }
    }
}



class MediumNativeAdLayout2: NativeAdLayoutBuilder {
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
            mediaView.layer.cornerRadius = Utils.dp(0)
            mediaView.clipsToBounds = true
            mediaView.mediaContent = nativeAd.mediaContent
            mediaView.contentMode = .scaleAspectFill
         
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(12)),
                mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(20)),
                mediaView.widthAnchor.constraint(equalToConstant: max(Utils.dp(120), configuration.mediaSize.width)),
                mediaView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-16))
            ])
        }
        
        if let iconView = iconView {
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = Utils.dp(8)
            iconView.clipsToBounds = true
            iconView.contentMode = .scaleAspectFill
            
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: (mediaView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(8)),
                iconView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(20)),
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
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.heightAnchor.constraint(equalToConstant: configuration.callActionStyle.height),
                callToActionView.leadingAnchor.constraint(equalTo: (mediaView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(8)),
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)),
                callToActionView.topAnchor.constraint(greaterThanOrEqualTo: (bodyView?.bottomAnchor ?? nativeAdView.topAnchor), constant: Utils.dp(8)),
                callToActionView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-16))
            ])
        }
    }
}
