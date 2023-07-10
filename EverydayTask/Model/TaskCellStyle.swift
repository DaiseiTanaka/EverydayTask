//
//  TaskCellStyle.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/07/10.
//

import Foundation
import SwiftUI

enum TaskCellStyle: String, CaseIterable, Identifiable  {
    case list
    case grid
    var id: Self { return self }
    
    var styleString: String {
        switch self {
        case .list:
            return "List"
        case .grid:
            return "Grid"
        }
    }
    
    var columns: [GridItem] {
        switch self {
        case .list:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 1)
        case .grid:
            return Array(repeating: .init(.flexible(minimum: 10, maximum: 500)), count: 2)
        }
    }
    
    var height: CGFloat {
        switch self {
        case .list:
            return 40
        case .grid:
            return 80
        }
    }
    
    var space: CGFloat {
        switch self {
        case .list:
            return 4
        case .grid:
            return 10
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .list:
            return 5
        case .grid:
            return 10
        }
    }
}
