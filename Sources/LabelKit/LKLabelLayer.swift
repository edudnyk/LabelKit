//
//  LKLabelLayer.swift
//  LabelKit
//
//  Copyright (c) 2019-2021 Eugene Dudnyk
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

@objc
open class LKLabelLayer: CALayer {
    fileprivate var stringDrawingContext: NSStringDrawingContext!
    fileprivate var stringDrawingOptions: NSStringDrawingOptions!
    private weak var textPresentationLayer: LKLabelLayer!
    public var adjustsTextForCustomLineHeight = false
    
    /// The underlying attributed string drawn by the label layer.
    /// Animatable.
    @NSManaged
    open dynamic var attributedText: NSAttributedString?
    
    override public init() {
        super.init()
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override private init(layer: Any) {
        super.init(layer: layer)
        masksToBounds = false
        guard let textLayer = layer as? LKLabelLayer, let recentLayer = textLayer.textPresentationLayer != nil ? textLayer.textPresentationLayer : textLayer else { return }
        stringDrawingOptions = recentLayer.stringDrawingOptions
        stringDrawingContext = recentLayer.stringDrawingContext
        textLayer.textPresentationLayer = self
    }
    
    private func commonInit() {
        stringDrawingOptions = [.usesFontLeading, .truncatesLastVisibleLine]
        stringDrawingContext = NSStringDrawingContext()
        needsDisplayOnBoundsChange = true
        isOpaque = false
    }
    
    /// Triggers attributed text change implicit animation.
    /// If layer is used without `LKLabel`, also triggers supporting bounds change action.
    @objc
    override open func action(forKey event: String) -> CAAction? {
        if event == keyPath(\LKLabelLayer.attributedText) {
            let action = textPresentationLayer?.currentTextDidChangeAnimation
            let fromText = action != nil ? action!.interpolatedFromAlpha > action!.interpolatedToAlpha ? action!.interpolatedFromAttributedText : action!.interpolatedToAttributedText : attributedText
            return LKTextDidChangeAction(from: fromText)
        }
        let superAction = super.action(forKey: event)
        guard event == keyPath(\CALayer.bounds),
              type(of: superAction) != LKCompositeAction.self,
              UIView.inheritedAnimationDuration > 0 else { return superAction }
        let textDrawingBoundsAction = LKBoundsDidChangeAction(fromBounds: bounds)
        let action: CAAction = superAction != nil ? LKCompositeAction(actions: [superAction!, textDrawingBoundsAction]) : textDrawingBoundsAction
        return action
    }
    
    @objc
    override open func preferredFrameSize() -> CGSize {
        let result = attributedText?.boundingRect(with: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude), options: stringDrawingOptions, context: stringDrawingContext).size
        return CGSize(width: ceil((result?.width ?? 0) + 1), height: ceil((result?.height ?? 0) + 1))
    }
    
    @objc
    override open func draw(in ctx: CGContext) {
        drawText(in: ctx.boundingBoxOfClipPath)
    }
    
    fileprivate func drawText(in rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let textChangeAction = currentTextDidChangeAnimation
        let toAlpha = textChangeAction?.interpolatedToAlpha ?? 1.0
        let modelLayer = model()
        let toDrawingText = textChangeAction?.interpolatedToAttributedText ?? modelLayer.attributedText
        let fromAlpha = textChangeAction?.interpolatedFromAlpha ?? 0
        if fromAlpha > 0 || toAlpha > 0 {
            ctx.setAllowsAntialiasing(true)
            ctx.setAllowsFontSmoothing(true)
            ctx.setAllowsFontSubpixelPositioning(true)
            ctx.setAllowsFontSubpixelQuantization(false)
            ctx.setShouldAntialias(true)
            ctx.setShouldSmoothFonts(true)
            ctx.setShouldSubpixelPositionFonts(true)
            var stringDrawingOptions = self.stringDrawingOptions ?? []
            if modelLayer != self {
                stringDrawingOptions = [stringDrawingOptions, .truncatesLastVisibleLine]
            }
            if fromAlpha > 0 {
                let fromDrawingText = textChangeAction?.interpolatedFromAttributedText
                if fromAlpha < 1 {
                    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
                    ctx.setAlpha(fromAlpha)
                }
                let fromRect = adjust(drawingRect: rect, for: fromDrawingText)
                fromDrawingText?.draw(with: fromRect, options: stringDrawingOptions, context: stringDrawingContext)
                if fromAlpha < 1 {
                    ctx.endTransparencyLayer()
                }
            }
            if toAlpha > 0 {
                if toAlpha < 1 {
                    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
                    ctx.setAlpha(toAlpha)
                }
                let toRect = adjust(drawingRect: rect, for: toDrawingText)
                toDrawingText?.draw(with: toRect, options: stringDrawingOptions, context: stringDrawingContext)
                if toAlpha < 1 {
                    ctx.endTransparencyLayer()
                }
            }
        }
    }
    
