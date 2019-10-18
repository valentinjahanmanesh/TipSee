//
//  TipSee-Exts.swift
//  Pods-TipSee_Example
//
//  Created by Farshad Jahanmanesh on 7/18/19.
//
import UIKit
public class TipSeeManager {
    public var pointer : TipSee
    public private(set) var tips : [TipSee.TipItem]
    public var latestTip : TipSee.TipItem?
    public var onBubbleTap: ((TipSee.TipItem?) -> Void)? {
        didSet{
            pointer.onBubbleTap = self.onBubbleTap
        }
    }
    public var onDimTap : ((TipSee.TipItem?) -> Void)? {
        didSet{
            pointer.onDimTap = self.onDimTap
        }
    }
    public var currentIndex : Int? {
        didSet {
            guard let index = currentIndex else {
                self.pointer.finish()
                return
            }
            latestTip = tips[index]
            self.pointer.show(item: latestTip!)
        }
    }
    
    /// creates a slider manager.
    /// - Warning: the TipPointer object that should be passed in in init, is accessed with strong reference so you do not need to keep it strong too
    /// - Parameters:
    ///   - pointer: tip pointer object
    ///   - items: items
    public init(on window : UIWindow,with options: TipSee.Options) {
        self.pointer = TipSee(on: window)
        self.pointer.options(options)
        self.tips = [TipSee.TipItem]()
    }
    public func add(new view : TipTarget,text string: String, with bubbleOption: TipSee.Options.Bubble?){
        self.tips.append(pointer.createItem(for: view,text: string, with: bubbleOption))
    }
	
    public func add(new item: TipSee.TipItem){
        self.tips.append(item)
    }
    /// shows the next tip
    public func next(){
        guard let current = latestTip,let currentIndex = tips.firstIndex(of: current) else {
            if !tips.isEmpty{
                self.currentIndex = 0
            }
            return
        }
        let next  = currentIndex+1
        if next < tips.count {
            self.currentIndex = next
        }
    }
    
    // shows the previous tip
    public func previous(){
        guard let current = latestTip,let currentIndex = tips.firstIndex(of: current) else {
            return
        }
        let previous  = currentIndex-1
        if previous >= 0 {
            self.currentIndex = previous
        }
    }
    
    public func finish(){
        pointer.finish()
    }
}


extension TipSeeManager{
	public func add(new view: TipTarget,texts strings: [String], with bubbleOption: TipSee.Options.Bubble?){
		let buttonsHeight : CGFloat = 30
		let height = strings.map({$0.height(font: bubbleOption?.font ?? pointer.options.bubbles.font,widthConstraint: 300)}).max()
		let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: (height ?? 160) + 40 ))
		

		let customScrollView = UIScrollView(frame: .zero)
		customScrollView.translatesAutoresizingMaskIntoConstraints = false
		customScrollView.showsHorizontalScrollIndicator = false
		customScrollView.showsVerticalScrollIndicator = false
		container.addSubview(customScrollView)
		customScrollView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 0.0).isActive = true
		customScrollView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0.0).isActive = true
		customScrollView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: 0.0).isActive = true
		customScrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: buttonsHeight).isActive = true
		customScrollView.heightAnchor.constraint(equalToConstant: container.bounds.height - buttonsHeight).isActive = true
		customScrollView.widthAnchor.constraint(equalToConstant: container.bounds.width).isActive = true

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
		strings.forEach { (str) in
			let label = UILabel()
			label.text = str
			label.textColor = .black
			label.lineBreakMode = .byWordWrapping
			label.numberOfLines = 0
			stackView.addArrangedSubview(label)
			label.widthAnchor.constraint(equalToConstant: container.frame.width).isActive = true
		}

		let stackViewButtons = UIStackView(frame: CGRect(x: 0, y: container.frame.height - buttonsHeight, width: container.frame.width, height: buttonsHeight))
		container.addSubview(stackViewButtons)
		stackViewButtons.heightAnchor.constraint(equalToConstant: buttonsHeight).isActive = true
		stackViewButtons.alignment = .fill
		stackViewButtons.distribution = .equalCentering
		stackViewButtons.axis = .horizontal
		["left","right"].forEach { (str) in
			let label = UIButton()
			label.setTitle(str, for: .normal)
			label.setTitleColor(.black, for: .normal)
			stackViewButtons.addArrangedSubview(label)
		}
		self.tips.append(.init(ID: UUID().uuidString, pointTo: view, contentView: container, bubbleOptions: bubbleOption))
    }
}
