@testable import RSSCore
import Testing

struct RSSXMLNodeTests {
    struct TrimmedTextTestCase: Sendable {
        let input: String
        let expected: String

        static let cases: [TrimmedTextTestCase] = [
            TrimmedTextTestCase(input: "  hello  ", expected: "hello"),
            TrimmedTextTestCase(input: "\n\ttext\n\t", expected: "text"),
            TrimmedTextTestCase(input: "no-trim", expected: "no-trim"),
        ]
    }

    struct EmptyContentTestCase: Sendable {
        let input: String

        static let cases: [EmptyContentTestCase] = [
            EmptyContentTestCase(input: ""),
            EmptyContentTestCase(input: "   "),
            EmptyContentTestCase(input: "\n\t\n"),
        ]
    }
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

    @Test(arguments: TrimmedTextTestCase.cases)
    func trimmedTextTrimsWhitespace(testCase: TrimmedTextTestCase) {
        let node = RSSXMLNode(name: "test", text: testCase.input)
        #expect(node.trimmedText == testCase.expected)
    }

    @Test(arguments: EmptyContentTestCase.cases)
    func trimmedTextReturnsNilForEmptyContent(testCase: EmptyContentTestCase) {
        let node = RSSXMLNode(name: "test", text: testCase.input)
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

    @Test
    func defaultValues() {
        let node = RSSXMLNode(name: "test")

        #expect(node.name == "test")
        #expect(node.text == nil)
        #expect(node.attributes.isEmpty)
        #expect(node.children.isEmpty)
    }
}
