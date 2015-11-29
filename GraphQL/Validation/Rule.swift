let allRules: [ValidationContext -> Rule] = [
    UniqueOperationNames.init,
]

protocol Rule {
    var context: ValidationContext { get }
    init(context: ValidationContext)

    /// An identity set of visitors to be used when a node is entered.
    /// Only a single visitor closure is executed per node, specific visitors are preferred over .Any visitors.
    func visitors() -> IdentitySet<Visitor>
}
