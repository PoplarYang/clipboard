//
//  main.swift
//  A simple command line tool to Paste PNG into files, much like pbpaste does for text.
//
//  Created by PoplarYang on 2020/3/23.
//  Copyright © 2020 PoplarYang. All rights reserved.
//

import Foundation
import AppKit
import PathKit
import CommandLineKit

class SaveManager{
    let cli = CommandLineKit.CommandLine()
    
    // command line argvs parse
    func argvParse() -> (String) {
        
        let filePath = StringOption(shortFlag: "o",
                                   longFlag: "out",
                                   required: false,
                                   helpMessage: "File path you want to save PNG to, default: ./clipboard.png")
        let help = BoolOption(shortFlag: "h",
                              longFlag: "help",
                              helpMessage: "Prints a help message.")
        cli.addOptions(filePath, help)

        do {
            try cli.parse()
            
            if help.wasSet && !filePath.wasSet {
                cli.printUsage()
                exit(-1)
            }
            return filePath.value ?? "./clipboard.png"
        } catch {
            cli.printUsage(error)
            return ""
        }
    }
    

    @available(OSX 10.13, *)
    func saveFile(filePath: String){
        let pasteboard = NSPasteboard.general
        // .fileURL
//        if let data = pasteboard.data(forType: .fileURL){
//            guard let fileUri = NSString(data: data , encoding: String.Encoding.utf8.rawValue) else{
//                print("Cilpboard has file, but it can't be converted by system.");
//                return
//            }
//
//            guard let url = URL(string: fileUri as String) else{
//                print("Convert URL failed.")
//                return
//            }
//            print("File Type: \(url)")
//
//            guard let contentData = try? Data(contentsOf: url) else{
//                print("Read file failed, maybe not be permiteted.")
//                return
//            }
//            print("Content Count: \(contentData.count)")
//            process
//            return
//        }

        // Image PNG
        if let data = pasteboard.data(forType: .png){
            let pngURL = URL(fileURLWithPath: filePath)
            
            let folderURL = pngURL.deletingLastPathComponent()
            let path = Path(folderURL.path)
            if !path.isDirectory {
                print("\(folderURL.path) not directory.")
                cli.printUsage()
                exit(-1)
            }
            
            do {
                try data.write(to: pngURL, options: .atomic)
            } catch {
                cli.printUsage(error)
                exit(-1)
            }
            print("File Path: \(pngURL)")
            print("File Type: PNG")
            print("Content Count: \(data.count)")
            return
        }

        // File Content Type
//        if let data = pasteboard.data(forType: .fileContents){
//            print("File Type: Content")
//            print("Content Count: \(data.count)")
//            process
//            return
//        }

        print("File Type: not png")
        cli.printUsage()
        exit(-1)
    }
}

let manager = SaveManager()
if #available(OSX 10.13, *) {
    let filePath =  manager.argvParse()
    if filePath == "" {
        exit(-1)
    }
    manager.saveFile(filePath: filePath)
} else {
    // Fallback on earlier versions
    print("Only support 10.13+")
    exit(-1)
}
