
# LabelKit

A `UILabel` that does true animation of attributed text.

Usage >> [`instructions`](https://github.com/edudnyk/LabelKit/blob/master/README.md) <<

## Installation
- [CocoaPods](#cocoapods)
- [Carthage](#carthage)
- [Swift Package Manager](#swift-package-manager)
- [Manually](#manually)

# 

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To give `LabelKit` a try with an example project, run the following command: 

```bash
$ pod try LabelKit
```

To integrate `LabelKit` into your Xcode project, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '1.0'
use_frameworks!

target 'MyApp' do
  pod 'LabelKit', '~> 1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager that builds your dependencies and provides you with binary frameworks.

To install Carthage with [Homebrew](http://brew.sh/) use the following command:

```bash
$ brew update
$ brew install carthage
```
To integrate LabelKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "edudnyk/LabelKit" ~> 1.0
```
Build the framework:

```bash
$ carthage update
```
Then, drag the built `LabelKit.framework` into your Xcode project.

### Swift Package Manager

"The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies."

To integrate `LabelKit` into your project, specify it in your `Package.swift` file:

```swift
let package = Package(
    name: "MyApp",
    dependencies: [
        .Package(url: "https://github.com/edudnyk/LabelKit.git", majorVersion: 1)
    ]
)
```

Then run:

```bash
$ swift build
```

Or, alternatively:

```bash
$ swift package generate-xcodeproj
```

### Manually

Drag `LabelKit.xcodeproj` into your Xcode project.

 > It should appear nested underneath your application's blue project icon.
 
Click on the `+` button under the "Embedded Binaries" section of your app's target and select the `LabelKit.framework` that matches the desired platform.

## Credits
Similarities to [FeedKit](https://github.com/nmdias/FeedKit)'s impecable setup instructions are not a coincidence 😃

## License

LabelKit is released under the Simplified BSD license. See [LICENSE](https://github.com/edudnyk/LabelKit/blob/master/LICENSE) for details.



