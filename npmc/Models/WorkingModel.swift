//
//  WorkingModel.swift
//  npmc
//
//  Created by Morris Albers on 4/3/23.
//

import Foundation
import Foundation
import FirebaseFirestore

class WorkingModel: ObservableObject {
    var cli:ClientModel = ClientModel()
    var cau:CauseModel = CauseModel()
    var rep:RepresentationModel = RepresentationModel()
    
    init() {
        self.cli = ClientModel()
        self.cau = CauseModel()
        self.rep = RepresentationModel()
    }
    
    init(Test:Int) {
        self.cli = ClientModel(Test: Test)
        self.cau = CauseModel(Test: Test)
        self.rep = RepresentationModel(Test: Test)
    }
}
