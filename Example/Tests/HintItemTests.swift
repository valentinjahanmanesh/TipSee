//
//  HintItemTests.swift
//  TipC_Tests
//
//  Created by Farshad Jahanmanesh on 7/19/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import TipC
class HintItemTests: XCTestCase {
    let id = "55"
    var sut : HintPointer.HintItem!
    var targetView : UIView!
    var bubbleContetView : UIView!
    override func setUp() {
        super.setUp()
        targetView = UIView()
        bubbleContetView = UIView()
        sut = HintPointer.HintItem(ID: id, pointTo: targetView, showView: bubbleContetView)
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
        sut.bubbleOptions = HintPointer.Options.Bubble.default().with{
            $0.backgroundColor = .blue
        }
        
        XCTAssertNotNil(sut.bubbleOptions)
        
        XCTAssertNotNil(sut.bubbleOptions!.backgroundColor == .blue)
    }
    
    func testEquality(){
        // given
        var new = HintPointer.HintItem(ID: "2", pointTo: UIView(), showView: UIView())
        
        // when
        new.ID = id
        
        // then
        XCTAssertEqual(new, sut)
    }
    
    func testCustomConfigInInit(){
        // given
        let new = HintPointer.HintItem(ID: "2", pointTo: UIView(), showView: UIView(),bubbleOptions: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .blue})
        
        // when
        sut.bubbleOptions = HintPointer.Options.Bubble.default().with{
            $0.backgroundColor = .blue
        }
        
        // then
        XCTAssertEqual(new.bubbleOptions!.backgroundColor, sut.bubbleOptions!.backgroundColor)
    }
	
	func testCustomFont(){
		// given
		let new = HintPointer.createItem(for: SimpleHintTarget(on: .zero,cornerRadius: 0), text: "XYS",with: HintPointer.Options.Bubble.default().with{$0.font = .italicSystemFont(ofSize: 100)})
		
		// then
		 XCTAssertEqual((new.showView as! UILabel).font, UIFont.italicSystemFont(ofSize: 100))
	}
	
	func testMEMORYLEAK(){
		
		// given
		var xView : UIView? = UIView()
		let count = CFGetRetainCount(xView!)
		print(count)
		let _ = HintPointer.HintItem(ID: "2", pointTo: xView!, showView: UIView(),bubbleOptions: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .blue})
		
		let _ = HintPointer.HintItem(ID: "2", pointTo: xView!, showView: UIView(),bubbleOptions: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .blue})
		
		let _ = HintPointer.HintItem(ID: "2", pointTo: xView!, showView: UIView(),bubbleOptions: HintPointer.Options.Bubble.default().with{$0.backgroundColor = .blue})
		
		let count2 = CFGetRetainCount(xView!)
		xView = nil
		print(count2)
		// then
		XCTAssertEqual(count2, count)
		XCTAssertNil(xView)
	}
}
