//
//  Colors.swift
//  Tracker
//
//  Created by Артур  Арсланов on 06.07.2024.
//

import UIKit

extension UIColor {
    static var ypBackground: UIColor { UIColor(named: "BackgroundYp") ?? UIColor.darkGray }
    static var ypBlack: UIColor { UIColor(named: "BlackYp") ?? UIColor.black}
    static var ypBlue: UIColor { UIColor(named: "BlueYp") ?? UIColor.blue }
    static var ypGray: UIColor { UIColor(named: "GrayYp") ?? UIColor.gray }
    static var ypLightGray: UIColor { UIColor(named: "LightGrayYp") ?? UIColor.lightGray}
    static var ypRed: UIColor { UIColor(named: "RedYp") ?? UIColor.red }
    static var ypWhite: UIColor { UIColor(named: "WhiteYp") ?? UIColor.white}
    
    
    func randomColor() -> UIColor {
        let randomRed = CGFloat.random(in: 0...1)
        let randomGreen = CGFloat.random(in: 0...1)
        let randomBlue = CGFloat.random(in: 0...1)
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
}
