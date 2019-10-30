//
//  TipSeeWith.swift
//  Pods-TipSee_Example
//
//  Created by Farshad on 10/30/19.
//

import Foundation

public protocol TipSeeConfiguration {
	func with(_ mutations: (inout Self) -> Void) -> Self
}

extension TipSeeConfiguration {
	public func with(_ mutations: (inout Self) -> Void) -> Self {
		var copyOfSelf = self
		mutations(&copyOfSelf)
		return copyOfSelf
	}
}
