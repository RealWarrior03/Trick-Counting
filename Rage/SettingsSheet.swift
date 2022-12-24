//
//  SettingsSheet.swift
//  Rage
//
//  Created by Henry Krieger on 11.01.22.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var userData = UserData()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Players.name, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Players>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Rounds.player, ascending: true)],
        animation: .default)
    private var rounds: FetchedResults<Rounds>
    
    @State var resetAlert: Bool = false
    @State var deleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        AddPlayers()
                    } label: {
                        Label("Set Players", systemImage: "person.2.circle")
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Label("Rounds:", systemImage: "number.circle")
                            Spacer()
                            Text("\(userData.roundAmount)")
                        }
                        //Label("Rounds: \(userData.roundAmount)", systemImage: "number.circle")
                        Stepper("", value: $userData.roundAmount, in: 0...20)
                    }
                    
                    VStack(alignment: .leading) {
                        Label("Mode:", systemImage: "iphone.circle")
                        Picker("", selection: $userData.mode) {
                            Text("SwiftUI").tag("swiftui")
                            Text("Enlarged").tag("enlarged")
                        }.pickerStyle(.segmented)
                    }
                } header: {
                    Text("Setup")
                } footer: {
                    HStack {
                        Spacer()
                        Text("Please restart the app for this to apply.")
                    }
                }
                
                /*
                Section {
                    NavigationLink {
                        Text("soon")
                    } label: {
                        Label("App Icon", systemImage: "app.badge")
                    }
                    
                    NavigationLink {
                        Text("soon")
                    } label: {
                        Label("Accent Color", systemImage: "eyedropper")
                    }
                }
                 */
                
                Section(header: Text("Player Data")) {
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
                
                Section(header: Text("Support")) {
                    NavigationLink {
                        TipJar()
                    } label: {
                        Label("Tip Jar", systemImage: "creditcard")
                    }.disabled(true)
                    
                    /*Link(destination: URL(string: "https://buymeacoffee.com/hkrieger")!) {
                        Label("Buy Me a Coffee", systemImage: "gift")
                    }*/
                    
                    Link(destination: URL(string: "https://twitter.com/_hkrieger_")!) {
                        Label("Twitter", image: "twitter")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheet()
            .previewDevice("iPhone 13 Pro")
    }
}
