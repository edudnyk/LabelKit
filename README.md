# ![LabelKit](https://media.githubusercontent.com/media/edudnyk/LabelKit/master/LabelKit.gif)

[![build status](https://travis-ci.org/edudnyk/LabelKit.svg)](https://travis-ci.org/edudnyk/LabelKit)
[![cocoapods compatible](https://img.shields.io/badge/cocoapods-compatible-brightgreen.svg)](https://cocoapods.org/pods/LabelKit)
[![carthage compatible](https://img.shields.io/badge/carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![language](https://img.shields.io/badge/spm-compatible-brightgreen.svg)](https://swift.org)
[![swift](https://img.shields.io/badge/swift-5.0-orange.svg)](https://github.com/edudnyk/LabelKit/releases)

A `UILabel` that does true animation of attributed text.

It animates all text attributes that are possible to animate, unlike  `CATextLayer` that animates only font and color.

It also has a great support of multiline text animations while keeping almost all the benefits of being `UILabel`.

It uses CoreText text rendering instead of CoreGraphics text rendering of `CATextLayer`. That makes the text to look the same by advancement and line height as the text in regular `UILabel`. 

It is a great and simple building block for UI which implements material design.

## Features
- [x] [Documentation](https://edudnyk.github.io/LabelKit/index.html)
- [x] Unit Test Coverage

## Requirements

![xcode](https://img.shields.io/badge/xcode-11%2b-lightgrey.svg)
![ios](https://img.shields.io/badge/ios-9.0%2b-lightgrey.svg)
![tvos](https://img.shields.io/badge/tvos-9.0%2b-lightgrey.svg)
![mac os](https://img.shields.io/badge/mac%20os-10.15%2b-lightgrey.svg)

Installation >> [`instructions`](https://github.com/edudnyk/LabelKit/blob/master/INSTALL.md) <<

## Usage

You can use either `LKLabel` or `LKLabelLayer`, both support implicitly animatable text change. 
When the layer is hosted by `LKLabel`, animations of text during bounds change are more stable.

Animating text change in `LKLabel` can be something like this:
```swift
// Swift
self.label.superview.setNeedsLayout()
self.label.setNeedsLayout()
UIView.animate(withDuration: 3, delay: 0, options: [], animations: {
    self.label.attributedText = attributedText
    self.label.superview.layoutIfNeeded()
}, completion: nil)
```

```objective-c
// Objective-C
[self.label.superview setNeedsLayout];
[self.label setNeedsLayout];
[UIView animateWithDuration:3 delay:0 options:kNilOptions animations:^{
    self.label.attributedText = attributedText;
    [self.label.superview layoutIfNeeded];
} completion:nil];
```

Animating text change in `LKLabelLayer` can be something like this:
```swift
// Swift
CATransaction.begin()
CATransaction.setAnimationDuration(3.0)
labelLayer.attributedText = attributedText
CATransaction.commit()
```

```objective-c
// Objective-C
[CATransaction begin];
[CATransaction setAnimationDuration:3.0];
labelLayer.attributedText = attributedText;
[CATransaction commit];
```

> Refer to the [`documentation`](https://edudnyk.github.io/LabelKit/index.html) for the detailed description of possibilities.

## License

LabelKit is released under the Simplified BSD license. See [LICENSE](https://github.com/edudnyk/LabelKit/blob/master/LICENSE) for details.



