//
//  SortKey.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/07/10.
//

import Foundation

enum SortKey: String, CaseIterable, Identifiable {
    case spanType
    case title
    case addedDate
    var id: Self { return self }
    
    var keyString: String {
        switch self {
        case .spanType:
            return "Span type"
        case .title:
            return "Title"
        case .addedDate:
            return "Added date"
        }
    }
}

enum DivideDisplayedTasks: String, CaseIterable, Identifiable {
    case divide
    case notDivide
    var id: Self { return self }
    
    var keyString: String {
        switch self {
        case .divide:
            return "Divide hidden tasks"
        case .notDivide:
            return "Not divide hidden tasks"
        }
    }
}
