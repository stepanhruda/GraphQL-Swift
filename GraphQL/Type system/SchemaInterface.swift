public final class SchemaInterface: SchemaType {

    var possibleTypes: IdentitySet<SchemaObject> {
        return undefined()
    }

    public let name: ValidName
    let description: String?
    lazy var fields: IdentitySet<SchemaObjectField> = self.lazyFields()

    let resolveType: Any -> SchemaObject
    private let lazyFields: () -> IdentitySet<SchemaObjectField>

    public init(
        name: ValidName,
        description: String? = nil,
        fields: () -> IdentitySet<SchemaObjectField>,
        resolveType: Any -> SchemaObject) {
            self.name = name
            self.description = description
            self.lazyFields = fields
            self.resolveType = resolveType
    }
}

extension SchemaInterface: AllowedAsObjectField {

}

extension SchemaObject {
    // TODO: This method needs to throw rather than abort so it can be tested
    func assertConformanceToInterface(interface: SchemaInterface) {
        for interfaceField in interface.fields {
            guard let objectField = fields.memberMatching(interfaceField) else {
                fatalError("\(interface.name) expects field \(interfaceField.name) but \(name) does not provide it.")
            }

            guard interfaceField.type.isSubtypeOf(objectField.type) else {
                fatalError("\(interface.name).\(interfaceField.name) expects type \(interfaceField.type) but \(name).\(objectField.name) provides type \(objectField.type)")
            }

            for interfaceArgument in interfaceField.arguments {

                guard let objectArgument = objectField.arguments.memberMatching(interfaceArgument) else {
                    fatalError("\(interface.name).\(interfaceField.name) expects argument \(interfaceArgument.name) but \(name).\(objectField.name) does not provide it.")
                }

                guard interfaceArgument.type.isEqualToType(objectArgument.type) else { fatalError("\(interface.name).\(interfaceField.name).(\(interfaceArgument.name):) expects type \(interfaceArgument.type) but \(name).\(objectField.name)(\(objectArgument.name):) provides type \(objectArgument.type)") }
            }

            for objectArgument in objectField.arguments
                where !interfaceField.arguments.contains(objectArgument)
                    && objectArgument.type is NonNull {
                fatalError("\(name).\(objectField.name)(\(objectArgument.name):) is of required type \(objectArgument.type) but is also not provided by the interface \(interface.name).\(interfaceField.name)")
            }
        }
    }
}

//extension SchemaObjectFieldType {
//    func isEqualToType(hopefullyEqualType: SchemaObjectFieldType) -> Bool {
//        switch (self, hopefullyEqualType) {
//        case (.Scalar(let a), .Scalar(let b)): return a == b
//        case (.Object(let a), .Object(let b)): return a === b
//        case (.Interface(let a), .Interface(let b)): return a === b
//        case (.Union (let a), .Union(let b)): return a === b
//        case (.Enum(let a), .Enum(let b)): return a === b
//        case (.List(let a), .List(let b)): return a.isEqualToType(b)
//        case (.NonNull(let a), .NonNull(let b)): return a.isEqualToType(b)
//        default: return false
//        }
//    }
//
//    func isSubtypeOf(hopefullySupertype: SchemaObjectFieldType) -> Bool {
//        if self.isEqualToType(hopefullySupertype) { return true }
//
//        switch (self, hopefullySupertype) {
//        case (.NonNull(let a), .NonNull(let b)): return a.isSubtypeOf(b)
//        case (.List(let a), .List(let b)): return a.isSubtypeOf(b)
//        case (.Object(let implementation), .Interface(let interface)): return interface.possibleTypes.contains(implementation)
//        case (.Object(let implementation), .Union(let union)): return union.possibleTypes.contains(implementation)
//        default: return false
//        }
//    }
//}