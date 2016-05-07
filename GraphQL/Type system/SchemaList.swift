public final class List: AllowedAsObjectField, AllowedAsNonNull {
    let objectFieldType: AllowedAsObjectField

    public init(_ objectFieldType: AllowedAsObjectField) {
        self.objectFieldType = objectFieldType
    }
}
