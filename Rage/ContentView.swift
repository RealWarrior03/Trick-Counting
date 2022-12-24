//
//  ContentView.swift
//  Rage
//
//  Created by Henry Krieger on 10.01.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Players.name, ascending: true)],
        animation: .default)
    private var players: FetchedResults<Players>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Rounds.roundNumber, ascending: true)],
        animation: .default)
    private var rounds: FetchedResults<Rounds>
    
    @State var showSettings: Bool = false
    @ObservedObject var userData = UserData()

    var body: some View {
        NavigationView {
            List {
                if userData.mode == "swiftui" {
                    Section(header: Text("Game")) {
                        ForEach(1..<(UserData().roundAmount+1), id: \.self) { item in
                            NavigationLink {
                                AddRound(roundNumber: item)
                            } label: {
                                Label("Round \(item)", systemImage: "\((UserData().roundAmount+1)-item).square")
                            }
                        }
                    }
                } else if userData.mode == "enlarged" {
                    Section(header: Text("Game")) {
                        ForEach(1..<(UserData().roundAmount+1), id: \.self) { item in
                            NavigationLink {
                                AddRoundUpdated(roundNumber: item)
                            } label: {
                                Label("Round \(item)", systemImage: "\((UserData().roundAmount+1)-item).square")
                                #warning("Future Update: show if a round is finished or not")
                            }
                        }
                    }
                }
                
                Section(header: Text("Result")) {
                    NavigationLink {
                        GameSummary()
                    } label: {
                        Label("Summary", systemImage: "sum")
                    }
                }
            }
            .navigationTitle("Trick Counting")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
            }
        }
    }
}

class UserData: ObservableObject {
    @Published var roundAmount: Int {
        didSet {
            UserDefaults.standard.set(roundAmount, forKey: "roundAmount")
        }
    }
    
    @Published var mode: String {
        didSet {
            UserDefaults.standard.set(mode, forKey: "mode")
        }
    }
    
    init() {
        self.roundAmount = UserDefaults.standard.object(forKey: "roundAmount") as? Int ?? 10
        self.mode = UserDefaults.standard.object(forKey: "mode") as? String ?? "enlarged"
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
