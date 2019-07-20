import XCTest
import TipC

class OptionsTests: XCTestCase {
    var sut : HintPointer!

    override func setUp() {
        super.setUp()
        let uiwindow = UIWindow()
        sut = HintPointer(on: uiwindow)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSettingOptions(){
        // given
        sut.options = HintPointer.Options.default()
        
        // when
        sut.options.dimColor = .red
        
        // then
        XCTAssertTrue(sut.options.dimColor == .red)
    }
    
    func testChangeBubbleOptions(){
        // given
        sut.options.bubbles = .default()
        
        // when
        sut.options.bubbles.backgroundColor = .yellow
        
        XCTAssertTrue(sut.options.bubbles.backgroundColor == .yellow)
    }
    
    func testHintPointerShouldHaveDefaultOptions(){
        XCTAssertNotNil(sut.options.bubbles, "Default bubble Option Should not be nil")
        XCTAssertNotNil(sut.options, "Default Option Should not be nil")
    }
    
}
