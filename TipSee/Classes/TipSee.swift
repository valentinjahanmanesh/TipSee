//  TipSee.swift
//  TipSee
//
//  Created by Farshad Jahanmanesh on 7/2/19.
//  Copyright © 2019 Tap30. All rights reserved.
//

public class TipSee: UIView, TipSeeManagerProtocol {
	public typealias TapGesture = ((TipItem) -> Void)
	/// properties
	public var options: Options = Options.default(){
		didSet{
			if options.dimColor != oldValue.dimColor {
				observeForDimColorChange()
			}
		}
	}
	
	fileprivate var shadowLayerPath: CGPath?
	fileprivate unowned let _window: UIWindow
	fileprivate lazy var views : [TipItem] = {
		attachToWindow()
		return [TipItem]()
	}()
	
	fileprivate lazy var bubbles = {return [BubbleView]()}()
	fileprivate var latestTip : TipItem?
	
	/// in a very odd situation, hit test called twice and we want to prevent multiple calls to our functions
	fileprivate var touched : (view:UIView?,timeStamp: Date?)
	public var onBubbleTap: TapGesture?
	public var onDimTap : TapGesture?
	/// shows a bubble which points to the given view
	///
	/// - Parameters:
	///   - item: the view that we want to point at and a text for bubble
	///   - bubbleOption: custom options for bubble
	/// - Returns: generated item that can use to access to views or dismiss action
	@discardableResult public func show(for view : TipTarget,text string : String, with bubbleOption: Options.Bubble? = nil) -> TipItem {
		let viewToShow = createItem(for: view,text: string, with: bubbleOption)
		return self.show(item: viewToShow, with: bubbleOption)
	}
	
	@discardableResult public func createItem(for target: TipTarget, text: String, with bubbleOption: Options.Bubble? = nil) -> TipItem {
		return TipItem(ID: UUID().uuidString, pointTo: target, contentView: TipSee.createLabel(for: text, with: bubbleOption, defaultOptions: self.options) as UIView, bubbleOptions: bubbleOption)
	}
	@discardableResult public static func createItem(for target: TipTarget, text: String, with bubbleOption: Options.Bubble? = nil) -> TipItem {
		return TipItem(ID: UUID().uuidString, pointTo: target, contentView: TipSee.createLabel(for: text, with: bubbleOption, defaultOptions: .default()) as UIView, bubbleOptions: bubbleOption)
	}
	
	private final func clearAllViews(){
		guard  !views.isEmpty else{return}
		views.forEach { (item) in
			self.dismiss(item: item)
		}
	}
	
	private final func store(tip : TipItem,bubble : BubbleView){
		self.latestTip = tip
		self.views.append(tip)
		self.bubbles.append(bubble)
	}
	
	private final func deStore(index : Int){
		if self.bubbles.count > index {
			self.bubbles.remove(at: index)
		}
		if self.views.count > index{
			self.views.remove(at: index)
		}
	}
	
	/// shows a bubble which points to the given view
	///
	/// - Parameters:
	///   - item: the view that you want to point at and a view that will show inside the bubble
	///   - bubbleOption: custom options for bubble
	/// - Returns: generated item that can use to access to views or dismiss action
	@discardableResult public func show(item: TipItem, with bubbleOption: Options.Bubble? = nil) -> TipItem {
		let tip = TipItem(ID: item.ID.isEmpty ? UUID().uuidString : item.ID, pointTo: item.pointTo, contentView: item.contentView as UIView, bubbleOptions:  bubbleOption ?? item.bubbleOptions)
		if options.bubbleLiveDuration == .untilNext {
			clearAllViews()
		}
		store(tip: tip, bubble: self.point(to: tip))
		createHoleForVisibleViews()
		return tip
	}
	
