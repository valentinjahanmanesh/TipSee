//
//  NSAttributedString+Size.swift
//  TipSee
//
//  Created by Adam Law on 01/03/2020.
//

extension NSAttributedString {
	func height(widthConstraint: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize(width: widthConstraint, height: CGFloat.greatestFiniteMagnitude),
									 options: [.usesLineFragmentOrigin, .usesFontLeading],
									 context: nil)
        return ceil(rect.size.height)
	}
	func width(widthConstraint: CGFloat, heightConstraint: CGFloat) -> CGFloat {
		let rect = self.boundingRect(with: CGSize(width: widthConstraint, height: heightConstraint),
									 options: [.usesLineFragmentOrigin, .usesFontLeading],
									 context: nil)
        return ceil(rect.size.width + 10)
	}
}
