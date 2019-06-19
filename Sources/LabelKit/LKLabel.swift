//
//  LKLabel.swift
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

open class LKLabel : UILabel {
    open override class var layerClass: AnyClass {
        get {
            return LKLabelLayer.self
        }
    }
    
    open var labelLayer : LKLabelLayer? {
        get {
            return self.layer as? LKLabelLayer
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        internalInit()
    }
    
    private func internalInit() {
        labelLayer?.isOpaque = false
        labelLayer?.needsDisplayOnBoundsChange = true
        labelLayer?.contentsScale = UIScreen.main.scale
        isOpaque = false
        isUserInteractionEnabled = false
        contentMode = .redraw
    }
    
    open override var attributedText: NSAttributedString? {
        didSet(previousValue) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(UIView.inheritedAnimationDuration)
            labelLayer?.attributedText = alignedAttributedText(attributedText)
            CATransaction.commit()
        }
    }
    
    open override var text: String? {
        didSet(previousValue) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(UIView.inheritedAnimationDuration)
            labelLayer?.attributedText = alignedAttributedText(attributedText)
            CATransaction.commit()
        }
    }
    
    open override var backgroundColor: UIColor? {
        didSet(previousValue) {
            labelLayer?.backgroundColor = backgroundColor?.cgColor ?? UIColor.clear.cgColor
        }
    }
    
    open override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        let result = super.action(for: layer, forKey: event)
        if event == keyPath(\CALayer.bounds) && result != nil && UIView.inheritedAnimationDuration > 0 {
            let textDrawingBoundsAction = LKBoundsDidChangeAction(fromBounds: layer.bounds)
            let action = LKCompositeAction(actions:[result!, textDrawingBoundsAction])
            return action
        }
        return result
    }
    
    open override func display(_ layer: CALayer) {
        if let labelLayer = layer as? LKLabelLayer {
            let textDrawingBoundsAction = labelLayer.currentBoundsDidChangeAnimation
            let rect = textDrawingBoundsAction?.bounds ?? self.bounds
            UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
            let textRect = rect.inset(by: self.layoutMargins)
            drawText(in: textRect)
            layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()
            return
        }
        super.display(layer)
    }
    
    private func alignedAttributedText(_ attributedText: NSAttributedString?) -> NSAttributedString? {
        guard let attributedText = attributedText else { return nil }
        var hasParagraphStyle = false
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.paragraphStyle, in: range, options: []) { (value, range, stop) in
            hasParagraphStyle = hasParagraphStyle || value != nil
            stop.assign(repeating: ObjCBool(hasParagraphStyle), count: 1)
        }
        if !hasParagraphStyle {
            let mutableText = NSMutableAttributedString(attributedString: attributedText)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            mutableText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            return mutableText
        }
        return attributedText
    }
}

class LKCompositeAction : CAAction {
    var actions : [CAAction]
    init(actions: [CAAction]) {
        self.actions = actions
    }
    
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
        actions.forEach { (action) in
            action.run(forKey: event, object: anObject, arguments: dict)
        }
    }
}
