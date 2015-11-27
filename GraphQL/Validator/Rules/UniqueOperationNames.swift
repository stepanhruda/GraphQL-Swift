enum UniqueOperationNamesError: ErrorType {
    case DuplicateOperationNames(Name)
}

final class UniqueOperationNames: Rule {
    let context: ValidationContext
    required init(context: ValidationContext) {
        self.context = context
    }

    var knownOperationNames: Set<Name> = Set<Name>()

    func visitor() -> Visitor {
        return Visitor(
            nodeType: .OperationDefinition,
            enter: { definition in
                guard let operation = definition as? OperationDefinition else { return .Continue }
                guard let name = operation.name else { return .Continue }

                if self.knownOperationNames.contains(name) {
                    // TODO: Strongly typed error
                    throw UniqueOperationNamesError.DuplicateOperationNames(name)
                }
                self.knownOperationNames.insert(name)

                return .Continue
            }
        )
    }
}

