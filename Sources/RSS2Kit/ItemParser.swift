import Foundation
import RSSCore

/// Parses RSS item elements into ``RSSItem`` models.
struct ItemParser: Sendable {
    private let dateParser: DateParser

    init(dateParser: DateParser = DateParser()) {
        self.dateParser = dateParser
    }

    /// Parses an item node into an ``RSSItem``.
    ///
    /// - Parameter node: The XML node representing an `<item>` element.
    /// - Returns: The parsed RSS item.
    func parse(_ node: RSSXMLNode) -> RSSItem {
        RSSItem(
            title: node.text(for: .title),
            link: parseURL(node.text(for: .link)),
            description: node.text(for: .description),
            author: node.text(for: .author),
            categories: parseCategories(node),
            comments: parseURL(node.text(for: .comments)),
            enclosure: parseEnclosure(node),
            guid: parseGUID(node),
            pubDate: parseDate(node.text(for: .pubDate)),
            source: parseSource(node)
        )
    }

    /// Parses multiple item nodes.
    ///
    /// - Parameter nodes: The XML nodes representing `<item>` elements.
    /// - Returns: An array of parsed RSS items.
    func parse(_ nodes: [RSSXMLNode]) -> [RSSItem] {
        nodes.map(parse)
    }
}

private extension ItemParser {
    func parseURL(_ string: String?) -> URL? {
        guard let string = string else { return nil }
        return URL(string: string)
    }

    func parseDate(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        return dateParser.parse(string)
    }

    func parseCategories(_ node: RSSXMLNode) -> [RSSCategory] {
        node.children(.category).compactMap { categoryNode in
            guard let value = categoryNode.trimmedText else { return nil }
            return RSSCategory(
                value: value,
                domain: categoryNode.attribute(.domain)
            )
        }
    }

    func parseEnclosure(_ node: RSSXMLNode) -> RSSEnclosure? {
        guard let enclosureNode = node.child(.enclosure),
              let urlString = enclosureNode.attribute(.url),
              let url = URL(string: urlString),
              let lengthString = enclosureNode.attribute(.length),
              let length = Int(lengthString),
              let type = enclosureNode.attribute(.type)
        else {
            return nil
        }

        return RSSEnclosure(url: url, length: length, type: type)
    }

    func parseGUID(_ node: RSSXMLNode) -> RSSGUID? {
        guard let guidNode = node.child(.guid),
              let value = guidNode.trimmedText
        else {
            return nil
        }

        let isPermaLink: Bool
        if let permaLinkAttr = guidNode.attribute(.isPermaLink) {
            isPermaLink = permaLinkAttr.lowercased() == "true"
        } else {
            isPermaLink = true // Default per RSS 2.0 spec
        }

        return RSSGUID(value: value, isPermaLink: isPermaLink)
    }

    func parseSource(_ node: RSSXMLNode) -> RSSSource? {
        guard let sourceNode = node.child(.source),
              let value = sourceNode.trimmedText,
              let urlString = sourceNode.attribute(.url),
              let url = URL(string: urlString)
        else {
            return nil
        }

        return RSSSource(value: value, url: url)
    }
}
