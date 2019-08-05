//  HintPointer.swift
//  Core
//
//  Created by Farshad Jahanmanesh on 7/2/19.
//  Copyright © 2019 Tap30. All rights reserved.
//

import Foundation
import UIKit



/// TipC needs would interact with this type only
public protocol HintTarget  {
	var hintFrame : CGRect {get}
	var cornersRadius : CGFloat {get}
}
extension HintTarget where Self : Hashable {
	public  static func ==(_ lhs : Self, rhs : Self)->Bool {
		return lhs.hintFrame == rhs.hintFrame
	}
}

extension UIView : HintTarget {
	public var cornersRadius: CGFloat {
		get {
			return self.layer.cornerRadius
		}
	}
	
	public var hintFrame: CGRect {
		guard let superView = self.superview else {
			return self.frame
		}
		let point = superView.convert(self.frame.origin, to: nil)
		return CGRect(origin: point, size: self.frame.size)
	}
}


/// HintTarget Type Erasure
public struct AnyHintTraget : HintTarget,Hashable {
	public 	var hintFrame : CGRect {return _hintTarget.hintFrame}
	public  var cornersRadius : CGFloat {return _hintTarget.cornersRadius}
	private var _hintTarget : HintTarget
	
	init(hintTarget : HintTarget){
		if Mirror(reflecting: hintTarget).displayStyle == .class {
			self._hintTarget = SimpleHintTarget(on: hintTarget.hintFrame, cornerRadius: hintTarget.cornersRadius)
		}else{
			self._hintTarget = hintTarget
		}
	}
	
	public func hash(into hasher: inout Hasher) {
		
	}
}

public struct SimpleHintTarget : HintTarget {
	public var hintFrame: CGRect
	public var cornersRadius: CGFloat
	public init(on target : CGRect,cornerRadius : CGFloat){
		self.hintFrame = target
		self.cornersRadius = cornerRadius
	}
}

/// Hint Items
public protocol HintItems: Equatable {
	var pointTo: AnyHintTraget {get set}
	var showView: UIView {get set}
	var bubbleOptions: HintPointer.Options.Bubble? {get set}
}

public class HintPointer: UIView, HintPointerManagerProtocol {
	public typealias TapGesture = ((HintItem) -> Void)
	/// properties
	public var options: Options = Options.default(){
		didSet{
			if options.dimColor != oldValue.dimColor {
				observeForDimColorChange()
			}
		}
	}
	fileprivate var shadowLayerPath: CGPath?
	fileprivate unowned var _window: UIWindow
	fileprivate var views = [HintItem]()
	fileprivate var bubbles = [BubbleView]()
	fileprivate var latestHint : HintItem!
	public var bubbleTap: TapGesture?
	public var dimTap : TapGesture?
	/// shows a bubble which points to the given view
	///
	/// - Parameters:
	///   - item: the view that we want to point at and a text for bubble
	///   - bubbleOption: custom options for bubble
	/// - Returns: generated item that can use to access to views or dismiss action
	@discardableResult public func show(for view : HintTarget,text string : String, with bubbleOption: Options.Bubble? = nil) -> HintItem {
		let viewToShow = createItem(for: view,text: string, with: bubbleOption)
		return self.show(item: viewToShow, with: bubbleOption)
	}
	
