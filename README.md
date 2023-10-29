# Subtweak

Subtweak is a command line tool and a Swift library for working with [SRT] subtitle files.

## Features

This package can be used from the command line or as a Swift library. The supported operations are:

- Remove a subtitle
- Set the duration of a subtitle, optionally adjusting the following subtitles
- Set the start time of a subtitle, optionally adjusting the following subtitles

## Command Line

This package produces an executable with the name `subtweak`. It allows you to read, edit and write SRT files.

Run `subtweak --help` to see a list of subcommands and their options.

## Library

The Swift library `SubtweakLib` allows you to perform the same operations as the command line.

## Installation

You can install the tool on macOS or Linux by using [Mint] as follows

```sh
$ mint install juri/subtweak@main
```

Or you can use Swift Package Manager manually:

```sh
$ git clone https://github.com/juri/subtweak
$ cd subtweak
$ swift build -c release
$ sudo cp .build/release/subtweak /usr/local/bin
```

[SRT]: https://en.wikipedia.org/wiki/SubRip
[Mint]: https://github.com/yonaskolb/Mint
