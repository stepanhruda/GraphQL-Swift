
struct GraphQLSchema {

}

enum GraphQLFormattedErrorCode: Int {
    case Unknown
}

struct GraphQLFormattedError: ErrorType {
    var _domain: String { get { return "technology.stepan.GraphQL-Swift" } }
    var _code: Int { get { return code.rawValue } }

    let code: GraphQLFormattedErrorCode
}

struct GraphQLResult {
    let data: Any?
    let errors: [GraphQLFormattedError]?
}

enum GraphQLComposedErrorCode: Int {
    case MultipleErrors
}

struct GraphQLComposedError: ErrorType {
    var _domain: String { get { return "technology.stepan.GraphQL-Swift" } }
    var _code: Int { get { return code.rawValue } }

    let code: GraphQLComposedErrorCode
    let errors: [ErrorType]
}


func graphql(schema: GraphQLSchema, requestString: String, rootObject: Any?, variableValues: Any, operationName: String?, completion: GraphQLResult -> Void) throws {
    do {
        let source = Source(body: requestString, name: "GraphQL request")
        let document = try parse(source)
        try validateDocument(document, schema: schema)
        execute(schema: schema, rootObject: rootObject, document: document, operationName: operationName, variableValues: variableValues)
    } catch let error {
        // TODO: Error processing
        throw error
    }

}