	@discardableResult public func createItem(for view : HintTarget,text : String, with bubbleOption: Options.Bubble? = nil) -> HintItem {
		return  HintItem.init(ID: UUID().uuidString, pointTo: view, showView: HintPointer.createLabel(for: text, with: bubbleOption,defaultOptions: self.options) as UIView, bubbleOptions: bubbleOption)
	}
	@discardableResult public static func createItem(for view : HintTarget,text : String, with bubbleOption: Options.Bubble? = nil) -> HintItem {
		return  HintItem.init(ID: UUID().uuidString, pointTo: view, showView: HintPointer.createLabel(for: text, with: bubbleOption,defaultOptions: .default()) as UIView, bubbleOptions: bubbleOption)
	}
	
	
	/// shows a bubble which points to the given view
	///
	/// - Parameters:
	///   - item: the view that you want to point at and a view that will show inside the bubble
	///   - bubbleOption: custom options for bubble
	/// - Returns: generated item that can use to access to views or dismiss action
	@discardableResult public func show(item: HintItem, with bubbleOption: Options.Bubble? = nil) -> HintItem {
		setupBackgroundDim()
		let viewToShow = HintItem.init(ID: item.ID.isEmpty ? UUID().uuidString : item.ID, pointTo: item.pointTo, showView: item.showView as UIView, bubbleOptions:  bubbleOption ?? item.bubbleOptions)
		
		switch options.bubbleLiveDuration {
		case .untilNext:
			if !views.isEmpty
			{
				views.forEach { (item) in
					self.dismiss(item: item)
				}
			}
		case .forever:
			break
			//        case .until(second: let _):
			//            break
		}
		
		self.views.append(viewToShow)
		bubbles.append(self.point(to: viewToShow))
		createHoleForVisibleViews()
		return viewToShow
	}
	
	private func setupBackgroundDim() {
		guard views.isEmpty else {return}
		//			if let old = _window.subviews.first(where: {($0 as? HintPointer) != nil}) {
		//				(old as! HintPointer).finish()
		//			}
		self.frame	 = _window.frame
		_window.addSubview(self)
		_window.bringSubviewToFront(self)
	}
	
