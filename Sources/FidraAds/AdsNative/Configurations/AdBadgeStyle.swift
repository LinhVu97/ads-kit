import SwiftUI

public struct AdBadgeStyle {
    public var text: String = "Ad"
    public var font: UIFont? =  UIFont.systemFont(ofSize: 12, weight: .medium)
    public var textColor: Color = .white
    public var backgroundColor: Color = .white.opacity(0.3)
    public var cornerRadius: CGFloat = 4
    public var padding: EdgeInsets = .init(top: 2, leading: 6, bottom: 2, trailing: 6)
    public var position: AdBadgePosition = .topRight
    public var margin: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    public init(
        text: String = "Ad",
        font: UIFont? = UIFont.systemFont(ofSize: 12, weight: .medium),
        textColor: Color = .white,
        backgroundColor: Color = .white.opacity(0.3),
        cornerRadius: CGFloat = 4,
        padding: EdgeInsets = .init(top: 2, leading: 6, bottom: 2, trailing: 6),
        position: AdBadgePosition = .topRight,
        margin: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.position = position
        self.margin = margin
    }
}
