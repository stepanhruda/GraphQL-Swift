final class UniqueArgumentNames: Rule {
    let context: ValidationContext
    required init(context: ValidationContext) {
        self.context = context
    }

    var knownArgumentNames: IdentitySet<Name> = []

    func visitors() -> IdentitySet<Visitor> {
        return [
            Visitor(nodeType: .Field,
                enter: { field in
                    self.knownArgumentNames = []
                    return .Continue
            }),
            Visitor(nodeType: .Directive,
                enter: { directive in
                    self.knownArgumentNames = []
                    return .Continue
                }),
            Visitor(nodeType: .Argument,
                enter: { argument in
                    let argument = argument as! Argument
                    guard self.knownArgumentNames.elementMatching(argument.name) == nil else {
                        throw DocumentValidationError.DuplicateArgumentNames(name: argument.name.value)
                    }

                    self.knownArgumentNames.add(argument.name)

                    return .Continue
                }),
        ]
    }
}


