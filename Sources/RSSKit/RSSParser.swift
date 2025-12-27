import Foundation
import RSS1Kit
import RSS2Kit
import RSSCore

/// Unified RSS parser with automatic format detection.
///
/// `RSSParser` automatically detects whether a feed is RSS 1.0 or RSS 2.0
/// and uses the appropriate parser.
///
/// ## Example
///
/// ```swift
/// let parser = RSSParser()
///
/// // Parse from Data - format is auto-detected
/// let feed = try parser.parse(data)
///
/// // Access channel metadata
/// print(feed.channel.title)
/// print(feed.channel.description)
///
/// // Iterate over items
/// for item in feed.channel.items {
///     print(item.title ?? "Untitled")
/// }
/// ```
///
/// ## Thread Safety
///
/// `RSSParser` is `Sendable` and can be safely used from any actor or thread.
public struct RSSParser: Sendable {
    private let rss1Parser: RSS1Parser
    private let rss2Parser: RSS2Parser
    private let formatDetector: RSSFormatDetector

    /// Creates a new RSS parser with automatic format detection.
    public init() {
        rss1Parser = RSS1Parser()
        rss2Parser = RSS2Parser()
        formatDetector = RSSFormatDetector()
    }

    /// Parses RSS feed data with automatic format detection.
    ///
    /// - Parameter data: The RSS XML data to parse.
    /// - Returns: The parsed RSS feed.
    /// - Throws: ``RSSError`` if parsing fails or format is unsupported.
    public func parse(_ data: Data) throws -> RSSFeed {
        let format = try formatDetector.detect(data)
        switch format {
        case .rss1:
            return try rss1Parser.parse(data)
        case .rss2:
            return try rss2Parser.parse(data)
        }
    }

    /// Parses an RSS feed from a string with automatic format detection.
    ///
    /// - Parameter string: The RSS XML string to parse.
    /// - Returns: The parsed RSS feed.
    /// - Throws: ``RSSError`` if parsing fails or format is unsupported.
    public func parse(_ string: String) throws -> RSSFeed {
        guard let data = string.data(using: .utf8) else {
            throw RSSError.invalidXML(underlying: "Failed to convert string to UTF-8 data")
        }
        return try parse(data)
    }
}