	public func finish() {
		UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
			self.alpha = 0
		}) { (done) in
			if done {
				self.removeFromSuperview()
			}
		}
	}
	
	/// removes the given item
	///
	/// - Parameter item: item to remove
	public func dismiss(item: HintItem) {
		if let index  = self.views.lastIndex(where: {$0  == item}) {
			let bubble = self.bubbles[index]
			bubble.removeFromSuperview()
			self.bubbles.remove(at: index)
			self.views.remove(at: index)
			createHoleForVisibleViews()
		}
	}
	
	/// creates a labelView for useing inside a bubble
	///
	/// - Parameter text: label text
	/// - Returns: generated label view
	private static func createLabel(for text: String, with itemOptions: Options.Bubble?, defaultOptions options : HintPointer.Options) -> UILabel {
		let label = UILabel()
		label.text = text
		label.textAlignment = .center
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.sizeToFit()
		label.font = itemOptions?.font ?? options.bubbles.font
		label.textColor = itemOptions?.foregroundColor ?? options.bubbles.foregroundColor
		return label
	}
	
	private func createHoleForVisibleViews() {
		//shadowLayer?.removeFromSuperlayer()
		guard superview != nil else { return }
		let pathBigRect = UIBezierPath(rect: superview!.frame)
		if self.views.isEmpty {
			return
		}
		
		///
		var startPoint: CGPoint?
		let viewsSet = Set(self.views.map({$0.pointTo}))
		viewsSet.forEach { (targetView) in
			// cuts a hole inside the layer
			let cutPosition = targetView.hintFrame.insetBy(dx: -4, dy: -4)
			if startPoint == nil {
				startPoint = CGPoint(x: cutPosition.midX, y: cutPosition.midY)
			}
			var cornerRadius: CGFloat = 0
			switch options.holeRadius {
			case .constantRadius(radius: let radius):
				cornerRadius = radius
			case .defaultOrGreater(default: let radius):
				cornerRadius = max(radius, targetView.cornersRadius)
			case .keepTargetViewCornerRadius :
				cornerRadius = targetView.cornersRadius
			default:
				cornerRadius = 0
			}
			pathBigRect.append(UIBezierPath(roundedRect: cutPosition.insetBy(dx: -4, dy: -4), cornerRadius: cornerRadius))
		}
		pathBigRect.usesEvenOddFillRule = true
		options.dimColor = latestHint.bubbleOptions?.changeDimColor ?? options.dimColor
		self.cutHole(for: pathBigRect.cgPath, startPoint: startPoint)
	}
	//    private var mainWindow: UIWindow!
	public init(on window: UIWindow) {
		self._window = window
		super.init(frame: .zero)
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDim(_:)))
		self.addGestureRecognizer(tap)
	}
	
	@objc
	private func tapDim(_ sender: UITapGestureRecognizer) {
		dimTap?(latestHint)
	}
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// finds bubble size
	///
	/// - Parameters:
	///   - availableSpace: avialable space for bubble to fit in
	///   - view: view that live in bubble view
	/// - Returns: proper size
	private func findBubbleProperSize(for view: UIView,on availableSpace: CGSize? = nil) -> CGSize {
		var calculatedFrame = CGSize.zero
		let availableSpace = availableSpace ?? CGSize(width: UIScreen.main.bounds.width - (64), height: UIScreen.main.bounds.height)
		if let label = view as? UILabel, let text = label.text {
			calculatedFrame.height = text.height(font: label.font, widthConstraint: availableSpace.width) + 16
			calculatedFrame.width = text.width(font: label.font, widthConstraint: availableSpace.width, heightConstraint: self.frame.size.height) + 16
		}else {
			calculatedFrame = view.frame.insetBy(dx: -8, dy: -8).size
		}
		return calculatedFrame
	}
	
	/// creates a default bubble
	///
	/// - Parameter item: hint item
	/// - Returns: bubble view
	private func createDefaultBubble(for item: HintItem) -> BubbleView {
		
		let bubble = BubbleView(frame: .zero)
		
		bubble.frame.size = findBubbleProperSize(for: item.showView)
		bubble.alpha = 0
		bubble.backColor = item.bubbleOptions?.backgroundColor ?? self.options.bubbles.backgroundColor
		bubble.arrow = .init(position: .init(distance: .mid(offset: 0), edge: UIRectEdge.left.toCGRectEdge()), size: .init(width: 10, height: 5))
		
		return bubble
	}
	
	@objc
	private func tapBubble(_ sender: UITapGestureRecognizer) {
		guard let item = self.views.first(where:{item in item.ID == sender.identifier} )else {
			assertionFailure("Here we have to have that bubble(hint) but we can not find it")
			return
		}
		bubbleTap?(item)
	}
	/// points to the given(target) view by constrainting/Positioning the bubbleView and furthermore adds animation to newborn bubble
	///
	/// - Parameter item: hint item
	/// - Returns: baked bubble view
	private func point(to item: HintItem) -> BubbleView {
		self.latestHint = item
		let view = item.pointTo
		let label = item.showView
		let bubble = createDefaultBubble(for: item)
		self.addSubview(bubble)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBubble(_:)))
		tap.identifier = item.ID
		bubble.addGestureRecognizer(tap)
		
		// animates the bubble appearing
		if let animation = item.bubbleOptions?.animation, animation {
			bubble.transform = .init(scaleX: 0.5, y: 0.5)
			self.animateBubble {
				bubble.transform = .identity
				bubble.alpha = 1
			}
		}else {
			self.animateBubble {
				bubble.alpha = 1
			}
		}
		
		// binds constraints
		let pointTo = self.setBubbleConstraints(for: bubble, to: item)
		bubble.setContent(view: label, padding: 8)
		self.layoutIfNeeded()
		
		// align the arrow
		let center  =  CGPoint(x: view.hintFrame.midX, y: view.hintFrame.midY)
		
		if [.top, .bottom].contains(pointTo) {
			bubble.arrow = .init(position: .init(distance: .constant(center.x - bubble.frame.origin.x), edge: pointTo.toCGRectEdge()), size: .init(width: 10, height: 5))
		}else {
			bubble.arrow = .init(position: .init(distance: .mid(offset:0), edge: pointTo.toCGRectEdge()), size: .init(width: 10, height: 5))
		}
		
		return bubble
	}
	
	private func animateBubble(with:@escaping () -> Void) {
		UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveLinear, animations: {
			with()
		}, completion: nil)
	}
	/// you can choose your prefered position for bubble to be shown, but sometimes there are no enough space there for showing that bubble, this will find a better place for bubbleView
	///
	/// - Parameters:
	///   - view: target view
	/// - Returns: the better edge
	private func findBetterSpace(view: HintTarget, preferredPosition: UIRectEdge?) -> UIRectEdge {
		let reletivePosition = view.hintFrame
		
		var edges = [(UIRectEdge, Bool)]()
		
		var left = options.safeAreaInsets.left + options.bubbles.padding.right + 16
		
		var right = _window.bounds.width - (options.safeAreaInsets.right + options.bubbles.padding.left + 16)
		
		var top = options.safeAreaInsets.top + options.bubbles.padding.bottom + 16
		
		var bottom = _window.bounds.height - ( options.safeAreaInsets.bottom + options.bubbles.padding.top + 16)
		if #available(iOS 11.0, *) {
			bottom = _window.bounds.height - (_window.safeAreaInsets.bottom + options.safeAreaInsets.bottom + options.bubbles.padding.top + 16)
			
			top = options.safeAreaInsets.top + options.bubbles.padding.bottom + 16 + _window.safeAreaInsets.top
			
			right = _window.bounds.width - (_window.safeAreaInsets.right + options.safeAreaInsets.right + options.bubbles.padding.left + 16)
			
			left = options.safeAreaInsets.left + options.bubbles.padding.right + 16 + _window.safeAreaInsets.left
		}
		
		edges.append((.left, reletivePosition.minX > left))
		
		edges.append((.top, reletivePosition.minY > top))
		
		edges.append((.right, reletivePosition.maxX < right))
		
		edges.append((.bottom, reletivePosition.maxY < bottom))
		
		guard let doIHaveEnoughSpace = edges.first(where: {$0.0 == preferredPosition ?? options.defaultBubblePosition}), doIHaveEnoughSpace.1 else {
			return edges.first(where: {$0.0 != preferredPosition ?? options.defaultBubblePosition && $0.1})?.0 ?? options.defaultBubblePosition
		}
		return preferredPosition ?? options.defaultBubblePosition
	}
	
	/// sets constraints for bubble view and the taget view
	///
	/// - Parameters:
	///   - view: target view
	///   - bubble: bubble view
	///   - padding: space between bubble view and target view
	/// - Returns: bubble view arrow position
	private func setBubbleConstraints(for bubble: BubbleView, to item: HintItem) -> UIRectEdge {
		let view = item.pointTo
		let preferredPosition = item.bubbleOptions?.position
		let padding: UIEdgeInsets = item.bubbleOptions?.padding ?? UIEdgeInsets.all(16)
		let position  = findBetterSpace(view: view, preferredPosition: preferredPosition)
		var arrowPoint: UIRectEdge = .right
		
		//if view.transform != .identity {
		let targetFrame  = view.hintFrame
		let controllerSize = self._window.bounds.size
		switch position {
		case .left:
			arrowPoint = .right
			bubble.frame.size = findBubbleProperSize(for: item.showView, on: CGSize(width: abs(targetFrame.minX - (options.safeAreaInsets.totalX + padding.left)), height: controllerSize.height - options.safeAreaInsets.totalY))
			
			bubble.frame.origin = CGPoint(x: targetFrame.minX - (padding.right + bubble.frame.size.width), y: targetFrame.midY - bubble.frame.midY)
		case .right:
			arrowPoint = .left
			bubble.frame.size = findBubbleProperSize(for: item.showView, on: CGSize(width: (controllerSize.width - (options.safeAreaInsets.totalX + padding.left + targetFrame.maxX)), height: controllerSize.height))
			bubble.frame.origin = CGPoint(x: targetFrame.minX + targetFrame.size.width  + padding.left, y: targetFrame.midY - bubble.frame.midY)
		case .bottom:
			arrowPoint = .top
			bubble.frame.origin.y = targetFrame.maxY + padding.top
			bubble.center.x =  view.hintFrame.midX
			
		case .top:
			arrowPoint = .bottom
			bubble.frame.origin.y = targetFrame.minY - bubble.frame.size.height - padding.bottom
			bubble.center.x =  targetFrame.midX
		default:
			break
		}
		if bubble.frame.minX < options.safeAreaInsets.left {
			bubble.frame.origin.x = options.safeAreaInsets.left
		}
		if bubble.frame.maxX > controllerSize.width - options.safeAreaInsets.right {
			bubble.frame.origin.x -= ((bubble.frame.maxX - controllerSize.width) + options.safeAreaInsets.right)
		}
		return arrowPoint
		//}
	}
	
	private var holeLayer: CAShapeLayer?
	private enum animationSet {
		case path
		case fill
		case all
	}
	
	private func observeForDimColorChange(){
		guard let shadowPath = self.layer.sublayers?[0] as? CAShapeLayer,shadowPath.fillColor != options.dimColor.cgColor else {
			return
		}
			let pathAnimation = basicAnimation(key: "fillColor", duration: 0.2)
			pathAnimation.fromValue = shadowPath.fillColor
			pathAnimation.toValue = options.dimColor.cgColor
			shadowPath.add(pathAnimation, forKey: nil)
			shadowPath.fillColor = options.dimColor.cgColor
	}
	
	private func cutHole(for path: CGPath, startPoint: CGPoint? = nil) {
		
		let fillLayer = CAShapeLayer()
		
		fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
		fillLayer.fillColor = options.dimColor.cgColor
		
		guard let shadowPath = self.layer.sublayers?[0] as? CAShapeLayer else {
			self.layer.insertSublayer(fillLayer, at: 0)
			let height =  2 * max(_window.bounds.width, _window.bounds.height)
			var circleRect = CGRect(origin: startPoint  ?? .zero, size: .init(width: height, height: height))
			circleRect.origin.x -= height / 2
			circleRect.origin.y -= height / 2
			let base = UIBezierPath(rect: _window.bounds)
			
			base.append( UIBezierPath(roundedRect: circleRect, cornerRadius: height / 2))
			base.usesEvenOddFillRule = true
			addAniamtionsForShowTime(on: fillLayer, old: base.cgPath, new: path,force: true)
			fillLayer.path = path
			shadowLayerPath = path
			return
		}
//
//		if shadowPath.fillColor != fillLayer.fillColor {
//			let pathAnimation = basicAnimation(key: "fillColor", duration: 0.2)
//			pathAnimation.fromValue = shadowPath.fillColor
//			pathAnimation.toValue = fillLayer.fillColor
//			shadowPath.add(pathAnimation, forKey: nil)
//			shadowPath.fillColor = fillLayer.fillColor
//		}
//
		shadowPath.path = path
		addAniamtionsForShowTime(on: shadowPath, old: shadowLayerPath!, new: path)
		shadowLayerPath = path
	}
	
	private func addAniamtionsForShowTime(on layer : CAShapeLayer,old : CGPath,new : CGPath,force : Bool = false){
		if force || options.bubbleLiveDuration == .untilNext {
			/// i didn'nt use group animation because each animations has some different options and group animation will not support this
			let pathAnimation = basicAnimation(key: "path", duration: 0.2)
			pathAnimation.fromValue = old
			pathAnimation.toValue = new
			layer.add(pathAnimation, forKey: nil)
		}
		
		if  options.dimFading {
			let pathAnimation = basicAnimation(key: "fillColor", duration: 1)
			pathAnimation.toValue = UIColor.clear.cgColor
			pathAnimation.beginTime = CACurrentMediaTime()+2;
			layer.add(pathAnimation, forKey: nil)
		}
	}
	private func basicAnimation(key: String, duration: TimeInterval) -> CABasicAnimation {
		
		let animation = CABasicAnimation(keyPath: key)
		animation.duration = duration
		animation.isRemovedOnCompletion = false
		animation.fillMode = CAMediaTimingFillMode.forwards
		return animation
	}
}


