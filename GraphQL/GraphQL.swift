
struct GraphQLSchema {

}

enum GraphQLFormattedErrorCode: Int {
    case Unknown
}

struct GraphQLFormattedError: ErrorType {
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
    let code: GraphQLComposedErrorCode
    let errors: [ErrorType]
}


func graphql(schema: GraphQLSchema, requestString: String = "", rootValue: Any?, variableValues: [String: Any]?, operationName: String?, completion: (GraphQLResult -> Void)?) throws {
    do {
        let source = Source(body: requestString, name: "GraphQL request")
        let document = try Parser.parse(source)
        try validateDocument(document, schema: schema)
        execute(schema: schema, rootValue: rootValue, document: document, operationName: operationName, variableValues: variableValues)
    } catch let error {
        // TODO: Error processing
        throw error
    }

}


