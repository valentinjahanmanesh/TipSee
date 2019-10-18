//
//  TipItemTests.swift
//  TipSee_Tests
//
//  Created by Farshad Jahanmanesh on 7/19/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import TipSee
class TipItemTests: XCTestCase {
    let id = "55"
    var sut : TipSee.TipItem!
    var targetView : UIView!
    var bubbleContetView : UIView!
    override func setUp() {
        super.setUp()
        targetView = UIView()
        bubbleContetView = UIView()
        sut = TipSee.TipItem(ID: id, pointTo: targetView, contentView: bubbleContetView)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        sut = nil
        targetView = nil
        bubbleContetView = nil
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDefaultOption(){
        XCTAssertNil(sut.bubbleOptions)
    }
    
    func testCustomConfig(){
        // when
        sut.bubbleOptions = TipSee.Options.Bubble.default().with{
            $0.backgroundColor = .blue
        }
        
        XCTAssertNotNil(sut.bubbleOptions)
        
        XCTAssertNotNil(sut.bubbleOptions!.backgroundColor == .blue)
    }
    
    func testEquality(){
        // given
        var new = TipSee.TipItem(ID: "2", pointTo: UIView(), contentView: UIView())
        
        // when
        new.ID = id
        
        // then
        XCTAssertEqual(new, sut)
    }
    
    func testCustomConfigInInit(){
        // given
        let new = TipSee.TipItem(ID: "2", pointTo: UIView(), contentView: UIView(),bubbleOptions: TipSee.Options.Bubble.default().with{$0.backgroundColor = .blue})
        
        // when
        sut.bubbleOptions = TipSee.Options.Bubble.default().with{
            $0.backgroundColor = .blue
        }
        
        // then
        XCTAssertEqual(new.bubbleOptions!.backgroundColor, sut.bubbleOptions!.backgroundColor)
    }
	func testCustomBubbeTap(){
		// when
		sut.bubbleOptions = TipSee.Options.Bubble.default().with{
			$0.backgroundColor = .blue
			$0.onBubbleTap = {_ in }
		}
		
		// then
		XCTAssertNotNil(sut.bubbleOptions!.onBubbleTap)
	}
	func testCustomFont(){
		// given
		let new = TipSee.createItem(for: SimpleTipTarget(on: .zero,cornerRadius: 0), text: "XYS",with: TipSee.Options.Bubble.default().with{$0.font = .italicSystemFont(ofSize: 100)})
		
		// then
		 XCTAssertEqual((new.contentView as! UILabel).font, UIFont.italicSystemFont(ofSize: 100))
	}
	
	func testMEMORYLEAK(){
		
		// given
		var xView : UIView? = UIView()
		let count = CFGetRetainCount(xView!)
		let _ = TipSee.TipItem(ID: "2", pointTo: xView!, contentView: UIView(),bubbleOptions: TipSee.Options.Bubble.default().with{$0.backgroundColor = .blue})
		
		let _ = TipSee.TipItem(ID: "2", pointTo: xView!, contentView: UIView(),bubbleOptions: TipSee.Options.Bubble.default().with{$0.backgroundColor = .blue})
		
		let _ = TipSee.TipItem(ID: "2", pointTo: xView!, contentView: UIView(),bubbleOptions: TipSee.Options.Bubble.default().with{$0.backgroundColor = .blue})
		
		let count2 = CFGetRetainCount(xView!)
		xView = nil
		// then
		XCTAssertEqual(count2, count)
		XCTAssertNil(xView)
	}
}
