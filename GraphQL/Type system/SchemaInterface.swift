/// Note that interface is a reference type, because fields can be self-referential etc.
public class SchemaInterface: SchemaNameable {

    var possibleTypes: [SchemaObjectType] {
        return undefined()
    }

    public let name: SchemaValidName
    let description: String?
    lazy var fields: IdentitySet<SchemaObjectField> = self.lazyFields()

    let resolveType: Any -> SchemaObjectType
    private let lazyFields: () -> IdentitySet<SchemaObjectField>

    public init(
        name: SchemaValidName,
        description: String? = nil,
        fields: () -> IdentitySet<SchemaObjectField>,
        resolveType: Any -> SchemaObjectType) {
            self.name = name
            self.description = description
            self.lazyFields = fields
            self.resolveType = resolveType
    }
}

extension SchemaObjectType {
    func assertConformanceToInterface(interface: SchemaInterface) {
        for interfaceField in interface.fields {
            guard let objectField = fields.latest(interfaceField) else {
                fatalError("\(interface.name) expects field \(interfaceField.name) but \(name) does not provide it.")
            }

            guard interfaceField.type.isSubtypeOf(objectField.type) else {
                fatalError("\(interface.name).\(interfaceField.name) expects type \(interfaceField.type) but \(name).\(objectField.name) provides type \(objectField.type)")
            }

        }
    }
}

extension SchemaObjectFieldType {
    func isSubtypeOf(hopefullySupertype: SchemaObjectFieldType) -> Bool {
        switch (self, hopefullySupertype) {
        case (.Scalar(let a), .Scalar(let b)): return a == b
        case (.Object(let a), .Object(let b)):
            if a === b { return true }
            // TODO:
            return false
        case (.Interface(let a), .Interface(let b)):
            if a === b { return true }
            // TODO:
            return false
        case (.Union(let a), .Union(let b)): return a === b
        case (.Enum(let a), .Enum(let b)): return a === b
        case (.List(let a), .List(let b)): return a.isSubtypeOf(b)
        case (.NonNull(let a), .NonNull(let b)): return a.isSubtypeOf(b)
        default: return false
        }
    }
}
