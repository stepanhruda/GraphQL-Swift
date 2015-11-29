/// We want `SchemaType` to be a protocol, but `IdentitySet<SchemaType>` isn't currently supported by Swift compiler.
/// Hence this workaround.
public enum SchemaType: Named {
    public var name: ValidName {
        return undefined()
    }
}

public struct Schema {
    let queryType: SchemaObjectType
    let mutationType: SchemaObjectType?
    let subscriptionType: SchemaObjectType?
    let directives: [SchemaDirective]
    let types: IdentitySet<SchemaType>

    public init(
        queryType: SchemaObjectType,
        mutationType: SchemaObjectType? = nil,
        subscriptionType: SchemaObjectType? = nil,
        directives: [SchemaDirective] = [includeDirective, skipDirective]
        ) {
            self.queryType = queryType
            self.mutationType = mutationType
            self.subscriptionType = subscriptionType
            self.directives = directives

//            let optionalArray: [SchemaObjectType?] = [queryType, mutationType, subscriptionType, Introspection.schema]
//            let topLevelTypes = IdentitySet(values: optionalArray.flatMap { $0 }.map { SchemaType.ObjectType($0) })
            self.types = Schema.collectAllTypesFrom([])

            assertTypesConformToTheirInterfaces()
    }

    static func collectAllTypesFrom(types: IdentitySet<SchemaType>) -> IdentitySet<SchemaType> {
        return []
    }

    func assertTypesConformToTheirInterfaces() {
//        for type in types {
//            switch type {
//            case .ObjectType(let objectType):
//                for interface in objectType.interfaces {
//                    objectType.assertConformanceToInterface(interface)
//                }
//            default: continue
//            }
//        }
    }
}
