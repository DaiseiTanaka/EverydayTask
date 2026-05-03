//
//  RKViewController.swift
//  RKCalendar
//
//  Created by Raffi Kian on 7/14/19.
//  Copyright © 2019 Raffi Kian. All rights reserved.
//

import SwiftUI

struct RKViewController: View {
    
    @ObservedObject var taskViewModel: TaskViewModel
    @ObservedObject var rkManager: RKManager

    @State var tappedBackground: Bool
    @State var addBottomSpace: Bool
    @State var showSideBarButton: Bool
    
    @State var id: String = ""

    var body: some View {
        ScrollViewReader { (proxy: ScrollViewProxy) in
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(0..<taskViewModel.numberOfMonth, id: \.self) { index in
                            RKMonth(taskViewModel: taskViewModel, rkManager: self.rkManager, monthOffset: index, tappedBackground: self.$tappedBackground, id: $id)
                        }
                        
                        if addBottomSpace {
                            ZStack {}
                                .frame(height: 400)
                        }
                    }
                    .padding(.top, 50)

                }
                .background(
                    rkManager.colors.monthBackColor
                )
                // 画面がロードされた時は下へスクロール
                .onAppear {
                    // 画面がロードされてすぐ
                    self.id = taskViewModel.returnDayStringLong(date: Date())
                    scrollToThisMonth(proxy: proxy, date: rkManager.selectedDate)
                }
                // 選択している日付の位置までスクロール
                .onChange(of: rkManager.selectedDate) { newValue in
                        scrollToThisMonth(proxy: proxy, date: rkManager.selectedDate)
                }
                // カレンダーの余白をタップした時は下へスクロール
                .onChange(of: tappedBackground) { _ in
                    scrollToThisMonth(proxy: proxy, date: rkManager.selectedDate)
                }
                
                VStack {
                    RKWeekdayHeader(taskViewModel: taskViewModel, rkManager: self.rkManager, showSideMenuButton: showSideBarButton)
                    Spacer()
                }
                // ヘッダーをタップすると一番上へスクロール
                .onTapGesture {
                    scrollToThisMonth(proxy: proxy, date: taskViewModel.returnLatestDate(tasks: taskViewModel.tasks))
                }
            }
        }
    }
    
    func scrollToThisMonth(proxy: ScrollViewProxy, date: Date) {
        let target: CGFloat = 0.4
        let id: String = taskViewModel.returnDayStringLong(date: date)
        withAnimation {
            proxy.scrollTo(id, anchor: UnitPoint(x: 1.0, y: target))
        }
    }
    
}


