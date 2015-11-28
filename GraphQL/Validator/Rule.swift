let allRules: [ValidationContext -> Rule] = [
    UniqueOperationNames.init,
]

protocol Rule {
    var context: ValidationContext { get }
    init(context: ValidationContext)

    func visitor() -> Visitor
}
