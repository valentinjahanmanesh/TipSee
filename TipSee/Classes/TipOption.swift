//
//  TipOption.swift
//  Pods
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation
extension TipSee {
	
	public  enum BubbleLiveDuration {
		case forever
		case untilNext
		//        case until(second:TimeInterval)
	}
	
	public enum HoleRadius {
		/// uses target view layer corner radius
		case keepTargetAreaCornerRadius
		
		/// sets constant radius for all
		case constantRadius(radius : CGFloat)
		
		/// sets a constant default value or uses the target view layer corner radius if it is greater that the default value
		case defaultOrGreater(default : CGFloat)
		
		/// no corner rradius
		case none
	}
	
	public struct Options: TipSeeConfiguration {
		public typealias BubblePosition = UIRectEdge
		public struct Bubble: TipSeeConfiguration {
			
			/// bubble's background color
			public  var backgroundColor: UIColor
			
			/// preferred position for the bubble
			public  var position: BubblePosition?
			
			/// text's font
			public  var font: UIFont
			
			/// text's color
			public  var foregroundColor: UIColor
			
			/// text's alignment
			public  var textAlignments: NSTextAlignment
			
			/// bubble's appearance animation (bounce + fade-in)
			public  var hasAppearAnimation: Bool
			
			/// distance between the bubble and the target view
			public  var padding: UIEdgeInsets = .zero
			
			/// whole tip(dim and bubble) should be dismiss when user is touched on the target area
			public  var dismissOnTargetAreaTap: Bool
			
			/// will execute when user taps on target area
			public var onTargetAreaTap : TapGesture?
			
			/// each tip could has a different dim color
			public var changeDimColor : UIColor?
			
			/// will execute when user taps on the bubble
			public var onBubbleTap : TapGesture?
			public static func `default`()->TipSee.Options.Bubble {
				return Options.Bubble(backgroundColor: .red, position: nil, font: UIFont.boldSystemFont(ofSize: 15), foregroundColor: UIColor.white, textAlignments: .center, hasAppearAnimation: true, padding: .init(top: 16, left: 16, bottom: 16, right: 16), dismissOnTargetAreaTap: false,onTargetAreaTap: nil,changeDimColor : nil,onBubbleTap: nil)
			}
			
		}
		
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
		
		/// if false, the dimTap Callback will not call. some times we need to let users to interact with the views behinde the dim
		public var absorbDimTouch : Bool
		
		/// if true, dim will fade after one second, combine this with absorbDimTouch if you want
		public var dimFading : Bool
		
		public static func `default`()->TipSee.Options {
			return Options(bubbles: Options.Bubble.default(), dimColor: UIColor.black.withAlphaComponent(0.7), bubbleLiveDuration: .forever, defaultBubblePosition: .left, holeRadius: .defaultOrGreater(default: 8), safeAreaInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),absorbDimTouch: true,dimFading: true)
		}
	}
}
