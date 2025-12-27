import Foundation
@testable import RSSCore
import Testing

struct XMLDocumentParserTests {
    let parser = XMLDocumentParser()

    @Test
    func parsesSimpleElement() throws {
        let xml = "<root>content</root>"
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        #expect(node.name == "root")
        #expect(node.trimmedText == "content")
    }

    @Test
    func parsesNestedElements() throws {
        let xml = """
        <parent>
            <child1>first</child1>
            <child2>second</child2>
        </parent>
        """
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        #expect(node.name == "parent")
        #expect(node.children.count == 2)
        #expect(node.child(named: "child1")?.trimmedText == "first")
        #expect(node.child(named: "child2")?.trimmedText == "second")
    }

    @Test
    func parsesAttributes() throws {
        let xml = #"<element attr1="value1" attr2="value2">text</element>"#
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        #expect(node.attributes["attr1"] == "value1")
        #expect(node.attributes["attr2"] == "value2")
    }

    @Test
    func parsesCDATA() throws {
        let xml = "<content><![CDATA[<html>raw content</html>]]></content>"
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        #expect(node.trimmedText == "<html>raw content</html>")
    }

    @Test
    func parsesMixedTextAndCDATA() throws {
        let xml = "<content>before<![CDATA[<inside>]]>after</content>"
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        #expect(node.trimmedText == "before<inside>after")
    }

    @Test
    func parsesEmptyElement() throws {
        let xml = "<empty/>"
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        #expect(node.name == "empty")
        #expect(node.text == nil)
        #expect(node.children.isEmpty)
    }

    @Test
    func parsesDeeplyNestedStructure() throws {
        let xml = "<a><b><c><d>deep</d></c></b></a>"
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        let deepNode = node.child(named: "b")?
            .child(named: "c")?
            .child(named: "d")
        #expect(deepNode?.trimmedText == "deep")
    }

    @Test
    func throwsOnInvalidXML() {
        let xml = "<unclosed>"
        let data = Data(xml.utf8)

        #expect(throws: RSSError.self) {
            try parser.parse(data)
        }
    }

    @Test
    func throwsOnEmptyData() {
        let data = Data()

        #expect(throws: RSSError.self) {
            try parser.parse(data)
        }
    }

    @Test
    func throwsOnMalformedXML() {
        let xml = "<root><child></root></child>"
        let data = Data(xml.utf8)

        #expect(throws: RSSError.self) {
            try parser.parse(data)
        }
    }

    @Test
    func parsesUTF8Content() throws {
        let xml = "<title>日本語テスト</title>"
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        #expect(node.trimmedText == "日本語テスト")
    }

    @Test
    func parsesSpecialCharacters() throws {
        let xml = "<text>&lt;tag&gt; &amp; &quot;quotes&quot;</text>"
        let data = Data(xml.utf8)

        let node = try parser.parse(data)

        #expect(node.trimmedText == #"<tag> & "quotes""#)
    }
}
