final class UniqueOperationNames: Rule {
    let context: ValidationContext
    required init(context: ValidationContext) {
        self.context = context
    }

    var knownOperationNames: IdentitySet<Name> = []

    func visitors() -> IdentitySet<Visitor> {
        return [Visitor(
            nodeType: .OperationDefinition,
            enter: { operation in
                // TODO: How can this be strongly typed?
                guard let operation = operation as? OperationDefinition else { return .Continue }
                guard let name = operation.name else { return .Continue }

                guard self.knownOperationNames.elementMatching(name) == nil else {
                    throw DocumentValidationError.DuplicateOperationNames(name: name.value)
                }

                self.knownOperationNames.add(name)

                return .Continue
            })]
    }
}

