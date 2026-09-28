import UIKit
import GoogleMobileAds

/// ColorPicker `NativeAdWithoutImage`: CTA trên, headline + body, không icon/media.
class TextOnlyNativeAdLayout: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        let headlineLabel = UILabel()
        headlineLabel.numberOfLines = max(configuration.headlineStyle.numberOfLines, 2)
        headlineLabel.font = configuration.headlineStyle.font
        headlineLabel.textColor = configuration.headlineStyle.textColor.toUIColor()
        headlineLabel.textAlignment = configuration.headlineStyle.textAlignment
        headlineLabel.isUserInteractionEnabled = false
        headlineLabel.text = nativeAd.headline
        nativeAdView.headlineView = headlineLabel

        let bodyLabel = UILabel()
        bodyLabel.numberOfLines = configuration.bodyStyle.numberOfLines
        bodyLabel.font = configuration.bodyStyle.font
        bodyLabel.textColor = configuration.bodyStyle.textColor.toUIColor()
        bodyLabel.textAlignment = configuration.bodyStyle.textAlignment
        bodyLabel.isUserInteractionEnabled = false
        bodyLabel.text = nativeAd.body
        nativeAdView.bodyView = bodyLabel

        let callToActionButton = GradientNativeAdButton()
        callToActionButton.titleLabel?.font = configuration.callActionStyle.font
        callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
        callToActionButton.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
        callToActionButton.colors = configuration.callActionStyle.backgroundColor
        callToActionButton.layer.cornerRadius = min(
            configuration.callActionStyle.cornerRadius,
            configuration.callActionStyle.height / 2
        )
        callToActionButton.isUserInteractionEnabled = false
        nativeAdView.callToActionView = callToActionButton

        nativeAdView.iconView = nil
        nativeAdView.mediaView = nil

        nativeAdView.addSubview(headlineLabel)
        nativeAdView.addSubview(bodyLabel)
        nativeAdView.addSubview(callToActionButton)
        nativeAdView.isUserInteractionEnabled = true

        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        callToActionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            callToActionButton.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(20)),
            callToActionButton.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(8)),
            callToActionButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-8)),
            callToActionButton.heightAnchor.constraint(equalToConstant: max(configuration.callActionStyle.height, Utils.dp(44))),

            headlineLabel.topAnchor.constraint(equalTo: callToActionButton.bottomAnchor, constant: Utils.dp(8)),
            headlineLabel.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(20)),
            headlineLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-20)),

            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: Utils.dp(2)),
            bodyLabel.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(20)),
            bodyLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-20)),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: nativeAdView.bottomAnchor, constant: Utils.dp(-12))
        ])

        let badgeView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        badgeView.removeFromSuperview()
        nativeAdView.addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badgeView.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            badgeView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(-4)),
            badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(32)),
            badgeView.heightAnchor.constraint(equalToConstant: Utils.dp(18))
        ])
    }
}
