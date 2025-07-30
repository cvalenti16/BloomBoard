//
//  CalendarMonthView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/30/25.
//

import SwiftUI

struct CalendarMonthView: View {
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let days = Array(1...42)
    
    var body: some View {
        NavigationStack{
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(days, id: \.self) { day in
                        CalendarDayCellView(dayNumber: day)
                            .frame(minHeight: 48)
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("July 2025")
            .toolbarBackground(Color(.systemGray6), for: .navigationBar)
            .scrollIndicators(.hidden)
            
        }
    }
}


#Preview {
    CalendarMonthView()
}
