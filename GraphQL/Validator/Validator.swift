struct ValidationContext {
    let schema: Schema
    let document: Document
    let typeInfo: TypeInfo
}

// TODO: Location reporting
public enum DocumentValidationError: ErrorType {
    case DuplicateOperationNames(name: String)
    case DuplicateArgumentNames(name: String)
    case VariableIsNonInputType
}

extension Document {
    func validateForSchema(schema: Schema, ruleInitializers: [ValidationContext -> Rule] = allRules) throws {
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

    func visitUsingRule(rule: Rule, typeInfo: TypeInfo) throws {

        try visit(Visitor(nodeType: .Any,

            enter: { node in
                print("Entering \(node.type.rawValue)")
                typeInfo.enter(node)

                guard let visitor = rule.findVisitorForNode(node),
                    let enter = visitor.enter else { return .Continue }

                let action = try enter(node)

                if case .SkipSubtree = action {
                    typeInfo.leave(node)
                }

                return action },

            leave: { node in
                print("Leaving \(node.type.rawValue)")

                guard let visitor = rule.findVisitorForNode(node),
                    let leave = visitor.leave else { return .Continue }

                let action = try leave(node)
                
                typeInfo.leave(node)
                
                return action }))
    }
}

extension Rule {

    private func findVisitorForNode(node: Node) -> Visitor? {
        let cachedVisitors = visitors()
        let specificVisitor = cachedVisitors.memberForIdentifier(node.type.identifier)
        let anyVisitor = cachedVisitors.memberForIdentifier(NodeType.Any.identifier)
        return specificVisitor ?? anyVisitor
    }
}
