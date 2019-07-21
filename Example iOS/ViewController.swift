//
//  ViewController.swift
//  Example iOS
//
//  Created by Eugene Dudnyk on 15/07/2019.
//  Copyright © 2019 Imaginarium Works. All rights reserved.
//

import UIKit
import LabelKit

class ViewController: UIViewController {
    let strings = ["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis scelerisque semper diam in pharetra. Nullam ultrices varius enim ac ultrices. In convallis felis leo, sit amet mollis nisl sodales in. Mauris ut bibendum tortor. Praesent sollicitudin lacus nec lorem finibus convallis. Quisque quis ultricies ante, id malesuada nibh. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Quisque a vehicula ligula. Duis quis mauris porttitor, pulvinar elit ut, maximus dolor. Cras et sem vitae nisl accumsan porta non in quam. Nullam molestie, ipsum ut convallis iaculis, dui nibh facilisis mi, quis porta mi sem nec augue. Nulla elit sem, tempor id elit vitae, bibendum lacinia urna.",

        "Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nam sed sapien lobortis, posuere neque sit amet, vulputate nisl. Nullam quis enim venenatis, porttitor risus nec, ullamcorper dolor. Pellentesque dictum risus lacus, a sodales elit bibendum eu. Vivamus sit amet dignissim ante. Nunc imperdiet porttitor commodo. Aenean in hendrerit est. Interdum et malesuada fames ac ante ipsum primis in faucibus. Donec et purus id diam blandit varius. Pellentesque orci est, varius non fermentum vitae, condimentum eget ex. Mauris placerat, elit non blandit pretium, risus neque suscipit felis, vel facilisis est eros non turpis.",

        "Donec at maximus enim, non dapibus nisl. Nunc porta lectus ante, nec maximus tortor rhoncus sed. Sed in malesuada nisi. In congue dignissim elit, sit amet vehicula massa. Aliquam non justo elit. In finibus diam lectus, et convallis ligula iaculis sit amet. Morbi eu interdum eros. Quisque ut scelerisque quam, lobortis hendrerit ligula. Pellentesque sit amet arcu est. Donec facilisis convallis ligula ac interdum.",

        "Curabitur ornare ex quis nunc eleifend efficitur. Donec nisl nulla, eleifend eget justo vel, rhoncus condimentum risus. Nulla erat nunc, lacinia sed commodo a, finibus efficitur ipsum. Ut ut maximus augue, vel consequat lacus. Integer quis aliquet quam, at condimentum dui. Pellentesque quis pellentesque lectus, at luctus quam. Vestibulum libero ligula, blandit non metus in, sollicitudin lacinia nisi. Morbi nulla arcu, cursus sed erat at, maximus finibus libero. Proin efficitur, diam nec blandit feugiat, erat nisi aliquet elit, ut venenatis augue ante et tortor. Maecenas finibus, dui id malesuada interdum, massa risus convallis dui, in sagittis lorem justo a elit.",

        "Quisque lobortis malesuada fermentum. Fusce nunc ipsum, hendrerit nec fermentum nec, vulputate at justo. Aenean lobortis dignissim lorem. Sed dapibus ligula a ante ullamcorper laoreet et pretium ex. Nulla a tincidunt dolor, ut sagittis diam. Suspendisse nec erat ullamcorper, rutrum leo nec, consectetur dolor. Aliquam sodales condimentum massa non faucibus. Nam euismod id sapien id consequat.",]
    
    var timer : Timer?
    @IBOutlet var label: LKLabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            view.setNeedsLayout()
            label.setNeedsLayout()
            self.label.attributedText = self.randomAttributedText()
            view.layoutIfNeeded()
        }
        startAnimation()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimation()
    }

    func startAnimation() {
        timer = Timer(timeInterval: 3, target: self, selector: #selector(updateText), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .default)
        updateText()
    }
    
    func stopAnimation() {
        timer?.invalidate()
    }
    
    @objc func updateText() {
        view.setNeedsLayout()
        label.setNeedsLayout()
        UIView.animate(withDuration: 3, delay: 0, options: [], animations: {
            self.label.attributedText = self.randomAttributedText()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func randomAttributedText()->NSAttributedString {
        let idx = Int(round(rnd() * CGFloat(strings.count - 1)))
        let string = strings[idx]
        let attributedText = NSMutableAttributedString(string: string)
        attributedText.beginEditing()
        attributedText.addAttributes([.foregroundColor : self.randomColor(),
                                      .font : self.randomFont(),
                                      .shadow : self.randomShadow() ], range: NSRange(string.startIndex..<string.endIndex, in: string))
        attributedText.endEditing()
        return attributedText
    }
    
    func rnd()->CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
    }
    
    func randomFont()->UIFont {
        let pointSize = 10.0 + rnd() * 22.0
        let weigth = UIFont.Weight(CGFloat(rnd() * 2 - 1))
        return UIFont.systemFont(ofSize: pointSize, weight: weigth)
    }
    
    func randomColor()->UIColor {
        return UIColor(red: rnd() * 0.6, green: rnd() * 0.6, blue: rnd() * 0.6, alpha: 1)
    }
    
    func randomShadow()->NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = randomColor()
        shadow.shadowBlurRadius = rnd() * 5
        shadow.shadowOffset = CGSize(width: rnd() * -5, height: rnd() * -5)
        return shadow
    }
}

public extension NSRange {
    private init(string: String, lowerBound: String.Index, upperBound: String.Index) {
        let utf16 = string.utf16
        
        guard let lowerBound = lowerBound.samePosition(in: utf16),
            let upperBound = upperBound.samePosition(in: utf16) else {
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
