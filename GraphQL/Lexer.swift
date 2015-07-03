// TODO: Make this an object?
func lex(source: Source) -> (String.Index? throws -> Token) {
    var previousPosition = source.body.startIndex
    return { position in
        var token: Token

        do {
            token = try Lexer.readSource(source, position: position ?? previousPosition)
        } catch let error {
            throw error
        }

        previousPosition = token.end
        return token
    }
}

enum LexerErrorCode: Int {
    case UnexpectedCharacter
    case InvalidNumber
    case UnterminatedString
    case BadCharacterEscapeSequence
}

struct LexerError: ErrorType {
    var _domain: String { get { return "technology.stepan.GraphQL-Swift.Lexer" } }
    var _code: Int { get { return code.rawValue } }

    let code: LexerErrorCode
    let source: Source
    let position: String.Index
}

struct Lexer {
    static func readSource(source: Source, position: String.Index) throws -> Token {
        let characters = source.body.characters

        let position = positionAfterWhitespace(body: source.body, position: position)

        if position >= characters.endIndex {
            return Token(kind: .EndOfFile(), start: position, end: position)
        }

        switch characters[position] {

        case "!": return Token(kind: .Bang(), start: position, end: position + 1)
        case "$": return Token(kind: .Dollar(), start: position, end: position + 1)
        case "(": return Token(kind: .ParenLeft(), start: position, end: position + 1)
        case ")": return Token(kind: .ParenRight(), start: position, end: position + 1)

        case "." where characters[position + 1] == "." && characters[position + 2] == ".":
            return Token(kind: .Spread(), start: position, end: position + 3)

        case ":": return Token(kind: .Colon(), start: position, end: position + 1)
        case "=": return Token(kind: .Equals(), start: position, end: position + 1)
        case "@": return Token(kind: .At(), start: position, end: position + 1)
        case "[": return Token(kind: .BracketLeft(), start: position, end: position + 1)
        case "]": return Token(kind: .BracketRight(), start: position, end: position + 1)
        case "{": return Token(kind: .BraceLeft(), start: position, end: position + 1)
        case "|": return Token(kind: .Pipe(), start: position, end: position + 1)
        case "}": return Token(kind: .BraceRight(), start: position, end: position + 1)

        case "A"..."Z", "_", "a"..."z": return readName(source: source, position: position)
        case "-", "0"..."9":
            do {
                return try readNumber(source: source, position: position)
            } catch let error {
                throw error
            }
        case "\"":
            do {
                return try readString(source: source, position: position)
            } catch let error {
                throw error
            }

        default: throw LexerError(code: .UnexpectedCharacter, source: source, position: position)

        }
    }

    static func readName(source source: Source, position start: String.Index) -> Token {
        let body = source.body
        var end = start

        for character in body[start..<body.endIndex].generate() {
            guard character.isValidNameCharacter else { break }
            end++
        }

        end--

        return Token(kind: .Name(body[start...end]), start: start, end: end)
    }

    static func readNumber(source source: Source, position start: String.Index) throws -> Token {
        let body = source.body
        var lastValid = start
        var generator = body[start..<body.endIndex].generate()
        var isFloat = false
        let nextCharacter: Void -> Character? = {
            lastValid++
            return generator.next()
        }
        var character = nextCharacter()
        lastValid--

        if character == "-" {
            character = nextCharacter()
        }

        if character == "0" {
            character = nextCharacter()
        } else if let tested = character, case "1"..."9" = tested {
            repeat {
                character = nextCharacter()
                guard let tested = character, case "0"..."9" = tested else { lastValid--; break }
            } while true
        } else {
            throw LexerError(code: .InvalidNumber, source: source, position: lastValid + 1)
        }

        if character == "." {
            isFloat = true
            character = nextCharacter()

            if let tested = character, case "0"..."9" = tested {
                repeat {
                    character = nextCharacter()
                    guard let tested = character, case "0"..."9" = tested else { break }
                } while true
            } else {
                throw LexerError(code: .InvalidNumber, source: source, position: lastValid + 1)
            }

            if character == "e" {
                character = nextCharacter()

                if character == "-" {
                }
                if let tested = character, case "0"..."9" = tested {
                    repeat {
                        character = nextCharacter()
                        guard let tested = character, case "0"..."9" = tested else { lastValid--; break }
                    } while true
                } else {
                    throw LexerError(code: .InvalidNumber, source: source, position: lastValid + 1)
                }
            }
        }

        let value = body[start...lastValid]
        return Token(kind: isFloat ? .FloatValue(Float(value)!): .IntValue(Int(value)!), start: start, end: lastValid)
    }

    static func readString(source source: Source, position start: String.Index) throws -> Token {
        let body = source.body
        var alreadyProcessed = start
        var end = start
        var value = ""
        var escapingCharacters = false
        var charactersToSkip = 0

        lexing: for character in body[(start + 1)..<body.endIndex].generate() {
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
        return Token(kind: .StringValue(value), start: start, end: end)
    }

    static func positionAfterWhitespace(body body: String, position start: String.Index) -> String.Index {
        var position = start
        var insideComment = false

        search: for character in body[start..<body.endIndex].generate() {
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
    return advance(left, right)
}

func - (left: String.Index, right: Int) -> String.Index {
    return advance(left, -right)
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
