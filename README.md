# Subtweak

Subtweak is a command line tool and a Swift library for working with SRT subtitle files.

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
