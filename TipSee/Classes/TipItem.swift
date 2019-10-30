//
//  HintItem.swift
//  Pods
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation
/// Hint Items

extension TipSee.TipItem {
	public static func == (lhs: TipSee.TipItem, rhs: TipSee.TipItem) -> Bool {
		return lhs.ID == rhs.ID
	}
}

extension TipSee {
	public struct TipItem: Equatable {
		public typealias ID = String
		public var ID: ID
		public var pointTo: AnyTipTraget
		public var contentView: UIView
		public var bubbleOptions: TipSee.Options.Bubble?
		public init(ID: ID = UUID().uuidString, pointTo: TipTarget, contentView: UIView) {
			self.ID  = ID
			self.pointTo = AnyTipTraget.init(tipTarget: pointTo)
			self.contentView = contentView
		}
		
		public init(ID: ID = UUID().uuidString, pointTo: TipTarget, contentView: UIView, bubbleOptions: TipSee.Options.Bubble?) {
			self.ID  = ID
			self.pointTo = AnyTipTraget.init(tipTarget: pointTo)
			self.contentView = contentView
			self.bubbleOptions = bubbleOptions
		}
	}
}