    @objc
    override open class func needsDisplay(forKey key: String) -> Bool {
        var result = super.needsDisplay(forKey: key)
        result = result || key == keyPath(\LKLabelLayer.attributedText) ||
            key == keyPath(\LKLabelLayer.currentTextDidChangeAnimation) ||
            key == keyPath(\LKLabelLayer.currentBoundsDidChangeAnimation) ||
            key == keyPath(\LKLabelLayer.bounds)
        return result
    }
    
    private func adjust(drawingRect: CGRect, for text: NSAttributedString?) -> CGRect {
        guard let text = text, text.length > 0 else { return drawingRect }
        var result = drawingRect
        if stringDrawingOptions.contains(.usesLineFragmentOrigin) {
            if adjustsTextForCustomLineHeight, let lastParagraphStyle = text.attribute(.paragraphStyle, at: text.length - 1, effectiveRange: nil) as? NSParagraphStyle {
                result.origin.y = roundToPixels(result.origin.y + lastParagraphStyle.lineSpacing / 2.0, scale: contentsScale)
            }
        } else {
            if let firstParagraphStyle = text.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle,
               let firstFont = text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
                let lineHeightCompensation = adjustsTextForCustomLineHeight && firstParagraphStyle.lineHeightMultiple > 0 ? firstParagraphStyle.lineHeightMultiple * firstFont.lineHeight - firstFont.lineHeight : 0.0
                result.origin.y = roundToPixels(result.origin.y + lineHeightCompensation * 1.5 + firstFont.ascender, scale: contentsScale)
            }
        }
        return result
    }
}

extension LKLabel {
    override open func drawText(in rect: CGRect) {
        let layer = labelLayer?.presentation() ?? labelLayer
        layer?.drawText(in: rect)
    }
    
    @objc
    override open var minimumScaleFactor: CGFloat {
        didSet(previousValue) {
            labelLayer?.stringDrawingContext.minimumScaleFactor = adjustsFontSizeToFitWidth ? minimumScaleFactor : 1.0
        }
    }
    
    @objc
    override open var adjustsFontSizeToFitWidth: Bool {
        didSet(previousValue) {
            let minimumScaleFactor = self.minimumScaleFactor
            self.minimumScaleFactor = minimumScaleFactor
        }
    }
    
    @objc
    override open var lineBreakMode: NSLineBreakMode {
        didSet(previousValue) {
            if let labelLayer = self.labelLayer {
                if lineBreakMode == .byTruncatingTail {
                    labelLayer.stringDrawingOptions = labelLayer.stringDrawingOptions.union(.truncatesLastVisibleLine)
                } else {
                    _ = labelLayer.stringDrawingOptions.remove(.truncatesLastVisibleLine)
                }
            }
        }
    }
    
    @objc
    override open var numberOfLines: Int {
        didSet(previousValue) {
            if let labelLayer = self.labelLayer {
                if numberOfLines != 1 {
                    labelLayer.stringDrawingOptions = labelLayer.stringDrawingOptions.union(.usesLineFragmentOrigin)
                } else {
                    _ = labelLayer.stringDrawingOptions.remove(.usesLineFragmentOrigin)
                }
            }
        }
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let actionsDisabled = CATransaction.disableActions()
        CATransaction.setDisableActions(true)
        super.traitCollectionDidChange(previousTraitCollection)
        CATransaction.setDisableActions(actionsDisabled)
    }
}
