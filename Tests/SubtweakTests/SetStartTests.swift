import CustomDump
import SRTParse
import SubEdit
import XCTest

final class SetStartTests: XCTestCase {
    func testSetStartBackwardsNoAdjust() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: Subs(entries: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ]),
                newlineMode: .lf
            )
        )

        try editor.setStart(number: 1, at: Duration.milliseconds(500), shouldAdjustRest: false)

        XCTAssertNoDifference(
            editor.srtSubs.subs.entries,
            [
                Sub(start: Duration.milliseconds(500), duration: Duration.seconds(1), text: "s1"),
                Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
            ]
        )
    }

    func testSetStartNegative() {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: Subs(entries: [
                    Sub(start: Duration.seconds(1), duration: Duration.seconds(1), text: "s1"),
                    Sub(start: Duration.seconds(3), duration: Duration.seconds(1), text: "s2"),
                ]),
                newlineMode: .lf
            )
        )
        XCTAssertThrowsError(
            try editor.setStart(number: 1, at: Duration.seconds(-1), shouldAdjustRest: false)
        ) { error in

            guard let durationError = error as? InvalidDurationError else {
                XCTFail("Unexpected error \(error)")
                return
            }
            XCTAssertEqual(durationError, InvalidDurationError(duration: .seconds(-1)))
        }
    }
}
