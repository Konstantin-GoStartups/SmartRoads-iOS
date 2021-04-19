//
//  ImageTests.swift
//  SmartRoadsTests
//
//  Created by Konstantin Kostadinov on 16.04.21.
//

import XCTest
@testable import SmartRoads

class ImageTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        guard let pathStringToDefaultPixelsPNG = Bundle(for: type(of: self)).path(forResource: "defaultPixels", ofType: "png") else {
            fatalError("defaultPixels.png not found")
        }
        guard let pathStringToVideoPixelsPNG = Bundle(for: type(of: self)).path(forResource: "videoPixels", ofType: "png") else {
            fatalError("videoPixels.png not found")
        }
        
        guard let defaultPixelsImage = UIImage(contentsOfFile: pathStringToDefaultPixelsPNG) else { return }
        guard let videoPixelsImage = UIImage(contentsOfFile: pathStringToVideoPixelsPNG) else { return }
        
        let defaultPixelColors = defaultPixelsImage.subscriptColor(x: 0, y: 0)
        let videoPixelColors = videoPixelsImage.subscriptColor(x: 0, y: 0)
        print(defaultPixelColors?.rgba, videoPixelColors?.rgba)
        
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
