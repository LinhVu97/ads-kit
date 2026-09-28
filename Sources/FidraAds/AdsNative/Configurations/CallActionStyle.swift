//
//  CallActionStyle.swift
//  FidraCore
//
//  Created by hi on 18/3/25.
//

import SwiftUI

public struct CallActionStyle {
    public var font: UIFont?
    public var textColor: Color
    public var backgroundColor: [CGColor]
    public var cornerRadius: CGFloat
    public var height: CGFloat
    public var padding: EdgeInsets
    public var backgroundColorActive: [CGColor]
    
    public var borderColor: Color
    public var borderWidth: CGFloat
    
    public init(
        font: UIFont? = UIFont.systemFont(ofSize: 14, weight: .bold),
        textColor: Color = .black,
        backgroundColor: [Color] = [.red, .red],
        cornerRadius: CGFloat = 4,
        height: CGFloat = 48,
        padding: EdgeInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16),
        backgroundColorActive: [Color] = [.red, .red],
        borderColor: Color = .clear,
        borderWidth: CGFloat = 2.0
    ) {
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor.map { $0.toUIColor().cgColor }
        self.cornerRadius = cornerRadius
        self.height = height
        self.padding = padding
        self.backgroundColorActive = backgroundColorActive.map { $0.toUIColor().cgColor }
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}
