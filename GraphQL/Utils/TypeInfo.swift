struct GraphQLOutputType {

}

struct GraphQLCompositeType {

}

struct GraphQLInputType {

}

struct GraphQLFieldDefinition {

}

struct TypeInfo {
    let schema: GraphQLSchema
    private var typeStack: [GraphQLOutputType] = []
    private var parentTypeStack: [GraphQLCompositeType] = []
    private var inputTypeStack: [GraphQLInputType] = []
    private var fieldDefinitionStack: [GraphQLFieldDefinition] = []

    init(schema: GraphQLSchema) {
        self.schema = schema
    }
}
