import Foundation

/// Input source for subtitle editing.
public enum Input: Equatable, Sendable {
    /// Read from standard input.
    case stdin

    /// Read from a file URL.
    case url(URL)

    func read() throws -> Data {
        switch self {
        case .stdin:
            try FileHandle.standardInput.readToEnd() ?? Data()
        case let .url(url):
            try Data(contentsOf: url)
        }
    }
}

/// Output target for saving edited subtitles.
public enum Output: Equatable {
    /// Write to standard output.
    case stdout

    /// Write to a file URL.
    case url(URL)

    func write(data: Data) throws {
        switch self {
        case .stdout:
            try FileHandle.standardOutput.write(contentsOf: data)
        case let .url(url):
            try data.write(to: url, options: .atomic)
        }
    }
}
