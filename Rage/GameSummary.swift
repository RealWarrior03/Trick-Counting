//
//  GameSummary.swift
//  Rage
//
//  Created by Henry Krieger on 10.01.22.
//

import SwiftUI
import Charts

struct GameSummary: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Players.points, ascending: false),
            NSSortDescriptor(keyPath: \Players.name, ascending: true)
        ],
        animation: .default)
    private var players: FetchedResults<Players>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Rounds.player, ascending: true)
        ],
        animation: .default)
    private var rounds: FetchedResults<Rounds>
    
    @State var resetAlert: Bool = false
    @State var deleteAlert: Bool = false
    
    
    struct ToyShape: Identifiable {
        var type: String
        var count: Double
        var id = UUID()
    }
    var data: [ToyShape] = [
        .init(type: "Cube", count: 5),
        .init(type: "Sphere", count: 4),
        .init(type: "Pyramid", count: 4)
    ]
    
    func calcPointSum(currentRound: Int, player: String, rounds: FetchedResults<Rounds>) -> Int {
        var result = 0
        for round in rounds {
            if round.player == player && round.roundNumber <= currentRound {
                result += Int(round.points)
            }
        }
        return result
    }
    
    @State var showTotalPoints: Bool = true
    @State var showRoundPoints: Bool = false
    @State var showPlusFive: Bool = false
    @State var showMinusFive: Bool = false
    
    var body: some View {
        List {
            Section(header: Text("Game Result")) {
                ForEach(players, id: \.self) { item in
                    HStack {
                        Text("\(item.name)")
                        Spacer()
                        Text("\(item.points)")
                    }
                }
            }
            
            if #available(iOS 16.0, *) {
                Section(header: Text("Charts")) {
                    DisclosureGroup(isExpanded: $showTotalPoints) {
                        Chart(rounds) {
                            let pointsSplitSum = calcPointSum(currentRound: Int($0.roundNumber), player: $0.player!, rounds: rounds)
                            LineMark(
                                x: .value("Round", $0.roundNumber),
                                y: .value("Points", pointsSplitSum),
                                series: .value("Player", $0.player!)
                            )
                            .foregroundStyle(by: .value("Player", $0.player!))
                            .interpolationMethod(.catmullRom)
                        }.frame(height: 250)
                        .chartXScale(range: .plotDimension(startPadding: 1, endPadding: CGFloat(UserData().roundAmount)))
                    } label: {
                        Text("Total Points")
                    }
                    
                    /*DisclosureGroup(isExpanded: $showRoundPoints) {
                        Chart {
                            ForEach(rounds) {
                                LineMark(
                                    x: .value("Round", $0.roundNumber),
                                    y: .value("Points", $0.points),
                                    series: .value("Player", $0.player!)
                                )
                                .foregroundStyle(by: .value("Player", $0.player!))
                            }
                        }.frame(height: 250)
                    } label: {
                        Text("Points per Round")
                    }*/
                    
                    /*DisclosureGroup(isExpanded: $showPlusFive) {
                        Chart {
                            ForEach(rounds) {
                                BarMark(
                                    x: .value("Round", $0.roundNumber),
                                    y: .value("Amount", $0.plusFive)
                                )
                                .foregroundStyle(by: .value("Player", $0.player!))
                            }
                        }.frame(height: 250)
                            .chartYScale(range: .plotDimension(startPadding: 0, endPadding: 4))
                            .chartXScale(range: .plotDimension(startPadding: 0, endPadding: CGFloat(UserData().roundAmount)))
                    } label: {
                        Text("+5 Cards")
                    }*/
                    
                    /*DisclosureGroup(isExpanded: $showMinusFive) {
                        Chart {
                            ForEach(rounds) {
                                BarMark(
                                    x: .value("Round", $0.roundNumber),
                                    y: .value("Amount", $0.minusFive)
                                )
                                .foregroundStyle(by: .value("Player", $0.player!))
                            }
                        }.frame(height: 250)
                            .chartYScale(range: .plotDimension(startPadding: 0, endPadding: 4))
                            .chartXScale(range: .plotDimension(startPadding: 0, endPadding: CGFloat(UserData().roundAmount)))
                    } label: {
                        Text("-5 Cards")
                    }*/
                }
            }
            
            Section(header: Text("Round Results")) {
                ForEach(1..<(UserData().roundAmount+1), id: \.self) { item in
                    NavigationLink {
                        RoundSummary(roundNumber: item)
                    } label: {
                        Label("Round \(item)", systemImage: "\((UserData().roundAmount + 1) - item).square")
                    }
                }
            }
            
            Section {
                Button {
                    resetAlert.toggle()
                } label: {
                    Label("Reset Data", systemImage: "exclamationmark.triangle.fill")
                }
                .alert(isPresented: $resetAlert) {
                    Alert(title: Text("Attention"), message: Text("This will reset the data from every player.\nThis cannot be undone!"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Confirm"), action: {
                        for player in players {
                            player.points = 0
                            
                            for round in rounds {
                                viewContext.delete(round)
                            }
                            
                            do {
                                try viewContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }))
                }
                
                Button {
                    deleteAlert.toggle()
                } label: {
                    Label("Delete All Players", systemImage: "trash")
                }
                .alert(isPresented: $deleteAlert) {
                    Alert(title: Text("Attention"), message: Text("This will delete all players.\nThis cannot be undone!"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Confirm"), action: {
                        for player in players {
                            
                            for round in rounds {
                                viewContext.delete(round)
                            }
                            
                            viewContext.delete(player)
                            
                            do {
                                try viewContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }))
                }
            }
        }
        .navigationTitle("Summary")
    }
}

struct GameSummary_Previews: PreviewProvider {
    static var previews: some View {
        GameSummary()
    }
}
