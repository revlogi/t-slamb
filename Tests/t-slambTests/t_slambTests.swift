@testable import t_slamb
import Testing

struct EvalTests {
    private func identityApplication(to exp: Expr) -> Expr {
        .apply(
            fun: .lambda(param: "x", body: .variable(name: "x")),
            arg: exp
        )
    }

    private func unusedApplication(to exp: Expr) -> Expr {
        .apply(
            fun: .lambda(param: "x", body: .number(value: 42)),
            arg: exp
        )
    }

    @Test func identityApplication() throws {
        // \x.x 42
        let expression = identityApplication(to: .number(value: 42))

        let result = try eval(exp: expression, env: [:])
        expect42(result)
    }

    @Test func bodyUsesCapturedEnvironment() throws {
        // f = \y. x where x = 42
        let function = try eval(
            exp: .lambda(param: "y", body: .variable(name: "x")),
            env: ["x": .number(42)]
        )

        let result = try eval(
            exp: .apply(
                fun: .variable(name: "f"),
                arg: .number(value: 0)
            ),
            env: [
                "f": function,
                "x": .number(10),
            ]
        )
        expect42(result)
    }

    @Test func argumentUsesCallerEnvironment() throws {
        let identity = try eval(
            exp: .lambda(
                param: "x",
                body: .variable(name: "x")
            ),
            env: ["y": .number(10)]
        )

        let result = try eval(
            exp: .apply(fun: .variable(name: "f"), arg: .variable(name: "y")),
            env: [
                "f": identity,
                "y": .number(42),
            ]
        )
        expect42(result)
    }

    @Test func definitionValuesUsesOuterBinding() throws {
        let expression = Expr.define(
            variable: "x",
            value: .variable(name: "x"),
            body: .variable(name: "x")
        )

        let result = try eval(
            exp: expression,
            env: [
                "x": .number(42),
            ]
        )
        expect42(result)
    }

    @Test func undefinedArgument() {
        let expression = identityApplication(to: .variable(name: "missing"))

        #expect(throws: evalErrors.self) {
            _ = try eval(exp: expression, env: [:])
        }
    }

    @Test func unusedArgumentEval() {
        let expression = unusedApplication(to: .variable(name: "missing"))

        #expect(throws: evalErrors.self) {
            _ = try eval(exp: expression, env: [:])
        }
    }
}

private func expect42(_ result: Val) {
    guard case let .number(value) = result else {
        Issue.record("Not a number.")
        return
    }
    #expect(value == 42)
}

@Test func example() {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    // Swift Testing Documentation
    // https://developer.apple.com/documentation/testing
}
