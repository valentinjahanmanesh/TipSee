//
//  TipSeeManager.swift
//  TipSee
//
//  Created by Farshad Jahanmanesh on 7/18/19.
//

import UIKit

public final class TipSeeManager {
    public private(set) var pointer: TipSee
    public internal(set) var tips: [TipSee.TipItem]
    public private(set) var latestTip: TipSee.TipItem?
    public var onBubbleTap: ((TipSee.TipItem?) -> Void)? {
        didSet {
            pointer.onBubbleTap = self.onBubbleTap
        }
    }
    public var onDimTap: ((TipSee.TipItem?) -> Void)? {
        didSet {
            pointer.onDimTap = self.onDimTap
        }
    }
	public var onFinished: (() -> Void)? {
		didSet {
			pointer.onFinished = self.onFinished
		}
	}
    public private(set) var currentIndex: Int? {
        didSet {
            guard let index = currentIndex else {
                self.pointer.finish()
                return
            }
            latestTip = tips[index]
            self.pointer.show(item: latestTip!)
        }
    }

    /// Designated intializer.
    /// - Parameters:
    ///   - window: The window used for attaching the tip view to.
    ///   - options: Manager appearance configuration options.
    public init(on window: UIWindow, with options: TipSee.Options) {
        self.pointer = TipSee(on: window)
        self.pointer.options(options)
        self.tips = [TipSee.TipItem]()
    }

	/// Adds a tip which targets a given object conforming to `TipTarget`
	/// - Parameters:
	///   - view: Target object used for pinning the tip to.
	///   - string: Tip text to show in the bubble.
	///   - bubbleOptions: Bubble appearance configuration options.
    public func add(new view: TipTarget, text string: String, with bubbleOption: TipSee.Options.Bubble?) {
        self.tips.append(pointer.createItem(for: view,text: string, with: bubbleOption))
    }

	/// Adds a tip which targets a given object conforming to `TipTarget`
	/// - Parameters:
	///   - item: Target object used for pinning the tip to.
    public func add(new item: TipSee.TipItem) {
        self.tips.append(item)
    }

    /// shows the next tip
    public func next() {
        guard let current = latestTip, let currentIndex = tips.firstIndex(of: current) else {
            if !tips.isEmpty{
                self.currentIndex = 0
            }
            return
        }
        let next = currentIndex+1
        if next < tips.count {
            self.currentIndex = next
		} else {
			finish()
		}
    }
    
    // shows the previous tip
    public func previous() {
        guard let current = latestTip, let currentIndex = tips.firstIndex(of: current) else {
            return
        }
        let previous = currentIndex-1
        if previous >= 0 {
            self.currentIndex = previous
        }
    }
    
    public func finish() {
        pointer.finish()
    }
}

extension TipSeeManager {
	
	public func add(
		new view: TipTarget,
		texts strings: [String],
		with bubbleOption: TipSee.Options.Bubble?,
		buttonsConfigs: ((_ previousButton: UIButton, _ nextButton: UIButton) -> Void))
	{
		let buttonsHeight : CGFloat = 30
		let font = bubbleOption?.font ?? pointer.options.bubbles.font
		var containerHeight  : CGFloat = 40
		var containerWidth : CGFloat = strings.max()?.width(font: font, widthConstraint: UIScreen.main.bounds.width - 48, heightConstraint: 40) ?? 100
	
		if  containerWidth > UIScreen.main.bounds.width {
			containerWidth = UIScreen.main.bounds.width - 48
		}
		containerHeight = strings.max()?.height(font: font, widthConstraint: containerWidth) ?? 100

		let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight + 40 ))
		
		// creates a scroll view and appends it to bubble view
		let customScrollView = UIScrollView(frame: .zero)
		customScrollView.translatesAutoresizingMaskIntoConstraints = false
		customScrollView.showsHorizontalScrollIndicator = false
		customScrollView.showsVerticalScrollIndicator = false
		container.addSubview(customScrollView)
		customScrollView.isScrollEnabled = false
		customScrollView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 0.0).isActive = true
		customScrollView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0.0).isActive = true
		customScrollView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: 0.0).isActive = true
		customScrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: buttonsHeight).isActive = true
		customScrollView.heightAnchor.constraint(equalToConstant: container.bounds.height - buttonsHeight).isActive = true
		customScrollView.widthAnchor.constraint(equalToConstant: container.bounds.width).isActive = true
		
		// creates a stack view and apeends it to scroll view
		let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: container.frame.width, height: 200))
		customScrollView.addSubview(stackView)
		customScrollView.isPagingEnabled = true
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.leadingAnchor.constraint(equalTo: customScrollView.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: customScrollView.trailingAnchor).isActive = true
		stackView.topAnchor.constraint(equalTo: customScrollView.topAnchor).isActive = true
		stackView.bottomAnchor.constraint(equalTo: customScrollView.bottomAnchor).isActive = true
		stackView.heightAnchor.constraint(equalToConstant: container.bounds.height - buttonsHeight).isActive = true
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.axis = .horizontal
		
		// appends all texts as label inside stack view
		strings.forEach { (str) in
			let label = UILabel()
			label.text = str
			label.font = font
			label.lineBreakMode = .byWordWrapping
			label.numberOfLines = 0
			label.textColor = bubbleOption?.foregroundColor ?? pointer.options.bubbles.foregroundColor
			stackView.addArrangedSubview(label)
			label.widthAnchor.constraint(equalToConstant: container.frame.width).isActive = true
		}

		// creates next and previous button
		let leftButton = UIButton(frame: CGRect.init(origin: CGPoint(x: 0, y: container.frame.height - 25), size: CGSize(width: 25, height: 25)))
		leftButton.setTitleColor(.black, for: .normal)
		leftButton.accessibilityHint = "previous"
		leftButton.tag = 0
		leftButton.addTarget(self, action: #selector(scrollMultiLine(_:)), for: .touchUpInside)
		container.addSubview(leftButton)
		
		let rightButton = UIButton(frame: CGRect.init(origin: .zero, size: CGSize(width: 25, height: 25)))
		rightButton.setTitleColor(.black, for: .normal)
		rightButton.accessibilityHint = "next"
		rightButton.tag = 0
		rightButton.addTarget(self, action: #selector(scrollMultiLine(_:)), for: .touchUpInside)
		rightButton.frame.origin = CGPoint(x: container.frame.width - rightButton.frame.width, y: container.frame.height - 25)
		container.addSubview(rightButton)
		
		// creates a new item with new created conent view
		self.tips.append(.init(pointTo: view, contentView: container, bubbleOptions: bubbleOption))
		
		// return those two button so users can change the configurstions
		buttonsConfigs(leftButton, rightButton)
    }
	
	@objc
	private func scrollMultiLine(_ sender: UIButton) {
		guard let action = sender.accessibilityHint, let scrollView = sender.superview?.subviews.first(where: {$0 is UIScrollView }) as? UIScrollView else {
			return
		}
		var frame: CGRect = scrollView.frame

		var page = scrollView.tag
			page +=  action == "next" ? 1 : -1
		if page < 0 {
			return
		} else if (frame.size.width * CGFloat(page)) >= scrollView.contentSize.width {
			return
		}
		scrollView.tag = page
		print(page)
		frame.origin.x = frame.size.width * CGFloat(page)
		frame.origin.y = 0
		scrollView.scrollRectToVisible(frame, animated: true)
	}
}
