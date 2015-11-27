struct GraphQLOutputType {

}

struct GraphQLCompositeType {

}

struct GraphQLInputType {

}

struct GraphQLFieldDefinition {

}

/// TypeInfo is a utility class which, given a GraphQL schema, can keep track
/// of the current field and type definitions at any point in a GraphQL document
/// AST during a recursive descent by calling `enter` and `leave`.
struct TypeInfo {
    let schema: Schema
    private var typeStack: [GraphQLOutputType] = []
    private var parentTypeStack: [GraphQLCompositeType] = []
    private var inputTypeStack: [GraphQLInputType] = []
    private var fieldDefinitionStack: [GraphQLFieldDefinition] = []

    init(schema: Schema) {
        self.schema = schema
    }

    mutating func enter(node: Node) {

    }

    mutating func leave(node: Node) {

    }
}