	private final func attachToWindow() {
		self.frame	 = _window.frame
		self.tag = 9891248
		_window.addSubview(self)
		_window.bringSubviewToFront(self)
	}
	
	
	/// has animation
	public func finish() {
		UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: [], animations: {
			self.alpha = 0
		}) { (done) in
			if done {
				self.removeFromSuperview()
			}
		}
	}
	
	/// removes the given item. it will finish tipPointer after dismissing if this is the last item in tips array, if you plan to show another item on dimissal(one by one) create an array of items and add them to the tipPointer and set the bubbleLiveDuration == .untilNext.
	///
	/// - Parameter item: item to remove
	public func dismiss(item: TipItem) {
		if let index  = self.views.lastIndex(where: {$0  == item}) {
			let bubble = self.bubbles[index]
			bubble.removeFromSuperview()
			deStore(index: index)
			createHoleForVisibleViews()
		}
	}
	
	private final func createHoleForVisibleViews() {
		//shadowLayer?.removeFromSuperlayer()
		guard superview != nil else { return }
		let pathBigRect = UIBezierPath(rect: superview!.frame)
		if self.views.isEmpty {
			return
		}
		
		///
		var startPoint: CGPoint?
		let viewsSet = Set(self.views.map({$0.pointTo}))
		viewsSet.forEach { (targetArea) in
			// cuts a hole inside the layer
			let cutPosition = targetArea.tipFrame.insetBy(dx: -4, dy: -4)
			if startPoint == nil {
				startPoint = CGPoint(x: cutPosition.midX, y: cutPosition.midY)
			}
			var cornerRadius: CGFloat = 0
			switch options.holeRadius {
			case .constantRadius(radius: let radius):
				cornerRadius = radius
			case .defaultOrGreater(default: let radius):
				cornerRadius = max(radius, targetArea.cornersRadius)
			case .keepTargetAreaCornerRadius :
				cornerRadius = targetArea.cornersRadius
			default:
				cornerRadius = 0
			}
			pathBigRect.append(UIBezierPath(roundedRect: cutPosition.insetBy(dx: -4, dy: -4), cornerRadius: cornerRadius))
		}
		pathBigRect.usesEvenOddFillRule = true
		options.dimColor = latestTip?.bubbleOptions?.changeDimColor ?? options.dimColor
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
		guard let latestTip = latestTip else {
			assertionFailure("here, POINTER have to have a tip, so check if something wrong")
			return
		}
		onDimTap?(latestTip)
	}
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc
	private func tapBubble(_ sender: UITapGestureRecognizer) {
		guard let item = self.views.first(where:{item in item.ID == sender.identifier} )else {
			assertionFailure("Here we have to have that bubble(tip) but we can not find it")
			return
		}
		if let customGesture = item.bubbleOptions?.onBubbleTap {
			customGesture(item)
		}else{
			onBubbleTap?(item)
			
		}
	}
	
	/// points to the given(target) view by constrainting/Positioning the bubbleView and furthermore adds animation to newborn bubble
	///
	/// - Parameter item: tip item
	/// - Returns: baked bubble view
	private final func point(to item: TipItem) -> BubbleView {
		self.latestTip = item
		let view = item.pointTo
		let label = item.contentView
		let bubble = defaultBubble(for: item, defaultOptions: options)
			.setProperSizeWith(content: label)
		
		self.addSubview(bubble)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBubble(_:)))
		tap.identifier = item.ID
		bubble.addGestureRecognizer(tap)
		
		// animates the bubble appearing
		if let animation = item.bubbleOptions?.hasAppearAnimation, animation {
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
		let arrowInstalledPosition = self.setBubbleConstraints(for: bubble, to: item)
		bubble.setContent(view: label, padding: 8)
		self.layoutIfNeeded()
		
		// align the arrow
		let center  =  CGPoint(x: view.tipFrame.midX, y: view.tipFrame.midY)
		
		if [.top, .bottom].contains(arrowInstalledPosition) {
			bubble.arrow = .init(position: .init(distance: .constant(center.x - bubble.frame.origin.x), edge: arrowInstalledPosition.toCGRectEdge()), size: .init(width: 10, height: 5))
		}else {
			bubble.arrow = .init(position: .init(distance: .mid(offset:0), edge: arrowInstalledPosition.toCGRectEdge()), size: .init(width: 10, height: 5))
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
	private func findBetterSpace(view: TipTarget, preferredPosition: UIRectEdge?, bubblePrefereddSize: CGRect?) -> UIRectEdge {
		let reletivePosition = view.tipFrame
		
		var edges = [(UIRectEdge, Bool)]()
		
		var left = options.safeAreaInsets.left + options.bubbles.padding.right + 16 + (bubblePrefereddSize?.width ?? 0)
		
		var right = _window.bounds.width - (options.safeAreaInsets.right + options.bubbles.padding.left + 16) - (bubblePrefereddSize?.width ?? 0)
		
		var top = options.safeAreaInsets.top + options.bubbles.padding.bottom + 16 + (bubblePrefereddSize?.height ?? 0)
		
		var bottom = _window.bounds.height - ( options.safeAreaInsets.bottom + options.bubbles.padding.top + 16) + (bubblePrefereddSize?.height ?? 0)
		if #available(iOS 11.0, *) {
			bottom = _window.bounds.height - (_window.safeAreaInsets.bottom + options.safeAreaInsets.bottom + options.bubbles.padding.top + 16) + (bubblePrefereddSize?.height ?? 0)
			
			top = options.safeAreaInsets.top + options.bubbles.padding.bottom + 16 + _window.safeAreaInsets.top + (bubblePrefereddSize?.height ?? 0)
			
			right = _window.bounds.width - (_window.safeAreaInsets.right + options.safeAreaInsets.right + options.bubbles.padding.left + 16) - (bubblePrefereddSize?.width ?? 0)
			
			left = options.safeAreaInsets.left + options.bubbles.padding.right + 16 + _window.safeAreaInsets.left + (bubblePrefereddSize?.width ?? 0)
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
	private func setBubbleConstraints(for bubble: BubbleView, to item: TipItem) -> UIRectEdge {
		let view = item.pointTo
		let preferredPosition = item.bubbleOptions?.position
		let padding = item.bubbleOptions?.padding ?? UIEdgeInsets.all(16)
		let position = findBetterSpace(view: view, preferredPosition: preferredPosition, bubblePrefereddSize: bubble.frame)
		var arrowPoint: UIRectEdge = .right
		
		let targetFrame  = view.tipFrame
		let controllerSize = self._window.bounds.size
		switch position {
		case .left:
			arrowPoint = .right
			bubble.frame.size = findBubbleProperSize(for: item.contentView, on: CGSize(width: abs(targetFrame.minX - (options.safeAreaInsets.totalX + padding.left)), height: controllerSize.height - options.safeAreaInsets.totalY))
			
			bubble.frame.origin = CGPoint(x: targetFrame.minX - (padding.right + bubble.frame.size.width), y: targetFrame.midY - bubble.frame.midY)
		case .right:
			arrowPoint = .left
			bubble.frame.size = findBubbleProperSize(for: item.contentView, on: CGSize(width: (controllerSize.width - (options.safeAreaInsets.totalX + padding.left + targetFrame.maxX)), height: controllerSize.height))
			bubble.frame.origin = CGPoint(x: targetFrame.minX + targetFrame.size.width  + padding.left, y: targetFrame.midY - bubble.frame.midY)
		case .bottom:
			arrowPoint = .top
			bubble.frame.origin.y = targetFrame.maxY + padding.top
			bubble.center.x =  view.tipFrame.midX
			
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
	
	private final func cutHole(for path: CGPath, startPoint: CGPoint? = nil) {
		
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
		
		shadowPath.path = path
		addAniamtionsForShowTime(on: shadowPath, old: shadowLayerPath!, new: path)
		shadowLayerPath = path
	}
	
	private final func addAniamtionsForShowTime(on layer : CAShapeLayer,old : CGPath,new : CGPath,force : Bool = false){
		let pathAnimation = basicAnimation(key: "path", duration: self.options.holePositionChangeDuration)
		pathAnimation.fromValue = options.bubbleLiveDuration == .untilNext ? old : new
		pathAnimation.toValue = new
		layer.add(pathAnimation, forKey: nil)
		
		
		if  options.dimFading {
			let fillColorAnimation = basicAnimation(key: "fillColor", duration: 1)
			fillColorAnimation.toValue = UIColor.clear.cgColor
			fillColorAnimation.beginTime = CACurrentMediaTime()+2;
			layer.add(fillColorAnimation, forKey: nil)
		}
	}
	private final func basicAnimation(key: String, duration: TimeInterval) -> CABasicAnimation {
		
		let animation = CABasicAnimation(keyPath: key)
		animation.duration = duration
		animation.isRemovedOnCompletion = false
		animation.fillMode = CAMediaTimingFillMode.forwards
		return animation
	}
}

fileprivate extension UIRectEdge {
	func toCGRectEdge() -> CGRectEdge {
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

fileprivate extension UIEdgeInsets {
	static func all(_ value: CGFloat) -> UIEdgeInsets {
		return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
	}
	
	var totalX: CGFloat {
		return self.left + self.right
	}
	
	var totalY: CGFloat {
		return self.top + self.bottom
	}
}

extension String {
	func height(font: UIFont, widthConstraint: CGFloat) -> CGFloat {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: widthConstraint, height: CGFloat.greatestFiniteMagnitude))
		label.numberOfLines = 0
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = font
		label.text = self + "  "

		label.sizeToFit()
		return label.frame.height
	}
	func width(font: UIFont, widthConstraint: CGFloat, heightConstraint: CGFloat) -> CGFloat {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: widthConstraint, height: heightConstraint))
		label.numberOfLines = 0
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = font
		label.text = self + "  "

		label.sizeToFit()
		return label.frame.width
	}
}

/// Overrides HitTest and Point inside
extension TipSee {
	public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		guard self.touched.timeStamp == nil else {
			let touchedView = self.touched.view
			self.touched = (nil,nil)
			return touchedView
		}
		let hitted  = super.hitTest(point, with: event)
		self.touched = (hitted,Date())
		if hitted == self, !options.absorbDimTouch {
			return nil
		}
		else if hitted == self, options.absorbDimTouch{
			return hitted
		}
		return hitted
	}
	public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		guard shadowLayerPath != nil, let latestTip = latestTip  else {
			return false
		}
		let targetArea = latestTip.pointTo
		let cutted = targetArea.tipFrame.insetBy(dx: -4, dy: -4)
		let isInTheActionable = cutted.contains(point)
		let option = latestTip.bubbleOptions ?? self.options.bubbles
		if !option.isTargetAreaUserinteractionEnabled {
			return true
		}
		if isInTheActionable {
			option.onTargetAreaTap?(latestTip)
			if option.dismissOnTargetAreaTap {
				self.finish()
			}
		}

		return !isInTheActionable
	}
}

