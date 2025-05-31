//
//  CloudContainer.swift
//  KakeiboMVP2
//
//  Created by Hiroki Kashihara on 2025/05/20.
//

import CloudKit

enum CloudContainer {
    static let identifier = "iCloud.com.org.KakeiboMVP"
    static let shared = CKContainer(identifier: identifier)
}
