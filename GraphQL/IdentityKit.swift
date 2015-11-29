public protocol Identifiable {
    var identifier: String { get }
}

public struct IdentitySet<Member: Identifiable> {
    private var storage: [String: Member]

    public init(values: [Member] = []) {
        var storage = [String: Member](minimumCapacity: values.count)
        for value in values {
            storage[value.identifier] = value
        }
        self.storage = storage
    }

    public mutating func insert(member: Member) {
        storage[member.identifier] = member
    }

    public mutating func remove(member: Member) {
        removeForIdentifier(member.identifier)
    }

    public mutating func removeForIdentifier(identifier: String) {
        storage[identifier] = nil
    }

    public func memberMatching(member: Member) -> Member? {
        return memberForIdentifier(member.identifier)
    }

    public func memberForIdentifier(identifier: String) -> Member? {
        return storage[identifier]
    }

    public func contains(member: Member) -> Bool {
        return memberMatching(member) != nil
    }

    subscript(identifier: String) -> Member? {
        get { return memberForIdentifier(identifier) }
        // set subscript doesn't make sense, you use `add` instead
    }
}

extension IdentitySet: ArrayLiteralConvertible {
    public typealias Element = Member

    public init(arrayLiteral elements: IdentitySet.Element...) {
        self.init(values: elements)
    }
}

extension IdentitySet: SequenceType {
    public typealias Generator = IdentitySetGenerator<Member>

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
