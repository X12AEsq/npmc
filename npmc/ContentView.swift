//
//  ContentView.swift
//  npmc
//
//  Created by Morris Albers on 4/3/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@available(iOS 15.0, *)
struct ContentView: View {
    @State private var showingEditVehicleView = false
    
    @EnvironmentObject var CVModel:CommonViewModel
 
//    @FirestoreQuery(collectionPath: "vehicles", predicates: []) var vehicles: [Vehicle]
    
//    @Binding var loggedIn: Bool

    var body: some View {
        Group {
            if CVModel.userSession != nil {
                MainInterfaceView()
            } else {
                LoginView()
            }
        }
        .onAppear {
//            CVModel.clientSubscribe()
//            CVModel.causeSubscribe()
//            CVModel.representationSubscribe()
//            CVModel.appearanceSubscribe()
//            CVModel.noteSubscribe()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
