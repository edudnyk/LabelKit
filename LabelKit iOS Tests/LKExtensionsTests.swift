//
//  LabelKit_iOS_Tests.swift
//  LabelKit iOS Tests
//
//  Created by Eugene Dudnyk on 20/07/2019.
//  Copyright © 2019 Imaginarium Works. All rights reserved.
//

import XCTest
@testable import LabelKit

class LKExtensionsTests : XCTestCase {

    func testFontWeightDecoding() {
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let dict = UIFont.lk_dictEncode(object: font)
        let font2 = UIFont.lk_dictDecode(dictionaryRepresentation: dict)
        XCTAssertEqual(font, font2)
    }
    
    func testColorDecoding() {
        let color = UIColor(red: 0.2, green: 0.4, blue: 0.3, alpha: 0.55)
        let dict = UIColor.lk_dictEncode(object: color)
        let color2 = UIColor.lk_dictDecode(dictionaryRepresentation: dict)
        XCTAssertEqual(color, color2)
    }
    
    func testParagraphStyleDecoding() {
        let ps = NSMutableParagraphStyle()
        ps.lineSpacing = 42
        let dict = NSParagraphStyle.lk_dictEncode(object: ps)
        let ps2 = NSParagraphStyle.lk_dictDecode(dictionaryRepresentation: dict)
        XCTAssertEqual(ps, ps2)
    }
    
    func testShadowDecoding() {
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.magenta
            let dict = NSShadow.lk_dictEncode(object: shadow)
            let shadow2 = NSShadow.lk_dictDecode(dictionaryRepresentation: dict)
            XCTAssertEqual(shadow, shadow2)
        }

    func testFontWeightDecodingPerformance() {
        // This is an example of a performance test case.
        self.measure {
            for _ in 0 ..< 1000 {
                let font = UIFont.systemFont(ofSize: 10 + rnd() * 20, weight: UIFont.Weight(rnd() * 2 - 1))
                let dict = UIFont.lk_dictEncode(object: font)
                let _ = UIFont.lk_dictDecode(dictionaryRepresentation: dict)
            }
        }
    }

    func rnd()->CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
    }
}
