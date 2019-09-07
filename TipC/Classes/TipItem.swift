//
//  HintItem.swift
//  Pods
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation
/// Hint Items

extension TipC.TipItem {
	public static func == (lhs: TipC.TipItem, rhs: TipC.TipItem) -> Bool {
		return lhs.ID == rhs.ID
	}
}

extension TipC {
public struct TipItem: Equatable {
	public typealias ID = String
	public var ID: ID
	public var pointTo: AnyTipTraget
	public var contentView: UIView
	public var bubbleOptions: TipC.Options.Bubble?
	public init(ID: String, pointTo: TipTarget, contentView: UIView) {
		self.ID  = ID
		self.pointTo = AnyTipTraget.init(tipTarget: pointTo)
		self.contentView = contentView
	}
	
	public init(ID: String, pointTo: TipTarget, contentView: UIView, bubbleOptions: TipC.Options.Bubble?) {
		self.ID  = ID
		self.pointTo = AnyTipTraget.init(tipTarget: pointTo)
		self.contentView = contentView
		self.bubbleOptions = bubbleOptions
	}
	}
}
