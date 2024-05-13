import XCTest
import Dependo
import DependoMacro

final class DependoTests: XCTestCase {
    func testRegister_and_resolve() {
        let container = Dependo()
            .register(instance: Int(4))

        XCTAssertEqual(container.resolve(Int.self), 4)
    }

    func testResolve_not_registered_type() {
        let container = Dependo()
            .register(instance: Int(4))

        let resolver = container as Resolver
        expectFatalError {
            let _: Double = resolver.resolve()
        }
    }

    func testOptionalResolve_not_registered_type() {
        let container = Dependo()
            .register(instance: Int(4))

        XCTAssertNil(container.optionalResolve(Double.self))
    }

    func testRegister_two_times_the_same() {
        let container = Dependo()
            .register(instance: Int(4))

        expectFatalError {
            container.register(instance: Int(12))
        }
    }

    func testRegister_then_replace() {
        let container = Dependo().register(instance: Int(4))
        container.replace(instance: Int(12))
        XCTAssertEqual(container.resolve(Int.self), 12)
    }
    
    func testRegister_then_replace_using_type() {
        let container = Dependo().register(instance: Int(4))
        container.replace(Int.self, instance: Int(12))
        XCTAssertEqual(container.resolve(Int.self), 12)
    }

    func testRegister_instance_with_type() {
        let container = Dependo()
            .register(Int.self, instance: Int(4))
        XCTAssertEqual(container.resolve(Int.self), 4)
    }

    func testRegister_factory_returning_type() {
        let container = Dependo().register { _ in Int(4) }
        XCTAssertEqual(container.resolve(Int.self), 4)
    }
    
    func testResolve_nullable_type() {
        let container = Dependo()
            .register(instance: Int(4))

        let value: Int? = container.resolve()

        XCTAssertEqual(value, Int(4))

        expectFatalError {
            let _: Double? = container.resolve()
        }
    }

    func testResolve_not_registered_nullable() {
        let container: Resolver = Dependo()
            .register(instance: Int(4))

        let value: Int = container.resolve()

        XCTAssertEqual(value, Int(4))

        expectFatalError {
            let _: Double? = container.resolve()
        }
    }

    func testOptionalResolve_optional() {
        let container: Resolver = Dependo().register(instance: Int(4))
        let value: Int? = container.optionalResolve()

        XCTAssertEqual(value, 4)
    }
    
    func testRegisteredEntities() {
        let container = Dependo()
            .register(SomeClass.self) { _ in SomeClass() }
            .register(SomeOtherClass.self) { _ in SomeOtherClass() }

        container.registeredEntities()
            .forEach { constructor in
                XCTAssertNotNil(constructor())
            }
    }

    func testRegister_thread_safety() {
        let container = Dependo()
        let someClassExp = expectation(description: "SomeClass")
        let someOtherClassExp = expectation(description: "SomeOtherClass")
        let allResolveExp = expectation(description: "All Registered")

        container.register(SomeClass.self) { _ in SomeClass() }
        container.register(SomeOtherClass.self) { _ in SomeOtherClass() }
        let iterations = 10000
        
        Task.detached(priority: .high) {
            DispatchQueue.concurrentPerform(iterations: iterations) { _ in
                container.replace(SomeClass.self) { _ in SomeClass() }
            }
            someClassExp.fulfill()
        }

        Task(priority: .low) {
            DispatchQueue.concurrentPerform(iterations: iterations) { _ in
                container.replace(SomeOtherClass.self) { _ in SomeOtherClass() }
            }
            someOtherClassExp.fulfill()
        }

        Task.detached(priority: .medium) {
            DispatchQueue.concurrentPerform(iterations: iterations) { _ in
                let a: SomeClass? = container.optionalResolve()
                let _: SomeOtherClass? = container.optionalResolve()
                XCTAssertNotNil(a)
            }
            allResolveExp.fulfill()
        }

        wait(for: [someClassExp, someOtherClassExp, allResolveExp], timeout: 5)
    }
    
    func testMacro_register_paremeter() {
        let myDI = SMyDI()
        myDI.register { param, resolver in
            SmoVM(value: 1)
        }
        
        let _: ISmoVM = myDI.resolve(param: 1)
    }
    
//    func testMacro_thread_safety() {
//        let myDI = SMyDI()
//        let iterations = 10000
//        let expectation = expectation(description: "all done")
//
//        Task.detached(priority: .medium) {
//            DispatchQueue.concurrentPerform(iterations: iterations) { _ in
//                myDI.register { param, resolver in
//                    SmoVM(value: 1)
//                }
//                let vm: ISmoVM = myDI.resolve(param: 1)
//                XCTAssertNotNil(vm)
//            }
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 5)
//    }
    
    private class SomeClass {
        var data = 1
    }

    private class SomeOtherClass {
        var data = 2
    }
}

protocol ISmoVM {}

final class SmoVM: ISmoVM {
    let value: Int
    init(value: Int) {
        self.value = value
    }
}

@register(parameters: Int.self, result: ISmoVM.self)
final class SMyDI: Dependo {
}
