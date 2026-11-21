@testable import t_slamb
import Testing

struct ScannerTests {
    @Test func tokenizesLambdaApplication() throws {
        let tokens = try tokenize("(\\x. x) 0042")

        #expect(tokens == [
            Token(kind: .leftParen, lexeme: "(", line: 1),
            Token(kind: .backslash, lexeme: "\\", line: 1),
            Token(kind: .identifier("x"), lexeme: "x", line: 1),
            Token(kind: .dot, lexeme: ".", line: 1),
            Token(kind: .identifier("x"), lexeme: "x", line: 1),
            Token(kind: .rightParen, lexeme: ")", line: 1),
            Token(kind: .number(42), lexeme: "0042", line: 1),
            Token(kind: .eof, lexeme: "", line: 1),
        ])
    }

    @Test func recognizesOnlyWholeBooleanKeywords() throws {
        let tokens = try tokenize("true false\ntrueValue")

        #expect(tokens == [
            Token(kind: .boolean(true), lexeme: "true", line: 1),
            Token(kind: .boolean(false), lexeme: "false", line: 1),
            Token(kind: .identifier("trueValue"), lexeme: "trueValue", line: 2),
            Token(kind: .eof, lexeme: "", line: 2),
        ])
    }
}
