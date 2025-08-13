import CustomDump
import SRTParse
import SubEdit
import XCTest

final class InsertTests: XCTestCase {
    func testInsertAsFirst() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: .seconds(1), duration: .seconds(1), text: "n1"),
                ],
                newlineMode: .lf
            )
        )

        XCTAssertTrue(editor.canInsert(at: 1))
        try editor.insert(at: 1)

        expectNoDifference(editor.subs, [
            Sub(
                start: .init(secondsComponent: 0, attosecondsComponent: 333_333_333_333_333_312),
                duration: .init(secondsComponent: 0, attosecondsComponent: 333_333_333_333_333_312),
                text: ""
            ),
            Sub(start: .seconds(1), duration: .seconds(1), text: "n1"),
        ])
    }

    func testInsertInMiddle() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: .zero, duration: .seconds(1), text: "n1"),
                    Sub(start: .seconds(2), duration: .seconds(1), text: "n2"),
                ],
                newlineMode: .lf
            )
        )

        XCTAssertTrue(editor.canInsert(at: 2))
        try editor.insert(at: 2)

        expectNoDifference(editor.subs, [
            Sub(start: .zero, duration: .seconds(1), text: "n1"),
            Sub(start: .milliseconds(1334), duration: .milliseconds(333), text: ""),
            Sub(start: .seconds(2), duration: .seconds(1), text: "n2"),
        ])
    }

    func testInsertIntoEmpty() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [],
                newlineMode: .lf
            )
        )

        XCTAssertFalse(editor.canInsert(at: 0))
        XCTAssertThrowsError(try editor.insert(at: 0)) { error in
            guard let error = error as? SubtitleNumberError else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            expectNoDifference(error, SubtitleNumberError(number: 0, numberOfEntries: 0))
        }
    }

    func testInsertAsFirstWithInsufficientSpace() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: .milliseconds(1), duration: .seconds(1), text: "n1"),
                ],
                newlineMode: .lf
            )
        )

        XCTAssertFalse(editor.canInsert(at: 1))
        XCTAssertThrowsError(try editor.insert(at: 1)) { error in
            guard let error = error as? InsufficientSpaceForNewSubtitleError else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            expectNoDifference(error, InsufficientSpaceForNewSubtitleError(number: 1))
        }
    }

    func testInsertInMiddleWithInsufficientSpace() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: .milliseconds(1), duration: .seconds(1), text: "n1"),
                    Sub(start: .milliseconds(1002), duration: .seconds(1), text: "n2"),
                ],
                newlineMode: .lf
            )
        )

        XCTAssertFalse(editor.canInsert(at: 2))
        XCTAssertThrowsError(try editor.insert(at: 2)) { error in
            guard let error = error as? InsufficientSpaceForNewSubtitleError else {
                XCTFail("Unexpected error: \(error)")
                return
            }
            expectNoDifference(error, InsufficientSpaceForNewSubtitleError(number: 2))
        }
    }
}
