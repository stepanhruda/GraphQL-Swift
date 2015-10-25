class UniqueOperationNames: Rule, Visiting {

    var knownOperationNames: Set<Name> = Set<Name>()

    func visitor() -> Visitor {
        return .OnEnter (
            .OperationDefinition,
            { definition in
                guard let operation = definition as? OperationDefinition else { return .Continue }
                guard let name = operation.name else { return .Continue }

                if self.knownOperationNames.contains(name) {
                    throw GraphQLFormattedError.Unknown
                }
                self.knownOperationNames.insert(name)

                return .Continue
            }
        )
    }
}

