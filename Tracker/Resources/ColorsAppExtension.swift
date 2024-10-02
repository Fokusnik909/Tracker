//
//  Colors.swift
//  Tracker
//
//  Created by Артур  Арсланов on 06.07.2024.
//

import UIKit

extension UIColor {
    
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static var ypBackground: UIColor { UIColor(named: "BackgroundYp") ?? UIColor.darkGray }
    static var ypBlack: UIColor { UIColor(named: "BlackYp") ?? UIColor.black}
    static var ypBlue: UIColor { UIColor(named: "BlueYp") ?? UIColor.blue }
    static var ypGray: UIColor { UIColor(named: "GrayYp") ?? UIColor.gray }
    static var ypLightGray: UIColor { UIColor(named: "LightGrayYp") ?? UIColor.lightGray}
    static var ypRed: UIColor { UIColor(named: "RedYp") ?? UIColor.red }
    static var ypWhite: UIColor { UIColor(named: "WhiteYp") ?? UIColor.white}
    static var ypPickerColor: UIColor { UIColor(named: "dataPickerColor") ?? UIColor.gray}
    
    
    func randomColor() -> UIColor {
        let randomRed = CGFloat.random(in: 0...1)
        let randomGreen = CGFloat.random(in: 0...1)
        let randomBlue = CGFloat.random(in: 0...1)
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
}
