//
//  MainInterfaceView.swift
//  ah2404
//
//  Created by Morris Albers on 2/20/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct MainInterfaceView: View {
    
    enum Route: Hashable {
        case causes
        case clients
    }

    @State private var showingEditVehicleView = false
//    @State private var presentedViews:[String] = ["MainInterfaceView"]
    
    @EnvironmentObject var CVModel:CommonViewModel
    
//    @FirestoreQuery(collectionPath: "vehicles", predicates: []) var vehicles: [Vehicle]

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.5)
            VStack {
                Button {
                    _ = CVModel.signout()
                } label: {
                    Text("sign out")
                        .padding(10)
//                        .foregroundColor(.white)
//                        .background(.white.opacity(0.3))
                        .clipShape(Capsule())
                }
                Text(CVModel.appStatus)
                NavigationStack {
                    VStack(alignment: .leading) {
                        NavigationLink("Clients") {
                            SelectClient(option: 1)
                        }
                        .font(.title)
                        .padding(.bottom, 10.0)
                        NavigationLink("Causes") {
                            SelectCause(option: 1)
                        }
                        .font(.title)
                        .padding(.bottom, 10.0)
//                        NavigationLink("Representations") {
//                            SelectRepresentation()
//                        }
//                        .font(.title)
                        Spacer()
                    }
                    .padding(.bottom, 10.0)
                    
                    Spacer()
                    Text("SelectionOptions")
                        .font(.largeTitle)
                        .foregroundColor(.primary)

                        .navigationTitle("Albers Law Practice")
                }
                
                Spacer()
                Button {
                    CVModel.clientSubscribe()
                    CVModel.clientRefresh()
                    CVModel.causeSubscribe()
                    CVModel.causeRefresh()
                } label: {
                    Text("refresh")
                        .padding(10)
//                        .foregroundColor(.white)
//                        .background(.white.opacity(0.3))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

//
//struct MainInterfaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainInterfaceView()
//    }
//}
