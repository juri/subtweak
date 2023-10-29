import CustomDump
import SRTParse
import SubEdit
import XCTest

final class InputOutputTests: XCTestCase {
    func testInvalidEncoding() async throws {
        try await inTemporaryDirectory { tempDir in
            let bytes: [UInt8] = [0xC3, 0x28]
            let data = Data(bytes)
            let srtLocation = tempDir.appending(path: "invalid.srt", directoryHint: .notDirectory)
            try data.write(to: srtLocation)
            XCTAssertThrowsError(try SubEditor(source: .url(srtLocation))) { error in
                guard let decodingError = error as? InputDecodingError else {
                    XCTFail("Unexpected error \(error)")
                    return
                }
                XCTAssertNoDifference(decodingError, InputDecodingError(input: .url(srtLocation)))
            }
        }
    }

    func testWithLF() async throws {
        try await inTemporaryDirectory { tempDir in
            let srt = """
            1
            00:01:00,023 --> 00:01:02,456
            Nothing to be done.

            2
            00:01:08,001 --> 00:01:10,100
            I'm beginning to come round
            to that opinion.


            """
            let srtLocation = tempDir.appending(path: "test.srt", directoryHint: .notDirectory)
            try Data(srt.utf8).write(to: srtLocation)
            let editor = try SubEditor(source: .url(srtLocation))

            XCTAssertNoDifference(
                editor.srtSubs.subs.entries,
                [
                    Sub(start: .milliseconds(60023), duration: .milliseconds(2433), text: "Nothing to be done."),
                    Sub(
                        start: .milliseconds(68001),
                        duration: .milliseconds(2099),
                        text: "I'm beginning to come round\nto that opinion."
                    ),
                ]
            )
            XCTAssertNoDifference(editor.srtSubs.newlineMode, .lf)

            let saveLocation = tempDir.appending(path: "save.srt", directoryHint: .notDirectory)
            try editor.write(target: .url(saveLocation))
            let writtenData = try Data(contentsOf: saveLocation)

            XCTAssertNoDifference(String(data: writtenData, encoding: .utf8), srt)
        }
    }

    func testWithCRLF() async throws {
        try await inTemporaryDirectory { tempDir in
            let srt = """
            1\r
            00:01:00,023 --> 00:01:02,456\r
            Nothing to be done.\r
            \r
            2\r
            00:01:08,001 --> 00:01:10,100\r
            I'm beginning to come round\r
            to that opinion.\r
            \r

            """
            let srtLocation = tempDir.appending(path: "test.srt", directoryHint: .notDirectory)
            try Data(srt.utf8).write(to: srtLocation)
            let editor = try SubEditor(source: .url(srtLocation))

            XCTAssertNoDifference(
                editor.srtSubs.subs.entries,
                [
                    Sub(start: .milliseconds(60023), duration: .milliseconds(2433), text: "Nothing to be done."),
                    Sub(
                        start: .milliseconds(68001),
                        duration: .milliseconds(2099),
                        text: "I'm beginning to come round\nto that opinion."
                    ),
                ]
            )
            XCTAssertNoDifference(editor.srtSubs.newlineMode, .crLF)

            let saveLocation = tempDir.appending(path: "save.srt", directoryHint: .notDirectory)
            try editor.write(target: .url(saveLocation))
            let writtenData = try Data(contentsOf: saveLocation)

            XCTAssertNoDifference(writtenData, Data(srt.utf8))
        }
    }
}

private func inTemporaryDirectory(_ closure: (URL) async throws -> Void) async throws {
    let url = URL(
        filePath: UUID().uuidString,
        directoryHint: .isDirectory,
        relativeTo: URL(filePath: NSTemporaryDirectory(), directoryHint: .isDirectory)
    ).absoluteURL
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    defer {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            fatalError("Error removing directory \(url): \(error)")
        }
    }
    try await closure(url)
}
