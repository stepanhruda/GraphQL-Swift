enum TokenKind {
    case EndOfFile
    case Bang
    case Dollar
    case ParenLeft
    case ParenRight
    case Spread
    case Colon
    case Equals
    case At
    case BracketLeft
    case BracketRight
    case BraceLeft
    case Pipe
    case BraceRight
    case Name
    case Variable
    case Int
    case Float
    case String
}

struct Token {
    let kind: TokenKind
    let start: String.Index
    let end: String.Index
    let value: Any?

    init(kind: TokenKind, start: String.Index, end: String.Index, value: Any? = nil) {
        self.kind = kind
        self.start = start
        self.end = end
        self.value = value
    }
}
