import Foundation

/// Parses RFC 822 date strings commonly used in RSS feeds.
package struct DateParser: Sendable {
    /// Common date formats found in RSS feeds.
    private static let formats: [String] = [
        "EEE, dd MMM yyyy HH:mm:ss zzz",
        "EEE, dd MMM yyyy HH:mm:ss Z",
        "EEE, dd MMM yyyy HH:mm zzz",
        "EEE, dd MMM yyyy HH:mm Z",
        "dd MMM yyyy HH:mm:ss zzz",
        "dd MMM yyyy HH:mm:ss Z",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:sszzz",
        "yyyy-MM-dd",
    ]

    package init() {}

    /// Parses a date string using common RSS date formats.
    ///
    /// - Parameter string: The date string to parse.
    /// - Returns: The parsed date, or `nil` if parsing fails.
    package func parse(_ string: String) -> Date? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        for format in Self.formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            if let date = formatter.date(from: trimmed) {
                return date
            }
        }

        return nil
    }
}
