import UIKit
import GoogleMobileAds

/// ColorPicker `NativeAdLargeType1`: CTA trên → icon + text → media dưới.
class MediumWithMediaCTAFirstNativeAdLayout: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        setupMediaView(nativeAdView: nativeAdView)

        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        let mediaView = nativeAdView.mediaView
        let badgeView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)

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
                callToActionView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(8)),
                callToActionView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(40)),
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-40)),
                callToActionView.heightAnchor.constraint(equalToConstant: configuration.callActionStyle.height)
            ])
        }

        if let iconView = iconView {
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = Utils.dp(8)
            iconView.clipsToBounds = true

            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(
                    equalTo: callToActionView?.bottomAnchor ?? nativeAdView.topAnchor,
                    constant: Utils.dp(8)
                ),
                iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(20)),
                iconView.widthAnchor.constraint(equalToConstant: max(configuration.iconSize.width, Utils.dp(51))),
                iconView.heightAnchor.constraint(equalToConstant: max(configuration.iconSize.height, Utils.dp(51)))
            ])
        }

        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.textColor = configuration.headlineStyle.textColor.toUIColor()
            headlineView.numberOfLines = max(configuration.headlineStyle.numberOfLines, 2)

            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.topAnchor.constraint(
                    equalTo: callToActionView?.bottomAnchor ?? nativeAdView.topAnchor,
                    constant: Utils.dp(8)
                ),
                headlineView.leadingAnchor.constraint(equalTo: iconView?.trailingAnchor ?? nativeAdView.leadingAnchor, constant: Utils.dp(16)),
                headlineView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-20))
            ])
        }

        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines

            bodyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyView.topAnchor.constraint(equalTo: headlineView?.bottomAnchor ?? nativeAdView.topAnchor, constant: Utils.dp(6)),
                bodyView.leadingAnchor.constraint(equalTo: iconView?.trailingAnchor ?? nativeAdView.leadingAnchor, constant: Utils.dp(16)),
                bodyView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-20))
            ])
        }

        if let mediaView = mediaView {
            mediaView.backgroundColor = configuration.background.toUIColor()
            mediaView.layer.cornerRadius = Utils.dp(10)
            mediaView.clipsToBounds = true
            mediaView.mediaContent = nativeAd.mediaContent

            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.topAnchor.constraint(equalTo: iconView?.bottomAnchor ?? nativeAdView.topAnchor, constant: Utils.dp(5)),
                mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(30)),
                mediaView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-30)),
                mediaView.heightAnchor.constraint(greaterThanOrEqualToConstant: max(Utils.dp(120), configuration.mediaSize.height)),
                mediaView.bottomAnchor.constraint(lessThanOrEqualTo: nativeAdView.bottomAnchor, constant: Utils.dp(-8))
            ])
        }

        badgeView.removeFromSuperview()
        nativeAdView.addSubview(badgeView)
        badgeView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badgeView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            badgeView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-16)),
            badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(25)),
            badgeView.heightAnchor.constraint(equalToConstant: Utils.dp(16))
        ])
    }
}
