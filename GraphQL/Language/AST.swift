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
    let operation: String
    let name: Name?
    let variableDefinitions: [VariableDefinition]?
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?
}

struct Directive {
    let name: Name
    let value: Value?
    let location: Location?
}

struct FragmentDefinition: Definition {
    let name: Name
    let typeCondition: Name
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?
}

struct VariableDefinition: Definition {
    let variable: Variable
    let type: Any
    let defaultValue: Value?
    let location: Location?
}

struct Name {
    let value: String
    let location: Location?
}

protocol Value {
    
}

protocol Selection {

}

protocol Fragment: Selection {

}

struct SelectionSet {
    let selections: [Selection]
    let location: Location?
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
    let value: Value
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

struct Field: Selection {
    let alias: Name?
    let name: Name
    let arguments: [Argument]
    let directives: [Directive]
    let selectionSet: SelectionSet?
    let location: Location?
}

struct FragmentSpread: Fragment {
    let name: Name
    let directives: [Directive]
    let location: Location?
}

struct InlineFragment: Fragment {
    let typeCondition: Name
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?
}

struct Argument {
    let name: Name
    let value: Value
    let location: Location?
}

protocol Type { }

struct NamedType: Type {
    let value: String
    let location: Location?
}

struct NonNullType: Type {
    let type: Type
    let location: Location?
}

struct ListType: Type {
    let type: Type
    let location: Location?
}
