struct Location {
    let start: String.Index
    let end: String.Index
    let source: Source?
}

struct Document {
    let definitions: [Definition]
    let location: Location?
}

protocol Definition {

}


struct OperationDefinition: Definition {
    
}

struct Directive {
    let name: Name
    let value: Value?
    let location: Location?
}

struct FragmentDefinition: Definition {
    let name: Name
    let typeCondition: (Token, Name)
    let directives: [Directive]
    let selectionSet: Any
    let location: Location?
}

struct Name {
    let value: String
    let location: Location?
}

protocol Value {
    
}

struct SelectionSet {
    
}

struct Array: Value {
    let values: [Value]
    let location: Location?
}

struct Object: Value {
    let fields: [ObjectField]
    let location: Location?
}

struct ObjectField: Value {
    let name: Name
    let value: (Token, Value)
    let location: Location?
}

struct IntValue: Value {
    let value: Int
    let location: Location?
}

struct FloatValue: Value {
    let value: Float
    let location: Location?
}

struct StringValue: Value {
    let value: String
    let location: Location?
}

struct Variable: Value {
    let value: Name
    let location: Location?
}

struct BoolValue: Value {
    let value: Bool
    let location: Location?
}

struct EnumValue: Value {
    let value: String
    let location: Location?
}