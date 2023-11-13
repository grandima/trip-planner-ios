//
//  DetailView.swift
//  TripPlanner
//
//  Created by Dmytro Medynskyi on 31.10.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct DetailReducer: Reducer {
    struct State: Equatable, Identifiable {
        let id: Int
        var name: String
    }
    enum Action: Equatable {
        case updateName(String)
    }
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateName(let string):
                state.name = string
                return .none
            }
        }
    }
    
}

struct DetailView: View {
    let store: Store<DetailReducer.State, DetailReducer.Action>
    
    init(store: Store<DetailReducer.State, DetailReducer.Action>) {
        self.store = store
    }
    var body: some View {
        WithViewStore(store, observe: {$0}) { viewStore in
            Text(viewStore.state.name)
            TextField.init("aaa", text: viewStore.binding(get: \.name, send: {DetailReducer.Action.updateName($0)}))
        }
    }
}