public class BubbleView: UIView {
	public var insideView: UIView?
	private let cornerRadius: CGFloat = 4
	private lazy var shape: CAShapeLayer = {
		let shape = CAShapeLayer()
		shape.rasterizationScale = UIScreen.main.scale
		shape.shouldRasterize = true
		return shape
	}()
	
	var backColor: UIColor? {
		didSet { setNeedsLayout() }
	}
	
	public struct Arrow {
		public struct Position {
			public enum Distance {
				case mid(offset:CGFloat)
				case constant(_ offset:CGFloat)
			}
			public var distance: Distance
			public var edge: CGRectEdge
		}
		public var position: Position
		public var size: CGSize
	}
	
	public var arrow: Arrow = .init(position: .init(distance: .constant(0), edge: .minXEdge), size: .zero) {
		didSet { setNeedsLayout() }
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		//default value
		backgroundColor = .clear//UIColor(red: 0.18, green: 0.52, blue: 0.92, alpha: 1.0)
		
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureView() {
		layer.insertSublayer(shape, at: 0)
		backgroundColor = .clear
		layer.shadowOpacity = 0.2
		layer.shadowOffset = CGSize(width: 0, height: 1)
		layer.shadowRadius = 1.0
		layer.shadowColor = UIColor.black.cgColor
	}
	
	func setContent(view: UIView, padding: CGFloat = 0) {
		//remove all subviews
		self.subviews.forEach {
			$0.removeFromSuperview()
		}
		
		self.addSubview(view)
		insideView = view
		if self.translatesAutoresizingMaskIntoConstraints {
			view.frame.origin = CGPoint(x: padding, y: padding)
			view.frame.size = self.frame.insetBy(dx: padding, dy: padding).size
			view.removeConstraints(view.constraints)
		}else {
			view.translatesAutoresizingMaskIntoConstraints = false
			if #available(iOS 11.0, *) {
				view.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -padding).isActive = true
				view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: padding).isActive = true
				view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -padding).isActive = true
				view.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: padding).isActive = true
				
			} else {
				view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding).isActive = true
				view.topAnchor.constraint(equalTo: self.topAnchor, constant: padding).isActive = true
				view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding).isActive = true
				view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding).isActive = true
			}
		}
	}
	
	private func getStandardArrowCenterOffset() -> CGFloat {
		let minOffset = arrow.size.width/2 + cornerRadius
		let viewWidth = self.frame.width
		switch arrow.position.distance {
		case .mid(let offset):
			switch arrow.position.edge {
			case .maxYEdge, .minYEdge:
				return max(minOffset, min(offset +  self.bounds.midX, self.frame.width - minOffset))
			default :
				return max(minOffset, min(offset + self.bounds.midY, self.frame.height - minOffset))
			}
		case .constant(let offset):
			return max(minOffset, min(offset, viewWidth - minOffset))
		}
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		let path = UIBezierPath()
		
		let height = self.frame.height
		let width = self.frame.width
		let minX = self.bounds.minX
		let minY = self.bounds.minY
		let arrowWidth = arrow.size.width
		let arrowHeight = arrow.size.height
		let offset = getStandardArrowCenterOffset()
		
		switch arrow.position.edge {
		case .minYEdge:
			path.move(to: CGPoint(x: minX + offset - arrowWidth/2, y: minY))
			path.addLine(to: CGPoint(x: minX + offset, y: minY - arrowHeight))
			path.addLine(to: CGPoint(x: minX + offset + arrowWidth/2, y: minY))
		case .maxYEdge:
			path.move(to: CGPoint(x: minX + offset - arrowWidth/2, y: minY + height))
			path.addLine(to: CGPoint(x: minX + offset, y: minY + height + arrowHeight))
			path.addLine(to: CGPoint(x: minX + offset + arrowWidth/2, y: minY + height))
		case .maxXEdge:
			path.move(to: CGPoint(x: minX + width, y: minY + offset - arrowWidth/2))
			path.addLine(to: CGPoint(x: minX + width + arrowHeight, y: minY + offset))
			path.addLine(to: CGPoint(x: minX + width, y: minY + offset + arrowWidth/2))
		default:
			path.move(to: CGPoint(x: minX, y: minY + offset - arrowWidth/2))
			path.addLine(to: CGPoint(x: minX - arrowHeight, y: minY + offset))
			path.addLine(to: CGPoint(x: minX, y: minY + offset + arrowWidth/2))
		}
		
		let roundedRectPath = UIBezierPath(
			roundedRect: CGRect(x: minX, y: minY, width: width, height: height),
			cornerRadius: cornerRadius
		)
		
		path.append(roundedRectPath)
		shape.fillColor = backColor?.cgColor
		shape.path = path.cgPath
		
	}
}

