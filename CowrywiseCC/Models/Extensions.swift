//
//  Extensions.swift
//  CowrywiseCC
//
//  Created by Admin on 1/3/21.
//  Copyright © 2021 rapid interactive. All rights reserved.
//

import Foundation
import UIKit

enum FontStyle: String {
    case liuJianMaoCao = "LiuJianMaoCao-Regular"
}

extension UIFont {
     convenience init?(fontStyle: FontStyle, size: CGFloat) {
        self.init(name: fontStyle.rawValue, size: size)
    }
}
