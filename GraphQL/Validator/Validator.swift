extension Document {
    func validateForSchema(schema: GraphQLSchema, ruleInitializers: [ValidationContext -> Rule] = allRules) throws {
        var typeInfo = TypeInfo(schema: schema)
        let context = ValidationContext(schema: schema, document: self, typeInfo: typeInfo)

        var errors: [ErrorType] = []

        var recursiveVisitUsingRule: (Node, Rule) -> Void = { node, rule in }

        let visitUsingRule: (Node, Rule) -> Void = { node, rule in

            guard let visitable = rule as? Visiting else { return }
            let visitor = visitable.visitor()

            visit(node, .OnEnterAndLeave(.Any,

                { node in
                    var resultAction = VisitAction.Continue

                    typeInfo.enter(node)

                    guard node.type != .FragmentDefinition || !rule.visitSpreadFragments else { return .SkipSubtree }

                    do {
                        switch visitor {
                        case .OnEnter(let type, let onEnter):
                            if node.type == type { resultAction = try onEnter(node) }

                            break
                        case .OnEnterAndLeave(let type, let onEnter, _):
                            if node.type == type { resultAction = try onEnter(node) }

                            break
                        }
                    } catch let error {
                        errors.append(error)
                        resultAction = .SkipSubtree
                    }

                    if let spread = node as? FragmentSpread,
                        case .Continue = resultAction
                        where rule.visitSpreadFragments {
                            let fragment = context.getFragment(spread.name)
                            recursiveVisitUsingRule(fragment, rule)
                    }

                    if case .SkipSubtree = resultAction {
                        typeInfo.leave(node)
                    }

                    return resultAction
                },

                { node in
                    var resultAction = VisitAction.Continue

                    do {
                        switch visitor {
                        case .OnEnter(_, _): break
                        case .OnEnterAndLeave(let type, _, let onLeave):
                            if node.type == type { resultAction = try onLeave(node) }

                            break
                        }
                    } catch let error {
                        errors.append(error)
                        resultAction = .SkipSubtree
                    }

                    typeInfo.leave(node)

                    return resultAction
            })
            )

        }
        recursiveVisitUsingRule = visitUsingRule

        for ruleInitializer in ruleInitializers {
            let rule = ruleInitializer(context)
            visitUsingRule(self, rule)
        }
        
        if !errors.isEmpty {
            throw GraphQLComposedError.MultipleErrors(errors)
        }
    }
}


struct ValidationContext {
    let schema: GraphQLSchema
    let document: Document
    let typeInfo: TypeInfo
    
    func getFragment(value: Name) -> FragmentDefinition {
        return undefined()
    }
}