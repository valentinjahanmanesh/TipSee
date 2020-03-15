//
//  TipSeeConfiguration.swift
//  TipSee
//
//  Created by Farshad on 10/30/19.
//

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
