import UIKit
import GoogleMobileAds

class SmallNativeAdLayout2: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        let textView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        
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
                iconView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(15)),
                iconView.widthAnchor.constraint(equalToConstant: 48),
                iconView.heightAnchor.constraint(equalToConstant: 48)
            ])
        }
        
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = .systemFont(ofSize: 14, weight: .semibold)
            headlineView.numberOfLines = 1
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: (iconView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: 12),
                headlineView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(15)),
                headlineView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-12))
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
            textView.heightAnchor.constraint(equalToConstant: 14),
            textView.leadingAnchor.constraint(equalTo: (iconView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: 12),
            textView.topAnchor.constraint(equalTo: (headlineView?.bottomAnchor ?? nativeAdView.topAnchor), constant: 2)
        ])
        
        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = .systemFont(ofSize: 12)
            bodyView.textColor = .gray
            bodyView.numberOfLines = 2
            
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: (iconView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: 12),
                bodyView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
                bodyView.bottomAnchor.constraint(lessThanOrEqualTo: nativeAdView.bottomAnchor, constant: -12)
            ])
        }
        
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
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-6)),
                callToActionView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(6)),
                callToActionView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-11)),
                callToActionView.heightAnchor.constraint(equalToConstant: Utils.dp(36))
            ])
        }
    }
}
