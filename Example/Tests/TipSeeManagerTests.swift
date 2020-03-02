//
//  TipSeeManagerTests.swift
//  TipSee_Example
//
//  Created by Adam Law on 01/03/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import TipSee

class TipSeeManagerTests: XCTestCase {

	private let window = UIWindow()
	private lazy var sut: TipSeeManager = {
		return TipSeeManager(on: window, with: TipSee.Options.default())
	}()

    override func setUp() {
        super.setUp()
		XCTAssertNil(sut.currentIndex)
		XCTAssertTrue(sut.tips.isEmpty)
    }

	func test_addTip() {
		sut.add(new: TestData.tipItem1)
		XCTAssertEqual(sut.tips.count, 1)
	}

	func test_addTip_withAttributedTextAndBubbleOptions() {
		let text = NSAttributedString.init(string: "Tip message")
		sut.add(new: TestData.target, text: text, with: TestData.bubbleOptions)
		XCTAssertEqual(sut.tips.count, 1)
	}

	func test_addTip_withBubbleOptions() {
		sut.add(new: TestData.target, text: "Tip message", with: TestData.bubbleOptions)
		XCTAssertEqual(sut.tips.count, 1)
	}

	func test_addTips_withBubbleOptions() {
		sut.add(
			new: TestData.target,
			texts: ["Tip message 1", "Tip message 2"],
			with: TestData.bubbleOptions
		) { previousButton, nextButton in }

		XCTAssertEqual(sut.tips.count, 1)
	}

	func test_nextTip_withTwoTips() {
		sut.add(new: TestData.tipItem1)
		sut.add(new: TestData.tipItem2)

		sut.next()
		XCTAssertEqual(sut.currentIndex, 0)
		XCTAssertEqual(sut.latestTip, TestData.tipItem1)

		sut.next()
		XCTAssertEqual(sut.currentIndex, 1)
		XCTAssertEqual(sut.latestTip, TestData.tipItem2)
	}

	func test_nextTip_withNoTips() {
		sut.next()
		XCTAssertNil(sut.currentIndex)
		XCTAssertNil(sut.latestTip)
	}

	func test_previousTip_withTwoTips() {
		sut.add(new: TestData.tipItem1)
		sut.next()
		sut.add(new: TestData.tipItem2)
		sut.next()

		sut.previous()
		XCTAssertEqual(sut.currentIndex, 0)
		XCTAssertEqual(sut.latestTip, TestData.tipItem1)

		sut.previous()
		XCTAssertEqual(sut.currentIndex, 0)
		XCTAssertEqual(sut.latestTip, TestData.tipItem1)
	}

	func test_previousTip_withNoTips() {
		sut.previous()
		XCTAssertNil(sut.currentIndex)
		XCTAssertNil(sut.latestTip)

		sut.finish()
	}

	private struct TestData {
		static let target = SimpleTipTarget(on: CGRect.zero, cornerRadius: 0)
		static let bubbleOptions = TipSee.Options.Bubble.default()
		static let tipItem1 = TipSee.TipItem(pointTo: target, contentView: UIView())
		static let tipItem2 = TipSee.TipItem(pointTo: target, contentView: UIView())
	}
}
