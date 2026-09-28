//
//  HeadlineStyle.swift
//  FidraCore
//
//  Created by hi on 18/3/25.
//

import SwiftUI

public struct HeadlineStyle {
    public var numberOfLines: Int = 1
    public var font: UIFont? = UIFont.systemFont(ofSize: 12, weight: .bold)
    public var textColor: Color = .black
    public var lineSpacing: CGFloat = 0
    public var truncationMode: NSLineBreakMode = .byTruncatingTail
    public var textAlignment: NSTextAlignment
    
    public init(
        numberOfLines: Int = 1,
        font: UIFont? = UIFont.systemFont(ofSize: 16, weight: .bold),
        textColor: Color = .black,
        lineSpacing: CGFloat = 0,
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
