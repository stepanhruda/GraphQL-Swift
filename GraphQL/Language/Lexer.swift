enum LexerErrorCode: Int {
    case UnexpectedCharacter
    case InvalidNumber
    case UnterminatedString
    case BadCharacterEscapeSequence
}

struct LexerError: ErrorType {
    let code: LexerErrorCode
    let source: Source
    let position: String.Index
}

struct Lexer {
    static func functionForSource(source: Source) -> (String.Index? throws -> Token) {
        var previousPosition = source.body.startIndex
        return { position in
            let token = try readSource(source, position: position ?? previousPosition)
            previousPosition = token.end
            return token
        }
    }

    static func readSource(source: Source, position: String.Index) throws -> Token {
        let characters = source.body.characters

        let position = positionAfterWhitespace(body: source.body, position: position)

        if position >= characters.endIndex {
            return Token(kind: .EndOfFile, start: position, end: position)
        }

        switch characters[position] {

        case "!": return Token(kind: .Bang, start: position, end: position + 1)
        case "$": return Token(kind: .Dollar, start: position, end: position + 1)
        case "(": return Token(kind: .ParenLeft, start: position, end: position + 1)
        case ")": return Token(kind: .ParenRight, start: position, end: position + 1)

        case "." where characters[position + 1] == "." && characters[position + 2] == ".":
            return Token(kind: .Spread, start: position, end: position + 3)

        case ":": return Token(kind: .Colon, start: position, end: position + 1)
        case "=": return Token(kind: .Equals, start: position, end: position + 1)
        case "@": return Token(kind: .At, start: position, end: position + 1)
        case "[": return Token(kind: .BracketLeft, start: position, end: position + 1)
        case "]": return Token(kind: .BracketRight, start: position, end: position + 1)
        case "{": return Token(kind: .BraceLeft, start: position, end: position + 1)
        case "|": return Token(kind: .Pipe, start: position, end: position + 1)
        case "}": return Token(kind: .BraceRight, start: position, end: position + 1)

        case "A"..."Z", "_", "a"..."z": return readName(source: source, position: position)
        case "-", "0"..."9":
            return try readNumber(source: source, position: position)

        case "\"":
            return try readString(source: source, position: position)

        default: throw LexerError(code: .UnexpectedCharacter, source: source, position: position)

        }
    }

    static func readName(source source: Source, position start: String.Index) -> Token {
        let body = source.body
        var end = start

        for character in body[start..<body.endIndex].characters.generate() {
            guard character.isValidNameCharacter else { break }
            end++
        }

        return Token(kind: .Name, start: start, end: end, value: body[start..<end])
    }

    static func readNumber(source source: Source, position start: String.Index) throws -> Token {
        let body = source.body
        var end = start
        var generator = body[start..<body.endIndex].characters.generate()
        var lastCharacterInvalid = false
        var isFloat = false
        let nextCharacter: Void -> Character? = {
            let next = generator.next()
            guard let _ = next else { return next }
            end++
            return next
        }

        var character = nextCharacter()

        let readDigits: Void -> Void = {
            repeat {
                character = nextCharacter()
                guard let tested = character, case "0"..."9" = tested else {
                    if end < body.endIndex {
                        lastCharacterInvalid = true
                    }
                    break
                }
            } while true
        }

        if character == "-" {
            character = nextCharacter()
        }

        if character == "0" {
            character = nextCharacter()
        } else if let tested = character, case "1"..."9" = tested {
            readDigits()
        } else {
            throw LexerError(code: .InvalidNumber, source: source, position: end)
        }

        if character == "." {
            isFloat = true
            lastCharacterInvalid = false
            character = nextCharacter()

            if let tested = character, case "0"..."9" = tested {
                readDigits()
            } else {
                throw LexerError(code: .InvalidNumber, source: source, position: end)
            }

            if character == "e" {
                lastCharacterInvalid = false
                character = nextCharacter()

                if character == "-" {
                    character = nextCharacter()
                }
                if let tested = character, case "0"..."9" = tested {
                    readDigits()
                } else {
                    throw LexerError(code: .InvalidNumber, source: source, position: end)
                }
            }
        }

        if lastCharacterInvalid { end-- }

        let value = body[start..<end]
        // IMPROVEMENT: Raise error if the number cannot be converted
        // IMPROVEMENT: Add support for Double instead of Float
        return Token(kind: isFloat ? .Float : .Int, start: start, end: end, value: isFloat ? Float(value)! : Int(value)!)
    }

    static func readString(source source: Source, position start: String.Index) throws -> Token {
        let body = source.body
        var alreadyProcessed = start
        var end = start
        var value = ""
        var escapingCharacters = false
        var charactersToSkip = 0

        lexing: for character in body[(start + 1)..<body.endIndex].characters.generate() {
            end++

            if (charactersToSkip > 0) {
                --charactersToSkip > 0
                continue
            }

            if (!escapingCharacters) {

                switch character {
                case "\"", "\n", "\r", "\u{2028}", "\u{2029}": break lexing
                case "\\":
                    value += body[(alreadyProcessed + 1)..<end]
                    alreadyProcessed = end - 1
                    escapingCharacters = true
                default: continue
                }

            } else {
                switch character {
                case "\"": value += "\""
                case "/": value += "/"
                case "\\": value += "\\"
                case "b": value += "\\b"
                case "f": value += "\\f"
                case "n": value += "\\n"
                case "r": value += "\\r"
                case "t": value += "\\t"
                case "u":

                    charactersToSkip = 4

                    guard body.endIndex > end + 3 else {
                        throw LexerError(code: .BadCharacterEscapeSequence, source: source, position: end)
                    }

                    let characterCode = Int(body[(end + 1)...(end + 4)], radix: 16)

                    if let characterCode = characterCode {
                        var unicodeCharacter = ""
                        UnicodeScalar(characterCode).writeTo(&unicodeCharacter)
                        value += unicodeCharacter

                        alreadyProcessed = alreadyProcessed + 4
                    } else {
                        throw LexerError(code: .BadCharacterEscapeSequence, source: source, position: end)
                    }

                default:
                    throw LexerError(code: .BadCharacterEscapeSequence, source: source, position: end)
                }

                alreadyProcessed = alreadyProcessed + 2
                escapingCharacters = false
            }
        }

        guard body[end] == "\"" && end > start else {
            throw LexerError(code: .UnterminatedString, source: source, position: end)
        }

        value += body[(alreadyProcessed + 1)..<end]
        return Token(kind: .String, start: start, end: end + 1, value: value)
    }

    static func positionAfterWhitespace(body body: String, position start: String.Index) -> String.Index {
        var position = start
        var insideComment = false

        search: for character in body[start..<body.endIndex].characters.generate() {
            if (!insideComment) {
                switch character {
                case " ", ",", "\t"..."\r", "\u{2028}", "\u{2029}" : position++
                case "#": insideComment = true; position++
                default: break search
                }
            } else {
                position++
                switch character {
                case "\n", "\r", "\u{2028}", "\u{2029}": insideComment = false
                default: continue
                }
            }
        }

        return position
    }
}



func + (left: String.Index, right: Int) -> String.Index {
    return left.advancedBy(right)
}

func - (left: String.Index, right: Int) -> String.Index {
    return left.advancedBy(-right)
}

extension Character {
    var isValidNameCharacter: Bool {
        get {
            switch self {
            case "A"..."Z", "_", "a"..."z", "0"..."9": return true
            default: return false
            }
        }
    }
}
