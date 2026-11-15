indirect enum Expr {
    case variable(name: String)
    case number(value: Int)
    case boolean(value: Bool)
    case apply(fun: Expr, arg: Expr)
    case lambda(param: String, body: Expr)
    case define(variable: String, value: Expr, body: Expr)
}

enum Val {
    case number(Int)
    case boolean(Bool)
    case closure(param: String, body: Expr, env: Environment)
}

typealias Environment = [String: Val]

func bind_var(variable: String, value: Val, env: Environment) -> Environment {
    var newEnv = env
    newEnv[variable] = value
    return newEnv
}

func eval(exp: Expr, env: Environment) throws -> Val {
    switch exp {
    case let .variable(name):
        guard let res = env[name] else {
            throw evalErrors(description: "Can't find this variable.")
        }
        return res
    case let .number(value):
        return .number(value)
    case let .boolean(value):
        return .boolean(value)
    case let .lambda(param, body):
        return .closure(param: param, body: body, env: env)
    case let .apply(fun, arg):
        let function = try eval(exp: fun, env: env)
        guard case let .closure(param, body, cenv) = function else {
            throw evalErrors(description: "Not a function.")
        }
        let newEnv = try bind_var(variable: param, value: eval(exp: arg, env: env), env: cenv)
        return try eval(exp: body, env: newEnv)
    case let .define(variable, value, body):
        let val = try eval(exp: value, env: env)
        let newEnv = bind_var(variable: variable, value: val, env: env)
        return try eval(exp: body, env: newEnv)
    }
}
