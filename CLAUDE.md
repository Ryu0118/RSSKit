# RSSKit

A lightweight Swift library for parsing RSS feeds.

## Project Overview

RSSKit is a focused RSS parsing library that prioritizes simplicity and correctness over feature breadth.

**Scope:**
- RSS 2.0 parsing only
- Read-only (no feed generation)

**Not Supported:**
- Atom feeds
- JSON Feed
- RSS feed creation/writing

## Build Requirements

- Swift 6.2+
- Xcode 26.1+
- Platform versions:
  - iOS 16.0+
  - macOS 13.0+
  - tvOS 16.0+
  - watchOS 9.0+
  - visionOS 1.0+

## Architecture

### Design Principles

- **SOLID**: Each type has a single responsibility
- **DRY**: Shared logic extracted into reusable components
- **One major type per file**: Keep files focused and navigable
- **Abstraction through composition**: Break complex parsing into smaller, testable units

### Module Structure

```
Sources/
└── RSSKit/
    ├── Models/           # Data structures (RSSFeed, RSSChannel, RSSItem, etc.)
    ├── Parsing/          # XML parsing logic
    ├── Extensions/       # Swift extensions
    └── Errors/           # Error types

Tests/
└── RSSKitTests/
    ├── ParserTests/      # Unit tests for parsers
    ├── ModelTests/       # Unit tests for models
    └── Fixtures/         # Sample RSS feeds for testing
```

### Key Types

| Type | Responsibility |
|------|----------------|
| `RSSFeed` | Root model representing a parsed RSS feed |
| `RSSChannel` | Channel metadata (title, link, description, etc.) |
| `RSSItem` | Individual feed item |
| `RSSParser` | Public API for parsing RSS data |
| `RSSError` | Parsing and validation errors |

## Code Style

### Swift Conventions

- Use Swift 6 strict concurrency
- Prefer value types (`struct`) over reference types
- Use `Sendable` where appropriate
- Leverage Swift's type system for safety

### Naming

- Models: Noun-based (`RSSFeed`, `RSSItem`)
- Parsers: Suffix with `Parser` (`ChannelParser`, `ItemParser`)
- Errors: Suffix with `Error` (`RSSError`)

### Documentation

- Document all public APIs with DocC-compatible comments
- Include code examples for main entry points

## Testing

All tests reside in `RSSKitTests`. Follow these guidelines:

- Test each parser in isolation
- Use fixture files for complex RSS documents
- Test edge cases (malformed XML, missing elements, encoding issues)
- Aim for high coverage on parsing logic

Run tests:
```bash
swift test
```

## Dependencies

None. RSSKit uses only Foundation's `XMLParser`.
