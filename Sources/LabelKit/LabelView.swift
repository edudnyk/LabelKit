//
//  LKLabel.swift
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

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0.0, *)
@available(tvOS 13.0.0, *)
public struct LabelView: View {
    public var attributedText: NSAttributedString?

    public init(attributedText: NSAttributedString?) {
        self.attributedText = attributedText
    }

    public var text: String? {
        get {
            return attributedText?.string
        }
        set(newValue) {
            guard let text = newValue else {
                attributedText = nil
                return
            }
            attributedText = NSAttributedString(string: text)
        }
    }

    public var body: some View {
        GeometryReader { geometry in
            internalLabelView(frame: geometry.frame(in: .local))
        }
    }

    private func internalLabelView(frame: CGRect) -> some View {
        return InternalLabelView(width: frame.width, attributedText: attributedText)
            .position(x: frame.midX, y: frame.midY)
    }
}

@available(iOS 13.0.0, *)
@available(tvOS 13.0.0, *)
internal struct InternalLabelView: UIViewRepresentable {
    static let durationRegEx = try? NSRegularExpression(pattern: "duration: ([\\d\\.]*),",
                                                        options: [.caseInsensitive])

    typealias UIViewType = LKLabel

    var width: CGFloat
    var attributedText: NSAttributedString?
    var numberOfLines: Int = 0

    func makeUIView(context: Context) -> UIViewType {
        let label = UIViewType()
        UIView.performWithoutAnimation {
            label.numberOfLines = numberOfLines
            label.preferredMaxLayoutWidth = width
            label.attributedText = attributedText
            label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
        return label
    }

    func updateUIView(_ label: UIViewType, context: Context) {
        label.numberOfLines = numberOfLines
        label.preferredMaxLayoutWidth = width
        let transaction = context.transaction
        var duration: Double = 0
        if let animation = transaction.animation {
            let animationDescription = String(describing: animation)
            if animationDescription.count > 0,
               let durationResult = InternalLabelView.durationRegEx?.firstMatch(in: animationDescription,
                                                                                options: [],
                                                                                range: NSRange(location: 0, length: animationDescription.count)),
               durationResult.numberOfRanges > 0
            {
                let matchRange = durationResult.range(at: 1)
                duration = animationDescription.lk_substringAsDouble(matchRange)
            }
        }

        let setter = {
            label.attributedText = attributedText
        }

        if duration > 0 && !transaction.disablesAnimations {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: setter, completion: nil)
        } else {
            UIView.performWithoutAnimation(setter)
        }
    }
}

extension String {
    func lk_substring(_ range: NSRange) -> Substring {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        return self[start ..< end]
    }

    func lk_substringAsDouble(_ range: NSRange) -> Double {
        return Double(lk_substring(range)) ?? 0
    }
}

@available(iOS 13.0.0, *)
@available(tvOS 13.0.0, *)
public struct LabelView_Previews: PreviewProvider {
    public static var previews: some View {
        HStack {
            LabelView(attributedText: NSAttributedString(string: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis scelerisque semper diam in pharetra. Nullam ultrices varius enim ac ultrices. In convallis felis leo, sit amet mollis nisl sodales in. Mauris ut bibendum tortor. Praesent sollicitudin lacus nec lorem finibus convallis. Quisque quis ultricies ante, id malesuada nibh. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Quisque a vehicula ligula. Duis quis mauris porttitor, pulvinar elit ut, maximus dolor. Cras et sem vitae nisl accumsan porta non in quam. Nullam molestie, ipsum ut convallis iaculis, dui nibh facilisis mi, quis porta mi sem nec augue. Nulla elit sem, tempor id elit vitae, bibendum lacinia urna."))
        }
    }
}
#endif
