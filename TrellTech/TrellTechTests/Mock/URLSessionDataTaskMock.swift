//
//  URLSessionDataTaskMock.swift
//  TrellTechTests
//
//  Created by Xiam Chebila on 12/03/2024.
//

import Foundation

class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    func resume() {
        closure()
    }
}

