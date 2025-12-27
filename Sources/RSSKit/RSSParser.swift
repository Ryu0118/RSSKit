import Foundation

/// Parses RSS 2.0 feeds from XML data.
///
/// `RSSParser` is the main entry point for parsing RSS feeds.
/// It supports RSS 2.0 format only.
///
/// ## Example
///
/// ```swift
/// let parser = RSSParser()
///
/// // Parse from Data
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
    private let xmlParser: XMLDocumentParser
    private let channelParser: ChannelParser

    /// Creates a new RSS parser.
    public init() {
        xmlParser = XMLDocumentParser()
        channelParser = ChannelParser()
    }

    /// Parses RSS feed data.
    ///
    /// - Parameter data: The RSS XML data to parse.
    /// - Returns: The parsed RSS feed.
    /// - Throws: ``RSSError`` if parsing fails.
    public func parse(_ data: Data) throws -> RSSFeed {
        let root = try xmlParser.parse(data)
        return try parseRSS(root)
    }

    /// Parses an RSS feed from a string.
    ///
    /// - Parameter string: The RSS XML string to parse.
    /// - Returns: The parsed RSS feed.
    /// - Throws: ``RSSError`` if parsing fails.
    public func parse(_ string: String) throws -> RSSFeed {
        guard let data = string.data(using: .utf8) else {
            throw RSSError.invalidXML(underlying: "Failed to convert string to UTF-8 data")
        }
        return try parse(data)
    }
}

private extension RSSParser {
    func parseRSS(_ root: RSSXMLNode) throws -> RSSFeed {
        guard root.name == RSSElement.rss.rawValue else {
            throw RSSError.invalidRSSStructure
        }

        let version = root.attribute("version") ?? "2.0"

        guard let channelNode = root.child(.channel) else {
            throw RSSError.invalidRSSStructure
        }

        let channel = try channelParser.parse(channelNode)

        return RSSFeed(version: version, channel: channel)
    }
}
