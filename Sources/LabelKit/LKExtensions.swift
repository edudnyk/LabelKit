//
//  LKExtensions.swift
//  LabelKit
//
//  Copyright (c) 2019 Eugene Dudnyk
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the LabelKit project.
//

import UIKit

func keyPath(_ base: Any, suffix: Any)-> String {
    return "\(base).\(suffix)"
}

func keyPath(_ base: Any, range: NSRange)-> String {
    return keyPath(base, suffix: NSStringFromRange(range))
}

func keyPath<Root, Key>(_ keyPath: KeyPath<Root, Key>)->String {
    return NSExpression(forKeyPath: keyPath).keyPath
}

func keyPathCocoa<Root, Key>(_ keyPath: KeyPath<Root, Key>)->NSString {
    return NSExpression(forKeyPath: keyPath).keyPath as NSString
}

protocol LKNSDictionaryCoding {
    static func lk_dictEncode(object: AnyObject?)->NSMutableDictionary
    static func lk_dictDecode(dictionaryRepresentation dictionary: NSDictionary?)->Self
}

extension UIColor : LKNSDictionaryCoding {
    
    static func lk_dictEncode(object: AnyObject?)->NSMutableDictionary {
        let color = object as? UIColor
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha: CGFloat = 0
        if color?.getRed(&red, green:&green, blue:&blue, alpha:&alpha) == false {
            _ = color?.getWhite(&red, alpha:&alpha)
            green = red
            blue = red
        }
        let result = NSMutableDictionary(sharedKeySet: NSMutableDictionary.sharedKeySet(forKeys: [ NSString("r"), NSString("g"), NSString("b"), NSString("a")] ))
        result["r"] = red
        result["g"] = green
        result["b"] = blue
        result["a"] = alpha
        return result
    }
    