extension UIRectEdge {
	fileprivate   func toCGRectEdge() -> CGRectEdge {
		switch self {
		case .top:
			return .minYEdge
		case .bottom :
			return .maxYEdge
		case .right :
			return .maxXEdge
		default:
			return .minXEdge
		}
	}
}

extension UIEdgeInsets {
	fileprivate static func all(_ value: CGFloat) -> UIEdgeInsets {
		return UIEdgeInsets.init(top: value, left: value, bottom: value, right: value)
	}
}

extension UIView {
	/// Helper to get pre transform frame
	var originalFrame: CGRect {
		let currentTransform = transform
		transform = .identity
		let originalFrame = frame
		transform = currentTransform
		return originalFrame
	}
	
	/// Helper to get point offset from center
	func centerOffset(_ point: CGPoint) -> CGPoint {
		return CGPoint(x: point.x - center.x, y: point.y - center.y)
	}
	
	/// Helper to get point back relative to center
	func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
		return CGPoint(x: point.x + center.x, y: point.y + center.y)
	}
	
	/// Helper to get point relative to transformed coords
	func newPointInView(_ point: CGPoint) -> CGPoint {
		// get offset from center
		let offset = centerOffset(point)
		// get transformed point
		let transformedPoint = offset.applying(transform)
		// make relative to center
		return pointRelativeToCenter(transformedPoint)
	}
	
	var newTopLeft: CGPoint {
		return newPointInView(originalFrame.origin)
	}
	
	var newTopRight: CGPoint {
		var point = originalFrame.origin
		point.x += originalFrame.width
		return newPointInView(point)
	}
	
	var newBottomLeft: CGPoint {
		var point = originalFrame.origin
		point.y += originalFrame.height
		return newPointInView(point)
	}
	
	var newBottomRight: CGPoint {
		var point = originalFrame.origin
		point.x += originalFrame.width
		point.y += originalFrame.height
		return newPointInView(point)
	}
}

