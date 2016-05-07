public struct NonNull: AllowedAsInputValue, AllowedAsObjectField {
    let value: AllowedAsNonNull

    public init(_ value: AllowedAsNonNull) {
        self.value = value
    }
}

public protocol AllowedAsNonNull {}
