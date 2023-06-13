//
//  EsseApp.swift
//  Esse
//
//  Created by Alexander Mazanov on 6/9/23.
//

import SwiftUI

@main
struct EsseApp: App {
    var body: some Scene {
        WindowGroup {
            MacMainView()
        }.commands {
            SidebarCommands()
        }
    }
}
