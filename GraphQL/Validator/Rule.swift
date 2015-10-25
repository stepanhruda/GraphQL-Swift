let allRules: [ValidationContext -> Rule] = [
    UniqueOperationNames.init,
]

class Rule {
    let context: ValidationContext
    var visitSpreadFragments: Bool { return false }

    required init(context: ValidationContext) {
        self.context = context
    }
}

protocol Visiting {
    func visitor() -> Visitor
}