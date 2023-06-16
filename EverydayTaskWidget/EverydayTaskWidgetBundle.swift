//
//  EverydayTaskWidgetBundle.swift
//  EverydayTaskWidget
//
//  Created by 田中大誓 on 2023/06/15.
//

import WidgetKit
import SwiftUI

@main
struct EverydayTaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        EverydayTaskWidget()
        EverydayTaskWidgetLiveActivity()
    }
}
