import Foundation
import RSSCore

/// Parses RSS 1.0 item elements into ``RSSItem`` models.
struct RSS1ItemParser: Sendable {
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
            title: node.child(named: "title")?.trimmedText,
            link: parseURL(node.child(named: "link")?.trimmedText),
            description: node.child(named: "description")?.trimmedText,
            author: node.child(named: RSS1Element.dcCreator.rawValue)?.trimmedText,
            categories: parseCategories(node),
            pubDate: parseDate(node.child(named: RSS1Element.dcDate.rawValue)?.trimmedText),
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

private extension RSS1ItemParser {
    func parseURL(_ string: String?) -> URL? {
        guard let string = string else { return nil }
        return URL(string: string)
    }

    func parseDate(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        return dateParser.parse(string)
    }

    func parseCategories(_ node: RSSXMLNode) -> [RSSCategory] {
        node.children(named: RSS1Element.dcSubject.rawValue).compactMap { subjectNode in
            guard let value = subjectNode.trimmedText else { return nil }
            return RSSCategory(value: value, domain: nil)
        }
    }

    func parseSource(_ node: RSSXMLNode) -> RSSSource? {
        guard let sourceString = node.child(named: RSS1Element.dcSource.rawValue)?.trimmedText,
              let url = URL(string: sourceString)
        else {
            return nil
        }
        return RSSSource(value: sourceString, url: url)
    }
}
