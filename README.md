[![Build](https://github.com/juri/subtweak/actions/workflows/build.yml/badge.svg)](https://github.com/juri/subtweak/actions/workflows/build.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjuri%2Fsubtweak%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/juri/subtweak)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fjuri%2Fsubtweak%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/juri/subtweak)

# Subtweak

Subtweak is a command line tool and a Swift library for working with [SRT] subtitle files.

## Features

This package can be used from the command line or as a Swift library. The supported operations are:

- Remove a subtitle
- Set the duration or the end time of a subtitle, optionally adjusting the following subtitles
- Set the start time of a subtitle, optionally adjusting the following subtitles
- List gaps between subtitles

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
