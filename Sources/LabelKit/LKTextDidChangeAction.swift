//
//  LKTextDidChangeAction.swift
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

import QuartzCore
import UIKit

class LKTextDidChangeAction : CAAnimationGroup {
    private static let LabelLayerFromToAlphaSwapAnimationDuration : TimeInterval = 1.0
    private static let attributedStringKeys : [String] = [ NSAttributedString.Key.font.rawValue,
                                                     NSAttributedString.Key.foregroundColor.rawValue,
                                                     NSAttributedString.Key.paragraphStyle.rawValue,
                                                     NSAttributedString.Key.backgroundColor.rawValue,
                                                     NSAttributedString.Key.strokeColor.rawValue,
                                                     NSAttributedString.Key.strokeWidth.rawValue,
                                                     NSAttributedString.Key.ligature.rawValue,
                                                     NSAttributedString.Key.kern.rawValue,
                                                     NSAttributedString.Key.strikethroughStyle.rawValue,
                                                     NSAttributedString.Key.underlineStyle.rawValue,
                                                     NSAttributedString.Key.textEffect.rawValue,
                                                     NSAttributedString.Key.attachment.rawValue,
                                                     NSAttributedString.Key.shadow.rawValue,
                                                     NSAttributedString.Key.link.rawValue,
                                                     NSAttributedString.Key.baselineOffset.rawValue,
                                                     NSAttributedString.Key.underlineColor.rawValue,
                                                     NSAttributedString.Key.strikethroughColor.rawValue,
                                                     NSAttributedString.Key.obliqueness.rawValue,
                                                     NSAttributedString.Key.expansion.rawValue,
                                                     NSAttributedString.Key.writingDirection.rawValue,
                                                     NSAttributedString.Key.verticalGlyphForm.rawValue, ]
    var interpolatedFromAttributedText : NSAttributedString? {
        get {
            if interpolatedFromAlpha > 0 {
                return fill(withInterpolatedAttributes: fromAttributedText)
            }
            return nil
        }
    }
    var interpolatedToAttributedText : NSAttributedString? {
        get {
            if interpolatedToAlpha > 0 && toAttributedText != nil {
                return fill(withInterpolatedAttributes: toAttributedText!)
            }
            return nil
        }
    }
    @objc private(set) var interpolatedFromAlpha : CGFloat = 0
    @objc private(set) var interpolatedToAlpha : CGFloat = 0
    @objc var interpolatedAttributeStates : NSMutableDictionary!
    
    var fromAttributedText : NSAttributedString?
    var toAttributedText : NSAttributedString?
    
    
    
