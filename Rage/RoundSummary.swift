//
//  RoundSummary.swift
//  Rage
//
//  Created by Henry Krieger on 22.01.22.
//

import SwiftUI
import Charts

struct RoundSummary: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Players.name, ascending: true)
        ],
        animation: .default)
    private var players: FetchedResults<Players>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Rounds.points, ascending: false)
        ],
        animation: .default)
    private var rounds: FetchedResults<Rounds>
    
    var roundNumber: Int
    
    var body: some View {
        List {
            Section(header: Text("Standings in Round \(roundNumber)")) {
                ForEach(rounds, id: \.self) { item in
                    if item.roundNumber == self.roundNumber {
                        HStack {
                            Text(item.player!)
                            Spacer()
                            Text("\(item.points)")
                        }
                    }
                }
            }
            ForEach(players, id: \.self) { player in
                Section(header: Text("\(player.name)")) {
                    ForEach(rounds, id: \.self) { round in
                        if round.roundNumber == roundNumber && round.player == player.name {
                            HStack {
                                Text("Predicted/Won")
                                Spacer()
                                Text("\(round.prediction)/\(round.tricks)")
                            }
                            HStack {
                                Text("+5 Cards/-5 Cards")
                                Spacer()
                                Text("\(round.plusFive)/\(round.minusFive)")
                            }
                            HStack {
                                Text("Points")
                                Spacer()
                                Text("\(round.points)")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Summary - Round \(roundNumber)")
    }
}