extension String {
	func height(font: UIFont, widthConstraint: CGFloat) -> CGFloat {
		let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: widthConstraint, height: CGFloat.greatestFiniteMagnitude))
		label.numberOfLines = 0
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = font
		label.text = self
		
		label.sizeToFit()
		return label.frame.height
	}
	func width(font: UIFont, widthConstraint: CGFloat, heightConstraint: CGFloat) -> CGFloat {
		let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: widthConstraint, height: heightConstraint))
		label.numberOfLines = 0
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = font
		label.text = self
		
		label.sizeToFit()
		return label.frame.width
	}
}

extension UIEdgeInsets {
	fileprivate var totalX: CGFloat {
		return self.left + self.right
	}
	
	fileprivate var totalY: CGFloat {
		return self.top + self.bottom
	}
}

extension HintPointer {
	public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitted  = super.hitTest(point, with: event)
		if hitted == self, !options.absorbDimTouch {
			return nil
		}
		else if hitted == self, options.absorbDimTouch{
			return hitted
		}
		return hitted
	}
	public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		guard shadowLayerPath != nil  else {
			return false
		}
		let targetView = latestHint.pointTo
		let cutted = targetView.hintFrame.insetBy(dx: -4, dy: -4)
		let isInTheActionable = cutted.contains(point)
		if isInTheActionable,let option = latestHint.bubbleOptions {
			option.targetViewTap?(latestHint)
			//				if option.dismissOnTargetViewTap {
			//					self.finish()
			//				}
		}
		return !isInTheActionable
	}
}

