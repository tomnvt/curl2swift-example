//
//  curl2swiftExampleTests.swift
//  curl2swiftExampleTests
//
//  Created by Tom Novotny on 27.03.2021.
//

import XCTest
@testable import curl2swiftExample

class curl2swiftExampleTests: XCTestCase {

    func testTestRequest() {
        let expectation = XCTestExpectation(description: "waiting for reponse")
        TestRequest()
            .set(.baseURL("https://api.github.com"))
            .set(.path("/users/defunkt"))
            .makeRxRequest()
            .mapTo(TestRequest.Response.self)
            .do(onSuccess: { _ in expectation.fulfill() },
                onError: { _ in XCTFail("The request should succeed") })
            .discardableSubscribe()
        wait(for: [expectation], timeout: 10)
    }
}
