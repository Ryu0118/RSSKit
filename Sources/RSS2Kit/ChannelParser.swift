import Foundation
import RSSCore

/// Parses RSS channel elements into ``RSSChannel`` models.
struct ChannelParser: Sendable {
    private let dateParser: DateParser
    private let itemParser: ItemParser
    private let imageParser: ImageParser

    init(
        dateParser: DateParser = DateParser(),
        itemParser: ItemParser? = nil,
        imageParser: ImageParser = ImageParser()
    ) {
        self.dateParser = dateParser
        self.itemParser = itemParser ?? ItemParser(dateParser: dateParser)
        self.imageParser = imageParser
    }

    /// Parses a channel node into an ``RSSChannel``.
    ///
    /// - Parameter node: The XML node representing a `<channel>` element.
    /// - Returns: The parsed RSS channel.
    /// - Throws: ``RSSError/missingRequiredElement(_:)`` if required elements are missing.
    func parse(_ node: RSSXMLNode) throws -> RSSChannel {
        guard let title = node.text(for: .title) else {
            throw RSSError.missingRequiredElement(RSSElement.title.rawValue)
        }

        guard let linkString = node.text(for: .link),
              let link = URL(string: linkString)
        else {
            throw RSSError.missingRequiredElement(RSSElement.link.rawValue)
        }

        guard let description = node.text(for: .description) else {
            throw RSSError.missingRequiredElement(RSSElement.description.rawValue)
        }

        return RSSChannel(
            title: title,
            link: link,
            description: description,
            language: node.text(for: .language),
            copyright: node.text(for: .copyright),
            managingEditor: node.text(for: .managingEditor),
            webMaster: node.text(for: .webMaster),
            pubDate: parseDate(node.text(for: .pubDate)),
            lastBuildDate: parseDate(node.text(for: .lastBuildDate)),
            categories: parseCategories(node),
            generator: node.text(for: .generator),
            docs: parseURL(node.text(for: .docs)),
            ttl: parseInt(node.text(for: .ttl)),
            image: parseImage(node),
            items: parseItems(node)
        )
    }
}

private extension ChannelParser {
    func parseURL(_ string: String?) -> URL? {
        guard let string = string else { return nil }
        return URL(string: string)
    }

    func parseDate(_ string: String?) -> Date? {
        guard let string = string else { return nil }
        return dateParser.parse(string)
    }

    func parseInt(_ string: String?) -> Int? {
        guard let string = string else { return nil }
        return Int(string)
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

    func parseImage(_ node: RSSXMLNode) -> RSSImage? {
        guard let imageNode = node.child(.image) else { return nil }
        return imageParser.parse(imageNode)
    }

    func parseItems(_ node: RSSXMLNode) -> [RSSItem] {
        itemParser.parse(node.children(.item))
    }
}
