final class VariablesAreInputTypes: Rule {
    let context: ValidationContext
    required init(context: ValidationContext) {
        self.context = context
    }

    func visitors() -> IdentitySet<Visitor> {
        return [Visitor(nodeType: .VariableDefinition, enter: { variableDefinition in
            let _ = variableDefinition as! VariableDefinition

            // TODO: throw DocumentValidationError.VariableIsNonInputType

            return .Continue
        })]
    }
}