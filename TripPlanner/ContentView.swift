//  ContentView.swift
//  TripPlanner
//
//
//  Created by Dmytro Medynskyi on 29.10.2023.
//

import SwiftUI
import ComposableArchitecture

struct ListReducer: Reducer {
    struct State: Equatable {
        var rows: IdentifiedArrayOf<DetailReducer.State>
        var showingElement: Identified<DetailReducer.State.ID, DetailReducer.State?>?
    }
    public enum Action: Equatable {
        case select(selection: Int?)
        case detailAction(DetailReducer.Action)
    }
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .select(selection: let .some(id)):
                state.showingElement = .some(.init(state.rows[id], id: id))
            case .select(selection: .none):
                print("none")
            case .detailAction(let action):
                switch action {
                case .updateName(let name):
                    if let id = state.showingElement?.id {
                        state.rows[id: id]?.name = name
                    }
                }
            default:
                break
            }
            return .none
        }
//        .forEach(\.rows, action: /Action.detailAction) {
//            DetailReducer()
//        }
        .ifLet(\.showingElement, action: /Action.detailAction) {
            EmptyReducer()
                .ifLet(\.value, action: .self) {
                    DetailReducer()
                }
        }
    }
}

struct ContentView: View {
    let store: Store<ListReducer.State, ListReducer.Action>
    init() {
        let array = IdentifiedArray(uniqueElements: Array(0...10).map{DetailReducer.State(id: $0, name: "Detail: \($0)")})
        self.store = Store.init(initialState: ListReducer.State.init(rows: array), reducer: {
            ListReducer()
        })
    }
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            NavigationStack {
                ScrollView {
                    LazyVStack {
                        ForEach(viewStore.rows, id: \.id) { row in
                            Text("\(row.name))")
                                .onTapGesture {
                                    viewStore.send(.select(selection: row.id))
                                }
                        }
                    }
                }
                .navigationDestination(isPresented: viewStore.binding(get: {$0.showingElement != nil}, send: {_ in .select(selection: nil)}), destination: {
                    IfLetStore(store.scope(state: \.showingElement?.value, action: {.detailAction($0)})) { store in
                        DetailView(store: store)
                    }
                })
            }
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
