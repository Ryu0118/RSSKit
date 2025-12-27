import Foundation
@testable import RSSKit
import Testing

struct ItemParserTests {
    let parser = ItemParser()

    @Test
    func parsesTitle() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "title", text: "Article Title")]
        )

        let item = parser.parse(node)
        #expect(item.title == "Article Title")
    }

    @Test
    func parsesLink() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "link", text: "https://example.com/article")]
        )

        let item = parser.parse(node)
        #expect(item.link?.absoluteString == "https://example.com/article")
    }

    @Test
    func parsesDescription() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "description", text: "Article summary")]
        )

        let item = parser.parse(node)
        #expect(item.description == "Article summary")
    }

    @Test
    func parsesAuthor() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "author", text: "author@example.com")]
        )

        let item = parser.parse(node)
        #expect(item.author == "author@example.com")
    }

    @Test
    func parsesComments() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "comments", text: "https://example.com/comments")]
        )

        let item = parser.parse(node)
        #expect(item.comments?.absoluteString == "https://example.com/comments")
    }

    @Test
    func parsesPubDate() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "pubDate", text: "Sat, 07 Sep 2002 09:42:31 GMT")]
        )

        let item = parser.parse(node)
        #expect(item.pubDate != nil)
    }

    @Test
    func parsesEmptyItem() {
        let node = RSSXMLNode(name: "item", children: [])

        let item = parser.parse(node)

        #expect(item.title == nil)
        #expect(item.link == nil)
        #expect(item.description == nil)
        #expect(item.categories.isEmpty)
    }

    @Test
    func parsesSingleCategory() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "category", text: "Technology")]
        )

        let item = parser.parse(node)
        #expect(item.categories.count == 1)
        #expect(item.categories.first?.value == "Technology")
    }

    @Test
    func parsesMultipleCategories() {
        let node = RSSXMLNode(
            name: "item",
            children: [
                RSSXMLNode(name: "category", text: "Technology"),
                RSSXMLNode(name: "category", text: "Programming"),
            ]
        )

        let item = parser.parse(node)
        #expect(item.categories.count == 2)
    }

    @Test
    func parsesCategoryWithDomain() {
        let node = RSSXMLNode(
            name: "item",
            children: [
                RSSXMLNode(
                    name: "category",
                    text: "Swift",
                    attributes: ["domain": "http://example.com/tags"]
                ),
            ]
        )

        let item = parser.parse(node)
        #expect(item.categories.first?.value == "Swift")
        #expect(item.categories.first?.domain == "http://example.com/tags")
    }

    @Test
    func skipsCategoryWithEmptyText() {
        let node = RSSXMLNode(
            name: "item",
            children: [
                RSSXMLNode(name: "category", text: ""),
                RSSXMLNode(name: "category", text: "Valid"),
            ]
        )

        let item = parser.parse(node)
        #expect(item.categories.count == 1)
        #expect(item.categories.first?.value == "Valid")
    }

    @Test
    func parsesEnclosure() {
        let node = RSSXMLNode(
            name: "item",
            children: [
                RSSXMLNode(
                    name: "enclosure",
                    attributes: [
                        "url": "https://example.com/audio.mp3",
                        "length": "12345678",
                        "type": "audio/mpeg",
                    ]
                ),
            ]
        )

        let item = parser.parse(node)
        #expect(item.enclosure?.url.absoluteString == "https://example.com/audio.mp3")
        #expect(item.enclosure?.length == 12_345_678)
        #expect(item.enclosure?.type == "audio/mpeg")
    }

    @Test(arguments: [
        ["length": "12345", "type": "audio/mpeg"], // missing url
        ["url": "https://example.com/audio.mp3", "type": "audio/mpeg"], // missing length
        ["url": "https://example.com/audio.mp3", "length": "12345"], // missing type
        ["url": "https://example.com/audio.mp3", "length": "invalid", "type": "audio/mpeg"], // invalid length
    ])
    func returnsNilForIncompleteEnclosure(attributes: [String: String]) {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "enclosure", attributes: attributes)]
        )

        let item = parser.parse(node)
        #expect(item.enclosure == nil)
    }

    @Test
    func parsesGUID() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "guid", text: "unique-id-123")]
        )

        let item = parser.parse(node)
        #expect(item.guid?.value == "unique-id-123")
        #expect(item.guid?.isPermaLink == true) // default
    }

    @Test(arguments: [
        ("true", true),
        ("TRUE", true),
        ("false", false),
        ("FALSE", false),
    ])
    func parsesGUIDIsPermaLink(attrValue: String, expected: Bool) {
        let node = RSSXMLNode(
            name: "item",
            children: [
                RSSXMLNode(
                    name: "guid",
                    text: "id",
                    attributes: ["isPermaLink": attrValue]
                ),
            ]
        )

        let item = parser.parse(node)
        #expect(item.guid?.isPermaLink == expected)
    }

    @Test
    func returnsNilForEmptyGUID() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "guid", text: "")]
        )

        let item = parser.parse(node)
        #expect(item.guid == nil)
    }

    @Test
    func parsesSource() {
        let node = RSSXMLNode(
            name: "item",
            children: [
                RSSXMLNode(
                    name: "source",
                    text: "Source Feed",
                    attributes: ["url": "https://source.com/feed.xml"]
                ),
            ]
        )

        let item = parser.parse(node)
        #expect(item.source?.value == "Source Feed")
        #expect(item.source?.url.absoluteString == "https://source.com/feed.xml")
    }

    @Test
    func returnsNilForSourceWithoutURL() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "source", text: "Source Feed")]
        )

        let item = parser.parse(node)
        #expect(item.source == nil)
    }

    @Test
    func returnsNilForSourceWithEmptyText() {
        let node = RSSXMLNode(
            name: "item",
            children: [
                RSSXMLNode(
                    name: "source",
                    text: "",
                    attributes: ["url": "https://source.com/feed.xml"]
                ),
            ]
        )

        let item = parser.parse(node)
        #expect(item.source == nil)
    }

    @Test
    func returnsNilForEmptyLinkURL() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "link", text: "")]
        )

        let item = parser.parse(node)
        #expect(item.link == nil)
    }

    @Test
    func parsesMultipleItems() {
        let nodes = [
            RSSXMLNode(name: "item", children: [RSSXMLNode(name: "title", text: "First")]),
            RSSXMLNode(name: "item", children: [RSSXMLNode(name: "title", text: "Second")]),
            RSSXMLNode(name: "item", children: [RSSXMLNode(name: "title", text: "Third")]),
        ]

        let items = parser.parse(nodes)

        #expect(items.count == 3)
        #expect(items.map(\.title) == ["First", "Second", "Third"])
    }
}
