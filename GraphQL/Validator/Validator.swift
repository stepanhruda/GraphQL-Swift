struct ValidationContext {
    let schema: GraphQLSchema
    let document: Document
    let typeInfo: TypeInfo
}

extension Document {
    func validateForSchema(schema: GraphQLSchema, ruleInitializers: [ValidationContext -> Rule] = allRules) throws {
        let typeInfo = TypeInfo(schema: schema)
        let context = ValidationContext(schema: schema, document: self, typeInfo: typeInfo)
        let rules = ruleInitializers.map { $0(context) }
        var errors: [ErrorType] = []

        for rule in rules {
            do {
                try visitUsingRule(rule, typeInfo: typeInfo)
            } catch let error {
                errors.append(error)
            }
        }

        switch errors.count {
        case 1: throw errors.first!
        case _ where errors.count > 1: throw GraphQLComposedError.MultipleErrors(errors)
        default: break
        }

    }

    func visitUsingRule(rule: Rule, var typeInfo: TypeInfo) throws {

        try visit(Visitor(nodeType: .Any,

            enter: { node in
                typeInfo.enter(node)

                let visitor = rule.visitor()
                guard let enter = visitor.enter where visitor.nodeType == .Any || visitor.nodeType == node.type else { return .Continue }

                let action = try enter(node)

                if case .SkipSubtree = action {
                    typeInfo.leave(node)
                }

                return action },

            leave: { node in

                let visitor = rule.visitor()
                guard let leave = visitor.leave where visitor.nodeType == .Any || visitor.nodeType == node.type else { return .Continue }

                let action = try leave(node)
                
                typeInfo.leave(node)
                
                return action }))
    }
}
