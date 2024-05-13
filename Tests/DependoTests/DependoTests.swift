import XCTest
import Dependo
import DependoMacro

final class DependoTests: XCTestCase {
    func testInstanceResolve() {
        let container = Dependo()
            .register(instance: Int(4))

        XCTAssertEqual(container.resolve(Int.self), 4)
    }

    func testInvalidResolveFails() {
        let container = Dependo()
            .register(instance: Int(4))

        let resolver = container as Resolver
        expectFatalError {
            let _: Double = resolver.resolve()
        }
    }

    func testInvalidTryResolveNotFails() {
        let container = Dependo()
            .register(instance: Int(4))

        XCTAssertNil(container.optionalResolve(Double.self))
    }

    func testDoubleRegisterFails() {
        let container = Dependo()
            .register(instance: Int(4))

        expectFatalError {
            container.register(instance: Int(12))
        }
    }

    func testRegisterAndReplace() {
        let container = Dependo().register(instance: Int(4))
        container.replace(instance: Int(12))
        XCTAssertEqual(container.resolve(Int.self), 12)
    }

    func testRegisterTypeInstance() {
        let container = Dependo()
            .register(Int.self, instance: Int(4))
        XCTAssertEqual(container.resolve(Int.self), 4)
    }

    func testNullableResolve() {
        let container = Dependo()
            .register(instance: Int(4))

        let value: Int? = container.resolve()

        XCTAssertEqual(value, Int(4))

        expectFatalError {
            let _: Double? = container.resolve()
        }
    }

    func testNullableResolve_from_interface() {
        let container: Resolver = Dependo()
            .register(instance: Int(4))

        let value: Int = container.resolve()

        XCTAssertEqual(value, Int(4))

        expectFatalError {
            let _: Double? = container.resolve()
        }
    }

    func testTryResolve_from_interface() {
        let container: Resolver = Dependo().register(instance: Int(4))
        let value: Int? = container.optionalResolve()

        XCTAssertEqual(value, 4)
    }
    
    func testAllFactories() {
        let container = Dependo()
            .register(SomeClass.self) { _ in SomeClass() }
            .register(SomeOtherClass.self) { _ in SomeOtherClass() }

        container.registeredEntities()
            .forEach { constructor in
                XCTAssertNotNil(constructor())
            }
    }

    func testThreadSafety() {
        let container = Dependo()
        let registerAExp = expectation(description: "register all Test Classes")
        let registerBExp = expectation(description: "register all TestB Classes")
        let resolveExp = expectation(description: "register all")

        container.register(SomeClass.self) { _ in SomeClass() }
        container.register(SomeOtherClass.self) { _ in SomeOtherClass() }

        Task.detached(priority: .high) {
            DispatchQueue.concurrentPerform(iterations: 9000) { _ in
                container.replace(SomeClass.self) { _ in SomeClass() }
            }
            registerAExp.fulfill()
        }

        Task.detached(priority: .low) {
            DispatchQueue.concurrentPerform(iterations: 9000) { _ in
                container.replace(SomeOtherClass.self) { _ in SomeOtherClass() }
            }
            registerBExp.fulfill()
        }

        Task.detached(priority: .medium) {
            DispatchQueue.concurrentPerform(iterations: 9000) { _ in
                let a: SomeClass? = container.optionalResolve()
                let _: SomeOtherClass? = container.optionalResolve()
                XCTAssertNotNil(a)
            }
            resolveExp.fulfill()
        }

        wait(for: [registerAExp, registerBExp, resolveExp], timeout: 5)
    }

    func testMacros() {
        let myDI = SMyDI()
        myDI.register { param, resolver in
            SmoVM(value: 1)
        }
        
        let _: ISmoVM = myDI.resolve(param: 1)
    }
    
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
