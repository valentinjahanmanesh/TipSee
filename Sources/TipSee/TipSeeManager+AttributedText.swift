//
//  TipSeeManager+AttributedText.swift
//  TipSee
//
//  Created by Adam Law on 03/01/2020.
//

import UIKit

extension TipSeeManager {

	/// Adds a tip which targets a given object conforming to `TipTarget`
	/// - Parameters:
	///   - target: Target object used for pinning the tip to.
	///   - string: Attributed tip text to show in the bubble.
	///   - bubbleOptions: Bubble appearance configuration options.
    public func add(
		new target: TipTarget,
		text string: NSAttributedString,
		with bubbleOptions: TipSee.Options.Bubble?)
	{
        self.tips.append(pointer.createItem(for: target, text: string, with: bubbleOptions))
    }
}
