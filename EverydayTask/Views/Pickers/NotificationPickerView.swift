//
//  PickerView.swift
//  cLock_Timer
//
//  Created by 田中大誓 on 2023/03/15.
//

import SwiftUI

struct NotificationPickerView: View {
    //設定可能な時間単位の数値
    let hours = [Int](0..<24)
    //設定可能な分単位の数値
    let minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    
    @Binding var hourSelected: Int
    @Binding var minSelected: Int
    
    var body: some View {
        ZStack{
            VStack {
                HStack(spacing: 0) {
                    //時間単位のPicker
                    Picker(selection: self.$hourSelected, label: Text("")) {
                        ForEach(self.hours, id: \.self) { hour in
                            Text("\(hour)")
                                .tag(hour)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .compositingGroup()
                    .clipped(antialiased: true)
                    //時間単位を表すテキスト
                    Text(":")
                        .font(.headline)
                    
                    //分単位のPicker
                    Picker(selection: self.$minSelected, label: Text("")) {
                        ForEach(self.minutes, id: \.self) { min in
                            Text("\(min)")
                                .tag(min)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .compositingGroup()
                    .clipped(antialiased: true)
                    
                    //分単位を表すテキスト
                    Text("")
                        .font(.headline)
                }
                .padding(.horizontal)
            }
        }
    }
}

// タップしてないところが動くのを防ぐ
extension UIPickerView {
    open override var intrinsicContentSize: CGSize {
        //return CGSize(width: 200, height: 160)
        return CGSize(width: UIView.noIntrinsicMetric - 50, height: 160)
    }
}

//struct PickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PickerView(hourSelected: $1, minSelected: $1)
//            .previewLayout(.sizeThatFits)
//    }
//}
