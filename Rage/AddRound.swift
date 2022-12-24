//
//  AddRound.swift
//  Rage
//
//  Created by Henry Krieger on 10.01.22.
//

import SwiftUI

struct AddRound: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Players.name, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Players>
    
    @State var roundNumber: Int
    @State var points: Int64 = 0
    
    var body: some View {
        List {
            Section(header: Text("Players")) {
                ForEach(players.indices, id: \.self) { item in
                    NavigationLink {
                        roundForPlayer(playerIndice: item, playerData: players[item], playerName: players[item].name, roundNumber: roundNumber)
                    } label: {
                        Label("\(players[item].name)", systemImage: "person")
                    }
                }
            }
        }
        .navigationTitle("Round \(roundNumber)")
    }
}

struct roundForPlayer: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Players.name, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Players>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Rounds.player, ascending: true)],
        animation: .default)
    private var rounds: FetchedResults<Rounds>
    
    var playerIndice: FetchedResults<Players>.Index
    var playerData: FetchedResults<Players>.Element
    var playerName: String
    var roundNumber: Int
    
    @State var showAdvanced: Bool = false
    @State var disableEdits: Bool = false
    
    @State var prediction: Int = 0
    @State var rightPrediction: Bool = false
    @State var plusFiveAmount: Int = 0
    @State var minusFiveAmount: Int = 0
    @State var wonAmount: Int = 0
    
    @State var roundSum: Int64 = 0
    
    var body: some View {
        List {
            if disableEdits {
                Text("Round \(roundNumber) for \(playerName) has been saved")
            } else {
                Section(header: Text("Trick Prediction")) {
                    Stepper("\(prediction)", value: $prediction, in: 0...10).disabled(showAdvanced)
                        .font(.system(size: 25))
                }
                
                if showAdvanced {
                    Section(header: Text("Won Tricks")) {
                        Stepper("\(wonAmount)", value: $wonAmount, in: 0...10)
                    }.disabled(disableEdits)
                    
                    Section(header: Text("Amount of Tricks")) {
                        //Toggle("Correctly Predicted", isOn: $rightPrediction)
                        HStack {
                            Text("Correctly Predicted")
                            Spacer()
                            Circle()
                                .frame(width: 25, height: 25, alignment: .center)
                                .foregroundColor(self.prediction == self.wonAmount ? .green : .red)
                        }
                    }.disabled(disableEdits)
                    
                    Section(header: Text("+5 Cards")) {
                        Stepper("\(plusFiveAmount)", value: $plusFiveAmount, in: 0...5)
                    }.disabled(disableEdits)
                    
                    Section(header: Text("-5 Cards")) {
                        Stepper("\(minusFiveAmount)", value: $minusFiveAmount, in: 0...5)
                    }.disabled(disableEdits)
                }
            }
        }
        .onAppear {
            for round in rounds {
                if round.player == self.playerName {
                    if round.roundNumber == self.roundNumber {
                        self.prediction = Int(round.prediction)
                        showAdvanced = round.setPrediction
                        disableEdits = round.setRound
                    }
                }
            }
        }
        .navigationTitle("\(playerName) - Round \(roundNumber)")
        .overlay {
            if !self.disableEdits {
                if self.showAdvanced {
                    HStack {
                        VStack {
                            Spacer()
                            Button {
                                if wonAmount == prediction {
                                    roundSum += 10
                                } else {
                                    roundSum -= 5
                                }
                                roundSum += Int64(plusFiveAmount*5)
                                roundSum -= Int64(minusFiveAmount*5)
                                roundSum += Int64(wonAmount)
                                
                                for round in rounds {
                                    if round.player == self.playerName {
                                        if round.roundNumber == self.roundNumber {
                                            round.plusFive = Int64(self.plusFiveAmount)
                                            round.minusFive = Int64(self.minusFiveAmount)
                                            round.prediction = Int64(self.prediction)
                                            round.tricks = Int64(self.wonAmount)
                                            round.points = roundSum
                                            round.setRound = true
                                        }
                                    }
                                }
                                
                                players[playerIndice].points += roundSum
                                
                                do {
                                    try viewContext.save()
                                    presentationMode.wrappedValue.dismiss()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                Label("Save Round \(roundNumber) for \(playerName)", systemImage: "plus")
                                    .imageScale(.large)
                            }.buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    HStack {
                        VStack {
                            Spacer()
                            Button {
                                let newRound = Rounds(context: viewContext)
                                newRound.player = self.playerName
                                newRound.roundNumber = Int64(self.roundNumber)
                                newRound.prediction = Int64(self.prediction)
                                newRound.setPrediction = true
                                
                                do {
                                    try viewContext.save()
                                    presentationMode.wrappedValue.dismiss()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                Label("Save Prediction", systemImage: "plus.circle")
                            }.buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
    }
}