private var ExteraIDForTapGesture: String = ""
private extension UITapGestureRecognizer {
	var identifier: String {
		set {
			ExteraIDForTapGesture = newValue
		}
		get {
			return ExteraIDForTapGesture
		}
	}
}

extension TipSee {
	
	/// creates a default bubble
	///
	/// - Parameter item: tip item
	/// - Returns: bubble view
	final func defaultBubble(for item: TipSee.TipItem,defaultOptions options : TipSee.Options) -> BubbleView {
		
		let bubble = BubbleView.default()
		bubble.backColor = item.bubbleOptions?.backgroundColor ?? options.bubbles.backgroundColor
		return bubble
	}
	
	/// creates a labelView for useing inside a bubble
	///
	/// - Parameter text: label text
	/// - Returns: generated label view
	private static func createLabel(for text: String, with itemOptions: Options.Bubble?, defaultOptions options : TipSee.Options) -> UILabel {
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
	
	
	public func options(_ options: TipSee.Options) {
		self.options = options
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
		if let label = view as? UILabel, let text = label.attributedText {
			calculatedFrame.height = text.height(widthConstraint: availableSpace.width) + 16
			calculatedFrame.width = text.width(widthConstraint: availableSpace.width, heightConstraint: self.frame.size.height) + 16
		}else {
			calculatedFrame = view.frame.insetBy(dx: -8, dy: -8).size
		}
		return calculatedFrame
	}
}

extension BubbleView {
	/// finds bubble size
	///
	/// - Parameters:
	///   - availableSpace: avialable space for bubble to fit in
	///   - view: view that live in bubble view
	/// - Returns: updated bubble view
	fileprivate func setProperSizeWith(content view: UIView,on availableSpace: CGSize? = nil) -> BubbleView {
		let bubbleView = self
		var calculatedFrame = CGSize.zero
		let availableSpace = availableSpace ?? CGSize(width: UIScreen.main.bounds.width - (64), height: UIScreen.main.bounds.height)
		if let label = view as? UILabel, let text = label.attributedText {
			calculatedFrame.height = text.height(widthConstraint: availableSpace.width) + 16
			calculatedFrame.width = text.width(widthConstraint: availableSpace.width, heightConstraint: self.frame.size.height) + 16
		}else {
			calculatedFrame = view.frame.insetBy(dx: -8, dy: -8).size
			bubbleView.translatesAutoresizingMaskIntoConstraints = false
		}
		bubbleView.frame.size = calculatedFrame
		return bubbleView
	}
	
	/// creates a default bubble
	///
	/// - Parameter item: tip item
	/// - Returns: bubble view
	fileprivate static func `default`() -> BubbleView {
		let bubble = BubbleView(frame: .zero)
		bubble.alpha = 0
		bubble.arrow = .init(position: .init(distance: .mid(offset: 0), edge: UIRectEdge.left.toCGRectEdge()), size: .init(width: 10, height: 5))
		return bubble
	}
}
