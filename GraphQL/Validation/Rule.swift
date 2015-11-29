let allRules: [ValidationContext -> Rule] = [
    UniqueOperationNames.init,
    LoneAnonymousOperation.init,
    KnownTypeNames.init,
    FragmentsOnCompositeType.init,
    VariablesAreInputTypes.init,
    ScalarLeafs.init,
    FieldsOnCorrectType.init,
    UniqueFragmentNames.init,
    KnownFragmentNames.init,
    NoUnusedFragments.init,
    PossibleFragmentSpreads.init,
    NoFragmentCycles.init,
    NoUndefinedVariables.init,
    NoUnusedVariables.init,
    KnownDirectives.init,
    KnownArgumentNames.init,
    UniqueArgumentNames.init,
    ArgumentsOfCorrectType.init,
    ProvidedNonNullArguments.init,
    DefaultValuesOfCorrectType.init,
    VariablesInAllowedPosition.init,
    OverlappingFieldsCanBeMerged.init,
    UniqueInputFieldNames.init,
]

protocol Rule {
    var context: ValidationContext { get }
    init(context: ValidationContext)

    /// An identity set of visitors to be used when a node is entered.
    /// Only a single visitor closure is executed per node, specific visitors are preferred over .Any visitors.
    func visitors() -> IdentitySet<Visitor>
}
