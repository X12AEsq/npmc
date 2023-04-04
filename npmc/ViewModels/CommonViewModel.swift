//
//  CommonViewModel.swift
//  npmc
//
//  Created by Morris Albers on 4/3/23.
//

import Foundation
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import SwiftUI

class CommonViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    let auth = Auth.auth()
    
    @Published var taskCompleted = false
    
    @Published var userSession: FirebaseAuth.User?
    
    @Published var appStatus:String = ""
    
    init() {
        userSession = auth.currentUser
        appStatus = "npmb v1.07\n"
        appStatus += "EditRepresentationView needs CRUD logic and note and appearance UI\n"
    }
    
    // MARK: Master Work Area
    
    @Published var wm:WorkingModel = WorkingModel()
    
    // MARK: Login Functions
    
    @MainActor
    func createUser(withEmail email: String, password: String) async {
        do {
            let authDataResult = try await auth.createUser(withEmail: email, password: password)
            userSession = authDataResult.user
            print("Debug: User created successfully")
        } catch {
            print("Debug: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func signIn(withEmail email: String, password: String) async -> Bool {
        do {
            let authDataResult = try await auth.signIn(withEmail: email, password: password)
            userSession = authDataResult.user
            print("Debug: User signed in successfully")
//            self.clientSubscribe()
//            self.causeSubscribe()
//            self.noteSubscribe()
//            self.appearanceSubscribe()
//            self.representationSubscribe()
            return true
        } catch {
            print("Debug: Failed to sign in user with error \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    func signout() -> Bool {
        do {
            try auth.signOut()
            userSession = nil
            print("Debug: User signed out successfully")
            return true
        } catch {
            print("Debug: Failed to sign out user with error \(error.localizedDescription)")
            return false
        }
    }

}
