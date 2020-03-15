//
//  TipSeeTests.swift
//  TipSee_Example
//
//  Created by Farshad Jahanmanesh on 7/19/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import TipSee

class TipSeeTests: XCTestCase {
    var sut : TipSee!
    var window : UIWindow!
    override func setUp() {
        super.setUp()
        window = UIWindow()
        sut = TipSee(on: window)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        sut = nil
        window = nil
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShownItemConfig(){
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: TipSee.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        let givenItem = sut.show(item: item)
        
        // then
        XCTAssertEqual(givenItem.bubbleOptions!.backgroundColor , .green)
    }
    
    func testShownBubbleContent(){
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: TipSee.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        let givenItem = sut.show(item: item)
        
        // then
        XCTAssertNotNil(givenItem.contentView as? UILabel)
    }
    
    func testShownBubbleContentText(){
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: TipSee.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        let givenItem = sut.show(item: item)
        
        // then
        XCTAssert((givenItem.contentView as? UILabel)?.text == "hi")
    }
    
    func testShownDismissItem(){
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: TipSee.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        sut.show(item: item)
        
        // then
        sut.dismiss(item: item)
        XCTAssert(sut.subviews.count == 0)
    }
    
    func testNoOrderDismiss() {
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: TipSee.Options.Bubble.default().with{$0.backgroundColor = .green})
        let item2 = sut.createItem(for: targetView,text:"hi",with: TipSee.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        sut.show(item: item)
        sut.show(item: item2)
        // then
        sut.dismiss(item: item2)
        sut.dismiss(item: item2)
        
        XCTAssert(sut.subviews.count == 1)
    }
	
	func testItemMemoryLeak(){
		let container = UIView()
		let targetView = UIView()
		container.addSubview(targetView)
		// given
		let item = sut.createItem(for: targetView,text:"hi",with: TipSee.Options.Bubble.default().with{$0.backgroundColor = .green})
		var item2 : TipSee.TipItem? = sut.createItem(for: targetView,text:"hi",with: TipSee.Options.Bubble.default().with{$0.backgroundColor = .green})
		
		// when
		sut.show(item: item)
		sut.show(item: item2!)
		// then
		
		item2 = nil
		XCTAssertNil(item2)
	}
	
	public var options: TipSee.Options = TipSee.Options.default()
	private func findBetterSpace(view: TipTarget, preferredPosition: UIRectEdge?) -> UIRectEdge {
		let reletivePosition = view.tipFrame
		
		var edges = [(UIRectEdge, Bool)]()
		
		var left = options.safeAreaInsets.left + options.bubbles.padding.right + 16
		
		var right = UIScreen.main.bounds.width - (options.safeAreaInsets.right + options.bubbles.padding.left + 16)
		
		var top = options.safeAreaInsets.top + options.bubbles.padding.bottom + 16
		
		var bottom = UIScreen.main.bounds.height - (options.safeAreaInsets.bottom + options.bubbles.padding.top + 16)
		if #available(iOS 11.0, *) {
			bottom = UIScreen.main.bounds.height - (options.safeAreaInsets.bottom + options.bubbles.padding.top + 16)
			
			top = options.safeAreaInsets.top + options.bubbles.padding.bottom + 16
			
			right = UIScreen.main.bounds.width - (options.safeAreaInsets.right + options.bubbles.padding.left + 16)
			
			left = options.safeAreaInsets.left + options.bubbles.padding.right + 16
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
}
