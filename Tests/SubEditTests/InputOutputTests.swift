import CustomDump
import SRTParse
import SubEdit
import XCTest

final class InputOutputTests: XCTestCase {
    func testInvalidEncoding() async throws {
        try await inTemporaryDirectory { tempDir in
            let bytes: [UInt8] = [0xC3, 0x28]
            let data = Data(bytes)
            let srtLocation = tempDir.appendingPathComponent("invalid.srt", isDirectory: false)
            try data.write(to: srtLocation)
            XCTAssertThrowsError(try SubEditor(source: .url(srtLocation))) { error in
                guard let decodingError = error as? InputDecodingError else {
                    XCTFail("Unexpected error \(error)")
                    return
                }
                expectNoDifference(decodingError, InputDecodingError(input: .url(srtLocation)))
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
            let srtLocation = tempDir.appendingPathComponent("test.srt", isDirectory: false)
            try Data(srt.utf8).write(to: srtLocation)
            let editor = try SubEditor(source: .url(srtLocation))

            expectNoDifference(
                editor.srtSubs.subs,
                [
                    Sub(start: .milliseconds(60023), duration: .milliseconds(2433), text: "Nothing to be done."),
                    Sub(
                        start: .milliseconds(68001),
                        duration: .milliseconds(2099),
                        text: "I'm beginning to come round\nto that opinion."
                    ),
                ]
            )
            expectNoDifference(editor.srtSubs.newlineMode, .lf)

            let saveLocation = tempDir.appendingPathComponent("save.srt", isDirectory: false)
            try editor.write(target: .url(saveLocation))
            let writtenData = try Data(contentsOf: saveLocation)

            expectNoDifference(String(data: writtenData, encoding: .utf8), srt)
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
            let srtLocation = tempDir.appendingPathComponent("test.srt", isDirectory: false)
            try Data(srt.utf8).write(to: srtLocation)
            let editor = try SubEditor(source: .url(srtLocation))

            expectNoDifference(
                editor.srtSubs.subs,
                [
                    Sub(start: .milliseconds(60023), duration: .milliseconds(2433), text: "Nothing to be done."),
                    Sub(
                        start: .milliseconds(68001),
                        duration: .milliseconds(2099),
                        text: "I'm beginning to come round\nto that opinion."
                    ),
                ]
            )
            expectNoDifference(editor.srtSubs.newlineMode, .crLF)

            let saveLocation = tempDir.appendingPathComponent("save.srt", isDirectory: false)
            try editor.write(target: .url(saveLocation))
            let writtenData = try Data(contentsOf: saveLocation)

            expectNoDifference(writtenData, Data(srt.utf8))
        }
    }

    func testWithBOM() async throws {
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
            let srtLocation = tempDir.appendingPathComponent("test.srt", isDirectory: false)
//            try Data([0xEF, 0xBB, 0xBF]).write(to: srtLocation)
            try Data(Data([0xEF, 0xBB, 0xBF]) + srt.utf8).write(to: srtLocation)
            let editor = try SubEditor(source: .url(srtLocation))

            expectNoDifference(
                editor.srtSubs.subs,
                [
                    Sub(start: .milliseconds(60023), duration: .milliseconds(2433), text: "Nothing to be done."),
                    Sub(
                        start: .milliseconds(68001),
                        duration: .milliseconds(2099),
                        text: "I'm beginning to come round\nto that opinion."
                    ),
                ]
            )
            expectNoDifference(editor.srtSubs.newlineMode, .lf)

            let saveLocation = tempDir.appendingPathComponent("save.srt", isDirectory: false)
            try editor.write(target: .url(saveLocation))
            let writtenData = try Data(contentsOf: saveLocation)

            expectNoDifference(String(data: writtenData, encoding: .utf8), srt)
        }
    }
}

private func inTemporaryDirectory(_ closure: (URL) async throws -> Void) async throws {
    let url = URL(
        fileURLWithPath: UUID().uuidString,
        isDirectory: true,
        relativeTo: URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
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
