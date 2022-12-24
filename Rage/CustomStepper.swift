//
//  CustomStepper.swift
//  Rage
//
//  Created by Henry Krieger on 29.01.22.
//

import SwiftUI

struct CustomStepper: View {
    @Binding var inputInt: Int
    @State var disabledMinus: Bool = true
    @State var disabledPlus: Bool = false
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                if inputInt <= 0 {
                    disabledMinus = true
                    disabledPlus = false
                } else if inputInt == 1 {
                    inputInt -= 1
                    disabledPlus = false
                    disabledMinus = true
                } else {
                    inputInt -= 1
                    disabledPlus = false
                }
            } label: {
                Image(systemName: "minus.circle")
                    .resizable()
                    .frame(width: 150, height: 150, alignment: .center)
            }.disabled(disabledMinus)
            
            Button {
                if inputInt >= 10 {
                    disabledPlus = true
                    disabledMinus = false
                } else if inputInt == 9 {
                    inputInt += 1
                    disabledMinus = false
                    disabledPlus = true
                } else {
                    inputInt += 1
                    disabledMinus = false
                }
            } label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 150, height: 150, alignment: .center)
            }.disabled(disabledPlus)
            Spacer()
        }
        .onAppear {
            if inputInt != 0 {
                disabledMinus = false
            }
            if inputInt != 10 {
                disabledPlus = false
            }
        }
    }
}
