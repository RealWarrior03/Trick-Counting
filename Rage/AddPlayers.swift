//
//  AddPlayers.swift
//  Rage
//
//  Created by Henry Krieger on 10.01.22.
//

import SwiftUI

struct AddPlayers: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Players.name, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Players>
    
    @State var playerName: String = ""
    
    private enum Field: Int, Hashable {
        case name
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        List {
            ForEach(players, id: \.self) { player in
                Text("\(player.name)")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    viewContext.delete(players[index])
                }
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            HStack {
                TextField("Name of Player", text: $playerName).focused($focusedField, equals: .name)
                    .onSubmit {
                        let newPlayer = Players(context: viewContext)
                        newPlayer.name = self.playerName
                        newPlayer.points = 0
                        
                        do {
                            try viewContext.save()
                            playerName = ""
                        } catch {
                            print(error.localizedDescription)
                        }
                        focusedField = .name
                    }
                Spacer()
                Button {
                    let newPlayer = Players(context: viewContext)
                    newPlayer.name = self.playerName
                    newPlayer.points = 0
                    
                    let newRound = Rounds(context: viewContext)
                    newRound.player = self.playerName
                    newRound.roundNumber = 0
                    newRound.prediction = 0
                    newRound.setPrediction = true
                    newRound.plusFive = 0
                    newRound.minusFive = 0
                    newRound.prediction = 0
                    newRound.tricks = 0
                    newRound.points = 0
                    newRound.setRound = true
                    
                    do {
                        try viewContext.save()
                        playerName = ""
                    } catch {
                        print(error.localizedDescription)
                    }
                    focusedField = .name
                } label: {
                    Image(systemName: "plus")
                }.buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Players")
    }
}

struct AddPlayers_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayers()
    }
}
