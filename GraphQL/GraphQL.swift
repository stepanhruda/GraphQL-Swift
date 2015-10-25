
struct GraphQLSchema {

}

enum GraphQLFormattedError: ErrorType {
    case Unknown
}

struct GraphQLResult {
    let data: Any?
    let errors: [GraphQLFormattedError]?
}

enum GraphQLComposedError: ErrorType {
    case MultipleErrors([ErrorType])
}


func graphql(schema: GraphQLSchema, requestString: String = "", rootValue: Any?, variableValues: [String: Any]?, operationName: String?, completion: (GraphQLResult -> Void)?) throws {
    do {
        let source = Source(body: requestString, name: "GraphQL request")
        let document = try Parser.parse(source)
        try document.validateForSchema(schema)
        execute(schema: schema, rootValue: rootValue, document: document, operationName: operationName, variableValues: variableValues)
    } catch let error {
        // TODO: Error processing
        throw error
    }

}


