//
//  HintItem.swift
//  Pods
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation
/// Hint Items

extension HintPointer.HintItem {
	public static func == (lhs: HintPointer.HintItem, rhs: HintPointer.HintItem) -> Bool {
		return lhs.ID == rhs.ID
	}
}

extension HintPointer {
public struct HintItem: Equatable {
	public typealias ID = String
	public var ID: ID
	public var pointTo: AnyHintTraget
	public var contentView: UIView
	public var bubbleOptions: HintPointer.Options.Bubble?
	public init(ID: String, pointTo: HintTarget, contentView: UIView) {
		self.ID  = ID
		self.pointTo = AnyHintTraget.init(hintTarget: pointTo)
		self.contentView = contentView
	}
	
	public init(ID: String, pointTo: HintTarget, contentView: UIView, bubbleOptions: HintPointer.Options.Bubble?) {
		self.ID  = ID
		self.pointTo = AnyHintTraget.init(hintTarget: pointTo)
		self.contentView = contentView
		self.bubbleOptions = bubbleOptions
	}
	}
}
