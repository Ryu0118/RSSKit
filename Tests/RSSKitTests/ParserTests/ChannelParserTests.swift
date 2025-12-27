@testable import RSS2Kit
@testable import RSSCore
import Testing

private typealias XMLNode = RSSXMLNode

struct ChannelParserTests {
    let parser = ChannelParser()

    private func minimalChannelNode(
        title: String = "Title",
        link: String = "https://example.com",
        description: String = "Description",
        additionalChildren: [XMLNode] = []
    ) -> XMLNode {
        XMLNode(
            name: "channel",
            children: [
                XMLNode(name: "title", text: title),
                XMLNode(name: "link", text: link),
                XMLNode(name: "description", text: description),
            ] + additionalChildren
        )
    }

    @Test
    func parsesRequiredFields() throws {
        let node = minimalChannelNode()

        let channel = try parser.parse(node)

        #expect(channel.title == "Title")
        #expect(channel.link.absoluteString == "https://example.com")
        #expect(channel.description == "Description")
    }

    @Test
    func throwsWhenTitleMissing() {
        let node = XMLNode(
            name: "channel",
            children: [
                XMLNode(name: "link", text: "https://example.com"),
                XMLNode(name: "description", text: "Description"),
            ]
        )

        #expect(throws: RSSError.missingRequiredElement("title")) {
            try parser.parse(node)
        }
    }

    @Test
    func throwsWhenLinkMissing() {
        let node = XMLNode(
            name: "channel",
            children: [
                XMLNode(name: "title", text: "Title"),
                XMLNode(name: "description", text: "Description"),
            ]
        )

        #expect(throws: RSSError.missingRequiredElement("link")) {
            try parser.parse(node)
        }
    }

    @Test
    func throwsWhenDescriptionMissing() {
        let node = XMLNode(
            name: "channel",
            children: [
                XMLNode(name: "title", text: "Title"),
                XMLNode(name: "link", text: "https://example.com"),
            ]
        )

        #expect(throws: RSSError.missingRequiredElement("description")) {
            try parser.parse(node)
        }
    }

    @Test
    func throwsForEmptyLinkURL() {
        let node = minimalChannelNode(link: "")

        #expect(throws: RSSError.missingRequiredElement("link")) {
            try parser.parse(node)
        }
    }

    @Test
    func parsesLanguage() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "language", text: "en-us")]
        )

        let channel = try parser.parse(node)
        #expect(channel.language == "en-us")
    }

    @Test
    func parsesCopyright() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "copyright", text: "Copyright 2024")]
        )

        let channel = try parser.parse(node)
        #expect(channel.copyright == "Copyright 2024")
    }

    @Test
    func parsesManagingEditor() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "managingEditor", text: "editor@example.com")]
        )

        let channel = try parser.parse(node)
        #expect(channel.managingEditor == "editor@example.com")
    }

    @Test
    func parsesWebMaster() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "webMaster", text: "webmaster@example.com")]
        )

        let channel = try parser.parse(node)
        #expect(channel.webMaster == "webmaster@example.com")
    }

    @Test
    func parsesGenerator() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "generator", text: "RSSKit")]
        )

        let channel = try parser.parse(node)
        #expect(channel.generator == "RSSKit")
    }

    @Test
    func parsesPubDate() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "pubDate", text: "Sat, 07 Sep 2002 09:42:31 GMT")]
        )

        let channel = try parser.parse(node)
        #expect(channel.pubDate != nil)
    }

    @Test
    func parsesLastBuildDate() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "lastBuildDate", text: "Sat, 07 Sep 2002 09:42:31 GMT")]
        )

        let channel = try parser.parse(node)
        #expect(channel.lastBuildDate != nil)
    }

    @Test
    func returnsNilForInvalidDate() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "pubDate", text: "invalid date")]
        )

        let channel = try parser.parse(node)
        #expect(channel.pubDate == nil)
    }

    @Test
    func parsesDocs() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "docs", text: "https://example.com/rss")]
        )

        let channel = try parser.parse(node)
        #expect(channel.docs?.absoluteString == "https://example.com/rss")
    }

    @Test
    func returnsNilForEmptyDocsURL() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "docs", text: "")]
        )

        let channel = try parser.parse(node)
        #expect(channel.docs == nil)
    }

    @Test
    func parsesTTL() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "ttl", text: "60")]
        )

        let channel = try parser.parse(node)
        #expect(channel.ttl == 60)
    }

    @Test
    func returnsNilForInvalidTTL() throws {
        let node = minimalChannelNode(
            additionalChildren: [XMLNode(name: "ttl", text: "invalid")]
        )

        let channel = try parser.parse(node)
        #expect(channel.ttl == nil)
    }

    @Test
    func parsesCategories() throws {
        let node = minimalChannelNode(
            additionalChildren: [
                XMLNode(name: "category", text: "Technology"),
                XMLNode(name: "category", text: "Programming", attributes: ["domain": "http://example.com"]),
            ]
        )

        let channel = try parser.parse(node)

        #expect(channel.categories.count == 2)
        #expect(channel.categories[0].value == "Technology")
        #expect(channel.categories[0].domain == nil)
        #expect(channel.categories[1].value == "Programming")
        #expect(channel.categories[1].domain == "http://example.com")
    }

    @Test
    func parsesImage() throws {
        let node = minimalChannelNode(
            additionalChildren: [
                XMLNode(
                    name: "image",
                    children: [
                        XMLNode(name: "url", text: "https://example.com/logo.png"),
                        XMLNode(name: "title", text: "Logo"),
                        XMLNode(name: "link", text: "https://example.com"),
                    ]
                ),
            ]
        )

        let channel = try parser.parse(node)

        #expect(channel.image?.url.absoluteString == "https://example.com/logo.png")
        #expect(channel.image?.title == "Logo")
    }

    @Test
    func returnsNilForInvalidImage() throws {
        let node = minimalChannelNode(
            additionalChildren: [
                XMLNode(
                    name: "image",
                    children: [XMLNode(name: "url", text: "https://example.com/logo.png")]
                    // missing title and link
                ),
            ]
        )

        let channel = try parser.parse(node)
        #expect(channel.image == nil)
    }

    @Test
    func parsesItems() throws {
        let node = minimalChannelNode(
            additionalChildren: [
                XMLNode(name: "item", children: [XMLNode(name: "title", text: "First")]),
                XMLNode(name: "item", children: [XMLNode(name: "title", text: "Second")]),
            ]
        )

        let channel = try parser.parse(node)

        #expect(channel.items.count == 2)
        #expect(channel.items[0].title == "First")
        #expect(channel.items[1].title == "Second")
    }

    @Test
    func returnsEmptyItemsWhenNone() throws {
        let node = minimalChannelNode()

        let channel = try parser.parse(node)
        #expect(channel.items.isEmpty)
    }

    @Test
    func optionalFieldsDefaultToNil() throws {
        let node = minimalChannelNode()

        let channel = try parser.parse(node)

        #expect(channel.language == nil)
        #expect(channel.copyright == nil)
        #expect(channel.managingEditor == nil)
        #expect(channel.webMaster == nil)
        #expect(channel.pubDate == nil)
        #expect(channel.lastBuildDate == nil)
        #expect(channel.generator == nil)
        #expect(channel.docs == nil)
        #expect(channel.ttl == nil)
        #expect(channel.image == nil)
        #expect(channel.categories.isEmpty)
        #expect(channel.items.isEmpty)
    }
}