extension HintPointer {
	
	public func options(_ options: HintPointer.Options) {
		self.options = options
	}
}

public protocol HintConfiguration {
	func with(_ mutations: (inout Self) -> Void) -> Self
}

extension HintConfiguration {
	public func with(_ mutations: (inout Self) -> Void) -> Self {
		var copyOfSelf = self
		mutations(&copyOfSelf)
		return copyOfSelf
	}
}

extension HintPointer {
	public struct HintItem: HintItems {
		public typealias ID = String
		public static func == (lhs: HintPointer.HintItem, rhs: HintPointer.HintItem) -> Bool {
			return lhs.ID == rhs.ID
		}
		public var ID: ID
		public var pointTo: AnyHintTraget
		public var showView: UIView
		public var bubbleOptions: HintPointer.Options.Bubble?
		public init(ID: String, pointTo: HintTarget, showView: UIView) {
			self.ID  = ID
			self.pointTo = AnyHintTraget.init(hintTarget: pointTo)
			self.showView = showView
		}
		
		public init(ID: String, pointTo: HintTarget, showView: UIView, bubbleOptions: HintPointer.Options.Bubble?) {
			self.ID  = ID
			self.pointTo = AnyHintTraget.init(hintTarget: pointTo)
			self.showView = showView
			self.bubbleOptions = bubbleOptions
		}
	}
	
