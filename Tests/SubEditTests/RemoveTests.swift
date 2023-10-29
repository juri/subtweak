import CustomDump
import SRTParse
import SubEdit
import XCTest

final class RemoveTests: XCTestCase {
    func testRemoveFirst() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(
                        start: Duration(secondsComponent: 1, attosecondsComponent: 0),
                        duration: Duration(secondsComponent: 2, attosecondsComponent: 0),
                        text: "s1"
                    ),
                    Sub(
                        start: Duration(secondsComponent: 4, attosecondsComponent: 0),
                        duration: Duration(secondsComponent: 5, attosecondsComponent: 0),
                        text: "s2"
                    ),
                ],
                newlineMode: .lf
            )
        )

        try editor.remove(number: 1)

        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(
                    start: Duration(secondsComponent: 4, attosecondsComponent: 0),
                    duration: Duration(secondsComponent: 5, attosecondsComponent: 0),
                    text: "s2"
                ),
            ]
        )
    }

    func testRemoveLast() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        try editor.remove(number: 2)

        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1")]
        )
    }

    func testRemoveTooSmallNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.remove(number: 0)) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(numberError, SubtitleNumberError(number: 0, numberOfEntries: 2))
        }
    }

    func testRemoveTooLargeNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.remove(number: 3)) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(numberError, SubtitleNumberError(number: 3, numberOfEntries: 2))
        }
    }
}
