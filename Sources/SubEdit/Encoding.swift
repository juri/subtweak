import Foundation

struct Decoded {
    let encoding: String.Encoding
    let string: String
}

func decode(source: Input, data: Data) throws -> Decoded {
    var data = data
    if data.starts(with: [0xEF, 0xBB, 0xBF]) {
        data = data.dropFirst(3)
        guard let string = String(data: data, encoding: .utf8) else {
            throw InputDecodingError(input: source)
        }
        return Decoded(encoding: .utf8, string: string)
    } else if data.starts(with: [0xFE, 0xFF]) {
        data = data.dropFirst(2)
        guard let string = String(data: data, encoding: .utf16BigEndian) else {
            throw InputDecodingError(input: source)
        }
        return Decoded(encoding: .utf16BigEndian, string: string)
    } else if data.starts(with: [0xFF, 0xFE]) {
        data = data.dropFirst(2)
        guard let string = String(data: data, encoding: .utf16LittleEndian) else {
            throw InputDecodingError(input: source)
        }
        return Decoded(encoding: .utf16LittleEndian, string: string)
    }

    guard let string = String(data: data, encoding: .utf8) else {
        throw InputDecodingError(input: source)
    }
    return Decoded(encoding: .utf8, string: string)
}
