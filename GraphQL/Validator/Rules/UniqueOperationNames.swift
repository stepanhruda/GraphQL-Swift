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
                let operation = operation as! OperationDefinition
                guard let name = operation.name else { return .Continue }

                guard self.knownOperationNames.elementMatching(name) == nil else {
                    throw DocumentValidationError.DuplicateOperationNames(name: name.value)
                }

                self.knownOperationNames.add(name)

                return .Continue
            })]
    }
}

