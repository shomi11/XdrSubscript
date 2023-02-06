//
//  HistoryView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 3.2.23..
//

import SwiftUI
import CoreData

struct HistoryView: View {
    
    private enum DeleteSubAlert {
        case deleteSub(name: String)
        case deleteAll
        
        var title: String {
            switch self {
            case .deleteAll:
                return "Delete All Subscriptions from history?"
            case .deleteSub(let name):
                return "Delete \(name)?"
            }
        }
    }
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var appState: AppState
    @State private var showDeleteAlert: Bool = false
    @State private var deleteAlertType: DeleteSubAlert = .deleteAll
    @State private var selectedSubToDelete: Subscription?
    
    var body: some View {
        NavigationStack {
            Group {
                if appState.subscriptions.filter({$0.movedToHistory}).isEmpty == false && appState.loadingState != .loading {
                    List(appState.subscriptions.filter({$0.movedToHistory})) { sub in
                        Section {
                            cellForSub(sub: sub)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button {
                                        selectedSubToDelete = sub
                                        deleteAlertType = .deleteSub(name: sub.name)
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                    Button {
                                        appState.objectWillChange.send()
                                        sub.movedToHistory = false
                                        do {
                                            try moc.save()
                                        } catch {
                                            print(error)
                                        }
                                    } label: {
                                        Label("Move to active", systemImage: "folder")
                                    }
                                    .tint(.yellow)
                                }
                        } header: {
                            Text("Subscriptions".uppercased())
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundColor(.primary)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background {
                        BackgroundView()
                    }
                } else if appState.loadingState == .loading {
                    SpinnerView()
                        .tint(.indigo)
                } else {
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120, alignment: .center)
                        Text("Nothing in history yet.")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        Text("You can move your subscriptions to history from subscription details screen.")
                            .font(.body14)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("History")
            .toolbar {
                if appState.subscriptions.filter({$0.movedToHistory}).isEmpty == false {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            deleteAlertType = .deleteAll
                            showDeleteAlert.toggle()
                        } label: {
                            Label("Delete all", systemImage: "trash")
                        }
                    }
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(title: Text(deleteAlertType.title), message: Text("Are you sure?"), primaryButton: .cancel({
                    selectedSubToDelete = nil
                }), secondaryButton: .default(Text("Delete"), action: {
                    switch deleteAlertType {
                    case .deleteAll:
                        Task {
                            await deleteAll()
                        }
                    case .deleteSub:
                        deleteSubscription()
                    }
                }))
            }
        }
    }
    
    private func deleteAll() async {
        moc.performAndWait {
            for sub in appState.subscriptions.filter({$0.movedToHistory == true}) {
                moc.delete(sub)
            }
            appState.objectWillChange.send()
            appState.subscriptions.removeAll()
            DispatchQueue.main.async {
                do {
                    try moc.save()
                }
                catch {
                    print("==== cant delete object")
                }
            }
        }
    }
    
    private func deleteSubscription() {
        if let id = selectedSubToDelete?.objectID {
            let object = moc.object(with: id)
            moc.delete(object)
            
            appState.objectWillChange.send()
            if let index = appState.subscriptions.firstIndex(where: {$0.objectID == id}) {
                appState.subscriptions.remove(at: index)
            }
            DispatchQueue.main.async {
                do {
                    try moc.save()
                }
                catch {
                    print("==== cant delete object")
                }
            }
        }
    }
    
    func cellForSub(sub: Subscription) -> some View {
        HStack(alignment: .top, spacing: 16) {
            if let url = URL(string: "https://logo.clearbit.com/\(sub.imageUrl)") {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    if let letter = sub.name.first {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(Color.blue.opacity(0.4))
                                .frame(width: 50, height: 50, alignment: .center)
                            Text(String(letter))
                                .font(.title2)
                                .bold()
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    Text("Was Subscribed to:")
                        .foregroundColor(.secondary)
                        .font(.body15)
                    Spacer()
                    Text(sub.name)
                        .fontWeight(.medium)
                        .font(.body15)
                        .foregroundColor(.primary.opacity(0.7))
                }
                HStack(alignment: .bottom) {
                    Text("Start date:")
                        .font(.body14)
                        .foregroundColor(.secondary)
                        .foregroundColor(.primary.opacity(0.7))
                    Spacer()
                    Text(DateFormatter.localizedString(from: sub.startDate, dateStyle: .medium, timeStyle: .none))
                        .fontWeight(.medium)
                        .font(.body14)
                        .foregroundColor(.primary.opacity(0.7))
                }
                HStack(alignment: .bottom) {
                    Text("Moved to history:")
                        .font(.body14)
                        .foregroundColor(.secondary)
                        .foregroundColor(.primary.opacity(0.7))
                    Spacer()
                    Text(DateFormatter.localizedString(from: sub.dateMovedToHistory, dateStyle: .medium, timeStyle: .none))
                        .fontWeight(.medium)
                        .font(.body14)
                        .foregroundColor(.primary.opacity(0.7))
                }
                HStack(alignment: .bottom) {
                    Text("Total spent:")
                        .font(.body14)
                        .foregroundColor(.secondary)
                        .foregroundColor(.primary.opacity(0.7))
                    Spacer()
                    Text(sub.totalSpentHistory.formatted(.currency(code: appState.selectedCurrency)))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .font(.body14)
                }
            }
        }
        .padding()
        .background(Color.systemBackgroundColor.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
