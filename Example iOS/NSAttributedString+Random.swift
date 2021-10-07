//
//  NSAttributedString+Random.swift
//  LabelKit - Example iOS
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

import UIKit

let strings = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis scelerisque semper diam in pharetra. Nullam ultrices varius enim ac ultrices. In convallis felis leo, sit amet mollis nisl sodales in. Mauris ut bibendum tortor. Praesent sollicitudin lacus nec lorem finibus convallis. Quisque quis ultricies ante, id malesuada nibh. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Quisque a vehicula ligula. Duis quis mauris porttitor, pulvinar elit ut, maximus dolor. Cras et sem vitae nisl accumsan porta non in quam. Nullam molestie, ipsum ut convallis iaculis, dui nibh facilisis mi, quis porta mi sem nec augue. Nulla elit sem, tempor id elit vitae, bibendum lacinia urna.",

                      "Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nam sed sapien lobortis, posuere neque sit amet, vulputate nisl. Nullam quis enim venenatis, porttitor risus nec, ullamcorper dolor. Pellentesque dictum risus lacus, a sodales elit bibendum eu. Vivamus sit amet dignissim ante. Nunc imperdiet porttitor commodo. Aenean in hendrerit est. Interdum et malesuada fames ac ante ipsum primis in faucibus. Donec et purus id diam blandit varius. Pellentesque orci est, varius non fermentum vitae, condimentum eget ex. Mauris placerat, elit non blandit pretium, risus neque suscipit felis, vel facilisis est eros non turpis.",

                      " شيء آخر بالضبط ما كان لدينا. لا توجد كتلة ، الاتحاد الأوروبي ، ولكن ، للراحة ، بيئية ، وهذا هو. في شبكات العقارات الاحماء. لا نفسها. تصنيع دعاية الصلصة. الآن ابتسامة الفلفل الحار ، عطلة نهاية الأسبوع تشعل الكرتون في كرة القدم ولكن ، سابين. السريرية المستهدفة في شركة",

                      "Curabitur ornare ex quis nunc eleifend efficitur. Donec nisl nulla, eleifend eget justo vel, rhoncus condimentum risus. Nulla erat nunc, lacinia sed commodo a, finibus efficitur ipsum. Ut ut maximus augue, vel consequat lacus. Integer quis aliquet quam, at condimentum dui. Pellentesque quis pellentesque lectus, at luctus quam. Vestibulum libero ligula, blandit non metus in, sollicitudin lacinia nisi. Morbi nulla arcu, cursus sed erat at, maximus finibus libero. Proin efficitur, diam nec blandit feugiat, erat nisi aliquet elit, ut venenatis augue ante et tortor. Maecenas finibus, dui id malesuada interdum, massa risus convallis dui, in sagittis lorem justo a elit.",

                      " شيء آخر بالضبط ما كان لدينا. لا توجد كتلة ، الاتحاد الأوروبي ، ولكن ، للراحة ، بيئية ، وهذا هو. في شبكات العقارات الاحماء. لا نفسها. تصنيع دعاية الصلصة. الآن ابتسامة الفلفل الحار ، عطلة نهاية الأسبوع تشعل الكرتون في كرة القدم ولكن ، سابين. السريرية المستهدفة في شركة"]


extension NSAttributedString {
    
    static func random() -> NSAttributedString {
        let idx = Int(round(rnd() * CGFloat(strings.count - 1)))
        let string = strings[idx]
        let attributedText = NSMutableAttributedString(string: string)
        attributedText.beginEditing()
        attributedText.addAttributes([.foregroundColor: randomColor(),
                                      .font: randomFont(),
                                      .shadow: randomShadow()], range: NSRange(string.startIndex ..< string.endIndex, in: string))
        attributedText.endEditing()
        return attributedText
    }

    private static func randomFont() -> UIFont {
        let pointSize = 20.0 + rnd() * 22.0
        let weigth = UIFont.Weight(CGFloat(0)) // UIFont.Weight(CGFloat(rnd() * 2 - 1))
        return UIFont.systemFont(ofSize: pointSize, weight: weigth)
    }

    private static func randomColor() -> UIColor {
        return UIColor(red: rnd() * 0.6, green: rnd() * 0.6, blue: rnd() * 0.6, alpha: 1)
    }

    private static func randomShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = randomColor()
        shadow.shadowBlurRadius = rnd() * 5
        shadow.shadowOffset = CGSize(width: rnd() * -5, height: rnd() * -5)
        return shadow
    }
}

fileprivate func rnd() -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
}

fileprivate extension NSRange {
    private init(string: String, lowerBound: String.Index, upperBound: String.Index) {
        let utf16 = string.utf16
        
        guard let lowerBound = lowerBound.samePosition(in: utf16),
              let upperBound = upperBound.samePosition(in: utf16)
        else {
            self.init(location: NSNotFound, length: 0)
            return
        }
        let location = utf16.distance(from: utf16.startIndex, to: lowerBound)
        let length = utf16.distance(from: lowerBound, to: upperBound)
        
        self.init(location: location, length: length)
    }
    
    init(range: Range<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
    
    init(range: ClosedRange<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
}

#if canImport(SwiftUI)
import SwiftUI


@available(iOS 13.0.0, *)
@available(tvOS 13.0.0, *)
public extension Text {
    static func random() -> Text {
        let idx = Int(round(rnd() * CGFloat(strings.count - 1)))
        let string = strings[idx]
        return Text(string)
    }
}

extension View {
    func randomShadow() -> some View {
        shadow(color: randomColor, radius: rnd() * 5, x: rnd() * -5, y: rnd() * -5)
    }
    
    func randomFont() -> some View {
        let pointSize = 20.0 + rnd() * 22.0
//        let weigth = Font.Weight(CGFloat(rnd() * 2 - 1))
        return font(Font.system(size: pointSize))
    }

    func randomForegroundColor() -> some View {
        foregroundColor(randomColor)
    }
    
    var randomColor: Color {
        Color(red: Double(rnd()) * 0.6, green: Double(rnd()) * 0.6, blue: Double(rnd()) * 0.6, opacity: 1)
    }
}

#endif
