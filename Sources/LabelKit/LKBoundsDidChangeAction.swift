//
//  LKBoundsDidChangeAnimation.swift
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

class LKBoundsDidChangeAnimation : CABasicAnimation {
    @objc var bounds : CGRect = CGRect.zero
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let result = super.copy(with: zone)
        if let action = result as? Self {
            action.bounds = bounds
            return action
        }
        return result
    }
}

class LKBoundsDidChangeAction : CAAction {
    var pendingAnimation : LKBoundsDidChangeAnimation
    
    init(fromBounds: CGRect) {
        let rootContextKey = keyPath(\LKLabelLayer.currentBoundsDidChangeAnimation)
        let animation = LKBoundsDidChangeAnimation(keyPath:
            keyPath(rootContextKey, suffix: keyPath(\LKBoundsDidChangeAnimation.bounds)))
        animation.fromValue = fromBounds
        animation.duration = UIView.inheritedAnimationDuration > 0 ? UIView.inheritedAnimationDuration : CATransaction.animationDuration()
        animation.bounds = fromBounds
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pendingAnimation = animation
    }
    
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
        guard let textLayer = anObject as? LKLabelLayer, event == keyPath(\LKLabelLayer.bounds) else { return }
        if !pendingAnimation.bounds.equalTo(textLayer.bounds) {
            pendingAnimation.toValue = textLayer.bounds
            textLayer.add(pendingAnimation, forKey:keyPath(\LKBoundsDidChangeAnimation.bounds))
        }
    }
    
}
