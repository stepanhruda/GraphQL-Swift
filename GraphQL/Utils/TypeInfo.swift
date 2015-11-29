struct GraphQLOutputType {

}

struct GraphQLCompositeType {

}

struct GraphQLInputType {

}

struct SchemaObjectFieldDefinition {

}

/// TypeInfo is a utility class which, given a GraphQL schema, can keep track
/// of the current field and type definitions at any point in a GraphQL document
/// AST during a recursive descent by calling `enter` and `leave`.
final class TypeInfo {
    let schema: Schema
    private var typeStack: [GraphQLOutputType] = []
    private var parentTypeStack: [GraphQLCompositeType] = []
    private var inputTypeStack: [GraphQLInputType] = []
    private var fieldDefinitionStack: [SchemaObjectFieldDefinition] = []

    init(schema: Schema) {
        self.schema = schema
    }

    func enter(node: Node) {

    }

    func leave(node: Node) {

    }
}
