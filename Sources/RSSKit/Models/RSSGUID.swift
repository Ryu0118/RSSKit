import Foundation

/// A globally unique identifier for an RSS item.
public struct RSSGUID: Sendable, Equatable {
    /// The GUID value.
    public let value: String

    /// Whether the GUID is a permalink URL.
    ///
    /// If `true`, the GUID can be used as a URL to the item.
    /// Defaults to `true` per RSS 2.0 specification.
    public let isPermaLink: Bool

    public init(value: String, isPermaLink: Bool = true) {
        self.value = value
        self.isPermaLink = isPermaLink
    }
}
