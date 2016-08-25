public final class SchemaInterface<UnderlyingInterface>: SchemaType, AllowedAsObjectField {

    public var possibleTypes: [AnySchemaObject] {
        return undefined()
    }

    public let name: ValidName
    public let description: String?
    public lazy var fields: IdentitySet<SchemaObjectField<UnderlyingInterface, Any>> = self.lazyFields()

    let resolveType: (UnderlyingInterface) -> AnySchemaObject
    private let lazyFields: () -> IdentitySet<SchemaObjectField<UnderlyingInterface, Any>>

    public init(
        name: ValidName,
        description: String? = nil,
        fields: () -> IdentitySet<SchemaObjectField<UnderlyingInterface, Any>>,
        resolveType: (UnderlyingInterface) -> AnySchemaObject) {
            self.name = name
            self.description = description
            self.lazyFields = fields
            self.resolveType = resolveType
    }
}

public protocol AnySchemaInterface {
    var allFields: [AnySchemaObjectField] { get }
    var possibleTypes: [AnySchemaObject] { get }
}

extension SchemaInterface: AnySchemaInterface {
    public var allFields: [AnySchemaObjectField] {
        return fields.map { $0 as AnySchemaObjectField }
    }
}

extension SchemaObject {
    // TODO: This method needs to throw rather than abort so it can be tested
    func assertConformanceToInterface(interface: AnySchemaInterface) {
//        for interfaceField in interface.fields {
//            guard let objectField = fields.memberMatching(interfaceField) else {
//                fatalError("\(interface.name) expects field \(interfaceField.name) but \(name) does not provide it.")
//            }
//
//            guard interfaceField.type.isSubtypeOf(objectField.type) else {
//                fatalError("\(interface.name).\(interfaceField.name) expects type \(interfaceField.type) but \(name).\(objectField.name) provides type \(objectField.type)")
//            }
//
//            for interfaceArgument in interfaceField.arguments {
//
//                guard let objectArgument = objectField.arguments.memberMatching(interfaceArgument) else {
//                    fatalError("\(interface.name).\(interfaceField.name) expects argument \(interfaceArgument.name) but \(name).\(objectField.name) does not provide it.")
//                }
//
//                guard interfaceArgument.type.isEqualToType(objectArgument.type) else { fatalError("\(interface.name).\(interfaceField.name).(\(interfaceArgument.name):) expects type \(interfaceArgument.type) but \(name).\(objectField.name)(\(objectArgument.name):) provides type \(objectArgument.type)") }
//            }
//
//            for objectArgument in objectField.arguments
//                where !interfaceField.arguments.contains(objectArgument)
//                    && objectArgument.type is NonNull {
//                fatalError("\(name).\(objectField.name)(\(objectArgument.name):) is of required type \(objectArgument.type) but is also not provided by the interface \(interface.name).\(interfaceField.name)")
//            }
//        }
    }
}

//extension SchemaObjectFieldType {
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