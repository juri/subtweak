import ArgumentParser
import Foundation
import SRTParse
import SubEdit

@main
struct Edit: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "subtweak",
        abstract: "Edit SRT file.",
        subcommands: [Remove.self, SetDuration.self, SetStart.self]
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
    static var configuration
        = CommandConfiguration(abstract: "Set the duration of an entry.")

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

struct InputOutputOptions: ParsableArguments {
    @Argument(help: "Input file in SRT format", transform: FileURL.init(from:))
    var srtFile: FileURL?

    @Flag(help: "Overwrite input file")
    var overwrite: Bool = false

    @Option(help: "Output file path", transform: FileURL.init(from:))
    var outputFile: FileURL?

    func input() throws -> Input {
        guard let srtFile = self.srtFile else { return .stdin }
        return .url(srtFile.url)
    }

    func output() throws -> Output {
        if self.overwrite { return .url(self.srtFile!.url) }
        if let outputFile = self.outputFile { return .url(outputFile.url) }
        return .stdout
    }

    func validate() throws {
        if self.overwrite && self.outputFile != nil {
            throw ValidationError("Specify overwrite, output file or none, not both overwrite and output file")
        }

        if self.overwrite && self.srtFile == nil {
            throw ValidationError("Overwrite specified but reading from standard input")
        }
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
