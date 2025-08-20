//
//  SelectPostDate.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/20/25.
//

import SwiftUI

struct SelectPostDate: View {
    var initialDate: Date
    let onSave: (Date) -> Void
    
    @State private var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    init(initialDate: Date, onSave: @escaping (Date) -> Void) {
        self.initialDate = initialDate
        self.onSave = onSave
        _selectedDate = State(initialValue: initialDate)
    }
    
    var body: some View {
        VStack {
            Text(PostStrings.selectPostDate)
                .font(.headline)
            
            DatePicker(
                PostStrings.posted,
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            
            
            HStack {
                Button(UIStrings.cancelString) { dismiss() }
                
                Spacer()
                
                Button(UIStrings.saveString) {
                    onSave(selectedDate)
                    dismiss()
                }
            }
            .padding(.horizontal)
            .foregroundStyle(.text)
        }
    }
}

#Preview {
    SelectPostDate(initialDate: Date()) { date in
        
    }
}
