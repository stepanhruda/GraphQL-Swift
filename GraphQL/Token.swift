enum TokenKind {
    case EndOfFile(Void)
    case Bang(Void)
    case Dollar(Void)
    case ParenLeft(Void)
    case ParenRight(Void)
    case Spread(Void)
    case Colon(Void)
    case Equals(Void)
    case At(Void)
    case BracketLeft(Void)
    case BracketRight(Void)
    case BraceLeft(Void)
    case Pipe(Void)
    case BraceRight(Void)
    case Name(String)
    case Variable(String)
    case IntValue(Int)
    case FloatValue(Float)
    case StringValue(String)
}


struct Token {
    let kind: TokenKind
    let start: String.Index
    let end: String.Index
}

extension Token {

}