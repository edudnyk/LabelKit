//
//  ViewController.swift
//  LabelKit - Example iOS
//
//  Copyright (c) 2019-2020 Eugene Dudnyk
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

import LabelKit
import UIKit

class ViewController: UIViewController {
    var timer: Timer?
    @IBOutlet var label: LKLabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            label.attributedText = NSAttributedString.createRandom()
        }
        startAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimation()
    }

    func startAnimation() {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: 3, target: self, selector: #selector(updateText), userInfo: nil, repeats: true)
        self.timer = timer
        RunLoop.current.add(timer, forMode: .default)
        updateText()
    }
    
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateText() {
        view.setNeedsLayout()
        label.setNeedsLayout()
        UIView.animate(withDuration: 3, delay: 0, options: [], animations: {
            self.label.attributedText = NSAttributedString.createRandom()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
