import Foundation

public enum Input {
    case stdin
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

public enum Output {
    case stdout
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
