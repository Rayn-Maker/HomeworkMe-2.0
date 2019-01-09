//
//  AddClassVC.swift
//  HomeworkMe 2.0
//
//  Created by Radiance Okuzor on 1/8/19.
//  Copyright © 2019 RayCo. All rights reserved.
//

import UIKit
import Firebase

class AddClassVC: UIViewController {
    
    @IBOutlet weak var listOfCollgesPicker: UIPickerView!
    @IBOutlet weak var classSrchTxt: UITextField!
    @IBOutlet weak var classSearchTableView: UITableView!
     @IBOutlet weak var schlBtn: UIButton!
    
    var inSearching = false
    
    var allColleges = [FetchObject]()
    var uniClasses = [FetchObject]()
    var uni_sub_array = [FetchObject](); var myClassesArr = [FetchObject]()
    var allClassesArr = [FetchObject](); var allClassesArrFilterd = [FetchObject]()
    var selectedClasses = [FetchObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUni()
        fetchAllClasses()
    }
    
    @IBAction func donePrsd(_ sender: Any) {
        //save classes
        if !selectedClasses.isEmpty {
            for x in 0...selectedClasses.count - 1 {
                saveClasses(classs: selectedClasses[x])
            }
            let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDel.logUser()
        } else {
            let alert = UIAlertController(title: "Missing info", message: "You must selected your classes", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func clasSrchTxt(_ sender: UITextField) {
        inSearching = true
        if sender.text! == "" {
            inSearching = false
        }
        if sender.text! == " " {
            inSearching = false
        }
        filterContentForSearchText(sender.text!)
    }
    
    @IBAction func schllBtnPrsd(_ sender: Any) {
        listOfCollgesPicker.isHidden = false
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        allClassesArrFilterd = allClassesArr.filter({( classe : FetchObject) -> Bool in
            return classe.title!.lowercased().contains(searchText.lowercased())
        })
        
        classSearchTableView.reloadData()
    }
    
    func fetchUni() {
        let ref = Database.database().reference()
        ref.child("Universities").queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
                self.uni_sub_array.removeAll()
                let universities = response.value as! [String:AnyObject]
                for (_,b) in universities {
                    var university = FetchObject()
                    if let uid = b["uid"] {
                        university.uid = uid as? String
                    }
                    if let title = b["name"] {
                        university.title = title as? String
                    }
                    if let subDict = b["Subjects"]  {
                        university.dict = subDict as? [String : AnyObject]
                        
                    }
                    self.uni_sub_array.append(university)
                }
                self.uni_sub_array.sort(by:{ $0.title! < $1.title! } )
                self.allColleges = self.uni_sub_array
                self.listOfCollgesPicker.reloadAllComponents()
            }
        })
    }
    
