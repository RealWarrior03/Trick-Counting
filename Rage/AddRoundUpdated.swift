//
//  AddRoundUpdated.swift
//  Rage
//
//  Created by Henry Krieger on 29.01.22.
//

import SwiftUI

struct AddRoundUpdated: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Players.name, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Players>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Rounds.roundNumber, ascending: true)],
        animation: .default)
    private var rounds: FetchedResults<Rounds>
    
    @State var roundNumber: Int
    @State var points: Int64 = 0
    @State var selection: String = "predict"
    
    var body: some View {
        List {
            Section(header: Text("Players")) {
                ForEach(players.indices, id: \.self) { item in
                    NavigationLink {
                        RoundForPlayerUpdated(playerIndice: item, playerData: players[item], playerName: players[item].name, roundNumber: roundNumber, state: self.selection)
                    } label: {
                        Label("\(players[item].name)", systemImage: "person")
                        HStack {
                            Spacer()
                            Image(systemName: "p.circle").foregroundColor(!rounds.filter{$0.player==players[item].name && $0.roundNumber == roundNumber && $0.setPrediction}.isEmpty ? .green : .gray)
                            Image(systemName: "checkmark.circle").foregroundColor(!rounds.filter{$0.player==players[item].name && $0.roundNumber == roundNumber && $0.setRound}.isEmpty ? .green : .gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Round \(roundNumber)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Picker("", selection: $selection) {
                    Text("Predict").tag("predict")
                    Text("Score").tag("score")
                }
            }
        }
    }
}

enum AddRoundSteps {
    case prediction
    case wonTricks
    case plusFive
    case minusFive
    case summary
}

struct RoundForPlayerUpdated: View {
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
    
    @State var roundSteps: AddRoundSteps = .prediction
    
    var playerIndice: FetchedResults<Players>.Index
    var playerData: FetchedResults<Players>.Element
    var playerName: String
    var roundNumber: Int
    var state: String
    
    @State var roundExists: Bool = true
    @State var showAdvanced: Bool = false
    @State var disableEdits: Bool = false
    
    @State var prediction: Int = 0
    @State var rightPrediction: Bool = false
    @State var plusFiveAmount: Int = 0
    @State var minusFiveAmount: Int = 0
    @State var wonAmount: Int = 0
    
    @State var roundSum: Int64 = 0
    
    var body: some View {
        VStack {
            if state == "predict" {
                if roundSteps == .prediction {
                    GeometryReader { geo in
                        VStack(alignment: .leading) {
                            Text("Trick Prediction")
                                .font(.title)
                                .bold()
                            HStack {
                                Spacer()
                                Text("\(prediction)")
                                    .font(.system(size: 100))
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                            CustomStepper(inputInt: $prediction)
                            Spacer()
                            HStack {
                                Spacer()
                                Button {
                                    for round in rounds {
                                        if round.player == self.playerName {
                                            if round.roundNumber == self.roundNumber {
                                                round.prediction = Int64(self.prediction)
                                                self.roundExists = false
                                            }
                                        }
                                    }
                                    
                                    if self.roundExists {
                                        let newRound = Rounds(context: viewContext)
                                        newRound.player = self.playerName
                                        newRound.roundNumber = Int64(self.roundNumber)
                                        newRound.prediction = Int64(self.prediction)
                                        newRound.setPrediction = true
                                    }
                                    
                                    do {
                                        try viewContext.save()
                                        presentationMode.wrappedValue.dismiss()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                } label: {
                                    /*HStack {
                                        Text("Next")
                                        Image(systemName: "chevron.right")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)*/
                                    HStack {
                                        Text("Save")
                                        Image(systemName: "checkmark")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
                            }
                        }.padding()
                    }
                }
            }
            if state == "score" {
                if roundSteps == .wonTricks {
                    GeometryReader { geo in
                        VStack(alignment: .leading) {
                            Text("Won Tricks")
                                .font(.title)
                                .bold()
                            HStack {
                                Spacer()
                                Text("\(wonAmount)")
                                    .font(.system(size: 100))
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                            CustomStepper(inputInt: $wonAmount)
                            Spacer()
                            HStack {
                                Button {
                                    roundSteps = .prediction
                                } label: {
                                    HStack {
                                        //Image(systemName: "chevron.left")
                                        Text("Prediction: \(self.prediction)")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
                                    .disabled(true)
                                Spacer()
                                Button {
                                    roundSteps = .minusFive
                                } label: {
                                    HStack {
                                        Text("Next")
                                        Image(systemName: "chevron.right")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
                            }
                        }.padding()
                    }
                }
                if roundSteps == .minusFive {
                    GeometryReader { geo in
                        VStack(alignment: .leading) {
                            Text("-5 Amount")
                                .font(.title)
                                .bold()
                            HStack {
                                Spacer()
                                Text("\(minusFiveAmount)")
                                    .font(.system(size: 100))
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                            CustomStepper(inputInt: $minusFiveAmount)
                            Spacer()
                            HStack {
                                Button {
                                    roundSteps = .wonTricks
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
                                Spacer()
                                Button {
                                    roundSteps = .plusFive
                                } label: {
                                    HStack {
                                        Text("Next")
                                        Image(systemName: "chevron.right")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
                            }
                        }.padding()
                    }
                }
                if roundSteps == .plusFive {
                    GeometryReader { geo in
                        VStack(alignment: .leading) {
                            Text("+5 Amount")
                                .font(.title)
                                .bold()
                            HStack {
                                Spacer()
                                Text("\(plusFiveAmount)")
                                    .font(.system(size: 100))
                                    .bold()
                                Spacer()
                            }
                            Spacer()
                            CustomStepper(inputInt: $plusFiveAmount)
                            Spacer()
                            HStack {
                                Button {
                                    roundSteps = .minusFive
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
                                Spacer()
                                Button {
                                    roundSteps = .summary
                                } label: {
                                    HStack {
                                        Text("Next")
                                        Image(systemName: "chevron.right")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
                            }
                        }.padding()
                    }
                }
                if roundSteps == .summary {
                    GeometryReader { geo in
                        VStack(alignment: .leading) {
                            Text("Summary")
                                .font(.title)
                                .bold()
                            ZStack {
                                RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Material.thick)
                                VStack(alignment: .leading) {
                                    Text("Won Amount").bold()
                                    Stepper("\(wonAmount)", value: $wonAmount, in: 0...10)
                                }.padding()
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Material.thick)
                                VStack(alignment: .leading) {
                                    Text("-5 Amount").bold()
                                    Stepper("\(minusFiveAmount)", value: $minusFiveAmount, in: 0...10)
                                }.padding()
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Material.thick)
                                VStack(alignment: .leading) {
                                    Text("+5 Amount").bold()
                                    Stepper("\(plusFiveAmount)", value: $plusFiveAmount, in: 0...10)
                                }.padding()
                            }
                            Spacer()
                            HStack {
                                Button {
                                    roundSteps = .plusFive
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
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
                                                players[playerIndice].points -= round.points
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
                                    HStack {
                                        Text("Save")
                                        Image(systemName: "checkmark")
                                    }.frame(width: geo.size.width*0.35, height: 50, alignment: .center)
                                }.buttonStyle(.borderedProminent)
                            }
                        }.padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if state == "predict" {
                self.roundSteps = .prediction
            } else if state == "score" {
                self.roundSteps = .wonTricks
            }
            
            for round in rounds {
                if round.player == self.playerName {
                    if round.roundNumber == self.roundNumber {
                        self.prediction = Int(round.prediction)
                        showAdvanced = round.setPrediction
                        disableEdits = round.setRound
                        self.plusFiveAmount = Int(round.plusFive)
                        self.minusFiveAmount = Int(round.minusFive)
                        self.wonAmount = Int(round.tricks)
                    }
                }
            }
        }
    }
}
