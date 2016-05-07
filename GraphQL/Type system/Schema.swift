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
    let queryType: SchemaObject
    let mutationType: SchemaObject?
    let subscriptionType: SchemaObject?
    let directives: [SchemaDirective]
    let types: IdentitySet<AnySchemaType>

    public init(
        queryType: SchemaObject,
        mutationType: SchemaObject? = nil,
        subscriptionType: SchemaObject? = nil,
        directives: [SchemaDirective] = [includeDirective, skipDirective]
        ) {
            self.queryType = queryType
            self.mutationType = mutationType
            self.subscriptionType = subscriptionType
            self.directives = directives

            let optionalArray: [SchemaObject?] = [queryType, mutationType, subscriptionType]//, Introspection.schema]
            let topLevelTypes = IdentitySet(values: optionalArray.flatMap { $0 }.map { AnySchemaType($0) })
            self.types = Schema.collectAllTypesFrom(topLevelTypes)

            assertTypesConformToTheirInterfaces()
    }

    static func collectAllTypesFrom(types: IdentitySet<AnySchemaType>) -> IdentitySet<AnySchemaType> {
        return []
    }

    func assertTypesConformToTheirInterfaces() {
        for type in types {
            guard let objectType = type.wrappedType as? SchemaObject else { continue }
            for interface in objectType.interfaces {
                objectType.assertConformanceToInterface(interface)
            }
        }
    }
}
