//
//  CustomTaskPickerView.swift
//  EverydayTask
//
//  Created by 田中大誓 on 2023/07/03.
//

import SwiftUI

struct CustomTaskPickerView: View {
    let count = [Int](1..<100)
    
    @Binding var countSelected: Int
    @Binding var spanSelected: Spans
    
    var body: some View {
        ZStack{
            VStack {
                HStack(spacing: 0) {
                    //時間単位のPicker
                    Picker(selection: self.$countSelected, label: Text("")) {
                        ForEach(self.count, id: \.self) { count in
                            Text("\(count)")
                                .tag(count)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .compositingGroup()
                    .clipped(antialiased: true)
                    //時間単位を表すテキスト
                    Text("times / ")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    //分単位のPicker
                    Picker("", selection: $spanSelected) {
                        ForEach(Spans.allCases) {
                            Text(LocalizedStringKey($0.spanString))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .compositingGroup()
                    .clipped(antialiased: true)
                }
                .padding(.horizontal)
            }
        }
    }
}
