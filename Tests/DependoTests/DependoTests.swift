import XCTest
import Dependo

final class DependoTests: XCTestCase {
    func testRegister_resolvable_optional() {
        let dependo = Dependo()
        
        dependo.register(SampleVM1.self) { parameters in
            SampleVM1(parameters: parameters)
        }
        let k: SampleVM1? = dependo.optionalResolve((uid: "abc", nid: 123))
        
        XCTAssertNotNil(k)
    }
    
    func testRegister_resolvable_nonoptional() throws {
        let dependo = Dependo()
        
        dependo.register(SampleVM1.self) { parameters in
            SampleVM1(parameters: parameters)
        }
        let _: SampleVM1 = try dependo.resolve((uid: "abc", nid: 123))
    }
    
    func testRegister_protocol_resolvable_nonoptional() throws {
        let dependo = Dependo()
        
        dependo.register(SampleVM.self) { parameters in
            SampleVM1(parameters: parameters)
        }
        let _: SampleVM1 = try dependo.resolve((uid: "abc", nid: 123))
    }
    
    func testRegister_resolvable_nonoptional_cannot_resolve() {
        let dependo = Dependo()
        
        dependo.register(SampleVM1.self) { parameters in
            SampleVM1(parameters: parameters)
        }
        
        do {
            let _: SampleVM2 = try dependo.resolve(())
            XCTFail("SampleVM2 not available")
        } catch {}
    }
}

protocol SampleVM: Resolvable { }

class SampleVM2: Resolvable {
    typealias ReturnType = SampleVM2
    
    required init(parameters: Void) { }
}

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
