//
//  Extensions.swift
//  MDS-Yandex
//
//  Created by Adlet Zeineken on 18.02.2021.
//  Copyright © 2021 justadlet. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    func setImage(from url: URL?){
        self.sd_setImage(with: url, placeholderImage: UIImage(named: "AppIcon"), options: .refreshCached, context: nil)
    }
    
}

extension UIView {
    func addConstraint(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?,
                       centerXAnchor: NSLayoutXAxisAnchor?, centerYAnchor: NSLayoutYAxisAnchor?,
                       paddingTop: CGFloat = 0, paddingLeading: CGFloat = 0, paddingBottom: CGFloat = 0, paddingTrailing: CGFloat = 0,
                       width: CGFloat = 0, height: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: paddingTrailing).isActive = true
        }
        if let centerYTo = centerYAnchor {
            self.centerYAnchor.constraint(equalTo: centerYTo).isActive = true
        }
        if let centerXTo = centerXAnchor {
            self.centerXAnchor.constraint(equalTo: centerXTo).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UILabel {
    func addSpacing(value: Double = 3) {
        if let labelText = text, labelText.isEmpty == false {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(.kern,
                                          value: value,
                                          range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        return String(formatter.string(from: number) ?? "")
    }
}

extension UIButton {
    func edit(title: String, titleColor: UIColor, fontSize: CGFloat, weight: UIFont.Weight) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        setTitleColor(Color.black.withAlphaComponent(0.6), for: .highlighted)
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
    }
}

extension UIScrollView {
    func scrollTo(horizontalPage: Int? = 0, verticalPage: Int? = 0, animated: Bool? = true) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(horizontalPage ?? 0)
        frame.origin.y = frame.size.width * CGFloat(verticalPage ?? 0)
        self.scrollRectToVisible(frame, animated: animated ?? true)
    }
}

extension NSMutableAttributedString {
    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(
            .font,
            in: NSRange(location: 0, length: self.length)
        ) { (value, range, stop) in
            
            if let f = value as? UIFont,
                let newFontDescriptor = f.fontDescriptor
                    .withFamily(font.familyName)
                    .withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                
                let newFont = UIFont(
                    descriptor: newFontDescriptor,
                    size: font.pointSize
                )
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(
                        .foregroundColor,
                        range: range
                    )
                    addAttribute(
                        .foregroundColor,
                        value: color,
                        range: range
                    )
                }
            }
        }
        endEditing()
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func dictionaryValue() -> [String: AnyObject] {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject]
                return json!
                
            } catch {
                print("Error converting to JSON")
            }
        }
        return NSDictionary() as! [String : AnyObject]
    }
}

extension Dictionary {
    func jsonString() -> String {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String.init(data: jsonData, encoding: .utf8)!
        }
        catch {
            return "error converting"
        }
    }
}
