//
//  ApplicationColors.swift
//  Heart rate demo
//
//  Created by Pirush Prechathavanich on 9/18/18.
//  Copyright © 2018 nimbl3. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0,
                       green: CGFloat(green) / 255.0,
                       blue: CGFloat(blue) / 255.0,
                       alpha: alpha)
    }
    
    static let fusionRed: UIColor = .rgb(252, 92, 101)
    static let desire: UIColor = .rgb(235, 59, 90)
    
    static let orangeHibiscus: UIColor = .rgb(253, 150, 68)
    static let beniukonBronze: UIColor = .rgb(250, 130, 49)
    
    static let flirtatious: UIColor = .rgb(254, 211, 48)
    static let nycTaxi: UIColor = .rgb(247, 183, 49)
    
    static let reptileGreen: UIColor = .rgb(38, 222, 129)
    static let algalFuel: UIColor = .rgb(32, 191, 107)
    
    static let maximumBlueGreen: UIColor = .rgb(43, 203, 186)
    static let turquoiseTopaz: UIColor = .rgb(15, 185, 177)
    
    static let highBlue: UIColor = .rgb(69, 170, 242)
    static let boyzone: UIColor = .rgb(45, 152, 218)
    
    static let c64NTSC: UIColor = .rgb(75, 123, 236)
    static let royalBlue: UIColor = .rgb(56, 103, 214)
    
    static let lighterPurple: UIColor = .rgb(165, 94, 234)
    static let gloomyPurple: UIColor = .rgb(136, 84, 208)
    
    static let twinkleBlue: UIColor = .rgb(209, 216, 224)
    static let innuendo: UIColor = .rgb(165, 177, 194)
    
    static let blueGrey: UIColor = .rgb(119, 140, 163)
    static let blueHorizon: UIColor = .rgb(75, 101, 132)
    
}
