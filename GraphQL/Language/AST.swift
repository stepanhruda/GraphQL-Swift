protocol Node {
    var type: NodeType { get }
}

// TODO: remove this
extension Node {
    var type: NodeType { return .Any }
}

protocol Tree: Node {
    var children: [Node] { get }
    mutating func removeChildAtIndex(index: Int)
    mutating func replaceChildAtIndex(index: Int, newValue: Node)
}

extension Tree {
    mutating func removeChildAtIndex(index: Int) {}
    mutating func replaceChildAtIndex(index: Int, newValue: Node) {}
}

struct Location {
    let start: String.Index
    let end: String.Index
    let source: Source?
}

struct Document: Tree {
    var definitions: [Definition]
    let location: Location?

    var type: NodeType { return .Document }

    var children: [Node] { return definitions.map { $0 as Node } }

    mutating func removeChildAtIndex(index: Int) {
        definitions.removeAtIndex(index)
    }
    mutating func replaceChildAtIndex(index: Int, newValue: Node) {
        definitions[index] = newValue as! Definition
    }
}

protocol Definition: Node {
}

struct OperationDefinition: Definition, Tree {
    let operation: String
    let name: Name?
    let variableDefinitions: [VariableDefinition]?
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    var type: NodeType { return .OperationDefinition }

    var children: [Node] { return directives.map { $0 as Node } }
}

struct Directive: Node {
    let name: Name
    let value: Value?
    let location: Location?
}

struct FragmentDefinition: Definition, Tree {
    let name: Name
    let typeCondition: Name
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    var children: [Node] { return directives.map { $0 as Node } }
}

struct VariableDefinition: Definition {
    let variable: Variable
    let type: Any
    let defaultValue: Value?
    let location: Location?
}

struct Name: Node {
    let value: String
    let location: Location?
}

func ==(a: Name, b: Name) -> Bool {
    return a.value == b.value
}

extension Name: Hashable {
    var hashValue: Int { return value.hashValue }
}

protocol Value: Node {
    
}

protocol Selection: Node {

}

protocol Fragment: Selection {

}

struct SelectionSet: Tree {
    let selections: [Selection]
    let location: Location?

    var children: [Node] { return selections.map { $0 as Node } }
}

struct Array: Value, Tree {
    let values: [Value]
    let location: Location?

    var children: [Node] { return values.map { $0 as Node } }
}

struct Object: Value {
    let fields: [ObjectField]
    let location: Location?

    var children: [Node] { return fields.map { $0 as Node } }
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

struct Field: Selection, Tree {
    let alias: Name?
    let name: Name
    let arguments: [Argument]
    let directives: [Directive]
    let selectionSet: SelectionSet?
    let location: Location?

    var children: [Node] { return directives.map { $0 as Node } }
}

struct FragmentSpread: Fragment, Tree {
    let name: Name
    let directives: [Directive]
    let location: Location?

    var children: [Node] { return directives.map { $0 as Node } }
}

struct InlineFragment: Fragment, Tree {
    let typeCondition: Name
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    // TODO: Should SelectionSet be included?
    var children: [Node] { return directives.map { $0 as Node } }
}

struct Argument: Node {
    let name: Name
    let value: Value
    let location: Location?
}

protocol Type: Node { }

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
