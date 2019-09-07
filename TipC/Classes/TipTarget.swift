//
//  TipTarget.swift
//  Pods
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation

/// TipC needs would interact with this type only
public protocol TipTarget  {
	var tipFrame : CGRect {get}
	var cornersRadius : CGFloat {get}
}
extension TipTarget where Self : Hashable {
	public  static func ==(_ lhs : Self, rhs : Self)->Bool {
		return lhs.tipFrame == rhs.tipFrame
	}
}

extension UIView : TipTarget {
	public var cornersRadius: CGFloat {
		get {
			return self.layer.cornerRadius
		}
	}
	
	public var tipFrame: CGRect {
		guard let superView = self.superview else {
			return self.frame
		}
		let point = superView.convert(self.frame.origin, to: nil)
		return CGRect(origin: point, size: self.frame.size)
	}
}


/// TipTarget Type Erasure
public struct AnyTipTraget : TipTarget , Hashable {
	public 	var tipFrame : CGRect {return _tipTarget.tipFrame}
	public  var cornersRadius : CGFloat {return _tipTarget.cornersRadius}
	private var _tipTarget : TipTarget
	
	init(tipTarget : TipTarget){
		self._tipTarget = SimpleTipTarget(on: tipTarget.tipFrame, cornerRadius: tipTarget.cornersRadius)
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.tipFrame.origin.x)
		hasher.combine(self.tipFrame.origin.y)
		hasher.combine(self.tipFrame.width)
		hasher.combine(self.tipFrame.height)
		hasher.combine(self.cornersRadius)
	}
}

public struct SimpleTipTarget : TipTarget {
	public var tipFrame: CGRect
	public var cornersRadius: CGFloat
	public init(on target : CGRect,cornerRadius : CGFloat){
		self.tipFrame = target
		self.cornersRadius = cornerRadius
	}
}
