//
//  ProfileVC.swift
//  HomeworkMe 2.0
//
//  Created by Radiance Okuzor on 1/5/19.
//  Copyright © 2019 RayCo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Stripe
import GoogleSignIn
import GooglePlaces
import UserNotifications
import paper_onboarding
import Alamofire

class ProfileVC: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var bioText: UITextView!
    @IBOutlet weak var goLiveSwitch: UISwitch!
    @IBOutlet weak var goLiveLable: UILabel!
    @IBOutlet weak var myClassesTableView: UITableView!
    @IBOutlet weak var myLocationsTableView: UITableView!
    @IBOutlet weak var myPostsTableView: UITableView!
    @IBOutlet weak var locationsSearchTableView: UITableView!
    @IBOutlet weak var classSearchTableView: UITableView!
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var editPicBtn: UIButton!
    @IBOutlet weak var addClassBtn: UIButton!
    @IBOutlet weak var addPaymentBtn: UIButton!
    @IBOutlet weak var addLoctnBtn: UIButton!
    @IBOutlet weak var savePicPrsd: UIButton!
    @IBOutlet weak var cancelSave: UIButton!
    @IBOutlet weak var listOfCollgesPicker: UIPickerView!
    
    @IBOutlet weak var addClassView: UIView!
    @IBOutlet weak var schlBtn: UIButton!
    @IBOutlet weak var classSrchTxt: UITextField!
    
    @IBOutlet weak var addLoctnsView: UIView!
    
    var handle2: DatabaseHandle?
    let picker = UIImagePickerController()
    var userStorage: StorageReference!
    var functions = CommonFunctions()
    var ref: DatabaseReference!
    static var student = Student()
    var isMenuHidden = true
    var callSavePictr = false
    var inSearching = false
    var place = Place()
    
    var devicNotes = [String]()
    var myPostArr = [Post]()
    var uniClasses = [FetchObject]()
    var allColleges = [FetchObject]()
    var uni_sub_array = [FetchObject](); var myClassesArr = [FetchObject]()
    var allClassesArr = [FetchObject](); var allClassesArrFilterd = [FetchObject]()
    
    var placeArr = [Place](); var placeesDict = [String:[String]]()
    var selectedClasses = [FetchObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storage = Storage.storage().reference(forURL: "gs://hmwrkme.appspot.com")
        userStorage = storage.child("Students")
        picker.delegate = self
        
        dismissKeyboard()
        editImage(image: profilePic)
        
        fetchStudentInfo()
        fetchUni()
        fetchAllClasses()
    }
    
    @IBAction func categoryPrsd(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            myClassesTableView.isHidden = false
            myLocationsTableView.isHidden = true
            myPostsTableView.isHidden = true
        }
        if sender.selectedSegmentIndex == 1 {
            myClassesTableView.isHidden = true
            myLocationsTableView.isHidden = false
            myPostsTableView.isHidden = true
        }
        if sender.selectedSegmentIndex == 2 {
            myClassesTableView.isHidden = true
            myLocationsTableView.isHidden = true
            myPostsTableView.isHidden = false
        }
    }
    
    @IBAction func goLivePrsed(_ sender: Any) {
        if goLiveSwitch.isOn {
            goLiveLable.text = "I'm Live"
            let par = ["status": "live"] as [String: Any]
            
            
            ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").updateChildValues(par) { (err, resp) in
                if err != nil {
                    
                }
            }
        } else {
            goLiveLable.text = "Go Live!!!"
            let par = ["status": "off"] as [String: Any]
            
            
            ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").updateChildValues(par) { (err, resp) in
                if err != nil {
                    
                }
            }
        }
    }
    
    @IBAction func moreMenuPrsd(_ sender: Any) {
        if isMenuHidden {
            isMenuHidden = false
            UIView.animate(withDuration: 0.4) {
                self.historyBtn.isHidden = false
                self.addPaymentBtn.isHidden = false
                self.editPicBtn.isHidden = false
                self.addClassBtn.isHidden = false
                self.addLoctnBtn.isHidden = false
            }
        } else {
            hideMenu()
        }
    }
    
    @IBAction func schllBtnPrsd(_ sender: Any) {
        listOfCollgesPicker.isHidden = false
    }
    
    
    @IBAction func editPicPrsd(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        savePicPrsd.isHidden = false
        cancelSave.isHidden = false
        hideMenu()
        callSavePictr = true
    }
    
    @IBAction func savePicPrsd(_ sender: Any) {
        if callSavePictr {
            saveImage()
        }
        cancelSave.isHidden = true
        savePicPrsd.isHidden = true
    }
    
    @IBAction func cancelSave(_ sender: Any) {
        
        cancelSave.isHidden = true
        savePicPrsd.isHidden = true
    }
    
    @IBAction func addClassPrsd(_ sender: Any) {
        addClassView.isHidden = false
        hideMenu()
    }
    
    @IBAction func addLoctnPrsd(_ sender: Any) {
        //        savePicture
        hideMenu()
        addLoctnsView.isHidden = false
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func donePrsd(_ sender: Any) {
        addClassView.isHidden = true
        addLoctnsView.isHidden = true
        //save classes
        if !selectedClasses.isEmpty {
            for x in 0...selectedClasses.count - 1 {
                saveClasses(classs: selectedClasses[x])
            }
        }
        if !placeArr.isEmpty {
            for x in 0...placeArr.count - 1{
                savePlace(place: placeArr[x])
            }
        }
    }
    
    @IBAction func textEditingBegan(_ sender: Any) {
        cancelSave.isHidden = false
        savePicPrsd.isHidden = false
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
    
    @IBAction func addPaymentPrsd(_ sender: Any) {
        hideMenu()
    }
    
    
    func hideMenu(){
        isMenuHidden = true
        UIView.animate(withDuration: 0.4) {
            self.historyBtn.isHidden = true
            self.addPaymentBtn.isHidden = true
            self.editPicBtn.isHidden = true
            self.addClassBtn.isHidden = true
            self.addLoctnBtn.isHidden = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        savePicPrsd.isHidden = true
    }
    
    @objc func buttonTapped(sender: UIButton) {
        //Button Tapped and open your another ViewController
        
    }
    
    func fetchStudentInfo() {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        handle2 = ref.child("Students").child(uid!).queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
                self.myClassesArr.removeAll()
                let myclass = response.value as! [String:AnyObject]
                var name = " "
                if let dict = myclass["Classes"] as? [String : AnyObject] {
                    for (x,y) in dict {
                        var fetch = FetchObject()
                        fetch.title = y["className"] as? String
                        fetch.uid = y["uid"] as? String
                        self.myClassesArr.append(fetch)
                    }
                    self.myClassesArr.sort(by:{ $0.title! < $1.title! } )
                    self.myClassesTableView.reloadData()
                } //Myposts
                if let dict = myclass["Myposts"] as? [String : AnyObject] {
                    self.myPostArr.removeAll()
                    for (x,y) in dict {
                        let p = Post(b: y)
                        self.myPostArr.append(p)
                    }
                    self.myPostsTableView.reloadData()
                }
                
                if let fname = myclass["full_name"] as? String {
                    UserDefaults.standard.set(fname, forKey: "full_name")
                    ProfileVC.student.fullName = fname
                }
                if let fname = myclass["fName"] as? String {
                    UserDefaults.standard.set(fname, forKey: "fName")
                    name = fname
                    self.firstName.text = fname
                    ProfileVC.student.firstName = fname
                }
                if let phone = myclass["phoneNumber"] as? String {
                    UserDefaults.standard.set(phone, forKey: "phoneNumber")
                    self.phoneNumber.text = phone
                    ProfileVC.student.phoneNumber = phone
                    self.phoneNumber.text = phone
                } //isTutorApproved paymentSource
                if let email = myclass["email"] as? String {
                    UserDefaults.standard.set(email, forKey: "email")
                    ProfileVC.student.email = email
                    self.email.text = email
                } //status meetUpLocations
                if let status = myclass["status"] as? String {
                    ProfileVC.student.tutorStatus = status
                }
                if let status = myclass["paymentSource"] as? [ String] {
                    ProfileVC.student.paymentSource = status
                    
                } //fromDevice
                if let fromDevice = myclass["fromDevice"] as? String {
                    ProfileVC.student.deviceNotificationTokern = fromDevice
                }
                if let hasCard = myclass["hasCard"] {
                    print(hasCard)
                    ProfileVC.student.hasCard = hasCard as! Bool
                }
                if let meetUpLocations = myclass["meetUpLocations"] as? [String:[String]] {
                    ProfileVC.student.meetUpLocations.removeAll()
                    for (x,y) in meetUpLocations {
                        var place = Place()
                        place.lat = y[0] ; place.long = y[1]; place.address = y[3]; place.name = y[2]
                        ProfileVC.student.meetUpLocations.append(place)
                    }
                    self.myLocationsTableView.reloadData()
                }
                if let lname = myclass["lName"] as? String {
                    UserDefaults.standard.set(lname, forKey: "lName")
                    name += " " + lname + "\n " + (Auth.auth().currentUser?.email)!
                    ProfileVC.student.lastName = lname
                    self.lastName.text = lname 
                }
                if let id = myclass["uid"] as? String {
                    UserDefaults.standard.set(id, forKey: "userId")
                    ProfileVC.student.uid = id
                } //TutorProfile
                if let customer = myclass["customerId"] as? String {
                    UserDefaults.standard.set(customer, forKey: "customerId")
                    ProfileVC.student.customerId = customer
                }
//                self.userName.text = name
                if let pictureURl = myclass["pictureUrl"] as? String {
                    ProfileVC.student.pictureUrl = pictureURl
                    UserDefaults.standard.set(pictureURl, forKey: "pictureUrl")
                    self.storageRef.reference(forURL: pictureURl).getData(maxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                        if error == nil {
                            if let data = imgData{
                                UserDefaults.standard.set(data, forKey: "pictureData")
                                self.profilePic.image = UIImage(data: data)
                            }
                        }
                        else {
                            print(error?.localizedDescription)
                        }
                    })
                }
            }
        })
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
                        university.markCell = self.markCell(id: university.uid!)
                        self.allClassesArr.append(university)
                    }
                }
                self.allClassesArr.sort(by:{ $0.title! < $1.title! } )
                self.classSearchTableView.reloadData()
            }
        })
        self.classSearchTableView.reloadData()
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
    
    func markCell(id: String) -> Bool {
        if !myClassesArr.isEmpty {
            for x in 0...myClassesArr.count - 1 {
                if myClassesArr[x].uid == id {
                    return true
                } else {
                    
                }
            }
        }
        
        return false
    }
    
    func saveImage() {
        let ref = Database.database().reference()
        let userId = Auth.auth().currentUser?.uid
        let imageRef = self.userStorage.child("\(userId ?? "").jpg")
        let data = self.profilePic.image?.jpegData(compressionQuality: 0.5)
        
        let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            } else {
                UserDefaults.standard.set(data, forKey: "pictureData")
            }
            
            imageRef.downloadURL(completion: { (url, er) in
                if er != nil {
                    print(er!.localizedDescription)
                }
                if let url = url {
                    ProfileVC.student.pictureUrl = url.absoluteString
                    ref.child("Students").child(userId ?? "").child("pictureUrl").setValue(url.absoluteString)
                }
            })
        })
        uploadTask.resume()
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
        if myClassesArr.contains(where: { $0.uid == key }) {
            // student already in class
        } else {
            // student not in class therefore add student to class add class to student
            
            ref.child("Students").child(uid!).child("Classes").child(key!).updateChildValues(parameters)
            ref.child("Classes").child(key!).child("Students").child(uid!).updateChildValues(parameters2)
            
            devicNotes = classs.Notification_Devices
            if devicNotes.contains(ProfileVC.student.deviceNotificationTokern!) {
                
            } else {
                devicNotes.append(ProfileVC.student.deviceNotificationTokern!)
            }
            ref.child("Classes").child(key!).child("Notification_Devices").setValue(devicNotes)
        }
    }
    
    func savePlace(place:Place){
        //        let cell = classRoomTableView.cellForRow(at: indexPath)
        let ref = Database.database().reference()
        let key = ref.child("Universities").childByAutoId().key
        let uid = Auth.auth().currentUser?.uid
        let arr = [place.lat, place.long, place.name, place.address]
        
        if ProfileVC.student.meetUpLocations.contains(where: { $0.long == place.long }) {
            
        } else {
            
            ref.child("Students").child(uid!).child("meetUpLocations").child(key!).setValue(arr)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.profilePic.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        hideMenu()
    }
    
    var storageRef: Storage {
        return Storage.storage()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        allClassesArrFilterd = allClassesArr.filter({( classe : FetchObject) -> Bool in
            return classe.title!.lowercased().contains(searchText.lowercased())
        })
        
        classSearchTableView.reloadData()
    }
    
    func editImage(image:UIImageView){
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
}



extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == myClassesTableView{
            self.performSegue(withIdentifier: "profileToClasses", sender: self)
        } else if tableView == myLocationsTableView {
            
        } else if tableView == myPostsTableView {
            
        } else  if tableView == classSearchTableView {
            let cell = tableView.cellForRow(at: indexPath)
            if cell?.backgroundColor != UIColor.gray {
                if inSearching {
                    if cell?.accessoryType != .checkmark {
                        cell?.accessoryType = .checkmark
                        selectedClasses.append(allClassesArrFilterd[indexPath.row])
                    } else {
                        if let index = selectedClasses.index(where: {$0.uid == allClassesArrFilterd[indexPath.row].uid}) {
                            selectedClasses.remove(at: index)
                        }
                        cell?.accessoryType = .none
                    }
                } else {
                    if cell?.accessoryType != .checkmark {
                        selectedClasses.append(allClassesArr[indexPath.row])
                        cell?.accessoryType = .checkmark
                    } else {
                        if let index = selectedClasses.index(where: {$0.uid == allClassesArr[indexPath.row].uid}) {
                            selectedClasses.remove(at: index)
                        }
                        cell?.accessoryType = .none
                    }
                }
            } else {
                // paste a message to screen
            }
            
        } else if tableView == locationsSearchTableView {
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == myClassesTableView {
            if (editingStyle == UITableViewCell.EditingStyle.delete) {
//                deletValue(indexPathRow: indexPath.row)
                
                myClassesArr.remove(at: indexPath.row)
                myClassesTableView.deleteRows(at: [indexPath], with: .fade)
                
            }
        } else if tableView == myLocationsTableView {
            
        } else if tableView == myPostsTableView {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == myClassesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myClasses", for: indexPath)
            if !myClassesArr.isEmpty {
                cell.textLabel?.text = myClassesArr[indexPath.row].title
                cell.textLabel?.numberOfLines = 0
            }
            return cell
        } else if tableView == myLocationsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myLocations", for: indexPath)
            if !(ProfileVC.student.meetUpLocations.isEmpty)  {
                cell.textLabel?.text = ProfileVC.student.meetUpLocations[indexPath.row].name
                cell.textLabel?.numberOfLines = 0
            }
            return cell
        } else if tableView == myPostsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myPosts", for: indexPath)
            if !myPostArr.isEmpty {
                cell.textLabel?.text = myPostArr[indexPath.row].title
                cell.textLabel?.numberOfLines = 0
            }
            return cell
        } else if tableView == locationsSearchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "meetUpLocCell", for: indexPath)
            cell.textLabel?.text = placeArr[indexPath.row].name
            cell.textLabel?.numberOfLines = 0
            
            return cell
        } else if tableView == classSearchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "classSearch", for: indexPath)
            if !allClassesArr.isEmpty {
                if inSearching {
                    cell.textLabel?.text = allClassesArrFilterd[indexPath.row].title
                    if allClassesArrFilterd[indexPath.row].markCell {
                        cell.backgroundColor = UIColor.gray
                    } else {
                        cell.backgroundColor = UIColor.white
                    }
                    
                    
                } else {
                    cell.textLabel?.text = allClassesArr[indexPath.row].title
                    if allClassesArr[indexPath.row].markCell {
                        cell.backgroundColor = UIColor.gray
                    } else {
                        cell.backgroundColor = UIColor.white
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myClasses", for: indexPath)
            cell.textLabel!.text = myClassesArr[indexPath.row].title
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "classUniSearch", for: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myClassesTableView {
            return myClassesArr.count
        } else if tableView == myLocationsTableView {
            return ProfileVC.student.meetUpLocations.count
        } else if tableView == myPostsTableView {
            return myPostArr.count
        } else if tableView == classSearchTableView {
            if inSearching {
                return allClassesArrFilterd.count
            } else {
                return allClassesArr.count
            }
        } else if tableView == locationsSearchTableView {
            return placeArr.count
        } else {
            return 0
        }
        return 0
    }
    
    /* needs fixing not currently working
     supposed to put a button on the header of tableview, so you can add class or location from there.
     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == myClassesTableView {
            let frame: CGRect = tableView.frame
            
            //        let rect = CGRect(origin: CGPoint(x: frame.size.width - 200,y :0), size: CGSize(width: 150, height: 50))
            //        let rect2 = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: frame.size.width, height: frame.size.height))
            let DoneBut: UIButton = UIButton(frame: CGRect(x: frame.size.width - 100,y :0, width: 150, height: 50)) //
            DoneBut.setTitle("Done", for: .normal)
            DoneBut.backgroundColor = UIColor.blue
            
            
            
            DoneBut.addTarget(self, action: #selector(ProfileVC.buttonTapped(sender:)), for: .touchUpInside)
            
            DoneBut.backgroundColor = UIColor.blue
            
            
            let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            headerView.backgroundColor = UIColor.red
            headerView.addSubview(DoneBut)
            return headerView
        }
        let frame: CGRect = tableView.frame
        
//        let rect = CGRect(origin: CGPoint(x: frame.size.width - 200,y :0), size: CGSize(width: 150, height: 50))
//        let rect2 = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: frame.size.width, height: frame.size.height))
        let DoneBut: UIButton = UIButton(frame: CGRect(x: frame.size.width - 100,y :0, width: 150, height: 50)) //
        DoneBut.setTitle("Done", for: .normal)
        DoneBut.backgroundColor = UIColor.blue
        
        
        
        DoneBut.addTarget(self, action: #selector(ProfileVC.buttonTapped(sender:)), for: .touchUpInside)
        
        DoneBut.backgroundColor = UIColor.blue
        
        
        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.backgroundColor = UIColor.red
        headerView.addSubview(DoneBut)
        return headerView
    }
    */
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == myClassesTableView {
            return "My Classes"
        } else if tableView == myLocationsTableView {
            return "My Locations"
        } else if tableView == myPostsTableView {
            return "My Posts"
        } else if tableView == locationsSearchTableView{
            return "Locations Search"
        } else if tableView == classSearchTableView {
            return "Class Search "
        } else {
            return ""
        }
    }
}

extension ProfileVC: UIPickerViewDelegate, UIPickerViewDataSource {
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

extension ProfileVC: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.place.name = place.name
        self.place.long = "\(place.coordinate.longitude)"
        self.place.lat = "\(place.coordinate.latitude)"
        self.place.address = place.formattedAddress
        self.placeArr.append(self.place)
        let arr = ["\(place.coordinate.latitude)", "\(place.coordinate.longitude)", place.name, "\(place.formattedAddress ?? "")"]
        placeesDict["\(place.placeID)"] = arr
        locationsSearchTableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
