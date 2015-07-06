

func validateDocument(document: Document, schema: GraphQLSchema, rules: [Rule] = AllRules) throws {
    let typeInfo = TypeInfo(schema: schema)
    let context = ValidationContext(schema: schema, document: document, typeInfo: typeInfo)

    var errors: [ErrorType] = []

    for rule in rules {
        do {
            try visitRule(rule, context: context, document: document)
        } catch let error {
            errors.append(error)
        }
    }

    if !errors.isEmpty {
        throw GraphQLComposedError(code: .MultipleErrors, errors: errors)
    }
}

func visitRule(rule: Rule, context: ValidationContext, document: Document) throws {

}


struct ValidationContext {
    let schema: GraphQLSchema
    let document: Document
    let typeInfo: TypeInfo
}