	public  enum BubbleLiveDuration {
		case forever
		case untilNext
		//        case until(second:TimeInterval)
	}
	public enum HoleRadius {
		/// uses target view layer corner radius
		case keepTargetViewCornerRadius
		
		/// sets constant radius for all
		case constantRadius(radius : CGFloat)
		
		/// sets a constant default value or uses the target view layer corner radius if it is greater that the default value
		case defaultOrGreater(default : CGFloat)
		
		/// no corner rradius
		case none
	}
	public struct Options: HintConfiguration {
		public struct Bubble: HintConfiguration {
			public  var backgroundColor: UIColor
			
			/// preferred position for bubble based on target view
			public  var position: UIRectEdge?
			public  var font: UIFont
			public  var foregroundColor: UIColor
			public  var textAlignments: NSTextAlignment
			/// animation for the appearance
			public  var animation: Bool
			/// spaces between bubble view and target view
			public  var padding: UIEdgeInsets = .zero
			//			public  var dismissOnTargetViewTap: Bool
			public var targetViewTap : TapGesture?
			public var changeDimColor : UIColor?
			public static func `default`()->HintPointer.Options.Bubble {
				return Options.Bubble(backgroundColor: .red, position: nil, font: UIFont.boldSystemFont(ofSize: 15), foregroundColor: UIColor.white, textAlignments: .center, animation: true, padding: .init(top: 16, left: 16, bottom: 16, right: 16),targetViewTap: nil,changeDimColor : nil)
			}
			
		}
		public var bubbles: Bubble
		public var dimColor: UIColor
		/// bubbles life cycle
		public var bubbleLiveDuration: BubbleLiveDuration
		public var defaultBubblePosition: UIRectEdge
		public var holeRadius: HoleRadius
		public var safeAreaInsets: UIEdgeInsets
		// if false, the dimTap Callback will not call
		public var absorbDimTouch : Bool
		public var dimFading : Bool
		public static func `default`()->HintPointer.Options {
			return Options(bubbles: Options.Bubble.default(), dimColor: UIColor.black.withAlphaComponent(0.7), bubbleLiveDuration: .forever, defaultBubblePosition: .left, holeRadius: .defaultOrGreater(default: 8), safeAreaInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),absorbDimTouch: true,dimFading: true)
		}
	}
}

private var ExteraIDForTapGesture: String = ""
extension UITapGestureRecognizer {
	var identifier: String {
		set {
			ExteraIDForTapGesture = newValue
		}
		get {
			return ExteraIDForTapGesture
		}
	}
}

public protocol HintPointerManagerProtocol {
	/// removes the given item
	///
	/// - Parameter item: item to remove
	func dismiss(item: HintPointer.HintItem)
	
	@discardableResult
	func show(for view : HintTarget,text string : String, with bubbleOption: HintPointer.Options.Bubble?) -> HintPointer.HintItem
	
	@discardableResult
	func createItem(for view : HintTarget,text string : String, with bubbleOption: HintPointer.Options.Bubble?) -> HintPointer.HintItem
	
	/// shows a bubble which points to the given view
	///
	/// - Parameters:
	///   - item: the view that you want to point at and a view that will show inside the bubble
	///   - bubbleOption: custom options for bubble
	/// - Returns: generated item that can use to access to views or dismiss action
	@discardableResult
	func show(item: HintPointer.HintItem, with bubbleOption: HintPointer.Options.Bubble?) -> HintPointer.HintItem
	func finish()
}

