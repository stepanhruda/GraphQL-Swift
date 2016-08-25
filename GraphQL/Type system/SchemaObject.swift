public final class SchemaObject<UnderlyingType>: SchemaType, AllowedAsObjectField, AllowedAsNonNull {
    public let name: ValidName
    public let description: String?

    public lazy var fields: IdentitySet<SchemaObjectField<UnderlyingType, Any>> = self.lazyFields()
    public let interfaces: [AnySchemaInterface]

    private let lazyFields: () -> IdentitySet<SchemaObjectField<UnderlyingType, Any>>

    public init(
        name: ValidName,
        description: String? = nil,
        fields: () -> IdentitySet<SchemaObjectField<UnderlyingType, Any>>,
        interfaces: [AnySchemaInterface] = []) {
            self.name = name
            self.description = description
            self.lazyFields = fields
            self.interfaces = interfaces
    }
}

public protocol AnySchemaObject {
    var allFields: [AnySchemaObjectField] { get }
}

extension SchemaObject: AnySchemaObject {
    public var allFields: [AnySchemaObjectField] {
        return fields.map { $0 as AnySchemaObjectField }
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

public protocol GraphQLType {
    static func graphqlType() -> AllowedAsObjectField
}
public extension GraphQLType {
    static func graphqlType() -> AllowedAsObjectField {
        return StringType()
    }
}
//public protocol CustomGraphQLType {}
//
public protocol DefaultGraphQLType {}
extension String: DefaultGraphQLType {
    static func graphqlType() -> AllowedAsObjectField {
        return StringType()
    }
}
//extension Optional: DefaultGraphQLType {}
//extension Array: DefaultGraphQLType {}

public struct SchemaObjectField<Parent, Arguments>: Named {
    public let name: ValidName
    let description: String?
//    let arguments: IdentitySet<SchemaInputValue<Any>>
    // Return type is any so we can keep field in a homogenous collection.
    let resolve: (Parent, Arguments) -> Any
    let deprecationReason: String?
    let type: AllowedAsObjectField

    public init<FieldValue>(
        name: ValidName,
        swiftType: FieldValue.Type,
        description: String? = nil,
        arguments: IdentitySet<SchemaInputValue<Any>> = [],
        resolve: (Parent, Arguments) -> FieldValue,
        deprecationReason: String? = nil) {
        self.name = name
        self.description = description
//        self.arguments = arguments
        self.resolve = resolve
        self.deprecationReason = deprecationReason

        guard let conformingSwiftType = swiftType as? GraphQLType.Type else { fatalError("Invalid field type for \(name)") }
        self.type = conformingSwiftType.graphqlType()
    }
}

public protocol AnySchemaObjectField: AllowedAsObjectField {

}

extension SchemaObjectField: AnySchemaObjectField {

}
