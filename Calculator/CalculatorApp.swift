//
//  CalculatorApp.swift
//  Calculator
//
//  Created by ice on 2024/10/12.
//

import SwiftUI

@main
struct CalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 300, minHeight: 400) // 可设置最小宽高
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        window
                            .setContentSize(
                                // 设置默认宽高
                                NSSize(width: 400, height: 550)
                            )
                    }
                }
        }
    }
}
