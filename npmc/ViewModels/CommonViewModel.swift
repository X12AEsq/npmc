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
    
    @Published var clients = [ClientModel]()
    @Published var causes = [CauseModel]()
    @Published var representations = [RepresentationModel]()
    
    var clientListener: ListenerRegistration?
    var causeListener: ListenerRegistration?
    var representationListener: ListenerRegistration?
    
    init() {
        userSession = auth.currentUser
        appStatus = "npmb v1.07\n"
        appStatus += "EditRepresentationView needs CRUD logic and note and appearance UI\n"
    }
    
    // MARK: Master Work Area
    
    @Published var wm:WorkingModel = WorkingModel()
    
    func assembleWorkArea(repid:Int) -> FunctionReturn {
        var fr:FunctionReturn = FunctionReturn(status: .empty, message: "", additional: 0)
        self.wm = WorkingModel()
        let workRepresentations:[RepresentationModel] = representations.filter { $0.internalID == repid }
        if workRepresentations.count == 0 {
            fr.message = String(repid) + " Not found"
            return fr
        }
        if workRepresentations.count > 1 {
            fr.status = .IOError
            fr.message = "Multiple copies of " + String(repid)
            return fr
        }
        wm.rep = workRepresentations[0]
        
        let workClients:[ClientModel] = clients.filter  { $0.internalID == wm.rep.involvedClient }
        if workClients.count == 1 {
            wm.cli = workClients[0]
        }
        
        let workCauses:[CauseModel] = causes.filter  { $0.internalID == wm.rep.involvedCause }
        if workCauses.count == 1 {
            wm.cau = workCauses[0]
        }
        
        return fr
    }
    
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
            self.clientSubscribe()
            self.causeSubscribe()
