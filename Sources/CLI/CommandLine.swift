import ArgumentParser
import Foundation
import SRTParse
import SubEdit

@main
struct Edit: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "subtweak",
        abstract: "Edit SRT file.",
        subcommands: [ListGaps.self, Remove.self, SetDuration.self, SetEnd.self, SetStart.self]
    )
}

struct Remove: ParsableCommand {
    static var configuration
        = CommandConfiguration(abstract: "Remove a subtitle entry from file.")

    @OptionGroup
    var numberOption: NumberOption

    @OptionGroup
    var inputOutputOptions: InputOutputOptions

    mutating func run() throws {
        let input = try inputOutputOptions.input()
        let output = try inputOutputOptions.output()

        var editor = try SubEditor(source: input)
        try editor.remove(number: self.numberOption.number)

        try editor.write(target: output)
    }
}

struct SetStart: ParsableCommand {
    static var configuration
        = CommandConfiguration(abstract: "Set the start time of an entry.")

    @OptionGroup
    var numberOption: NumberOption

    @Argument(help: "New start time", transform: parseDuration(_:))
    var start: Duration

    @Flag(inversion: .prefixedNo, help: "Adjust the times of the following entries")
    var adjustRest: Bool = true

    @OptionGroup
    var inputOutputOptions: InputOutputOptions

    mutating func run() throws {
        let input = try inputOutputOptions.input()
        let output = try inputOutputOptions.output()

        var editor = try SubEditor(source: input)
        try editor.setStart(number: self.numberOption.number, at: self.start, shouldAdjustRest: self.adjustRest)

        try editor.write(target: output)
    }
}

struct SetDuration: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Set the duration of an entry.",
        discussion: "See also set-end to set the end with a time stamp."
    )

    @OptionGroup
    var numberOption: NumberOption

    @Argument(help: "New duration", transform: parseDuration(_:))
    var duration: Duration

    @Flag(inversion: .prefixedNo, help: "Adjust the times of the following entries")
    var adjustRest: Bool = true

    @OptionGroup
    var inputOutputOptions: InputOutputOptions

    mutating func run() throws {
        let input = try inputOutputOptions.input()
        let output = try inputOutputOptions.output()

        var editor = try SubEditor(source: input)
        try editor.setDuration(
            number: self.numberOption.number,
            duration: self.duration,
            shouldAdjustRest: self.adjustRest
        )

        try editor.write(target: output)
    }
}

struct SetEnd: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Set the end time of an entry.",
        discussion: "See also set-duration to set the end relative to the start of the subtitle."
    )

    @OptionGroup
    var numberOption: NumberOption

    @Argument(help: "New end time", transform: parseDuration(_:))
    var endTime: Duration

    @Flag(inversion: .prefixedNo, help: "Adjust the times of the following entries")
    var adjustRest: Bool = true

    @OptionGroup
    var inputOutputOptions: InputOutputOptions

    mutating func run() throws {
        let input = try inputOutputOptions.input()
        let output = try inputOutputOptions.output()

        var editor = try SubEditor(source: input)
        try editor.setEnd(
            number: self.numberOption.number,
            at: self.endTime,
            shouldAdjustRest: self.adjustRest
        )

        try editor.write(target: output)
    }
}

struct ListGaps: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "List gaps following subtitles in range.",
        discussion: "Finds the subtitles in the specified range and lists the gaps after them."
    )

    @Argument(help: "Subtitle range start")
    var from: Int

    @Argument(help: "Subtitle range end")
    var to: Int

    @OptionGroup
    var inputOptions: InputOptions

    mutating func run() throws {
        let input = try inputOptions.input()
        let editor = try SubEditor(source: input)
        let gaps = try editor.listGaps(numberRange: self.from ... self.to)

        for gapEntry in gaps {
            print("\(gapEntry.number): \(gapEntry.gap)")
        }
    }

    func validate() throws {
        guard self.from >= 1 && self.to >= 1 else {
            throw ValidationError("Subtitle number must be at least 1")
        }
        guard self.from <= self.to else {
            throw ValidationError("The from argument must not be larger than the to argument")
        }
    }
}

struct InputOutputOptions: ParsableArguments {
    @OptionGroup
    var inputOptions: InputOptions

    @Flag(help: "Overwrite input file")
    var overwrite: Bool = false

    @Option(help: "Output file path", transform: FileURL.init(from:))
    var outputFile: FileURL?

    func input() throws -> Input {
        try self.inputOptions.input()
    }

    func output() throws -> Output {
        if self.overwrite { return .url(self.inputOptions.srtFile!.url) }
        if let outputFile = self.outputFile { return .url(outputFile.url) }
        return .stdout
    }

    func validate() throws {
        if self.overwrite && self.outputFile != nil {
            throw ValidationError("Specify overwrite, output file or none, not both overwrite and output file")
        }

        if self.overwrite && self.inputOptions.srtFile == nil {
            throw ValidationError("Overwrite specified but reading from standard input")
        }
    }
}

struct InputOptions: ParsableArguments {
    @Argument(help: "Input file in SRT format", transform: FileURL.init(from:))
    var srtFile: FileURL?

    func input() throws -> Input {
        guard let srtFile = self.srtFile else { return .stdin }
        return .url(srtFile.url)
    }
}

struct NumberOption: ParsableArguments {
    @Argument(help: "Subtitle number to operate on")
    var number: Int

    func validate() throws {
        guard self.number >= 1 else {
            throw ValidationError("Subtitle number must be at least 1")
        }
    }
}

struct FileURL {
    var url: URL

    init(from string: String) throws {
        // the new URL(filePath:directoryHint:) is not available on Linux
        let url = URL(fileURLWithPath: string, isDirectory: false)
        guard url.isFileURL else {
            throw ValidationError("Could not be parsed as path")
        }
        self.url = url
    }
}

func parseDuration(_ string: String) throws -> Duration {
    do {
        let ts = try SRTParse.timestamp.parse(string)
        return ts.duration
    } catch {
        throw ValidationError("Value should be in SRT timestamp format hh:mm:ss,nnn")
    }
}
