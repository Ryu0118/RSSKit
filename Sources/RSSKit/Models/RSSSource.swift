import Foundation

/// The source RSS channel for an item.
///
/// Used when an item is aggregated from another feed.
public struct RSSSource: Sendable, Equatable {
    /// The name of the source channel.
    public let value: String

    /// The URL of the source channel's RSS feed.
    public let url: URL

    public init(value: String, url: URL) {
        self.value = value
        self.url = url
    }
}
