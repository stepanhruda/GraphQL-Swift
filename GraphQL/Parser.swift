func parse(source: Source, options: ParseOptions = ParseOptions()) throws -> Document {
    let lexer = lex(source)
    var parser = Parser(lexer: lexer, source: source, options: options, previousEnd: source.body.startIndex, currentToken: try lexer(source.body.startIndex))
    return try parser.parseDocument()
}

enum ParserErrorCode: Int {
    case UnexpectedToken
    case DuplicateInputObjectField
}

struct ParserError: ErrorType {
    var _domain: String { get { return "technology.stepan.GraphQL-Swift.Parser" } }
    var _code: Int { get { return code.rawValue } }

    let code: ParserErrorCode
    let source: Source
    let position: String.Index
    let description: String?

    init(code: ParserErrorCode, source: Source, position: String.Index, description: String? = nil) {
        self.code = code
        self.source = source
        self.position = position
        self.description = description
    }
}

struct ParseOptions: OptionSetType {
    let rawValue: UInt
    static let NoLocation = ParseOptions(rawValue: 1)
    static let NoSource = ParseOptions(rawValue: 2)
}

enum Keyword: String {
    case Fragment = "fragment"
    case Mutation = "mutation"
    case On = "on"
    case Query = "query"
}

struct Parser {
    let lexer: String.Index? throws -> Token
    let source: Source
    let options: ParseOptions
    var previousEnd: String.Index
    var currentToken: Token

    mutating func parseDocument() throws -> Document {
        let start = currentToken.start
        var definitions: [Definition] = []

        repeat {

            switch currentToken.kind {
            case .BraceLeft:
                definitions.append(parseOperationDefinition())
            case .Name:
                let name = currentToken.value as! String
                switch name {
                case Keyword.Query.rawValue, Keyword.Mutation.rawValue:
                    definitions.append(parseOperationDefinition())
                case Keyword.Fragment.rawValue:
                    definitions.append( try parseFragmentDefinition())
                default:
                    try unexpectedToken()
                }
            default:
                try unexpectedToken()
            }

        } while try !skip(.EndOfFile)

        return Document(definitions: definitions, location: locateWithStart(start))
    }

    // TODO: this name is confusing
    mutating func skip(kind: TokenKind) throws -> Bool {
        let match = currentToken.kind == kind
        if (match) {
            try advance()
        }
        return match
    }

    mutating func advance() throws {
        previousEnd = currentToken.end
        currentToken = try lexer(previousEnd)
    }

    func nextTokenIs(kind: TokenKind) -> Bool {
        return currentToken.kind == kind
    }

    func parseOperationDefinition() -> OperationDefinition {
        let _ = currentToken.start

        if nextTokenIs(.BraceLeft) {

        } else {

        }

        return undefined()
    }

    mutating func parseFragmentDefinition() throws -> FragmentDefinition {
        let start = currentToken.start
        try expectKeyword(.Fragment)
        return FragmentDefinition(
            name: try parseName(),
            typeCondition: (try expectKeyword(.On), try parseName()),
            directives: try parseDirectives(),
            selectionSet: try parseSelectionSet(),
            location: locateWithStart(start))
    }

    func expectKeyword(keyword: Keyword) throws -> Token {
        return undefined()
    }

    mutating func parseName() throws -> Name {
        let start = currentToken.start
        let token = try expect(.Name)
        return Name(value: token.value as! String, location: locateWithStart(start))
    }

    mutating func expect(kind: TokenKind) throws -> Token {
        if currentToken.kind == kind {
            try advance()
            return currentToken
        } else {
            throw ParserError(code: .UnexpectedToken, source: source, position: previousEnd, description: "Expected \(kind), found \(currentToken.kind)")
        }
    }

    mutating func parseSelectionSet() throws -> SelectionSet {
        return undefined()
    }

    mutating func parseDirectives() throws -> [Directive] {
        var directives: [Directive] = []
        while nextTokenIs(.At) {
            directives.append(try parseDirective())
        }
        return directives
    }

