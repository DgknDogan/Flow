extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

protocol AnyOptional {
    var isNil: Bool { get }
}
