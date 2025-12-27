import Foundation
import RSSCore

/// Parses RSS 1.0 channel elements into ``RSSChannel`` models.
struct RSS1ChannelParser: Sendable {
    private let dateParser: DateParser
    private let itemParser: RSS1ItemParser

    init(
        dateParser: DateParser = DateParser(),
        itemParser: RSS1ItemParser? = nil
    ) {
        self.dateParser = dateParser
        self.itemParser = itemParser ?? RSS1ItemParser(dateParser: dateParser)
    }

    /// Parses a channel node into an ``RSSChannel``.
    ///
    /// - Parameters:
    ///   - node: The XML node representing a `<channel>` element.
    ///   - itemNodes: The item nodes from the root RDF element.
    /// - Returns: The parsed RSS channel.
    /// - Throws: ``RSSError/missingRequiredElement(_:)`` if required elements are missing.
    func parse(_ node: RSSXMLNode, itemNodes: [RSSXMLNode]) throws -> RSSChannel {
        guard let title = node.child(named: "title")?.trimmedText else {
            throw RSSError.missingRequiredElement("title")
        }

        guard let linkString = node.child(named: "link")?.trimmedText,
              let link = URL(string: linkString)
        else {
            throw RSSError.missingRequiredElement("link")
        }

        guard let description = node.child(named: "description")?.trimmedText else {
            throw RSSError.missingRequiredElement("description")
        }

        return RSSChannel(
            title: title,
            link: link,
            description: description,
            language: node.child(named: RSS1Element.dcLanguage.rawValue)?.trimmedText,
            copyright: node.child(named: RSS1Element.dcRights.rawValue)?.trimmedText,
            managingEditor: node.child(named: RSS1Element.dcCreator.rawValue)?.trimmedText,
            pubDate: parseDate(node.child(named: RSS1Element.dcDate.rawValue)?.trimmedText),
            categories: parseCategories(node),
            items: itemParser.parse(itemNodes)
        )
    }
}

private extension RSS1ChannelParser {
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
}
