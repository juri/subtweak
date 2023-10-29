import CustomDump
import SRTParse
import SubEdit
import XCTest

final class SetEndTests: XCTestCase {
    func testSetEndNegative() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(
            try editor.setEnd(number: 1, at: Duration.seconds(-1), shouldAdjustRest: false)
        ) { error in

            guard let durationError = error as? InvalidDurationError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(durationError, InvalidDurationError(duration: .seconds(-1)))
        }
    }

    func testSetStartTooSmallNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.setEnd(number: 0, at: .seconds(3), shouldAdjustRest: true)) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(numberError, SubtitleNumberError(number: 0, numberOfEntries: 2))
        }
    }

    func testSetStartTooLargeNumber() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(try editor.setEnd(number: 3, at: .seconds(3), shouldAdjustRest: true)) { error in
            guard let numberError = error as? SubtitleNumberError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(numberError, SubtitleNumberError(number: 3, numberOfEntries: 2))
        }
    }

    func testSetEndBeforeStart() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(
            try editor.setEnd(number: 1, at: Duration.milliseconds(500), shouldAdjustRest: false)
        ) { error in

            guard let overlapError = error as? TimeOverlapError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(
                overlapError,
                TimeOverlapError(
                    targetNumber: 1,
                    targetSub: Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    requestedTime: .end(.milliseconds(500)),
                    overlappingNumber: 1,
                    overlappingSub: Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1")
                )
            )
        }
    }

    func testSetEndOverlapNoAdjust() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(
            try editor.setEnd(number: 1, at: .milliseconds(3500), shouldAdjustRest: false)
        ) { error in

            guard let overlapError = error as? TimeOverlapError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertNoDifference(
                overlapError,
                TimeOverlapError(
                    targetNumber: 1,
                    targetSub: Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    requestedTime: .end(.milliseconds(3500)),
                    overlappingNumber: 2,
                    overlappingSub: Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2")
                )
            )
        }
    }

    func testSetEndOverlapAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        try editor.setEnd(number: 1, at: .milliseconds(3500), shouldAdjustRest: true)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: Duration.seconds(1), duration: Duration.milliseconds(2500), text: "s1"),
                Sub(start: Duration.milliseconds(4500), duration: Duration.seconds(1), text: "s2"),
            ]
        )
    }

    func testSetEnd() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        try editor.setEnd(number: 1, at: .seconds(4), shouldAdjustRest: false)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: .seconds(1), duration: .seconds(3), text: "s1"),
                Sub(start: .seconds(5), duration: .seconds(1), text: "s2"),
            ]
        )
    }

    func testSetEndAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(5), duration: Duration.seconds(1), text: "s2"),
                ],
                newlineMode: .lf
            )
        )

        try editor.setEnd(number: 1, at: .seconds(4), shouldAdjustRest: true)
        XCTAssertNoDifference(
            editor.srtSubs.subs,
            [
                Sub(start: .seconds(1), duration: .seconds(3), text: "s1"),
                Sub(start: .seconds(7), duration: .seconds(1), text: "s2"),
            ]
        )
    }
}
