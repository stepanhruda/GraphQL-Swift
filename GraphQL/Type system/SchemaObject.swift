public final class SchemaObject: SchemaType, AllowedAsObjectField, AllowedAsNonNull {
    public let name: ValidName
    let description: String?

    lazy var fields: IdentitySet<SchemaObjectField> = self.lazyFields()
    let interfaces: [SchemaInterface]

    private let lazyFields: () -> IdentitySet<SchemaObjectField>

    public init(
        name: ValidName,
        description: String? = nil,
        fields: () -> IdentitySet<SchemaObjectField>,
        interfaces: [SchemaInterface] = []) {
            self.name = name
            self.description = description
            self.lazyFields = fields
            self.interfaces = interfaces
    }
}

public protocol AllowedAsObjectField {
    func isEqualToType(otherType: AllowedAsObjectField) -> Bool
    func isSubtypeOf(hopefullySupertype: AllowedAsObjectField) -> Bool
}

extension AllowedAsObjectField {
    public func isEqualToType(otherType: AllowedAsObjectField) -> Bool { return false }
    public func isSubtypeOf(hopefullySupertype: AllowedAsObjectField) -> Bool { return false }
}

public struct SchemaObjectField: Named {
    public let name: ValidName
    let type: AllowedAsObjectField
    let description: String?
    let arguments: IdentitySet<SchemaInputValue>
    let resolve: (Any -> Any?)?
    let deprecationReason: String?

    public init(
        name: ValidName,
        type: AllowedAsObjectField,
        description: String? = nil,
        arguments: IdentitySet<SchemaInputValue> = [],
        resolve: (Any -> Any?)? = nil,
        deprecationReason: String? = nil) {
            self.name = name
            self.type = type
            self.description = description
            self.arguments = arguments
            self.resolve = resolve
            self.deprecationReason = deprecationReason
    }
}
