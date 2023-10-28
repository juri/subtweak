import CustomDump
import SRTParse
import Subtweak
import XCTest

final class RemoveTests: XCTestCase {
    func testRemove() throws {
        var editor = SubEditor(
            srtSubs: SRTSubs(
                subs: Subs(entries: [
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
                ]),
                newlineMode: .lf
            )
        )

        try editor.remove(number: 1)

        XCTAssertNoDifference(
            editor.srtSubs.subs.entries,
            [
                Sub(
                    start: Duration(secondsComponent: 4, attosecondsComponent: 0),
                    duration: Duration(secondsComponent: 5, attosecondsComponent: 0),
                    text: "s2"
                ),
            ]
        )
    }
}
