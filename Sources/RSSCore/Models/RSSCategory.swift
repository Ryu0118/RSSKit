import Foundation

/// A category for an RSS channel or item.
public struct RSSCategory: Sendable, Equatable {
    /// The category name.
    public let value: String

    /// A domain that identifies the categorization taxonomy.
    public let domain: String?

    public init(value: String, domain: String? = nil) {
        self.value = value
        self.domain = domain
    }
}
