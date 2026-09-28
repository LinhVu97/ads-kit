import UIKit
import GoogleMobileAds

/// ColorPicker `NativeAdSmallCustomView`: icon trái, badge + text giữa, CTA phải.
class SmallCompactNativeAdLayout: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)

        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        let badgeView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)

        nativeAdView.mediaView = nil

        if let iconView = iconView {
            iconView.image = nativeAd.icon?.image
            iconView.backgroundColor = configuration.background.toUIColor()
            iconView.layer.cornerRadius = Utils.dp(7)
            iconView.clipsToBounds = true

            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(4)),
                iconView.centerYAnchor.constraint(equalTo: nativeAdView.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: max(configuration.iconSize.width, Utils.dp(63))),
                iconView.heightAnchor.constraint(equalToConstant: max(configuration.iconSize.height, Utils.dp(56)))
            ])
        }

        badgeView.removeFromSuperview()
        nativeAdView.addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badgeView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(10)),
            badgeView.leadingAnchor.constraint(equalTo: iconView?.trailingAnchor ?? nativeAdView.leadingAnchor, constant: Utils.dp(8)),
            badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(20)),
            badgeView.heightAnchor.constraint(equalToConstant: Utils.dp(16))
        ])

        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.textColor = configuration.headlineStyle.textColor.toUIColor()
            headlineView.numberOfLines = max(configuration.headlineStyle.numberOfLines, 2)

            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(10)),
                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: Utils.dp(6)),
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
                bodyView.topAnchor.constraint(equalTo: headlineView?.bottomAnchor ?? nativeAdView.topAnchor, constant: Utils.dp(4)),
                bodyView.leadingAnchor.constraint(equalTo: iconView?.trailingAnchor ?? nativeAdView.leadingAnchor, constant: Utils.dp(8))
            ])
        }

        if let callToActionView = callToActionView {
            callToActionView.setTitle(nativeAd.callToAction, for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(
                configuration.callActionStyle.cornerRadius,
                configuration.callActionStyle.height / 2
            )

            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.topAnchor.constraint(equalTo: headlineView?.bottomAnchor ?? nativeAdView.topAnchor, constant: Utils.dp(4)),
                callToActionView.leadingAnchor.constraint(equalTo: bodyView?.trailingAnchor ?? nativeAdView.leadingAnchor, constant: Utils.dp(4)),
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-8)),
                callToActionView.widthAnchor.constraint(equalToConstant: Utils.dp(98)),
                callToActionView.heightAnchor.constraint(equalToConstant: max(configuration.callActionStyle.height, Utils.dp(28))),
                callToActionView.bottomAnchor.constraint(lessThanOrEqualTo: nativeAdView.bottomAnchor, constant: Utils.dp(-8))
            ])
        }
    }
}
