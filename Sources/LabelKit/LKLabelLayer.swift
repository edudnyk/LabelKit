//
//  LKLabelLayer.swift
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

open class LKLabelLayer : CALayer {
    fileprivate var stringDrawingContext : NSStringDrawingContext!
    fileprivate var stringDrawingOptions : NSStringDrawingOptions!
    private weak var textPresentationLayer : LKLabelLayer!
    
    /// The underlying attributed string drawn by the label layer.
    /// Animatable.
    @objc @NSManaged open dynamic var attributedText : NSAttributedString?
    
    public override init() {
        super.init()
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private override init(layer: Any) {
        super.init(layer: layer)
        masksToBounds = false
        guard let textLayer = layer as? LKLabelLayer, let recentLayer = textLayer.textPresentationLayer != nil ? textLayer.textPresentationLayer : textLayer else { return }
        stringDrawingOptions = recentLayer.stringDrawingOptions
        stringDrawingContext = recentLayer.stringDrawingContext
        textLayer.textPresentationLayer = self
    }
    
    private func commonInit() {
        stringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin, .truncatesLastVisibleLine ]
        stringDrawingContext = NSStringDrawingContext()
        needsDisplayOnBoundsChange = true
        isOpaque = false
    }
    
    /// Triggers attributed text change implicit animation.
    /// If layer is used without `LKLabel`, also triggers supporting bounds change action.
    open override func action(forKey event: String) -> CAAction? {
        if event == keyPath(\LKLabelLayer.attributedText) {
            let action = textPresentationLayer?.currentTextDidChangeAnimation
            let fromText = action != nil ? action!.interpolatedFromAlpha > action!.interpolatedToAlpha ? action!.interpolatedFromAttributedText : action!.interpolatedToAttributedText : self.attributedText
            return LKTextDidChangeAction(from: fromText)
        }
        let superAction = super.action(forKey:event)
        guard event == keyPath(\CALayer.bounds) && type(of: superAction) != LKCompositeAction.self else { return superAction }
        let textDrawingBoundsAction = LKBoundsDidChangeAction(fromBounds: self.bounds)
        let action : CAAction = superAction != nil ? LKCompositeAction(actions: [superAction!, textDrawingBoundsAction]) : textDrawingBoundsAction
        return action
    }
    
    open override func preferredFrameSize()->CGSize {
        let result = attributedText?.boundingRect(with:CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude), options:stringDrawingOptions, context:stringDrawingContext).size
        return CGSize(width: ceil((result?.width ?? 0) + 1), height: ceil((result?.height ?? 0) + 1))
    }
    
    open override func draw(in ctx: CGContext) {
        drawText(in: ctx.boundingBoxOfClipPath)
    }
    
    fileprivate func drawText(in rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let textChangeAction = currentTextDidChangeAnimation
        let toAlpha = textChangeAction?.interpolatedToAlpha ?? 1.0
        let toDrawingString = textChangeAction?.interpolatedToAttributedText ?? attributedText
        if textChangeAction?.interpolatedFromAlpha ?? 0 > 0 || toAlpha > 0 {
            ctx.setAllowsAntialiasing(true)
            ctx.setAllowsFontSmoothing(true)
            ctx.setAllowsFontSubpixelPositioning(true)
            ctx.setAllowsFontSubpixelQuantization(false)
            ctx.setShouldAntialias(true)
            ctx.setShouldSmoothFonts(true)
            ctx.setShouldSubpixelPositionFonts(true)
            var stringDrawingOptions = self.stringDrawingOptions ?? []
            if model() != self {
                stringDrawingOptions = [stringDrawingOptions, .truncatesLastVisibleLine]
            }
            let fromAlpha = textChangeAction?.interpolatedFromAlpha ?? 0
            if fromAlpha > 0 {
                let fromDrawingText = textChangeAction?.interpolatedFromAttributedText
                if fromAlpha < 1 {
                    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
                    ctx.setAlpha(fromAlpha)
                }
                fromDrawingText?.draw(with: rect, options:stringDrawingOptions, context: stringDrawingContext)
                if fromAlpha < 1 {
                    ctx.endTransparencyLayer()
                }
            }
            if toAlpha > 0 {
                if toAlpha < 1 {
                    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
                    ctx.setAlpha(toAlpha)
                }
                toDrawingString?.draw(with: rect, options:stringDrawingOptions, context: stringDrawingContext)
                if toAlpha < 1 {
                    ctx.endTransparencyLayer()
                }
            }
        }
    }
    
    open override class func needsDisplay(forKey key: String) -> Bool {
        var result = super.needsDisplay(forKey: key)
        result = result || key == keyPath(\LKLabelLayer.attributedText) ||
                            key == keyPath(\LKLabelLayer.currentTextDidChangeAnimation) ||
                            key == keyPath(\LKLabelLayer.currentBoundsDidChangeAnimation) ||
                            key == keyPath(\LKLabelLayer.bounds)
        return result
    }
}

extension LKLabel {
    open override func drawText(in rect: CGRect) {
        let layer = self.labelLayer?.presentation() ?? self.labelLayer
        layer?.drawText(in: rect)
    }
    
    open override var minimumScaleFactor: CGFloat {
        didSet(previousValue) {
            labelLayer?.stringDrawingContext.minimumScaleFactor = adjustsFontSizeToFitWidth ? minimumScaleFactor : 1.0
        }
    }
    
    open override var adjustsFontSizeToFitWidth: Bool {
        didSet(previousValue) {
            let minimumScaleFactor = self.minimumScaleFactor
            self.minimumScaleFactor = minimumScaleFactor
        }
    }
    
    open override var lineBreakMode: NSLineBreakMode {
        didSet(previousValue) {
            if let labelLayer = self.labelLayer {
                if (lineBreakMode == .byTruncatingTail) {
                    labelLayer.stringDrawingOptions = labelLayer.stringDrawingOptions.union(.truncatesLastVisibleLine)
                } else {
                    labelLayer.stringDrawingOptions = labelLayer.stringDrawingOptions.remove(.truncatesLastVisibleLine)
                }
            }
        }
    }
}
