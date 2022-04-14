//
//  URLSessionTests.swift
//
//
//  Created by Gao Sun on 2022/4/13.
//

import Foundation
@testable import Logto
import XCTest

final class URLSessionTests: XCTestCase {
    func testHandleResponseOk() {
        let mockData = "123".data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://logto.dev")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let (data, error) = URLSession.shared.handleResponse(data: mockData, response: response, error: nil)

        XCTAssertEqual(data, mockData)
        XCTAssertNil(error)
    }

    func testHandleResponseStatusCodeError() {
        let mockData = "123".data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://logto.dev")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )

        let (data, error) = URLSession.shared.handleResponse(data: mockData, response: response, error: nil)

        XCTAssertNil(data)

        guard let error = error as? LogtoErrors.Response, case .withCode = error else {
            XCTFail()
            return
        }
    }

    func testHandleResponseNotHttpResponse() {
        let mockData = "123".data(using: .utf8)!

        let (data, error) = URLSession.shared.handleResponse(data: mockData, response: nil, error: nil)

        XCTAssertNil(data)

        guard let error = error as? LogtoErrors.Response, case .notHttpResponse = error else {
            XCTFail()
            return
        }
    }
}
