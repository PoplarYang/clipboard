# clipboard
A simple command line tool to Paste PNG into files, much like pbpaste does for text.

![](https://github.com/PoplarYang/clipboard/workflows/.github/workflows/build.yaml/badge.svg)

## Save clipboard to local
If clipboard content is PNG, save it userhome directory named "image.png".
If not, do no thing.
Only support 10.13+

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
- [] Judge clipboard content
- [X] support command line argvs, such as save-dir,  output-name
