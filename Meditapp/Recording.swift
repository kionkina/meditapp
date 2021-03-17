//
//  Recording.swift
//  Meditapp
//
//  Created by Jackson Lu on 3/8/21.
//

import UIKit

class Recording: NSObject, Codable {
    init(_ myURL: URL, _ name: String){
        self.audioURL = myURL
        self.recordingName = name
        super.init()
    }
    let audioURL: URL
    let recordingName: String
    var checked: Bool = false
}
