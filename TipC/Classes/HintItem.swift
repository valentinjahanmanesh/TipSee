//
//  HintItem.swift
//  Pods
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation
/// Hint Items

extension HintPointer.HintItem {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.ID == rhs.ID
	}
}

extension HintPointer {
public struct HintItem: Equatable {
	public typealias ID = String
	public var ID: ID
	public var pointTo: AnyHintTraget
	public var showView: UIView
	public var bubbleOptions: HintPointer.Options.Bubble?
	public init(ID: String, pointTo: HintTarget, showView: UIView) {
		self.ID  = ID
		self.pointTo = AnyHintTraget.init(hintTarget: pointTo)
		self.showView = showView
	}
	
	public init(ID: String, pointTo: HintTarget, showView: UIView, bubbleOptions: HintPointer.Options.Bubble?) {
		self.ID  = ID
		self.pointTo = AnyHintTraget.init(hintTarget: pointTo)
		self.showView = showView
		self.bubbleOptions = bubbleOptions
	}
	}
}
