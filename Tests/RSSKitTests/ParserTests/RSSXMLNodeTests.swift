@testable import RSSKit
import Testing

struct RSSXMLNodeTests {
    // MARK: - Child Access

    @Test
    func childNamedReturnsFirstMatch() {
        let node = RSSXMLNode(
            name: "parent",
            children: [
                RSSXMLNode(name: "child", text: "first"),
                RSSXMLNode(name: "child", text: "second"),
                RSSXMLNode(name: "other", text: "third"),
            ]
        )

        let child = node.child(named: "child")
        #expect(child?.text == "first")
    }

    @Test
    func childNamedReturnsNilWhenNoMatch() {
        let node = RSSXMLNode(name: "parent", children: [])
        #expect(node.child(named: "missing") == nil)
    }

    @Test
    func childWithRSSElement() {
        let node = RSSXMLNode(
            name: "channel",
            children: [RSSXMLNode(name: "title", text: "Test")]
        )

        #expect(node.child(.title)?.text == "Test")
    }

    @Test
    func childrenNamedReturnsAll() {
        let node = RSSXMLNode(
            name: "parent",
            children: [
                RSSXMLNode(name: "item", text: "1"),
                RSSXMLNode(name: "other"),
                RSSXMLNode(name: "item", text: "2"),
                RSSXMLNode(name: "item", text: "3"),
            ]
        )

        let items = node.children(named: "item")
        #expect(items.count == 3)
        #expect(items.map(\.text) == ["1", "2", "3"])
    }

    // MARK: - Text Extraction

    @Test(arguments: [
        ("  hello  ", "hello"),
        ("\n\ttext\n\t", "text"),
        ("no-trim", "no-trim")
    ])
    func trimmedTextTrimsWhitespace(input: String, expected: String) {
        let node = RSSXMLNode(name: "test", text: input)
        #expect(node.trimmedText == expected)
    }

    @Test(arguments: ["", "   ", "\n\t\n"])
    func trimmedTextReturnsNilForEmptyContent(input: String) {
        let node = RSSXMLNode(name: "test", text: input)
        #expect(node.trimmedText == nil)
    }

    @Test
    func trimmedTextReturnsNilWhenTextIsNil() {
        let node = RSSXMLNode(name: "test", text: nil)
        #expect(node.trimmedText == nil)
    }

    @Test
    func textForReturnsChildText() {
        let node = RSSXMLNode(
            name: "item",
            children: [RSSXMLNode(name: "title", text: "  Article Title  ")]
        )

        #expect(node.text(for: .title) == "Article Title")
    }

    @Test
    func textForReturnsNilWhenChildMissing() {
        let node = RSSXMLNode(name: "item", children: [])
        #expect(node.text(for: .title) == nil)
    }

    // MARK: - Attribute Access

    @Test
    func attributeReturnsValue() {
        let node = RSSXMLNode(
            name: "enclosure",
            attributes: ["url": "https://example.com", "type": "audio/mpeg"]
        )

        #expect(node.attribute("url") == "https://example.com")
        #expect(node.attribute("type") == "audio/mpeg")
    }

    @Test
    func attributeReturnsNilWhenMissing() {
        let node = RSSXMLNode(name: "test", attributes: [:])
        #expect(node.attribute("missing") == nil)
    }

    @Test
    func attributeWithRSSElement() {
        let node = RSSXMLNode(
            name: "guid",
            attributes: ["isPermaLink": "false"]
        )

        #expect(node.attribute(.isPermaLink) == "false")
    }

    // MARK: - Initialization

    @Test
    func defaultValues() {
        let node = RSSXMLNode(name: "test")

        #expect(node.name == "test")
        #expect(node.text == nil)
        #expect(node.attributes.isEmpty)
        #expect(node.children.isEmpty)
    }
}
