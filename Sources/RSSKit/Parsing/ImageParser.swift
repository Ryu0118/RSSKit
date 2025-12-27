import Foundation

/// Parses RSS image elements into ``RSSImage`` models.
struct ImageParser: Sendable {
    /// Parses an image node into an ``RSSImage``.
    ///
    /// - Parameter node: The XML node representing an `<image>` element.
    /// - Returns: The parsed RSS image, or `nil` if required fields are missing.
    func parse(_ node: RSSXMLNode) -> RSSImage? {
        guard let urlString = node.text(for: .url),
              let url = URL(string: urlString),
              let title = node.text(for: .title),
              let linkString = node.text(for: .link),
              let link = URL(string: linkString)
        else {
            return nil
        }

        return RSSImage(
            url: url,
            title: title,
            link: link,
            width: parseInt(node.text(for: .width)),
            height: parseInt(node.text(for: .height)),
            description: node.text(for: .description)
        )
    }

    private func parseInt(_ string: String?) -> Int? {
        guard let string = string else { return nil }
        return Int(string)
    }
}