    override func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
        guard let textLayer = anObject as? LKLabelLayer, event == keyPath(\LKLabelLayer.attributedText) else { return }
        let duration = CATransaction.animationDuration()
        self.toAttributedText = textLayer.attributedText
        if (self.fromAttributedText != self.toAttributedText) {
            var animations = [CABasicAnimation]()
            let rootAttributesKey = keyPath(\LKLabelLayer.currentTextDidChangeAnimation?.interpolatedAttributeStates)
            let shouldAnimateAlpha = (fromAttributedText != nil || toAttributedText != nil) && fromAttributedText?.string != toAttributedText?.string
            self.interpolatedFromAlpha = 0.0
            self.interpolatedToAlpha = 1.0
            if (shouldAnimateAlpha) {
                self.interpolatedFromAlpha = 1.0
                self.interpolatedToAlpha = 0.0
                animations.append(contentsOf: type(of: self).animationsForAlphaSwap(forKeyPath: keyPath(\LKLabelLayer.currentTextDidChangeAnimation?.interpolatedFromAlpha), fromValue:1, toValue:0))
                animations.append(contentsOf: type(of: self).animationsForAlphaSwap(forKeyPath: keyPath(\LKLabelLayer.currentTextDidChangeAnimation?.interpolatedToAlpha), fromValue:0, toValue:1))
            }
            type(of: self).attributedStringKeys.forEach { (attributeRawValue) in
                var shorterTextValue : AnyObject? = nil
                let attributedStringKey = NSAttributedString.Key(rawValue: attributeRawValue)
                let swapped = self.toAttributedText?.length ?? 0 > self.fromAttributedText?.length ?? 0
                let longerText = swapped ? self.toAttributedText : self.fromAttributedText
                let shorterText = swapped ? self.fromAttributedText : self.toAttributedText
                longerText?.enumerateAttribute(attributedStringKey, in:NSMakeRange(0, longerText?.length ?? 0), options:[], using:{ (longerTextValue, longerTextRange, longerTextStop) in
                    let isLastLongerTextRange = NSMaxRange(longerTextRange) == longerText?.length
                    if shorterText != nil && longerTextRange.location < shorterText!.length {
                        let toEnumerationRange = isLastLongerTextRange ? NSMakeRange(longerTextRange.location, shorterText!.length - longerTextRange.location) : longerTextRange
                        shorterText!.enumerateAttribute(attributedStringKey, in: toEnumerationRange, options: [], using: { (value, shorterTextRange, shorterTextStop) in
                            shorterTextValue = value as AnyObject
                            if (longerTextValue != nil || shorterTextValue != nil) && !(longerTextValue as AnyObject).isEqual(shorterTextValue) {
                                let fromValue = swapped ? shorterTextValue : longerTextValue
                                let toValue = swapped ? longerTextValue : shorterTextValue
                                animations.append(contentsOf: type(of: self).animationsForAttributeDiff(forRootKey:rootAttributesKey, attributedStringKey:attributedStringKey, fromValue:fromValue, toValue:toValue, in:shorterTextRange, attributeStates:self.interpolatedAttributeStates, duration:duration))
                            }
                        })
                        if (shorterText == nil || NSMaxRange(longerTextRange) > shorterText!.length) && (longerTextValue != nil || shorterTextValue != nil) && !(longerTextValue as AnyObject).isEqual(shorterTextValue) {
                            let fromValue = swapped ? shorterTextValue : longerTextValue
                            let toValue = swapped ? longerTextValue : shorterTextValue
                            animations.append(contentsOf: type(of: self).animationsForAttributeDiff(forRootKey:rootAttributesKey, attributedStringKey:attributedStringKey, fromValue:fromValue, toValue:toValue, in:longerTextRange, attributeStates:self.interpolatedAttributeStates, duration:duration))
                        }
                    }
                })
            }
            if animations.count > 0 {
                self.animations = animations
                self.duration = duration
                self.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut )
                textLayer.add(self, forKey: keyPath(\LKLabelLayer.attributedText))
            }
        }
    }
    
    private static func decodeAttribute(from object: AnyObject?, forAttributedStringKey key: NSAttributedString.Key)->AnyObject? {
        guard let dictionary = object as? NSDictionary else { return object }
        switch key {
        case .font:
            return UIFont.lk_dictDecode(dictionaryRepresentation: dictionary)
        case .foregroundColor,
             .backgroundColor,
             .strokeColor,
             .underlineColor,
             .strikethroughColor:
            return UIColor.lk_dictDecode(dictionaryRepresentation: dictionary)
        case .paragraphStyle:
            return NSParagraphStyle.lk_dictDecode(dictionaryRepresentation: dictionary)
        case .shadow:
            return NSShadow.lk_dictDecode(dictionaryRepresentation: dictionary)
        default:
            return object
        }
    }
    
    required override init() {
        super.init()
    }
    
    required init(from text: NSAttributedString?) {
        super.init()
        fromAttributedText = text
        interpolatedAttributeStates = type(of: self).stringAttributesDictionary
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func animationsForAttributeDiff(forRootKey rootKey: String,
                                           attributedStringKey: NSAttributedString.Key,
                                           fromValue: Any?,
                                           toValue: Any?,
                                           in diffRange: NSRange,
                                           attributeStates : NSMutableDictionary,
                                           duration: TimeInterval)->[CABasicAnimation] {
        var animations = [CABasicAnimation]()
        let appendAnimation : (_ keyPath: String, _ from: Any?, _ to: Any?)->() = { (keyPath, from, to) in
            let animation = CABasicAnimation(forKeyPath:keyPath, fromValue:from, toValue:to, duration:duration)
            animations.append(animation)
        }
        if attributeStates[attributedStringKey.rawValue] == nil {
            attributeStates[attributedStringKey.rawValue] = NSMutableDictionary()
        }
        let objectDictKey = keyPath(attributedStringKey.rawValue, range: diffRange)
        let objectRootKey = keyPath(rootKey, suffix: objectDictKey)
        
        var encodingType : LKNSDictionaryCoding.Type?
        if fromValue != nil, let fromValueType = type(of: fromValue!) as? LKNSDictionaryCoding.Type {
            encodingType = fromValueType
        } else if toValue != nil, let toValueType = type(of: toValue!) as? LKNSDictionaryCoding.Type {
            encodingType = toValueType
        }
        if encodingType != nil {
            let fromObjectAttrs = encodingType!.lk_dictEncode(object: fromValue as AnyObject)
            let toObjectAttrs = encodingType!.lk_dictEncode(object: toValue as AnyObject)
            attributeStates.setValue(fromObjectAttrs, forKeyPath:objectDictKey)
            self.enumerateDiffs(leftDictionary: fromObjectAttrs, rightDictionary: toObjectAttrs, using: { (key, from, to) in
                let kPath = keyPath(objectRootKey, suffix: key)
                appendAnimation(kPath, from, to)
            })
        } else if let attrDict = attributeStates[attributedStringKey.rawValue] as? NSMutableDictionary {
            attrDict[NSStringFromRange(diffRange)] = fromValue
            appendAnimation(objectRootKey, fromValue, toValue)
        }
        return animations
    }
    
    private static func enumerateDiffs(leftDictionary: NSDictionary,
                               rightDictionary: NSDictionary,
                               using block: (_ key: String, _ fromValue: Any?, _ toValue: Any?)->()) {
        let totalKeySet = NSMutableSet(array: leftDictionary.allKeys)
        totalKeySet.addObjects(from: rightDictionary.allKeys)
        totalKeySet.forEach { (key) in
            let fromValue = leftDictionary[key]
            let toValue = rightDictionary[key]
            if (fromValue != nil || toValue != nil) && !(fromValue as AnyObject).isEqual(toValue) {
                if let fromValueDict = fromValue as? NSDictionary, let toValueDict = toValue as? NSDictionary {
                    self.enumerateDiffs(leftDictionary: fromValueDict, rightDictionary: toValueDict, using: { (keySuffix, from, to) in
                        block(keyPath(key, suffix: keySuffix), from, to)
                    })
                } else {
                    block(key as! String, fromValue, toValue)
                }
            }
        }
    }
    
    private static func animationsForAlphaSwap(forKeyPath keyPath: String, fromValue: Any?, toValue: Any?)->[CABasicAnimation] {
        let duration = CATransaction.animationDuration()
        guard duration > 0 else { return [CABasicAnimation]() }
        let alphaSwapDuration = min(LabelLayerFromToAlphaSwapAnimationDuration, 0.5 * duration)
        let alphaPersistDuration = (duration - alphaSwapDuration) / 2.0
        let persistFromAlphaAnimation = CABasicAnimation(forKeyPath: keyPath, fromValue: fromValue, toValue: fromValue, duration: alphaPersistDuration)
        let swapAlphaAnimation = CABasicAnimation(forKeyPath: keyPath, fromValue: fromValue, toValue: toValue, duration:alphaSwapDuration)
        let persistToAlphaAnimation = CABasicAnimation(forKeyPath: keyPath, fromValue: toValue, toValue: toValue, duration:alphaPersistDuration)
        persistFromAlphaAnimation.beginTime = 0
        swapAlphaAnimation.beginTime = alphaPersistDuration
        persistToAlphaAnimation.beginTime = alphaSwapDuration + alphaPersistDuration
        
        return [persistFromAlphaAnimation,
                swapAlphaAnimation,
                persistToAlphaAnimation]
    }
    
    
    private static var stringAttributesDictionary : NSMutableDictionary {
        get {
            return NSMutableDictionary(sharedKeySet: NSMutableDictionary.sharedKeySet(forKeys: attributedStringKeys as [NSCopying]));
        }
    }
    
    private func fill(withInterpolatedAttributes attributedString: NSAttributedString?)->NSAttributedString {
        let mutableInterpolatedAttributedText = attributedString != nil ? NSMutableAttributedString(attributedString: attributedString!) : NSMutableAttributedString()
        mutableInterpolatedAttributedText.beginEditing()
        interpolatedAttributeStates.enumerateKeysAndObjects { (keyInAttrStates, objInAttrStates, stopInAttrStates) in
            guard let attrValuePerRangeString = objInAttrStates as? NSDictionary, let attrStrKeyRawValue = keyInAttrStates as? String else { return }
            attrValuePerRangeString.enumerateKeysAndObjects { (keyInRange, objInRange, stopInRange) in
                guard let rangeString = keyInRange as? String else { return }
                let range = NSRangeFromString(rangeString)
                if range.location < mutableInterpolatedAttributedText.length {
                    let key = NSAttributedString.Key(rawValue: attrStrKeyRawValue)
                    if let decodedObject = LKTextDidChangeAction.decodeAttribute(from: objInRange as AnyObject, forAttributedStringKey: key) {
                        mutableInterpolatedAttributedText.addAttribute(key, value:decodedObject, range: NSMakeRange(range.location, min(mutableInterpolatedAttributedText.length - range.location, range.length)))
                    } else {
                        mutableInterpolatedAttributedText.removeAttribute(key, range: NSMakeRange(range.location, min(mutableInterpolatedAttributedText.length - range.location, range.length)))
                    }
                }
            }
        }
        
        mutableInterpolatedAttributedText.endEditing()
        return mutableInterpolatedAttributedText
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone)
        if let action = result as? LKTextDidChangeAction {
            action.fromAttributedText = fromAttributedText
            action.toAttributedText = toAttributedText
            action.interpolatedAttributeStates = interpolatedAttributeStates
            action.interpolatedFromAlpha = interpolatedFromAlpha
            action.interpolatedToAlpha = interpolatedToAlpha
            return action
        }
        return result
    }
}