    mutating func parseDirective() throws -> Directive {
        let start = currentToken.start
        try expect(.At)
        return Directive(
            name: try parseName(),
            value: try skip(.Colon) ? try parseValue(isConst: false) : nil,
            location: locateWithStart(start))
    }

    mutating func parseValue(isConst isConst: Bool) throws -> Value {
        switch currentToken.kind {
        case TokenKind.BracketLeft:
            return try parseArray(isConst: isConst)
        case TokenKind.BraceLeft:
            return try parseObject(isConst: isConst)
        case TokenKind.Int:
            return try parseInt()
        case TokenKind.Float:
            return try parseFloat()
        case TokenKind.String:
            return try parseString()
        case TokenKind.Name:
            return try parseBoolOrEnum()
        case TokenKind.Dollar:
            if (!isConst) {
                return try parseVariable()
            }
        default: break
        }
        try unexpectedToken()
        fatalError("^ error thrown here")
    }

    mutating func parseArray(isConst isConst: Bool) throws -> Array {
        let start = currentToken.start
        let parseFunction = { isConst ? try self.parseConstValue() : try self.parseVariableValue() }
        return Array(
            values: try parseBetweenDelimiters(left: .BracketLeft, function: parseFunction, right: .BracketRight),
            location: locateWithStart(start))
    }

    mutating func parseInt() throws -> IntValue {
        let token = currentToken
        try advance()
        return IntValue(value: token.value as! Int, location: locateWithStart(token.start))
    }

    mutating func parseFloat() throws -> FloatValue {
        let token = currentToken
        try advance()
        return FloatValue(value: token.value as! Float, location: locateWithStart(token.start))
    }

    mutating func parseString() throws -> StringValue {
        let token = currentToken
        try advance()
        return StringValue(value: token.value as! String, location: locateWithStart(token.start))
    }

    mutating func parseVariable() throws -> Variable {
        let start = currentToken.start
        try expect(.Dollar)
        return Variable(value: try parseName(), location: locateWithStart(start))
    }

    mutating func parseBoolOrEnum() throws -> Value {
        let string = currentToken.value as! String
        let location = locateWithStart(currentToken.start)
        try advance()
        switch string {
        case "true": return BoolValue(value: true, location: location)
        case "false": return BoolValue(value: false, location: location)
        default: return EnumValue(value: string, location: location)
        }
    }

    mutating func parseObject(isConst isConst: Bool) throws -> Object {
        let start = currentToken.start
        try expect(.BraceLeft)
        var fields: [ObjectField] = []
        var fieldNames: [Name] = []
        while try !skip(.BraceRight) {
            fields.append(try parseObjectField(isConst: isConst, existingFieldNames: &fieldNames))
        }
        return Object(fields: fields, location: locateWithStart(start))
    }

    mutating func parseObjectField(isConst isConst: Bool, inout existingFieldNames: [Name]) throws -> ObjectField {
        let start = currentToken.start
        let name = try parseName()
        guard !(existingFieldNames.contains { $0.value == name.value }) else {
            throw ParserError(code: .DuplicateInputObjectField, source: source, position: previousEnd, description: "Duplicate input object field \(name.value)")
        }
        existingFieldNames.append(name)

        return ObjectField(
            name: name,
            value: (try expect(.Colon), try parseValue(isConst: isConst)),
            location: locateWithStart(start))
    }

    mutating func parseConstValue() throws -> Value {
        return try parseValue(isConst: true)
    }

    mutating func parseVariableValue() throws -> Value {
        return try parseValue(isConst: false)
    }

    func unexpectedToken() throws {

    }

    mutating func parseBetweenDelimiters<T>(left left: TokenKind, function: () throws -> T, right: TokenKind) throws -> [T] {
        try expect(left)
        var nodes: [T] = []
        while try !skip(right) {
            nodes.append(try function())
        }
        try expect(right)
        return nodes
    }

    func locateWithStart(start: String.Index) -> Location? {
        if options.contains(ParseOptions.NoLocation) {
            return nil
        } else {
            let source: Source? = options.contains(ParseOptions.NoLocation) ? nil : self.source
            return Location(start: start, end: previousEnd, source: source)
        }
    }
}