//            self.noteSubscribe()
//            self.appearanceSubscribe()
            self.representationSubscribe()
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

    // MARK: Client Functions
    
    func clientSubscribe() {
        if clientListener == nil {
            clientListener = db.collection("clients").addSnapshotListener
            { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    return
                }
                self.clients = []
                _ = documents.map { queryDocumentSnapshot -> Void in
                    let data = queryDocumentSnapshot.data()
                    
                    let internalID = data["internalID"] as? Int ?? 0
                    let lastname = data["LastName"] as? String ?? ""
                    let firstName = data["FirstName"] as? String ?? ""
                    let middleName = data["MiddleName"] as? String ?? ""
                    let suffix = data["Suffix"] as? String ?? ""
                    let street = data["Street"] as? String ?? ""
                    let city = data["City"] as? String ?? ""
                    let state = data["State"] as? String ?? ""
                    let zip = data["Zip"] as? String ?? ""
                    let area = data["AreaCode"] as? String ?? ""
                    let exchange = data["Exchange"] as? String ?? ""
                    let number = data["TelNumber"] as? String ?? ""
                    let note = data["Note"] as? String ?? ""
                    let jail = data["Jail"] as? String ?? ""
                    let representation = data["Representation"] as? [Int] ?? []
                    let cl:ClientModel = ClientModel(fsid: queryDocumentSnapshot.documentID, intid:internalID, lastname:lastname, firstname: firstName, middlename: middleName, suffix: suffix, street: street, city: city, state: state, zip: zip, phone: FormattingService.fmtphone(area: area, exchange: exchange, number: number), note: note, jail: jail, representation: representation)
                    self.clients.append(cl)
//                    if cl.internalID == 419 {
//                        let debugMsg:String = Date().formatted(Date.FormatStyle().secondFraction(.milliseconds(4)))
//                        print("clientSubscribe " + String(cl.internalID) + "; " + cl.formattedName + "; " + String(self.clients.count) + "; " + debugMsg)
//                    }
                    return
                }
            }
        }
    }
    
    
    func nextClientID() -> Int {
        // find client with greatest internal id
        let greatestclient = clients.max {a, b in a.internalID < b.internalID }
        // find value of greatest internal id
        if greatestclient != nil {
            let gc = greatestclient!
            let i:Int = Int(gc.internalID)
            return i + 1
        } else {
            return 1
        }
    }
    
    public static func clientAny(internalID:Int, lastName:String, firstName:String, middleName:String, suffix:String, street:String, city:String, state:String, zip:String, areacode:String, exchange:String, telnumber:String, note:String, jail:String, representation:[Int]) -> [String:Any] {
        let newClient:[String:Any] = ["internalID":internalID,
                                      "LastName":lastName,
                                      "FirstName":firstName,
                                      "MiddleName":middleName,
                                      "Suffix":suffix,
                                      "Street":street,
                                      "City":city,
                                      "State":state,
                                      "Zip":zip,
                                      "AreaCode":areacode,
                                      "Exchange":exchange,
                                      "TelNumber":telnumber,
                                      "Note":note,
                                      "Jail":jail,
                                      "Representation":representation] as [String : Any]
        return newClient
    }
    
    @MainActor
    func addClient(lastName:String, firstName:String, middleName:String, suffix:String, street:String, city:String, state:String, zip:String, areacode:String, exchange:String, telnumber:String, note:String, jail:String) async -> FunctionReturn {
        
        var rtn:FunctionReturn = FunctionReturn(status: .empty, message: "", additional: 0)
        
        let intID = nextClientID()
        let uc:[String:Any] = CommonViewModel.clientAny(internalID: intID, lastName: lastName, firstName: firstName, middleName: middleName, suffix: suffix, street: street, city: city, state: state, zip: zip, areacode: areacode, exchange: exchange, telnumber: telnumber, note: note, jail: jail, representation: [])

        let reprRef = db.collection("clients")
        
        taskCompleted = false
        
        do {
            try await reprRef.document().setData(uc)
            rtn.status = .successful
            rtn.message = ""
            return rtn
        }
        catch {
            rtn.status = .IOError
            rtn.message = "Add Client failed: " + error.localizedDescription
            return rtn
        }
    }

    @MainActor
    func updateClient(clientID:String, internalID:Int, lastName:String, firstName:String, middleName:String, suffix:String, street:String, city:String, state:String, zip:String, areacode:String, exchange:String, telnumber:String, note:String, jail:String, representation:[Int]) async -> FunctionReturn {
        
        var rtn:FunctionReturn = FunctionReturn(status: .empty, message: "", additional: 0)
        
        let clientData:[String:Any] = CommonViewModel.clientAny(internalID:internalID, lastName: lastName, firstName: firstName, middleName: middleName, suffix: suffix, street: street, city: city, state: state, zip: zip, areacode: areacode, exchange: exchange, telnumber: telnumber, note: note, jail: jail, representation:representation)
        
        do {
            try await db.collection("clients").document(clientID).updateData(clientData)
            rtn.status = .successful
            rtn.message = ""
            rtn.additional = internalID
            return rtn
        } catch {
            rtn.status = .IOError
            rtn.message = "Debug updateClient failed " + error.localizedDescription
            return rtn
        }
    }

    // MARK: Cause Functions
    
    func causeSubscribe() {
        if causeListener == nil {
            causeListener = db.collection("causes").addSnapshotListener
            { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    return
                }
                self.causes = []
                _ = documents.map { queryDocumentSnapshot -> Void in
                    let data = queryDocumentSnapshot.data()
                    
                    let internalID = data["internalID"] as? Int ?? 0
                    let causeNo = data["CauseNo"] as? String ?? ""
                    let involvedClient = data["InvolvedClient"] as? Int ?? 0
                    let representations = data["Representations"] as? [Int] ?? []
                    let level = data["Level"] as? String ?? ""
                    let court = data["Court"] as? String ?? ""
                    let originalcharge = data["OriginalCharge"] as? String ?? ""
                    let causeType = data["CauseType"] as? String ?? ""
                    
                    let ca:CauseModel = CauseModel(fsid: queryDocumentSnapshot.documentID, client: involvedClient, causeno: causeNo, representations: representations, involvedClient: involvedClient, level: level, court: court, originalcharge: originalcharge, causetype: causeType, intid: internalID)
                    
                    self.causes.append(ca)
//                    if ca.internalID == 554 {
//                        let debugMsg:String = Date().formatted(Date.FormatStyle().secondFraction(.milliseconds(4)))
//                        print("causeSubscribe " + String(ca.internalID) + "; " + ca.causeNo + "; " + String(self.causes.count) + "; " + debugMsg)
//                    }
                    return
                }
            }
        }
    }
    
    // MARK: Representation Functions

    func representationSubscribe() {
        if representationListener == nil {
            representationListener = db.collection("representations").addSnapshotListener
            { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    return
                }
                self.representations = []
                _ = documents.map { queryDocumentSnapshot -> Void in
                    let data = queryDocumentSnapshot.data()
                    
                    let internalID = data["internalID"] as? Int ?? 0
                    let involvedClient = data["InvolvedClient"] as? Int ?? 0
                    let involvedCause = data["InvolvedCause"] as? Int ?? 0
                    let involvedAppearances = data["InvolvedAppearances"] as? [Int] ?? []
                    let involvedNotes = data["InvolvedNotes"] as? [Int] ?? []
                    let active = data["Active"] as? Bool ?? false               // Open,Closed
                    let assignedDate = data["AssignedDate"] as? String ?? ""
                    let dispositionDate = data["DispositionDate"] as? String ?? ""
                    let dispositionType = data["DispositionType"] as? String ?? ""
                    let dispositionAction = data["DispositionAction"] as? String ?? ""
                    let primaryCategory = data["PrimaryCategory"] as? String ?? ""

                    let rm:RepresentationModel = RepresentationModel(fsid: queryDocumentSnapshot.documentID, intid:internalID, client:involvedClient, cause:involvedCause, appearances:involvedAppearances, notes: involvedNotes, active:active, assigneddate:assignedDate, dispositiondate:dispositionDate, dispositionaction:dispositionAction, dispositiontype:dispositionType, primarycategory: primaryCategory)

                    self.representations.append(rm)
//                    let debugMsg:String = Date().formatted(Date.FormatStyle().secondFraction(.milliseconds(4)))
//                    if rm.internalID == 254 {
//                        print("representationsubscribe " + String(rm.internalID) + "; " + rm.primaryCategory + "; " + rm.involvedAppearances.description + "; " + String(self.representations.count) + "; " + debugMsg)
//                    }
                    return
                }
            }
        }
    }

}
