public protocol SchemaScalar: AllowedAsInputValue, AllowedAsNonNull, AllowedAsObjectField {

}

public struct Boolean: SchemaScalar {

}

public struct StringType: SchemaScalar {
    public init() {}
}
