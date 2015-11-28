public protocol Identifiable {
    var identifier: String { get }
}

public struct IdentitySet<SetElement: Identifiable> {
    private var storage: [String: SetElement]

    public init(values: [SetElement] = []) {
        var storage = [String: SetElement](minimumCapacity: values.count)
        for value in values {
            storage[value.identifier] = value
        }
        self.storage = storage
    }

    public mutating func add(element: SetElement) {
        storage[element.identifier] = element
    }

    public mutating func remove(element: SetElement) {
        removeForIdentifier(element.identifier)
    }

    public mutating func removeForIdentifier(identifier: String) {
        storage[identifier] = nil
    }

    public func elementMatching(value: SetElement) -> SetElement? {
        return elementForIdentifier(value.identifier)
    }

    public func elementForIdentifier(identifier: String) -> SetElement? {
        return storage[identifier]
    }

    subscript(identifier: String) -> SetElement? {
        get { return elementForIdentifier(identifier) }
        // set subscript doesn't make sense, you use `add` instead
    }
}

extension IdentitySet: ArrayLiteralConvertible {
    public typealias Element = SetElement

    public init(arrayLiteral elements: IdentitySet.Element...) {
        self.init(values: elements)
    }
}

extension IdentitySet: SequenceType {
    public typealias Generator = IdentitySetGenerator<SetElement>

    public func generate() -> Generator {
        return IdentitySetGenerator(dictionaryGenerator: storage.generate())
    }
}

public struct IdentitySetGenerator<GeneratedType: Identifiable>: GeneratorType {
    public typealias Element = GeneratedType

    private var dictionaryGenerator: DictionaryGenerator<String, GeneratedType>

    init(dictionaryGenerator: DictionaryGenerator<String, GeneratedType>) {
        self.dictionaryGenerator = dictionaryGenerator
    }

    public mutating func next() -> Element? {
        return dictionaryGenerator.next()?.1
    }
}
