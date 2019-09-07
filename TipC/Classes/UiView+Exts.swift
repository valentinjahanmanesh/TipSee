//
//  UiView+Exts.swift
//  Pods
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation
import UIKit
extension UIViewController  {
	var tipManager : TipC? {
		return self.view.window?.viewWithTag(9891248) as? TipC
	}
	
	fileprivate static func swizzleMethods(original: Selector, swizzled: Selector) {
		guard
			let originalMethod = class_getInstanceMethod(self, original),
			let swizzledMethod = class_getInstanceMethod(self, swizzled) else { return }
		method_exchangeImplementations(originalMethod, swizzledMethod)
	}
	
	@objc private func swizzled_keyboardListener_viewDidDisappear(_ animated: Bool) {
		swizzled_keyboardListener_viewDidDisappear(animated)
		self.tipManager?.finish()
	}
	
	fileprivate static let TipCViewDidAppearSwizzler: Void = {
		swizzleMethods(original: #selector(viewDidDisappear(_:)),
					   swizzled: #selector(swizzled_keyboardListener_viewDidDisappear))
	}()
}
