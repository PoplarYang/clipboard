//
//  main.swift
//  A simple command line tool to Paste PNG into files, much like pbpaste does for text.
//
//  Created by PoplarYang on 2020/3/23.
//  Copyright © 2020 PoplarYang. All rights reserved.
//

import Foundation
import AppKit

class SaveManager{

    let pasteboard = NSPasteboard.general

    @available(OSX 10.13, *)
    func saveToLocal(){
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
            let fileName: String = "image.png"
//            let pngPath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filePath)
            let home = FileManager.default.homeDirectoryForCurrentUser
            let pngPath = home.appendingPathComponent(fileName)

            do {
                try data.write(to: pngPath, options: .atomic)
            } catch {
                print(error)
            }
            print("File Path: \(pngPath)")
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
        exit(-1)
    }
}

let manager = SaveManager()
if #available(OSX 10.13, *) {
    manager.saveToLocal()
} else {
    // Fallback on earlier versions
    print("Only support 10.13+")
    exit(-1)
}
