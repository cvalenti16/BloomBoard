//
//  CalendarDayCellView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/30/25.
//

import SwiftUI

struct CalendarDayCellView: View {
    let dayNumber: Int
    
    var body: some View {
        VStack {
            Text("\(dayNumber)")
                .font(.caption)
                .fontWeight(.medium)
                .padding(.top, 6)
            Spacer()
        }
        .frame(width: 75, height: 100)
    }
}





