import XCTest
import Quick
import Nimble
@testable import Networker

final class NetworkerTests: QuickSpec {
    override func spec() {
        describe("GIVEN") {
            let toto = "toto"
            it("equal") {
                expect(toto).to(equal("toto"))
            }
        }
    }
}
