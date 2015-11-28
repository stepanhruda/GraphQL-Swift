public struct Schema {
    let queryType: SchemaObjectType
    let mutationType: SchemaObjectType?
    let subscriptionType: SchemaObjectType?
    let directives: [SchemaDirective]
    let types: IdentitySet<SchemaTopLevelType>

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
            self.types = undefined() // TODO

            assertInterfaceConformances()
    }

    func assertInterfaceConformances() {
        for type in types {
            switch type {
            case .Object(let object):
                for interface in object.interfaces {
                    object.assertConformanceToInterface(interface)
                }
            default: continue
            }
        }
    }
}

public indirect enum SchemaTopLevelType: SchemaNameable {
    case Object(SchemaObjectType)
    case Interface(SchemaInterface)
    case Union(SchemaUnion)
    case Enum(SchemaEnum)

    public var name: SchemaValidName {
        switch self {
        case .Object(let object): return object.name
        case .Interface(let interface): return interface.name
        case .Union(let union): return union.name
        case .Enum(let enumeration): return enumeration.name
        }
    }
}
