//
//  BodyStyle.swift
//  FidraCore
//
//  Created by hi on 18/3/25.
//

import SwiftUI

public struct BodyStyle {
    public var numberOfLines: Int = 2
    public var font: UIFont? = UIFont.systemFont(ofSize: 10, weight: .regular)
    public var textColor: Color = .white.opacity(0.8)
    public var lineSpacing: CGFloat = 2
    public var truncationMode: NSLineBreakMode = .byTruncatingTail
    public var textAlignment: NSTextAlignment
    
    public init(
        numberOfLines: Int = 2,
        font: UIFont? = UIFont.systemFont(ofSize: 14, weight: .regular),
        textColor: Color = .white.opacity(0.8),
        lineSpacing: CGFloat = 2,
        truncationMode: NSLineBreakMode = .byTruncatingTail,
        textAlignment: NSTextAlignment = .justified
    ) {
        self.numberOfLines = numberOfLines
        self.font = font
        self.textColor = textColor
        self.lineSpacing = lineSpacing
        self.truncationMode = truncationMode
        self.textAlignment = textAlignment
    }
}
