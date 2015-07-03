func parse(source: Source, options: ParseOptions? = nil) throws -> Document {
    let lexer = lex(source)
    do {
        let parser = Parser(lexer: lexer, source: source, options: options, previousEnd: source.body.startIndex, lexToken: try lexer(source.body.startIndex))
        return try parser.parseDocument()
    } catch let error {
        throw error
    }
}

struct ParseOptions {

}

struct Parser {
    let lexer: String.Index? throws -> Token
    let source: Source
    let options: ParseOptions?
    var previousEnd: String.Index
    var lexToken: Token

    func parseDocument() throws -> Document {

        return undefined()
    }
}

extension Parser {


}