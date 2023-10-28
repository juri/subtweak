import Foundation
import Subtitles

extension Subtitles.Sub {
    init(_ subtitle: Subtitle) {
        let startDuration = subtitle.start.duration
        let duration = subtitle.end.duration - startDuration

        self.init(start: startDuration, duration: duration, text: subtitle.text)
    }
}

extension Subtitle {
    init(number: Int, sub: Sub) {
        self.init(
            number: number,
            start: Timestamp(sub.start),
            end: Timestamp(sub.start + sub.duration),
            text: sub.text
        )
    }
}

extension Timestamp {
    var nanoseconds: Int {
        let nanoZeroes: Int = 9
        return self.fraction * power10(nanoZeroes - self.fractionDigitCount)
    }

    var duration: Duration {
        Duration.seconds(self.hours * 60 * 60)
            + Duration.seconds(self.minutes * 60)
            + Duration.seconds(self.seconds)
            + Duration.nanoseconds(self.nanoseconds)
    }

    init(_ duration: Duration) {
        let seconds = duration.components.seconds

        self.init(
            hours: Int(seconds / 60 / 60),
            minutes: Int(seconds / 60 % 60),
            seconds: Int(seconds % 60 % 60),
            fraction: Int(attosToMillis(duration.components.attoseconds)),
            fractionDigitCount: 3
        )
    }
}

private func power10(_ n: Int) -> Int {
    var out = 1
    for _ in 0 ..< n {
        out *= 10
    }
    return out
}

private let millisInAttos: Int64 = 1_000_000_000_000_000

func attosToMillis(_ attos: Int64) -> Int64 {
    Int64((Double(attos / (millisInAttos / 10)) / 10.0).rounded())
}
