//
//  AsyncOperationTests.swift
//  
//
//  Created by RICHEZ Thibaut on 1/24/21.
//

import Foundation
import Quick
import Nimble
@testable import Networker

final class NetworkerOperationTests: QuickSpec {
    override func spec() {
        
    }
}

final class AsyncOperationTests: QuickSpec {
    override func spec() {
        describe("GIVEN an async operation") {
            var sut: AsyncOperation!
            beforeEach {
                sut = .init()
            }

            context("WHEN we call start") {

                context("WHEN the operation is cancelled") {
                    beforeEach {
                        sut.cancel()
                        sut.start()
                    }

                    it("THEN isExecuting should be false and isFinished true") {
                        expect(sut.isExecuting).to(beFalse())
                        expect(sut.isFinished).to(beTrue())
                        expect(sut.isAsynchronous).to(beTrue())
                    }
                }

                context("WHEN the operation is not ready") {
                    beforeEach {
                        let dependency = AsyncOperation()
                        sut.addDependency(dependency)
                        sut.start()
                    }

                    it("THEN isExecuting and isFinished should have their default value") {
                        expect(sut.isExecuting).to(beFalse())
                        expect(sut.isFinished).to(beFalse())
                        expect(sut.isAsynchronous).to(beTrue())
                    }
                }

                context("WHEN the operation is already finished") {
                    beforeEach {
                        sut.finish()
                        sut.start()
                    }

                    it("THEN isExecuting should be false and isFinished true") {
                        expect(sut.isExecuting).to(beFalse())
                        expect(sut.isFinished).to(beTrue())
                        expect(sut.isAsynchronous).to(beTrue())
                    }
                }

                context("WHEN the operation is ready") {
                    it("THEN it should throw as a result of main() call and isExecuting should be true and isFinished false") {
                        expect(sut.start()).to(throwAssertion())
                        expect(sut.isFinished).to(beFalse())
                        expect(sut.isExecuting).to(beTrue())
                        expect(sut.isAsynchronous).to(beTrue())
                    }
                }

            }

            context("WHEN we call main") {
                it("THEN it sould throw an an assertion") {
                    expect(sut.main()).to(throwAssertion())
                    expect(sut.isAsynchronous).to(beTrue())
                }
            }

            context("WHEN we call finish") {
                beforeEach {
                    sut.finish()
                }

                it("THEN isExecuting should be false and isFinished true") {
                    expect(sut.isExecuting).to(beFalse())
                    expect(sut.isFinished).to(beTrue())
                    expect(sut.isAsynchronous).to(beTrue())
                }
            }
        }
    }
}
