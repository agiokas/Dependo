import XCTest
import Dependo

final class DependoTests: XCTestCase {
    func testRegister_Resolvable() throws {
        let dependo = Dependo()
        
        dependo.register(SampleVM1.self) { parameters in
            SampleVM1(parameters: parameters)
        }
        let k: SampleVM1? = dependo.optionalResolve((uid: "abc", nid: 123))
        
        XCTAssertNotNil(k)
    }
}

protocol SampleVM: Resolvable { }

class SampleVM1: SampleVM {
    typealias ReturnType = SampleVM
    
    required init(parameters: (uid: String, nid: UInt)) {
        self.nid = parameters.nid
        self.uid = parameters.uid
    }
    
    internal init(uid: String, nid: UInt) {
        self.uid = uid
        self.nid = nid
    }
    
    let uid: String
    let nid: UInt
}