    func fetchAllClasses() {
        let ref = Database.database().reference()
        ref.child("Classes").queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
                print("weew")
            } else {
                // you get a dictionary. get
                self.uniClasses.removeAll()
                self.uni_sub_array.removeAll()
                let classes = response.value as! [String:AnyObject]
                for (_,b) in classes {
                    var university = FetchObject()
                    university.title = b["name"] as? String
                    university.subjectID = b["subjectID"] as? String
                    university.subName = b["subjectName"] as? String
                    university.uid = b["uid"] as? String
                    university.uniID = b["uniId"] as? String
                    university.uniName = b["uniName"] as? String
                    
                    self.uniClasses.append(university)
                }
                // after you get all the classes compare and contrast the one you have to show based on the university.
                self.fetchClassesInUni(allClasses: self.uniClasses, uid: "-LJH2y7HOmoOfNHnRxVR")
            }
        })
    }
    
    func fetchClassesInUni(allClasses:[FetchObject], uid:String) {
        let ref = Database.database().reference()
        self.allClassesArr.removeAll()
        ref.child("Universities").child(uid).child("Classes").queryOrderedByKey().observeSingleEvent(of: .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
                print("stuff is nul")
            } else {
                // you get a dictionary. get
                
                let classes = response.value as! [String:AnyObject]
                for (a,b) in classes {
                    if let index = allClasses.index(where: {$0.uid == a}) {
                        var university = FetchObject()
                        university.title = allClasses[index].title
                        university.subjectID = allClasses[index].subjectID
                        university.subName = allClasses[index].subName
                        university.uid = allClasses[index].uid
                        university.uniID = allClasses[index].uniID
                        university.uniName = allClasses[index].uniName
                        self.allClassesArr.append(university)
                    }
                }
                self.allClassesArr.sort(by:{ $0.title! < $1.title! } )
                self.classSearchTableView.reloadData()
            }
        })
        self.classSearchTableView.reloadData()
    }
 
    func saveClasses(classs:FetchObject){
        //        let cell = classRoomTableView.cellForRow(at: indexPath)
        let ref = Database.database().reference()
        let key = classs.uid
        let className = classs.title
        let uid = Auth.auth().currentUser?.uid
        let parameters: [String:String] = ["uid" : key!,
                                           "className":className ?? ""]
        let parameters2: [String:String] = ["uid" : uid!,
                                            "studentName":ProfileVC.student.fullName ?? ""]
        ref.child("Students").child(uid!).child("Classes").child(key!).updateChildValues(parameters)
        ref.child("Classes").child(key!).child("Students").child(uid!).updateChildValues(parameters2)
        
        //            devicNotes = classs.Notification_Devices
        //            if devicNotes.contains(ProfileVC.student.deviceNotificationTokern!) {
        //
        //            } else {
        //                devicNotes.append(ProfileVC.student.deviceNotificationTokern!)
        //            }
        //            ref.child("Classes").child(key!).child("Notification_Devices").setValue(devicNotes)
    }

}

extension AddClassVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if tableView == classSearchTableView {
            let cell = tableView.cellForRow(at: indexPath)
            if inSearching {
                if cell?.accessoryType != .checkmark {
                    cell?.accessoryType = .checkmark
                    allClassesArrFilterd[indexPath.row].markCell = true
                    selectedClasses.append(allClassesArrFilterd[indexPath.row])
                } else {
                    if let index = selectedClasses.index(where: {$0.uid == allClassesArrFilterd[indexPath.row].uid}) {
                        selectedClasses.remove(at: index)
                        allClassesArrFilterd[indexPath.row].markCell = false
                    }
                    cell?.accessoryType = .none
                }
            } else {
                if cell?.accessoryType != .checkmark {
                    selectedClasses.append(allClassesArr[indexPath.row])
                    allClassesArr[indexPath.row].markCell = true
                    cell?.accessoryType = .checkmark
                } else {
                    if let index = selectedClasses.index(where: {$0.uid == allClassesArr[indexPath.row].uid}) {
                        selectedClasses.remove(at: index)
                        allClassesArr[indexPath.row].markCell = false
                    }
                    cell?.accessoryType = .none
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == classSearchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "classSearch2", for: indexPath)
            if !allClassesArr.isEmpty {
                if inSearching {
                    cell.textLabel?.text = allClassesArrFilterd[indexPath.row].title
                    if let index = selectedClasses.index(where: {$0.uid == allClassesArrFilterd[indexPath.row].uid}) {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                    
                    
                } else {
                    cell.textLabel?.text = allClassesArr[indexPath.row].title
//                    if allClassesArr[indexPath.row].markCell {
//                        cell.accessoryType = .checkmark
//                    } else {
//                        cell.accessoryType = .none
//                    }
                    if let index = selectedClasses.index(where: {$0.uid == allClassesArr[indexPath.row].uid}) {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "classSearch2", for: indexPath)
            cell.textLabel!.text = myClassesArr[indexPath.row].title
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "classSearch2", for: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == classSearchTableView {
            if inSearching {
                return allClassesArrFilterd.count
            } else {
                return allClassesArr.count
            }
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        return "Select all your classes"
    }
}

extension AddClassVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allColleges.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allColleges[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        schlBtn.setTitle(allColleges[row].title, for: .normal)
        listOfCollgesPicker.isHidden = true
        fetchClassesInUni(allClasses: self.uniClasses, uid: allColleges[row].uid!)
    }
}
