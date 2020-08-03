<p align="center">
<img src='Example/TipSee/images/TipSee.gif' height="600"/>
</p>


# TipSee
### TipSee is a lightweight and highly customizable library that helps you to show beautiful tips and hints.

[![CI Status](https://img.shields.io/travis/farshadjahanmanesh/TipSee.svg?style=flat)](https://travis-ci.org/farshadjahanmanesh/TipSee)
[![Version](https://img.shields.io/cocoapods/v/TipC.svg?style=flat)](https://cocoapods.org/pods/TipSee)
[![License](https://img.shields.io/cocoapods/l/TipC.svg?style=flat)](https://cocoapods.org/pods/TipSee)
[![Platform](https://img.shields.io/cocoapods/p/TipC.svg?style=flat)](https://cocoapods.org/pods/TipSee)

### To do:

- [x] Live change
- [x] Touchable target area
- [x] Animating between tips
- [x] Multipe Tip in the screen
- [x] Dim animation
- [x] bubble animation
- [x] multipleTip, one Location
- [ ] it is good for tip to follow it's target area movements

# What we can do with TipSee?
We can show interactive hints on top of the views or where ever we want but finding the best place to put the bubble (or custom view) is based on the TipSee's decision. it will find best place to show the hint by considering the available space and the content size, smartly. we can show custom views (like that heart) or simple text as you've seen in the Gif. Tips can point to all kind of views like button, images and ... or just a specific part of the view controller(like the hint that points to the center of the view in the gif) 


# Customization options: 
There are two types of configuration;
* Global, base configuration of all tips within a given instance of TipSee - **TipSee.Options**
* Individual tip configuration - **TipSee.Options.Bubble**

If a both a base and per tip configuration is set, then the per tip configuration will take precendence.

**Global Options**
```swift
public struct Options: TipSeeConfiguration {

  /// buble's options, bubbles will get the default if nothings set
  public var bubbles: Bubble

  /// default dim's color, each bubble could changes this color(optionaly) by setting the bubble.dimBackgroundColor
  public var dimColor: UIColor

  /// bubble's life cycle.
  /// forEver : bubbles will be visible and needs to be remove manualy by caliing dismiss(item), you can show multiple bubbles same time
  /// untilNext: everytime show() function is called, previous bubble(if exists) will remove and new one will present
  public var bubbleLiveDuration: BubbleLiveDuration

  /// indicates the default bubble's position, each bubble can has specific position by setting bubble.position
  public var defaultBubblePosition: BubblePosition

  /// specifies the hole's(Target Area) radius
  /// keepTargetAreaCornerRadius : uses target view layer corner radius
  /// constantRadius(radius) : sets constant radius for all
  /// defaultOrGreater(default) : sets a constant default value or uses the target view layer corner radius if it is greater that the default value
  /// none : no corner rradius
  public var holeRadius: HoleRadius

  /// indicates bubble's margin
  public var safeAreaInsets: UIEdgeInsets

  /// if true, dim will fade after one second
  public var dimFading: Bool

  /// default is false. It true, touches on the dimmed area will be passed through
  public var shouldPassTouchesThroughDimmingArea: Bool

  public var holePositionChangeDuration: TimeInterval
}
```
**Bubble Options**
```swift 
public struct Bubble: TipSeeConfiguration {
  
  /// bubble's background color
  public var backgroundColor: UIColor

  /// preferred position for the bubble
  public var position: BubblePosition?

  /// text's font
  public var font: UIFont

  /// text's color
  public var foregroundColor: UIColor

  /// text's alignment
  public var textAlignments: NSTextAlignment

  /// bubble's appearance animation (bounce + fade-in)
  public var hasAppearAnimation: Bool

  /// distance between the bubble and the target view
  public var padding: UIEdgeInsets = .zero

  /// default is false. It true, touches on target area will be passed through
  public var shouldPassTouchesThroughTargetArea: Bool

  /// will execute when user taps on target area
  public var onTargetAreaTap: TapGesture?

  /// each tip could has a different dim color
  public var changeDimColor: UIColor?

  /// Whole tip (dimming and bubble) should be dismissed when user taps on the target area.
  public var shouldFinishOnTargetAreaTap: Bool

  /// Whole tip (dimming and bubble) should be dismissed when user taps on the surronding dimmed area.
  public var shouldFinishOnDimmedAreaTap: Bool

  /// Whole tip (dimming and bubble) should be dismissed when user taps on the bubble.
  public var shouldFinishOnBubbleTap: Bool

  /// will execute when user taps on the bubble
  public var onBubbleTap: TapGesture?
}
```

## Actions
TipSee has four actions which we can react to them to handle some situations 
  1. **Bubble.onBubbleTap** when user clicks on the bubble view, we can access to tapped bubble and item 
  2. **Bubble.onTargetAreaTap** when user click on target area
  3. **HintObject.onDimTap** when user clicks on dim(background), we can access to latest hint on the screen 
  4. **HintObject.onBubbleTap** when user clicks on bubble, this is default action if the bubble has not specified one for itself

## Tip Lifecycle 
based on what we set for **bubbleLiveDuration** in options, tips have a life duration which means that tips should be on the screen until user taps on them to dismiss or should be removed  before new one is appearing 

## How To Use
first thing is setuping your option (or using default option) and then creating a new instance of TipSee
```swift 
  let defaultTipOption = TipSee.Options
			.default()
			.with {
				$0.dimColor =  UIColor.black.withAlphaComponent(0.3)
				$0.bubbleLiveDuration = .untilNext
				$0.dimFading = false
	}
  
  // TipSee needs a window to show it's content in it
  let tipsee = TipSee(on: self.view.window!)
  
  // shows a simple text(tip) that is pointed to the view(pugImage), this tip has not specific configuration
  // so it will use default one
	tipSee.show(for: self.pugImage, text: "good boy")
  ```
  
  or you can create a custom tip with customized configuration 
```swift 
  // creates new custom item with custom configs
  let pugLoveConfig = TipSee.Options.Bubble
        .default()
        .with{
            $0.backgroundColor = .clear
            $0.foregroundColor = .black
            $0.textAlignments = .left
            $0.padding = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
            $0.position = .top
        }
  tipSee.show(item TipSee.TipItem.init(ID: "100", pointTo: self.pugImage, contentView: image,bubbleOptions: pugLoveConfig))
  
```

in above exmaple wee need to handle tip sequence ourselves. next, previous, presenting or dismissing should be handled by using the actions like bubble tap, target area tap, dimtap and ... but there is a slideshow extension which we talk in neext section that helps us with these things.

## TipSeeManager
TipSee manager is a helper class that gives us the ability to have a slideshow like Tips. this manager handles tips array and provides handy apis (next, previous). we can add tips as many as we want and then start the sequence by calling **.next()**

```swift
let defaultTipOption = TipSee.Options
			.default()
			.with {
				$0.dimColor =  UIColor.black.withAlphaComponent(0.3)
				$0.bubbleLiveDuration = .untilNext
				$0.dimFading = false
		}
				
 let tipManager = TipcManager(on: self.view.window!,with: defaultTipOption)
 tipManager.add(new: TipSee.TipItem.init(ID: "100", pointTo: self.pugImage, contentView: image,bubbleOptions: pugLoveConfig))       
 tipManager.add(new: self.pugImage,text:"best dog ever <3 <3 ^_^ ^_^",with: pugDescriptionConfig.with{$0.position = .right})
 tipManager.add...
 ...
 ...
 ...
 
 tipManager.next()

```


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
this library doe's not need any requirement and has written in Swift5.
## Installation

#### Using [CocoaPods](https://cocoapods.org)

Edit your `Podfile` and specify the dependency:

```ruby
pod 'TipSee'
```

#### Using [Swift Package Manager](https://github.com/apple/swift-package-manager)

Once you have your Swift package set up, adding `TipSee` as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
  dependencies: [
    .package(url: "https://github.com/farshadjahanmanesh/TipSee.git", from: "1.6.0")
  ]
```

## Author
farshadjahanmanesh, farshadjahanmanesh@gmail.com

## Contributors 
 [lawmaestro](https://github.com/lawmaestro)

## License

TipSee is available under the MIT license. See the LICENSE file for more info. the demo's design is something that i've took from dribbble and is blong to https://dribbble.com/harshgopal
