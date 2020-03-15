//
//  TipSeeManagerProtocol.swift
//  TipSee
//
//  Created by Farshad on 10/30/19.
//

public protocol TipSeeManagerProtocol {
	/// removes the given item
	///
	/// - Parameter item: item to remove
	func dismiss(item: TipSee.TipItem)
	
	@discardableResult
	func show(for target: TipTarget, text string: String, with bubbleOption: TipSee.Options.Bubble?) -> TipSee.TipItem
	
	@discardableResult
	func createItem(for target: TipTarget, text string: String, with bubbleOption: TipSee.Options.Bubble?) -> TipSee.TipItem
	
	/// shows a bubble which points to the given view
	///
	/// - Parameters:
	///   - item: the view that you want to point at and a view that will show inside the bubble
	///   - bubbleOption: custom options for bubble
	/// - Returns: generated item that can use to access to views or dismiss action
	@discardableResult
	func show(item: TipSee.TipItem, with bubbleOption: TipSee.Options.Bubble?) -> TipSee.TipItem
	func finish()
}
