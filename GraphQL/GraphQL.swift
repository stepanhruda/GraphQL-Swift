
struct GraphQLSchema {

}

enum GraphQLFormattedErrorType: Int {
    case Unknown
}

struct GraphQLFormattedError: ErrorType {
    var _domain: String { get { return "technology.stepan.GraphQL-Swift" } }
    var _code: Int { get { return code.rawValue } }

    let code: GraphQLFormattedErrorType
}

struct GraphQLResult {
    let data: Any?
    let errors: [GraphQLFormattedError]?
}


func graphql(schema: GraphQLSchema, requestString: String, rootObject: Any?, variableValues: Any, operationName: String?, completion: GraphQLResult -> Void) throws {
    let source = Source(body: requestString, name: "GraphQL request")
    do {
        let _ = try parse(source)
    } catch let error {
        throw error
    }
}


