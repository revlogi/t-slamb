enum TokenKind: Equatable {
    case number(Int)
    case boolean(Bool)
    case identifier(String)
    case dot
    case backslash
    case leftParen
    case rightParen
    case eof
}

struct Token: Equatable {
    let kind: TokenKind
    let lexeme: String
    let line: Int
}

struct Cursor {
    let offset: Int
    let line: Int
}

struct ScanStep {
    let token: Token?
    let next_cursor: Cursor
}

enum ScanError: Error {
    case unexpectedCharacter(Character, line: Int)
    case integerOverflow(String, line: Int)
}

private func isDigit(_ char: Character) -> Bool {
    ("0" ... "9").contains(char)
}

private func isIdentifierStart(_ char: Character) -> Bool {
    char.isLetter || char == "_"
}

private func endOfRun(_ source: [Character], from begin: Int, while matches: (Character) -> Bool) -> Int {
    var end = begin
    while end < source.count && matches(source[end]) {
        end += 1
    }

    return end
}

private func scanNumber(_ source: [Character], at cursor: Cursor) throws -> ScanStep {
    let end = endOfRun(source, from: cursor.offset, while: isDigit)
    let lexeme = String(source[cursor.offset ..< end])

    guard let value = Int(lexeme) else {
        throw ScanError.integerOverflow(lexeme, line: cursor.line)
    }

    return ScanStep(
        token: Token(
            kind: .number(value),
            lexeme: lexeme,
            line: cursor.line
        ),
        next_cursor: Cursor(
            offset: end,
            line: cursor.line
        )
    )
}

private func scanIdentifier(_ source: [Character], at cursor: Cursor) -> ScanStep {
    let end = endOfRun(source, from: cursor.offset) {
        isIdentifierStart($0) || isDigit($0)
    }
    let lexeme = String(source[cursor.offset ..< end])
    let kind = Bool(lexeme).map(TokenKind.boolean) ?? .identifier(lexeme)

    return ScanStep(
        token: Token(
            kind: kind,
            lexeme: lexeme,
            line: cursor.line
        ),
        next_cursor: Cursor(
            offset: end,
            line: cursor.line
        )
    )
}

private func scanOne(_ source: [Character], at cursor: Cursor) throws -> ScanStep {
    let curr = source[cursor.offset]

    if curr.isWhitespace {
        return ScanStep(
            token: nil,
            next_cursor: Cursor(
                offset: cursor.offset + 1,
                line: cursor.line + (curr.isNewline ? 1 : 0)
            )
        )
    }

    if isDigit(curr) {
        return try scanNumber(source, at: cursor)
    }

    if isIdentifierStart(curr) {
        return scanIdentifier(source, at: cursor)
    }

    let kind: TokenKind = switch curr {
    case ".": .dot
    case "\\": .backslash
    case "(": .leftParen
    case ")": .rightParen
    default:
        throw ScanError.unexpectedCharacter(curr, line: cursor.line)
    }

    return ScanStep(
        token: Token(
            kind: kind,
            lexeme: String(curr),
            line: cursor.line
        ),
        next_cursor: Cursor(
            offset: cursor.offset + 1,
            line: cursor.line
        )
    )
}

func tokenize(_ source: String) throws -> [Token] {
    let chars = Array(source)
    var cursor = Cursor(offset: 0, line: 1)
    var tokens: [Token] = []

    while cursor.offset < chars.count {
        let step = try scanOne(chars, at: cursor)

        if let token = step.token {
            tokens.append(token)
        }

        cursor = step.next_cursor
    }

    tokens.append(Token(kind: .eof, lexeme: "", line: cursor.line))
    return tokens
}
