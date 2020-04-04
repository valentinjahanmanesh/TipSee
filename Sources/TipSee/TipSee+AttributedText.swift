//
//  TipSee+AttributedText.swift
//  TipSee
//
//  Created by Adam Law on 02/03/2020.
//

import Foundation
import UIKit

extension TipSee {

	/// shows a bubble which points to the given view
	///
	/// - Parameters:
	///   - item: the view that we want to point at and a text for bubble
	///   - bubbleOption: custom options for bubble
	/// - Returns: generated item that can use to access to views or dismiss action
	@discardableResult
	public func show(for view: TipTarget, text string: NSAttributedString, with bubbleOption: Options.Bubble? = nil) -> TipItem {
		let viewToShow = createItem(for: view, text: string, with: bubbleOption)
		return self.show(item: viewToShow, with: bubbleOption)
	}

	@discardableResult
	public func createItem(for target: TipTarget, text: NSAttributedString, with bubbleOption: Options.Bubble? = nil) -> TipItem {
		return TipItem(ID: UUID().uuidString, pointTo: target, contentView: TipSee.createLabel(for: text, with: bubbleOption, defaultOptions: .default()) as UIView, bubbleOptions: bubbleOption)
	}

	/// creates a labelView for useing inside a bubble
	///
	/// - Parameter text: label text
	/// - Returns: generated label view
	private static func createLabel(
		for text: NSAttributedString,
		with itemOptions: Options.Bubble?,
		defaultOptions options: TipSee.Options
	) -> UILabel
	{
		let label = UILabel()
		label.attributedText = text
		label.textAlignment = .center
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.font = itemOptions?.font ?? options.bubbles.font
		label.sizeToFit()
		label.textColor = itemOptions?.foregroundColor ?? options.bubbles.foregroundColor
		return label
	}
}
