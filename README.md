# clipboard
A simple command line tool to Paste PNG into files, much like pbpaste does for text.

![](https://github.com/PoplarYang/clipboard/workflows/.github/workflows/build.yaml/badge.svg)

## Save clipboard to local
If clipboard content is PNG (or TIFF that can be converted), save it to the path you provide (default `./clipboard.png`).  
Paths like `~/Pictures/shot.png` are expanded automatically and missing folders will be created for you.  
If clipboard content is not PNG-compatible, the tool now prints the available pasteboard types so you know what is stored.  
Only support macOS 10.13+

## Build
```shell
$ swift build
```

## Usage
```shell
$ ./clipboard [ -o /path/to/image.png ]


$ ./clipboard -h
Usage: ./clipboard [options]
  -o, --out:
      File path you want to save PNG to, default: ./clipboard.png
  -h, --help:
      Prints a help message.
```

## TODO
- [X] Judge clipboard content
- [X] support command line argvs, such as save-dir,  output-name
