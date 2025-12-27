import Foundation
import RSSCore

/// Parses RSS 1.0 (RDF) feeds from XML data.
///
/// `RSS1Parser` is the entry point for parsing RSS 1.0 feeds.
///
/// ## Example
///
/// ```swift
/// let parser = RSS1Parser()
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
/// `RSS1Parser` is `Sendable` and can be safely used from any actor or thread.
public struct RSS1Parser: Sendable {
    private let xmlParser: XMLDocumentParser
    private let channelParser: RSS1ChannelParser

    /// Creates a new RSS 1.0 parser.
    public init() {
        xmlParser = XMLDocumentParser()
        channelParser = RSS1ChannelParser()
    }

    /// Parses RSS 1.0 feed data.
    ///
    /// - Parameter data: The RSS XML data to parse.
    /// - Returns: The parsed RSS feed.
    /// - Throws: ``RSSError`` if parsing fails.
    public func parse(_ data: Data) throws -> RSSFeed {
        let root = try xmlParser.parse(data)
        return try parseRDF(root)
    }

    /// Parses an RSS 1.0 feed from a string.
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

private extension RSS1Parser {
    func parseRDF(_ root: RSSXMLNode) throws -> RSSFeed {
        guard root.name == RSS1Element.rdf.rawValue else {
            throw RSSError.invalidRSSStructure
        }

        guard let channelNode = root.child(named: RSS1Element.channel.rawValue) else {
            throw RSSError.invalidRSSStructure
        }

        // RSS 1.0 items are at the root level, not inside channel
        let itemNodes = root.children(named: RSS1Element.item.rawValue)
        let channel = try channelParser.parse(channelNode, itemNodes: itemNodes)

        return RSSFeed(version: "1.0", channel: channel)
    }
}
