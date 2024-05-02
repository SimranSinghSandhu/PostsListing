//
//  UIButton+EXT.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import UIKit

extension UIButton {
    func customBtnConfiguration(tintColor: UIColor, bgColor: UIColor, img: UIImage?, title: String, borderWidth: CGFloat = 0, buttonSize: UIButton.Configuration.Size = .large, imagePlacement: NSDirectionalRectEdge = .leading) {
        var config = Configuration.filled()
        config.baseForegroundColor = tintColor
        config.baseBackgroundColor = bgColor
        config.title = title
        config.buttonSize = buttonSize
        config.cornerStyle = .capsule
        config.image = img
        config.imagePadding = 5
        config.imagePlacement = imagePlacement
        self.configuration = config
    }
}
