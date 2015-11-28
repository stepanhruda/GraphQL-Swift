infix operator ¶ { associativity left }

/// Concatenates and adds a new line. Insert using `⌥ + 7`.
func ¶ (left: String, right: String) -> String {
    return left + "\n" + right
}
