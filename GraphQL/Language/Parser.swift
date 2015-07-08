func parse(source: Source, options: ParseOptions = ParseOptions()) throws -> Document {
    let lexer = Lexer.functionForSource(source)
    let parser = Parser(lexer: lexer, source: source, options: options, previousEnd: source.body.startIndex, token: try lexer(nil))
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
    static let NoLocation = ParseOptions(rawValue: 1 << 0)
    static let NoSource = ParseOptions(rawValue: 1 << 1)
}

enum Keyword: String {
    case Fragment = "fragment"
    case Mutation = "mutation"
    case On = "on"
    case Query = "query"
}

class Parser {
    let lexer: String.Index? throws -> Token
    let source: Source
    let options: ParseOptions
    var previousEnd: String.Index
    var currentToken: Token

    init(lexer: String.Index? throws -> Token, source: Source, options: ParseOptions, previousEnd: String.Index, token: Token) {
        self.lexer = lexer
        self.source = source
        self.options = options
        self.previousEnd = previousEnd
        self.currentToken = token
    }

    func parseDocument() throws -> Document {
        let start = currentToken.start
        var definitions: [Definition] = []

        repeat {

            switch currentToken.kind {
            case .BraceLeft:
                definitions.append(try parseOperationDefinition())
            case .Name:
                let name = currentToken.value as! String
                switch name {
                case Keyword.Query.rawValue, Keyword.Mutation.rawValue:
                    definitions.append(try parseOperationDefinition())
                case Keyword.Fragment.rawValue:
                    definitions.append(try parseFragmentDefinition())
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
    func skip(kind: TokenKind) throws -> Bool {
        let match = currentToken.kind == kind
        if (match) {
            try advance()
        }
        return match
    }

    func advance() throws {
        previousEnd = currentToken.end
        currentToken = try lexer(previousEnd)
    }

    func nextTokenIs(kind: TokenKind) -> Bool {
        return currentToken.kind == kind
    }

    func parseOperationDefinition() throws -> OperationDefinition {
        let start = currentToken.start

        if nextTokenIs(.BraceLeft) {
            return OperationDefinition(
                operation: Keyword.Query.rawValue,
                name: nil,
                variableDefinitions: nil,
                directives: [],
                selectionSet: try parseSelectionSet(),
                location: locateWithStart(start))
        } else {
            let operationToken = try expect(.Name)
            let operation = operationToken.value as! String
            return OperationDefinition(
                operation: operation,
                name: try parseName(),
                variableDefinitions: try parseVariableDefinitions(),
                directives: try parseDirectives(),
                selectionSet: try parseSelectionSet(),
                location: locateWithStart(start))
        }
    }

    func parseVariableDefinitions() throws -> [VariableDefinition] {
        return nextTokenIs(.ParenLeft)
        ? try parseOneOrMoreBetweenDelimiters(left: .ParenLeft, function: parseVariableDefinition, right: .ParenRight)
        : []
    }

    func parseVariableDefinition() throws -> VariableDefinition {
        let start = currentToken.start

        return VariableDefinition(
            variable: try parseVariable(),
            type: (try expect(.Colon), try parseType()),
            defaultValue: try skip(.Equals) ? try parseValue(isConst: true) : nil,
            location: locateWithStart(start))
    }

    func parseType() throws -> Type {
        let start = currentToken.start

        var type: Type
        if try skip(.BracketLeft) {
            type = try parseType()
            try expect(.BracketRight)
            type = ListType(type: type, location: locateWithStart(start))
        } else {
            type = try parseNamedType()
        }
        if try skip(.Bang) {
            return NonNullType(type: type, location: locateWithStart(start))
        } else {
            return type
        }
    }

    func parseNamedType() throws -> NamedType {
        let start = currentToken.start
        let token = try expect(.Name)
        return NamedType(value: token.value as! String, location: locateWithStart(start))
    }

    func parseFragmentDefinition() throws -> FragmentDefinition {
        let start = currentToken.start
        try expectKeyword(.Fragment)
        return FragmentDefinition(
            name: try parseName(),
            typeCondition: try parseTypeCondition(),
            directives: try parseDirectives(),
            selectionSet: try parseSelectionSet(),
            location: locateWithStart(start))
    }

    func parseTypeCondition() throws -> Name {
        try expectKeyword(.On)
        return try parseName()
    }

    func expectKeyword(keyword: Keyword) throws -> Token {
        guard currentToken.kind == .Name,
            let value = currentToken.value as? String where value == keyword.rawValue else {
            throw ParserError(code: .UnexpectedToken, source: source, position: previousEnd, description: "Expected \(keyword.rawValue), found \(currentToken)")
        }
        let token = currentToken
        try advance()
        return token
    }

    func parseName() throws -> Name {
        let start = currentToken.start
        let token = try expect(.Name)
        return Name(value: token.value as! String, location: locateWithStart(start))
    }

    func expect(kind: TokenKind) throws -> Token {
        if currentToken.kind == kind {
            let token = currentToken
            try advance()
            return token
        } else {
            throw ParserError(code: .UnexpectedToken, source: source, position: previousEnd, description: "Expected \(kind), found \(currentToken.kind)")
        }
    }

    func parseSelectionSet() throws -> SelectionSet {
        let start = currentToken.start
        return SelectionSet(
            selections: try parseOneOrMoreBetweenDelimiters(left: .BraceLeft, function: parseSelection, right: .BraceRight),
            location: locateWithStart(start))
    }

    func parseSelection() throws -> Selection {
        return nextTokenIs(.Spread) ? try parseFragment() : try parseField()
    }

    func parseFragment() throws -> Fragment {
        let start = currentToken.start
        try expect(.Spread)
        switch currentToken.value as! String {
        case Keyword.On.rawValue:
            try advance()

            return InlineFragment(
                typeCondition: try parseName(),
                directives: try parseDirectives(),
                selectionSet: try parseSelectionSet(),
                location: locateWithStart(start))
        default:
            return FragmentSpread(
                name: try parseName(),
                directives: try parseDirectives(),
                location: locateWithStart(start))
        }
    }

    func parseField() throws -> Field {
        let start = currentToken.start

        let nameOrAlias = try parseName()

        var alias: Name?
        var name: Name
        if try skip(.Colon) {
            alias = nameOrAlias
            name = try parseName()
        } else {
            alias = nil
            name = nameOrAlias
        }

        return Field(
            alias: alias,
            name: name,
            arguments: try parseArguments(),
            directives: try parseDirectives(),
            selectionSet: nextTokenIs(.BraceLeft) ? try parseSelectionSet() : nil,
            location: locateWithStart(start))
    }

    func parseArguments() throws -> [Argument] {
        return nextTokenIs(.ParenLeft)
            ? try parseOneOrMoreBetweenDelimiters(left: .ParenLeft, function: parseArgument, right: .ParenRight)
            : []
    }

    func parseArgument() throws -> Argument {
        let start = currentToken.start
        return Argument(
            name: try parseName(),
            value: try parseArgumentValue(),
            location: locateWithStart(start))
    }

    func parseArgumentValue() throws -> Value {
        try expect(.Colon)
        return try parseValue(isConst: false)
    }

    func parseDirectives() throws -> [Directive] {
        var directives: [Directive] = []
        while nextTokenIs(.At) {
            directives.append(try parseDirective())
        }
        return directives
    }

    func parseDirective() throws -> Directive {
        let start = currentToken.start
        try expect(.At)
        return Directive(
            name: try parseName(),
            value: try skip(.Colon) ? try parseValue(isConst: false) : nil,
            location: locateWithStart(start))
    }

    func parseValue(isConst isConst: Bool) throws -> Value {
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

    func parseArray(isConst isConst: Bool) throws -> Array {
        let start = currentToken.start
        let parseFunction = isConst ? parseConstValue : parseVariableValue
        return Array(
            values: try parseZeroOrMoreBetweenDelimiters(left: .BracketLeft, function: parseFunction, right: .BracketRight),
            location: locateWithStart(start))
    }

    func parseInt() throws -> IntValue {
        let token = currentToken
        try advance()
        return IntValue(value: token.value as! Int, location: locateWithStart(token.start))
    }

    func parseFloat() throws -> FloatValue {
        let token = currentToken
        try advance()
        return FloatValue(value: token.value as! Float, location: locateWithStart(token.start))
    }

    func parseString() throws -> StringValue {
        let token = currentToken
        try advance()
        return StringValue(value: token.value as! String, location: locateWithStart(token.start))
    }

    func parseVariable() throws -> Variable {
        let start = currentToken.start
        try expect(.Dollar)
        return Variable(value: try parseName(), location: locateWithStart(start))
    }

    func parseBoolOrEnum() throws -> Value {
        let start = currentToken.start
        let string = currentToken.value as! String
        try advance()
        switch string {
        case "true": return BoolValue(value: true, location: locateWithStart(start))
        case "false": return BoolValue(value: false, location: locateWithStart(start))
        default: return EnumValue(value: string, location: locateWithStart(start))
        }
    }

    func parseObject(isConst isConst: Bool) throws -> Object {
        let start = currentToken.start
        try expect(.BraceLeft)
        var fields: [ObjectField] = []
        var fieldNames: [Name] = []
        while try !skip(.BraceRight) {
            fields.append(try parseObjectField(isConst: isConst, existingFieldNames: &fieldNames))
        }
        return Object(fields: fields, location: locateWithStart(start))
    }

    func parseObjectField(isConst isConst: Bool, inout existingFieldNames: [Name]) throws -> ObjectField {
        let start = currentToken.start
        let name = try parseName()
        guard !(existingFieldNames.contains { $0.value == name.value }) else {
            throw ParserError(code: .DuplicateInputObjectField, source: source, position: previousEnd, description: "Duplicate input object field \(name.value)")
        }
        existingFieldNames.append(name)

        return ObjectField(
            name: name,
            value: try parseObjectFieldValue(isConst: isConst),
            location: locateWithStart(start))
    }

    func parseObjectFieldValue(isConst isConst: Bool) throws -> Value {
        try expect(.Colon)
        return try parseValue(isConst: isConst)
    }

    func parseConstValue() throws -> Value {
        return try parseValue(isConst: true)
    }

    func parseVariableValue() throws -> Value {
        return try parseValue(isConst: false)
    }

    func unexpectedToken() throws {
        throw ParserError(code: .UnexpectedToken, source: source, position: previousEnd, description: "Unexpected \(currentToken)")
    }

    func parseZeroOrMoreBetweenDelimiters<T>(left left: TokenKind, function: () throws -> T, right: TokenKind) throws -> [T] {
        try expect(left)
        var nodes: [T] = []
        while try !skip(right) {
            nodes.append(try function())
        }
        return nodes
    }

    func parseOneOrMoreBetweenDelimiters<T>(left left: TokenKind, function: () throws -> T, right: TokenKind) throws -> [T] {
        try expect(left)
        var nodes: [T] = [try function()]
        while try !skip(right) {
            nodes.append(try function())
        }
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