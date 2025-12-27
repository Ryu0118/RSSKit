import Foundation

/// A parsed RSS feed containing channel metadata and items.
///
/// This is the root type returned by ``RSSParser``.
///
/// ## Example
/// ```swift
/// let parser = RSSParser()
/// let feed = try parser.parse(data)
/// print(feed.channel.title)
/// for item in feed.channel.items {
///     print(item.title ?? "Untitled")
/// }
/// ```
public struct RSSFeed: Sendable, Equatable {
    /// The RSS version (e.g., "2.0").
    public let version: String

    /// The channel containing feed metadata and items.
    public let channel: RSSChannel

    public init(version: String, channel: RSSChannel) {
        self.version = version
        self.channel = channel
    }
}
