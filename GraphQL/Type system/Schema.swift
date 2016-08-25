public protocol SchemaType: Named {
}

public final class AnySchemaType: SchemaType {
    public let wrappedType: SchemaType

    public var name: ValidName {
        return wrappedType.name
    }

    init(_ type: SchemaType) {
        self.wrappedType = type
    }
}

public struct Schema {
    let queryType: AnySchemaObject
    let mutationType: AnySchemaObject?
    let subscriptionType: AnySchemaObject?
    let directives: [SchemaDirective]
    let types: IdentitySet<AnySchemaType>

    public init(
        queryType: AnySchemaObject,
        mutationType: AnySchemaObject? = nil,
        subscriptionType: AnySchemaObject? = nil,
        directives: [SchemaDirective] = [includeDirective, skipDirective]
        ) {
        self.queryType = queryType
        self.mutationType = mutationType
        self.subscriptionType = subscriptionType
        self.directives = directives

        let topLevelTypes = [queryType, mutationType, subscriptionType].flatMap { $0 } // + Introspection.schema
        self.types = Schema.collectAllTypesFrom(topLevelTypes)

        assertTypesConformToTheirInterfaces()
    }

    static func collectAllTypesFrom(types: [AnySchemaObject]) -> IdentitySet<AnySchemaType> {
        return []
    }

    func assertTypesConformToTheirInterfaces() {
//        for type in types {
//            guard let objectType = type.wrappedType as? SchemaObject else { continue }
//            for interface in objectType.interfaces {
//                objectType.assertConformanceToInterface(interface)
//            }
//        }
    }
}
