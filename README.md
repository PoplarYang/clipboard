# clipboard
A simple command line tool to Paste PNG into files, much like pbpaste does for text.

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
$ ./clipboard
```

## TODO
- [ ] Judge clipboard content
- [ ] support command line argvs, such as save-dir,  output-name
