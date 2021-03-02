//
//  NetworkerWithPathErrorBehavior.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation
import Quick
import Nimble
@testable import Networker

struct NetworkerGivenURLConverterErrorContext {
    var path: String
    var expectedError: NetworkerError
    var session: URLSessionMock
    var queues: NetworkerQueuesMock
    var networker: Networker
}

final class NetworkerGivenURLConverterErrorBehavior: Behavior<NetworkerGivenURLConverterErrorContext> {
    override class func spec(_ aContext: @escaping () -> NetworkerGivenURLConverterErrorContext) {
        describe("GIVEN an invalid path, the error it should produce and the executor") {
            var path: String!
            var expectedError: NetworkerError!
            var session: URLSessionMock!
            var queues: NetworkerQueuesMock!
            var networker: Networker!
            beforeEach {
                path = aContext().path
                expectedError = aContext().expectedError
                session = aContext().session
                queues = aContext().queues
                networker = aContext().networker
            }
            
            context("WHEN we call request") {
                var task: URLSessionTaskMock?
                var error: NetworkerError?
                
                beforeEach {
                    waitUntil { (done) in
                        task = networker.request(path: path, completion: { (result) in
                            error = result.error
                            done()
                        }) as? URLSessionTaskMock
                    }
                }
                
                it("THEN the session methods should not be called and we should have the expected error") {
                    expect(error).to(matchError(expectedError))
                    
                    expect(task).to(beNil())
                    
                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())
                    expect(session.didCallGetTasks).to(beFalse())
                    
                    expect(queues.asyncCallbackCallCount).to(equal(1))
                    expect(queues.didCallAddOperation).to(beFalse())
                    expect(queues.didCallCancelAllOperations).to(beFalse())
                }
            }
            
            context("WHEN we call upload") {
                var task: URLSessionTaskMock?
                var error: NetworkerError?
                
                beforeEach {
                    waitUntil { (done) in
                        task = networker.upload(
                            Data(),
                            to: path,
                            type: .post,
                            completion: { (result) in
                                error = result.error
                                done()
                            }) as? URLSessionTaskMock
                    }
                }
                
                it("THEN the session methods should not be called and we should have the expected error") {
                    expect(error).to(matchError(expectedError))
                    
                    expect(task).to(beNil())
                    
                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())
                    expect(session.didCallGetTasks).to(beFalse())
                    
                    expect(queues.asyncCallbackCallCount).to(equal(1))
                    expect(queues.didCallAddOperation).to(beFalse())
                    expect(queues.didCallCancelAllOperations).to(beFalse())
                }
            }
            
            context("WHEN we call download") {
                var task: URLSessionTaskMock?
                var error: NetworkerError?
                
                beforeEach {
                    waitUntil { (done) in
                        task = networker.download(
                            path: path,
                            requestType: .post,
                            fileHandler: nil,
                            completion: { (result) in
                                error = result.error
                                done()
                            }) as? URLSessionTaskMock
                    }
                }
                
                it("THEN the session methods should not be called and we should have the expected error") {
                    expect(error).to(matchError(expectedError))
                    
                    expect(task).to(beNil())
                    
                    expect(session.didCallUpload).to(beFalse())
                    expect(session.didCallRequest).to(beFalse())
                    expect(session.didCallDownload).to(beFalse())
                    expect(session.didCallGetTasks).to(beFalse())
                    
                    expect(queues.asyncCallbackCallCount).to(equal(1))
                    expect(queues.didCallAddOperation).to(beFalse())
                    expect(queues.didCallCancelAllOperations).to(beFalse())
                }
            }
        }
    }
}
