extension Strideable {
    
    /// Advance by 1.
    mutating func advance() {
        self = advanced(by: 1)
    }
}
