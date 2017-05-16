//
//  MockedURLProtocol.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/15/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation
import Alamofire

class MockedManager : SessionManager {
    override func request(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) -> DataRequest {
        // Get the generated request before we modify.
        let oldStartRequestsImmediately = startRequestsImmediately
        if startRequestsImmediately { startRequestsImmediately = false }
        let dataRequest = super.request(url, method: method, parameters: parameters,
                                        encoding: encoding, headers: headers)
        dataRequest.cancel()
        startRequestsImmediately = oldStartRequestsImmediately
        
        // We want to get the httpBody in URLProtocol, but by the time startLoading is called the
        // httpBody is gone. So what we want to do is store it with URLProtocol, but part of the 
        // API wasn't transitioned so we have to generate a new request from a mutableCopy.
        //
        // rdar://26849668 - URLProtocol had some API's that didnt make the value type conversion
        //
        if let request = dataRequest.request, let httpBody = request.httpBody {
            let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            URLProtocol.setProperty(httpBody, forKey: "httpBody", in: mutableRequest)
            return super.request(mutableRequest as URLRequest)
        }
        return dataRequest
    }
    
}

class MockedURLProtocol : URLProtocol {
    
    static var mockedData: Data?
    static let mockedHeaders = ["Content-Type" : "application/json; charset=utf-8"]
    static var requestDataHandler: ((Data?) -> Void)?
    
    override func startLoading() {
        let request = self.request
        
        let httpBody = URLProtocol.property(forKey: "httpBody", in: request) as? Data
        MockedURLProtocol.requestDataHandler?(httpBody)
        
        let client = self.client
        let response = HTTPURLResponse(url: request.url!, statusCode: 200,
                                       httpVersion: "HTTP/1.1",
                                       headerFields: MockedURLProtocol.mockedHeaders)
        client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
        if let data = MockedURLProtocol.mockedData {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
        
        // Reset.
        MockedURLProtocol.mockedData = nil
        MockedURLProtocol.requestDataHandler = nil
    }
    
    override func stopLoading() {
        //noop
    }
    
    override internal class func canInit(with request: URLRequest) -> Bool {
        return request.url?.scheme == "https"
    }
    
    override internal class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}

extension URLRequest {
    
}
