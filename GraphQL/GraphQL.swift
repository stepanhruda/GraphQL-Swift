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


func graphql(schema: Schema, requestString: String = "", rootValue: Any?, variableValues: [String: Any]?, operationName: String?, completion: (GraphQLResult -> Void)?) throws {
    do {
        let source = Source(body: requestString, name: "GraphQL request")
        let request = try Parser.parse(source)
        try request.validateForSchema(schema)
        execute(schema: schema, rootValue: rootValue, request: request, operationName: operationName, variableValues: variableValues)
    } catch let error {
        // TODO: Error processing
        throw error
    }

}


