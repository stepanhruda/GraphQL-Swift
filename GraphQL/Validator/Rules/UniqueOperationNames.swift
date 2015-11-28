final class UniqueOperationNames: Rule {
    let context: ValidationContext
    required init(context: ValidationContext) {
        self.context = context
    }

    var knownOperationNames: IdentitySet<Name> = []

    func visitor() -> Visitor {
        return Visitor(
            nodeType: .OperationDefinition,
            enter: { definition in
                guard let operation = definition as? OperationDefinition else { return .Continue }
                guard let name = operation.name else { return .Continue }

                guard self.knownOperationNames.elementMatching(name) == nil else {

                    throw DocumentValidationError.DuplicateOperationNames(self.knownOperationNames.elementMatching(name)!, name)
                }

                self.knownOperationNames.add(name)

                return .Continue
            }
        )
    }
}