    static func lk_dictDecode(dictionaryRepresentation dictionary: NSDictionary?)->Self {
        var red : CGFloat = 0, green : CGFloat = 0, blue : CGFloat = 0, alpha: CGFloat = 0
        if let redValue = dictionary?["r"] as? CGFloat {
            red = redValue
        }
        if let greenValue = dictionary?["g"] as? CGFloat {
            green = greenValue
        }
        if let blueValue = dictionary?["b"] as? CGFloat {
            blue = blueValue
        }
        if let alphaValue = dictionary?["a"] as? CGFloat {
            alpha = alphaValue
        }
        return Self(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIFont : LKNSDictionaryCoding {
    
    static func lk_dictEncode(object: AnyObject?)->NSMutableDictionary {
        let font = object as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
        let traits = font.fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.traits) as? [UIFontDescriptor.TraitKey: Any] ?? [:]
        let weight = traits[.weight] as? UIFont.Weight ?? UIFont.Weight(0)
        let dictionary = NSMutableDictionary(dictionary: ["pointSize" : font.pointSize,
                                                          "weight" : weight.rawValue])
        return dictionary
    }
    
    static func lk_dictDecode(dictionaryRepresentation dictionary: NSDictionary?)->Self {
        guard let pointSize = dictionary?["pointSize"] as? CGFloat, let weight = dictionary?["weight"] as? CGFloat else {
            return UIFont.preferredFont(forTextStyle: .body) as! Self
        }
        return UIFont.systemFont(ofSize: pointSize, weight: UIFont.Weight(rawValue: weight)) as! Self
    }
}

extension NSParagraphStyle : LKNSDictionaryCoding {
    
    static func lk_dictEncode(object: AnyObject?)->NSMutableDictionary {
        let paragraphStyle = object as? NSParagraphStyle ?? NSParagraphStyle.default
        return NSMutableDictionary(dictionary: paragraphStyle.dictionaryWithValues(forKeys: [ keyPath(\NSParagraphStyle.lineSpacing),
                                                                                              keyPath(\NSParagraphStyle.paragraphSpacing),
                                                                                              keyPath(\NSParagraphStyle.alignment),
                                                                                              keyPath(\NSParagraphStyle.headIndent),
                                                                                              keyPath(\NSParagraphStyle.tailIndent),
                                                                                              keyPath(\NSParagraphStyle.firstLineHeadIndent),
                                                                                              keyPath(\NSParagraphStyle.minimumLineHeight),
                                                                                              keyPath(\NSParagraphStyle.maximumLineHeight),
                                                                                              keyPath(\NSParagraphStyle.lineBreakMode),
                                                                                              keyPath(\NSParagraphStyle.baseWritingDirection),
                                                                                              keyPath(\NSParagraphStyle.lineHeightMultiple),
                                                                                              keyPath(\NSParagraphStyle.paragraphSpacingBefore),
                                                                                              keyPath(\NSParagraphStyle.hyphenationFactor),
                                                                                              keyPath(\NSParagraphStyle.defaultTabInterval),
                                                                                              keyPath(\NSParagraphStyle.allowsDefaultTighteningForTruncation),
        ]))
    }
    
    static func lk_dictDecode(dictionaryRepresentation dictionary: NSDictionary?)->Self {
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.setValuesForKeys(dictionary as! [String : Any])
        return mutableParagraphStyle as NSParagraphStyle as! Self
    }
}

extension NSShadow : LKNSDictionaryCoding {
    
    static func lk_dictEncode(object: AnyObject?)->NSMutableDictionary {
        let result = NSMutableDictionary(sharedKeySet: NSMutableDictionary.sharedKeySet(forKeys: [ keyPathCocoa(\NSShadow.shadowOffset),
                                                                                                   keyPathCocoa(\NSShadow.shadowBlurRadius),
                                                                                                   keyPathCocoa(\NSShadow.shadowColor)]))
        let shadow = object as? NSShadow ?? NSShadow()
        result[keyPath(\NSShadow.shadowOffset)] = shadow.shadowOffset
        result[keyPath(\NSShadow.shadowBlurRadius)] = shadow.shadowBlurRadius
        let color = shadow.shadowColor as? UIColor ?? UIColor.clear
        result[keyPath(\NSShadow.shadowColor)] = UIColor.lk_dictEncode(object: color )
        return result
    }
    
    static func lk_dictDecode(dictionaryRepresentation dictionary: NSDictionary?)->Self {
        let color = UIColor.lk_dictDecode(dictionaryRepresentation: dictionary?[keyPath(\NSShadow.shadowColor)] as? NSDictionary)
        let result = Self()
        var shadowOffset = CGSize.zero
        if let shadowOffsetValue = dictionary?[keyPath(\NSShadow.shadowOffset)] as? CGSize {
            shadowOffset = shadowOffsetValue
        }
        result.shadowOffset = shadowOffset
        var shadowBlurRadius : CGFloat = 0.0
        if let shadowBlurRadiusValue = dictionary?[keyPath(\NSShadow.shadowBlurRadius)] as? CGFloat {
            shadowBlurRadius = shadowBlurRadiusValue
        }
        result.shadowBlurRadius = shadowBlurRadius
        result.shadowColor = color
        return result
    }
}

extension LKLabelLayer {
    @objc var currentTextDidChangeAnimation : LKTextDidChangeAction? {
        get {
            return animation(forKey: keyPath(\LKLabelLayer.attributedText)) as? LKTextDidChangeAction
        }
    }

    @objc var currentBoundsDidChangeAnimation : LKBoundsDidChangeAnimation? {
        get {
            return animation(forKey: keyPath(\LKBoundsDidChangeAnimation.bounds)) as? LKBoundsDidChangeAnimation
        }
    }
}

extension CABasicAnimation {
    convenience init (forKeyPath keyPath: String, fromValue: Any?, toValue: Any?, duration: TimeInterval) {
        self.init(keyPath: keyPath)
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
    }
}


