//
//  HintPointerTests.swift
//  TipC_Tests
//
//  Created by Farshad Jahanmanesh on 7/19/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import TipC
class HintPointerTests: XCTestCase {
    var sut : HintPointer!
    var window : UIWindow!
    override func setUp() {
        super.setUp()
        window = UIWindow()
        sut = HintPointer(on: window)
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
        let item = sut.createItem(for: targetView,text:"hi",with: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        let givenItem = sut.show(item: item)
        
        // then
        XCTAssertEqual(givenItem.bubbleOptions!.backgroundColor , .green)
    }
    
    func testShownBubbleConent(){
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        let givenItem = sut.show(item: item)
        
        // then
        XCTAssertNotNil(givenItem.showView as? UILabel)
    }
    
    func testShownBubbleConentText(){
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        let givenItem = sut.show(item: item)
        
        // then
        XCTAssert((givenItem.showView as? UILabel)?.text == "hi")
    }
    
    func testShownDissmisItem(){
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        sut.show(item: item)
        
        // then
        sut.dismiss(item: item)
        XCTAssert(sut.subviews.count == 0)
    }
    
    func testNoOrderDissmiss(){
        let container = UIView()
        let targetView = UIView()
        container.addSubview(targetView)
        // given
        let item = sut.createItem(for: targetView,text:"hi",with: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .green})
        let item2 = sut.createItem(for: targetView,text:"hi",with: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .green})
        
        // when
        sut.show(item: item)
        sut.show(item: item2)
        // then
        sut.dismiss(item: item2)
        sut.dismiss(item: item2)
        
        XCTAssert(sut.subviews.count == 1)
    }
    
}
