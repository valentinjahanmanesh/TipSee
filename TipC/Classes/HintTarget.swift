//
//  HintTarget.swift
//  Pods
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation

/// TipC needs would interact with this type only
public protocol HintTarget  {
	var hintFrame : CGRect {get}
	var cornersRadius : CGFloat {get}
}
extension HintTarget where Self : Hashable {
	public  static func ==(_ lhs : Self, rhs : Self)->Bool {
		return lhs.hintFrame == rhs.hintFrame
	}
}

extension UIView : HintTarget {
	public var cornersRadius: CGFloat {
		get {
			return self.layer.cornerRadius
		}
	}
	
	public var hintFrame: CGRect {
		guard let superView = self.superview else {
			return self.frame
		}
		let point = superView.convert(self.frame.origin, to: nil)
		return CGRect(origin: point, size: self.frame.size)
	}
}


/// HintTarget Type Erasure
public struct AnyHintTraget : HintTarget , Hashable {
	public 	var hintFrame : CGRect {return _hintTarget.hintFrame}
	public  var cornersRadius : CGFloat {return _hintTarget.cornersRadius}
	private var _hintTarget : HintTarget
	
	init(hintTarget : HintTarget){
		self._hintTarget = SimpleHintTarget(on: hintTarget.hintFrame, cornerRadius: hintTarget.cornersRadius)
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.hintFrame.origin.x)
		hasher.combine(self.hintFrame.origin.y)
		hasher.combine(self.hintFrame.width)
		hasher.combine(self.hintFrame.height)
		hasher.combine(self.cornersRadius)
	}
}

public struct SimpleHintTarget : HintTarget {
	public var hintFrame: CGRect
	public var cornersRadius: CGFloat
	public init(on target : CGRect,cornerRadius : CGFloat){
		self.hintFrame = target
		self.cornersRadius = cornerRadius
	}
}
