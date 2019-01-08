//
//  AllClassesVC.swift
//  HomeworkMe 2.0
//
//  Created by Radiance Okuzor on 1/4/19.
//  Copyright © 2019 RayCo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Alamofire
import MessageUI
import paper_onboarding

class AllClassesVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var createNewPostView: UIView!
    @IBOutlet weak var greyBkGrnd: UIView!
    @IBOutlet weak var switchView: UILabel!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var requestsTableView: UITableView!
    @IBOutlet weak var classSearch: UITableView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var onBoardingView: OnboardingView!
    @IBOutlet weak var getStarted: UIButton!
    @IBOutlet weak var switchViewBtn: UIButton!
    @IBOutlet weak var classText: UITextField!
    @IBOutlet weak var postTitle: UITextField!
    @IBOutlet weak var teacherLName: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var listOfClassesPicker: UIPickerView!
    
    
    var isGiveHelp = false
    var isRequest = false
    var schedules = [String]()
    var handle: DatabaseHandle?; var handle2: DatabaseHandle?; var handle3: DatabaseHandle?
    let ref = Database.database().reference()
    let seg = "classRoomToPostSegue" //classroom to post view
    var postObject = Post() // variable to hold transfered data to PostView
    var isOffering: Bool!
    var notificationKey: String!
    var notificationKeyName: String!
    var functions = CommonFunctions()
    var inSearching = false
    var postCategory = "Homework"
    var selectedClass: FetchObject?
    var devicNotes = [String]()
    var tutorsInClass = [String:AnyObject]()
    var myPostArr = [Post](); var hmwrkArr = [Post](); var testArr = [Post](); var notesArr = [Post](); var otherArr = [Post](); var tutorArr = [Post](); var allPostHolder = [Post]()
    var allClassesArr = [FetchObject](); var allClassesArrFilterd = [FetchObject]()
    var myPostArrReq = [Post](); var hmwrkArrReq = [Post](); var testArrReq = [Post](); var notesArrReq = [Post](); var otherArrReq = [Post](); var tutorArrReq = [Post](); var allPostHolderReq = [Post]()
    var tableViewSections = ["All","Homework", "Test","Notes","Tutoring","Other"]
    var myClasses = [FetchObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        dismissKeyboard(); addKeyBrdButn(textField: classText); addKeyBrdButn(textField: postTitle); addKeyBrdButn(textField: teacherLName); addKeyBrdButn(textField: price)
        
        postsTableView.rowHeight = 82
        requestsTableView.rowHeight = 82
//        onBoardingView.dataSource = self
//        onBoardingView.delegate = self
        fetchStudent()
        if let ob = UserDefaults.standard.object(forKey: "hasSeenOS2") as? Bool {
            if ob {
                onBoardingView.isHidden = true
            }
        }
        
    }
    
    @IBAction func addPostPrsd(_ sender: Any) {
        let ref = Database.database().reference()
//        greyBkGrnd.isHidden = false
        if ProfileVC.student.paymentSource != nil {
            let alert4 = UIAlertController(title: "Give or Get help", message: "", preferredStyle: .alert)
            let giveHelp = UIAlertAction(title: "Give Help", style: .default) { (_) in
                self.isGiveHelp = true
                UIView.animate(withDuration: 1.0, animations: {
                    self.greyBkGrnd.isHidden = false
                    self.createNewPostView.isHidden = false
                })
            }
            let getHelp = UIAlertAction(title: "Get Help", style: .default) { (_) in
                self.isGiveHelp = false
                UIView.animate(withDuration: 1.0, animations: {
                    self.greyBkGrnd.isHidden = false
                    self.createNewPostView.isHidden = false
                })
            }
            alert4.addAction(giveHelp); alert4.addAction(getHelp)
            present(alert4, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Missing Information", message: "Kindly register your account for tutoring by selecting a method in which your students can pay you. Then tap to add an assignment again.", preferredStyle: .alert)
            let zelle = UIAlertAction(title: "Zelle", style: .default) { (resp) in
                let alert1 = UIAlertController(title: "Zelle", message: "what's your Zelle email or phone number", preferredStyle: .alert)
                alert1.addTextField { (textField) in
                    textField.placeholder = "zelle email or phone"
                }
                alert1.addTextField { (textField2) in
                    textField2.placeholder = "zelle email or phone confirmation"
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let Add = UIAlertAction(title: "Add", style: .default) { _ in
                    guard let text = alert1.textFields?.first?.text else { return }
                    guard let text2 = alert1.textFields?.first?.text else { return }
                    if text != "" && text2 != "" && text2 == text {
                        let ar = ["Zelle",text]
                        let par = ["paymentSource":ar] as [String:[String]]
                        ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").updateChildValues(par)
                        ProfileVC.student.paymentSource = ar
                    }
                }
                alert1.addAction(Add); alert1.addAction(cancel)
                self.present(alert1, animated: true, completion: nil)
            }
            let cash = UIAlertAction(title: "Cash App", style: .default) { (resp) in
                let alert2 = UIAlertController(title: "Cash App", message: "what's your Cash App $cash_tag (e.x. $Raycorp)", preferredStyle: .alert)
                alert2.addTextField { (textField) in
                    textField.placeholder = "$cash_tag"
                }
                alert2.addTextField { (textField2) in
                    textField2.placeholder = "Cash App confirmation"
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let Add = UIAlertAction(title: "Add", style: .default) { _ in
                    guard let text = alert2.textFields?.first?.text else { return }
                    guard let text2 = alert2.textFields?.first?.text else { return }
                    if text != "" && text2 != "" && text2 == text {
                        let ar = ["Zelle",text]
                        let par = ["paymentSource":ar] as [String:[String]]
                        ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").updateChildValues(par)
                        ProfileVC.student.paymentSource = ar
                    }
                }
                alert2.addAction(Add); alert2.addAction(cancel)
                self.present(alert2, animated: true, completion: nil)
            }
            let venmo = UIAlertAction(title: "Venmo", style: .default) { (resp) in
                let alert3 = UIAlertController(title: "Cash App", message: "what's your Venmo @username (e.x. @Raycorp)", preferredStyle: .alert)
                alert3.addTextField { (textField) in
                    textField.placeholder = "Venmo @username"
                }
                alert3.addTextField { (textField2) in
                    textField2.placeholder = "Venmo @username confirmation"
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let Add = UIAlertAction(title: "Add", style: .default) { _ in
                    guard let text = alert3.textFields?.first?.text else { return }
                    guard let text2 = alert3.textFields?.first?.text else { return }
                    if text != "" && text2 != "" && text2 == text {
                        let ar = ["Zelle",text]
                        let par = ["paymentSource":ar] as [String:[String]]
                        ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").updateChildValues(par)
                        ProfileVC.student.paymentSource = ar
                    }
                }
                alert3.addAction(Add); alert3.addAction(cancel)
                self.present(alert3, animated: true, completion: nil)
            }
            alert.addAction(zelle); alert.addAction(cash); alert.addAction(venmo)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func categoryPrsd(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            postCategory = "Assignment"
            postTitle.placeholder = "Homework, classwork, quize name and number"
        }
        if sender.selectedSegmentIndex == 1 {
            postCategory = "Notes"
            postTitle.placeholder = "Notes title"
        }
        if sender.selectedSegmentIndex == 2 {
            postCategory = "Test"
            postTitle.placeholder = "Test title and number"
        }
        if sender.selectedSegmentIndex == 3 {
            postCategory = "Other"
            postTitle.placeholder = "Homework, classwork, quize name and number"
        }
    }

    
 
    
    @IBAction func getStarted(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.onBoardingView.isHidden = true
            self.getStarted.isHidden = true
            UserDefaults.standard.set(true, forKey: "hasSeenOS2")
        }
    }
    
    @IBAction func switchView(_ sender: Any) {
        if requestsTableView.isHidden {
            requestsTableView.isHidden = false
            switchView.text = "Get Help"
            switchViewBtn.setTitle("Give Help", for: .normal)
            isRequest = true
        } else {
            requestsTableView.isHidden = true
            switchView.text = "Give Help"
            switchViewBtn.setTitle("Get Help", for: .normal)
            isRequest = true
        }
    }
    
    @IBAction func hidePicker(_ sender: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.listOfClassesPicker.isHidden = true
        }
    }
    
    @IBAction func addClassWithPicker(_ sender: UITextField) {
//        self.view.endEditing(true)
//        self.createNewPostView.endEditing(true)
        classText.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.listOfClassesPicker.isHidden = false
        }
    }
    
    @IBAction func srchInCls(_ sender: UITextField) {
        inSearching = true
        if sender.text! == "" {
            inSearching = false
        }
        if sender.text! == " " {
            inSearching = false
        }
        filterContentForSearchText(sender.text!)
    }
    
    @IBAction func searchBegin(_ sender: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.classSearch.isHidden = false
        }
    }
    
    @objc func createPost(_ sender: Any) {
        creatPost()
        UIView.animate(withDuration: 0.3) {
            self.createNewPostView.isHidden = true
            self.greyBkGrnd.isHidden = true
        }
        self.view.endEditing(true)
    }
    
    @objc func cancelPost(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.createNewPostView.isHidden = true
            self.greyBkGrnd.isHidden = true
        }
        self.view.endEditing(true)
    }
    
    func fetchStudent() {
        let uid = Auth.auth().currentUser?.uid
        handle3 = ref.child("Students").child(uid!).queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
                self.hmwrkArr.removeAll(); self.hmwrkArrReq.removeAll(); self.notesArr.removeAll(); self.notesArrReq.removeAll(); self.tutorArr.removeAll(); self.tutorArrReq.removeAll(); self.testArrReq.removeAll(); self.testArr.removeAll(); self.otherArr.removeAll(); self.otherArrReq.removeAll(); self.myPostArrReq.removeAll(); self.myPostArr.removeAll()
                    self.allClassesArr.removeAll()
                let myclass = response.value as! [String:AnyObject]
                if let dict = myclass["Classes"] as? [String : AnyObject] {
                    for (x,y) in dict {
                        self.fetchMyPostsKey(clasUid: x)
                        var classs = FetchObject()
                        classs.title = y["className"] as? String
                        classs.uid = y["uid"] as? String 
                        self.myClasses.append(classs)
                    }
                    self.myClasses.sort(by:{ $0.title! < $1.title! } )
                    self.listOfClassesPicker.reloadAllComponents()
                }
                if let paySrc = myclass["paymentSource"] as? [String] {
                    ProfileVC.student.paymentSource = paySrc
                }
                if let paySrc = myclass["phoneNumber"] as? String {
                    ProfileVC.student.phoneNumber = paySrc
                }
            }
        })
    }
    
    func fetchMyPostsKey(clasUid:String) {
        handle = ref.child("Classes").child(clasUid).queryOrderedByKey().observe( .value, with: { response in
            if response.value is NSNull {
                /// dont do anything
            } else {
                var classinfo = FetchObject()
                let posts = response.value as! [String:AnyObject]
                if let dict = posts["Posts"] as? [String : AnyObject] {
                    self.fetchPostInfo(dictCheck: dict)
                }
                if let notificationKey = posts["notificationKey"] as? String {
                    self.notificationKey = notificationKey
                }
                if let notificationKeyName = posts["notificationKeyName"] as? String {
                    self.notificationKeyName = notificationKeyName
                }
                if let Notification_Devices = posts["Notification_Devices"] as? [String] {
                    self.devicNotes = Notification_Devices
                } // Students
                if let tutorsInClass = posts["Students"] as? [String:AnyObject] {
                    self.tutorsInClass = tutorsInClass
                }
                if let className = posts["name"] as? String {
                    classinfo.title = className
                }
                if let classId = posts["uid"] as? String {
                    classinfo.uid = classId
                }
                self.allClassesArr.append(classinfo)
            }
            self.allClassesArr.sort(by:{ $0.title! < $1.title! } )
            self.classSearch.reloadData()
        })
       
    }
    
    func fetchPostInfo(dictCheck: [String:AnyObject]){
        
        for (x,d) in dictCheck {
            for (_,b) in d as! [String:AnyObject] {
                let postss = Post(b: b)
                if x == "GetHelp" {
                    if !self.myPostArrReq.contains(where: {$0.uid == postss.uid}) {
                        self.myPostArrReq.append(postss)
                        if postss.category == "Homework" {
                            self.hmwrkArrReq.append(postss)
                        } else if postss.category == "Notes" {
                            self.notesArrReq.append(postss)
                        }else if postss.category == "Tutoring" {
                            self.tutorArrReq.append(postss)
                        }else  if postss.category == "Test" {
                            self.testArrReq.append(postss)
                        }else if postss.category == "Other" {
                            self.otherArrReq.append(postss)
                        }
                    }
                } else {
                    if !self.myPostArr.contains(where: {$0.uid == postss.uid}) {
                        self.myPostArr.append(postss)
                        if postss.category == "Homework" {
                            self.hmwrkArr.append(postss)
                        } else if postss.category == "Notes" {
                            self.notesArr.append(postss)
                        }else if postss.category == "Tutoring" {
                            self.tutorArr.append(postss)
                        }else  if postss.category == "Test" {
                            self.testArr.append(postss)
                        }else if postss.category == "Other" {
                            self.otherArr.append(postss)
                        }
                    }
                }
            }
            
        }
        if !self.myPostArr.isEmpty {
            self.myPostArr.sort(by: { $0.timeStamp?.compare(($1.timeStamp)!) == ComparisonResult.orderedDescending})
        }
        if !self.myPostArrReq.isEmpty {
            self.myPostArrReq.sort(by: { $0.timeStamp?.compare(($1.timeStamp)!) == ComparisonResult.orderedDescending})
        }
        self.allPostHolder = self.myPostArr
        self.postsTableView.reloadData()
        self.requestsTableView.reloadData()
        self.activitySpinner.stopAnimating()
        self.activitySpinner.isHidden = true
        
    }
    
    func creatPost(){
        let authrName = Auth.auth().currentUser?.email
        let postKey = ref.child("Posts").childByAutoId().key
        let dateString = String(describing: Date())
        var picUrl:String!
        var authorFname: String!
        var authorLname: String!
        var phoneNumber: String?
        if let picurl = UserDefaults.standard.object(forKey: "pictureUrl") as? String {
            picUrl = picurl
        } //UserDefaults.standard.set(lname, forKey: "lName")
        if let fname = UserDefaults.standard.object(forKey: "fName") as? String {
            authorFname = fname
        }
        if let lname = UserDefaults.standard.object(forKey: "lName") as? String {
            authorLname = lname
        } // UserDefaults.standard.set(phone, forKey: "phoneNumber")
        
        if postTitle.text != "" || postTitle.text != nil {
            let name = postTitle.text! + " " + classText.text! + " " + teacherLName.text! + " " + price.text!
            
            let parameters = ["uid":postKey,
                              "name": name,
                              "authorID":Auth.auth().currentUser?.uid ?? " ",
                              "authorEmail": authrName ?? " ",
                              "authorName": authorFname + " " + authorLname,
                              "timeStamp":dateString,
                              "category":self.postCategory,
                              "price": Int(self.price.text ?? "0"),
                "postPic": picUrl,
                "classId": self.selectedClass?.uid ?? "",
                "className":self.selectedClass?.title ?? "",
                "phoneNumber":Int(ProfileVC.student.phoneNumber ?? "") as Any] as? [String : Any]
            
            
            let postParam = [postKey : parameters]
            
            if isGiveHelp {
                ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").child("Myposts").updateChildValues(postParam ?? [:])
                ref.child("Posts").child(postKey ?? "").updateChildValues(parameters!)
                ref.child("Classes").child(self.selectedClass?.uid! ?? "").child("Posts").child("GiveHelp").updateChildValues(postParam)

                self.callForHelp(title: "HomeworkMe Assignement Offer", body: "Your classmate in \(self.selectedClass?.title ?? ""), is helping with \(name ?? "")")
            } else {
                ref.child("Students").child(Auth.auth().currentUser?.uid ?? "").child("Myposts").updateChildValues(postParam ?? [:])
                ref.child("Posts").child(postKey ?? "").updateChildValues(parameters!)
                ref.child("Classes").child(self.selectedClass?.uid ?? "").child("Posts").child("GetHelp").updateChildValues(postParam)
                self.callForHelp(title: "HomeworkMe Assignment Request", body: "Your classmate in \(self.selectedClass?.title ?? ""),needs help with \(name )")
            }
            
        } else {
            // shake text
        }
    }

    func addKeyBrdButn(textField: UITextField){
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
//        DoneBut.addTarget(self, action: #selector(ProfileVC.buttonTapped(sender:)), for: .touchUpInside)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(AllClassesVC.createPost(_:)))
        
        let cancel: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(AllClassesVC.cancelPost(_:)))
        
        toolbar.setItems([cancel, flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        textField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction(sender: UIButton) {
        self.view.endEditing(true)
    }
 
    func imageWithImage(image:UIImage,scaledToSize newSize:CGSize)-> UIImage {
        
        UIGraphicsBeginImageContext( newSize )
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysTemplate)
    }
    
    func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func callForHelp(title:String, body:String){
        for x in 0...devicNotes.count - 1 {
            checkNotif(fromDevice: devicNotes[x], title: title, body: body)
            //            print("call for help ran \(x) times")
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        allClassesArrFilterd = allClassesArr.filter({( classe : FetchObject) -> Bool in
            return classe.title!.lowercased().contains(searchText.lowercased())
        })
        
        classSearch.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        creatPost()
//        UIView.animate(withDuration: 0.3) {
//            self.createNewPostView.isHidden = true
//            self.greyBkGrnd.isHidden = true
//        }
        return true
    }
    
    fileprivate func checkNotif(fromDevice:String, title:String, body:String)
    {
        //        guard let message = "text.text" else {return}
        let toDeviceID = fromDevice
        var headers:HTTPHeaders = HTTPHeaders()
        
        headers = ["Content-Type":"application/json","Authorization":"key=\(AppDelegate.SERVERKEY)"]
        
        let notification = ["to": fromDevice,
                            "notification":[
                                "body":body,
                                "title":title,
                                "badge":1,
                                "sound":"default"]
            ] as [String:Any]
        
        Alamofire.request("https://fcm.googleapis.com/fcm/send" as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print(response)
        }
    }
    
    fileprivate func setupPushNotification(fromDevice:String, title:String, body:String)
    {
        //        guard let message = "text.text" else {return}
        let toDeviceID = fromDevice
        var headers:HTTPHeaders = HTTPHeaders()
        
        headers = ["Content-Type":"application/json","Authorization":"key=\(AppDelegate.SERVERKEY)"
            
        ]
        let notification = ["to":"cXerwI8NeS4:APA91bE8AyQGyvQ3UAg4OpIpLrjlNFE6iV39dXWoq3EknYeHwtTTDbdEvhldhRX6SVCQqOktADc2tciBe46QrHQF_dtnMMt4wqBM-Xg4erVAE3j1DnkLvVwn5JaJneT8fjsLNkxNHJfb","notification":["body":body,"title":title,"badge":1,"sound":"default"]] as [String:Any]
        
        Alamofire.request(AppDelegate.NOTIFICATION_URL as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print(response)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == seg {
            let vc = segue.destination as? SinglePostVC
            vc?.fetchObject = self.postObject
        }
    }

}


extension AllClassesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == postsTableView {
            switch (section) { //["All","Homework", "Test","Notes","Tutoring","Other"]
            case 0:
                return myPostArr.count
            case 1:
                return hmwrkArr.count
            case 2:
                return testArr.count
            case 3:
                return notesArr.count
            case 4:
                return tutorArr.count
            case 5:
                return otherArr.count
            default:
                return 0
            }
        } else if tableView == requestsTableView {
            switch (section) { //["All","Homework", "Test","Notes","Tutoring","Other"]
            case 0:
                return myPostArrReq.count
            case 1:
                return hmwrkArrReq.count
            case 2:
                return testArrReq.count
            case 3:
                return notesArrReq.count
            case 4:
                return tutorArrReq.count
            case 5:
                return otherArrReq.count
            default:
                return 0
            }
        } else if tableView == classSearch {
            if inSearching {
                return allClassesArrFilterd.count
            } else {
                return allClassesArr.count
            }
        }
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == postsTableView {
            return tableViewSections.count
        }  else if tableView == requestsTableView {
            return tableViewSections.count
        } else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == postsTableView {
            return self.tableViewSections[section]
            
        } else if tableView == requestsTableView {
            return self.tableViewSections[section]
        }
        return "select class"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == postsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postsCell", for: indexPath) as! TableViewCell
            var cellTxt = " "
            var urlString = ""
            switch (indexPath.section) {
            case 0:
                let post = self.myPostArr[indexPath.row]
                cell.giveHelpPost = post
                
            case 1:
                let post = self.hmwrkArr[indexPath.row]
                cell.giveHelpPost = post
                
            case 2:
                
                let post = self.testArr[indexPath.row]
                cell.giveHelpPost = post
                
            case 3:
                let post = self.notesArr[indexPath.row]
                cell.giveHelpPost = post
                
            case 4:
                let post = self.tutorArr[indexPath.row]
                cell.giveHelpPost = post
                
            case 5:
                let post = self.otherArr[indexPath.row]
                cell.giveHelpPost = post
                
            default:
                cellTxt = " "
            }
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = cellTxt
            //                    cell.imageView?.image = #imageLiteral(resourceName: "manInWater")
            
//            cell.imageView?.image = imageWithImage(image: UIImage(named: "manInWater")!, scaledToSize: CGSize(width: 30, height: 30))
            return cell
            
        } else if tableView == classSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "filteredClassSearch", for: indexPath)
            if inSearching {
                cell.textLabel?.text = allClassesArrFilterd[indexPath.row].title
            } else {
                cell.textLabel?.text = allClassesArr[indexPath.row].title
            }
            return cell
        } else if tableView == requestsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as! TableViewCell
            
            var cellTxt = " "
            var urlString = ""
            var data = Data()
            switch (indexPath.section) {
            case 0:
                let post = self.myPostArrReq[indexPath.row]
                cell.getHelpPost = post
                
            case 1:
                let post = self.hmwrkArrReq[indexPath.row]
                cell.getHelpPost = post
                
            case 2:
                
                let post = self.testArrReq[indexPath.row]
                cell.getHelpPost = post
                
            case 3:
                let post = self.notesArrReq[indexPath.row]
                cell.getHelpPost = post
                
            case 4:
                let post = self.tutorArrReq[indexPath.row]
                cell.getHelpPost = post
                
            case 5:
                let post = self.otherArrReq[indexPath.row]
                cell.getHelpPost = post
                
            default:
                cellTxt = " "
            }
 
//            cell.textLabel?.numberOfLines = 0
//            cell.textLabel?.text = cellTxt
            //                    cell.imageView?.image = #imageLiteral(resourceName: "manInWater")
            
//            cell.imageView?.image = imageWithImage(image: UIImage(named: "manInWater")!, scaledToSize: CGSize(width: 30, height: 30))
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postsCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == postsTableView {
            self.isOffering = true
            switch (indexPath.section) { //["All","Homework", "Test","Notes","Tutoring","Other"]
            case 0:
                postObject = myPostArr[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 1:
                postObject = hmwrkArr[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 2:
                postObject = testArr[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 3:
                postObject = notesArr[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 4:
                postObject = tutorArr[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 5:
                postObject = otherArr[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            default:
                print(seg)
            }
        } else if tableView == requestsTableView {
            self.isOffering = false
            switch (indexPath.section) { //["All","Homework", "Test","Notes","Tutoring","Other"]
            case 0:
                postObject = myPostArrReq[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 1:
                postObject = hmwrkArrReq[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 2:
                postObject = testArrReq[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 3:
                postObject = notesArrReq[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 4:
                postObject = tutorArrReq[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            case 5:
                postObject = otherArrReq[indexPath.row]
                self.performSegue(withIdentifier: seg, sender: self)
            default:
                print(seg)
            }
        } else if tableView == classSearch {
            if inSearching {
                classText.text = allClassesArrFilterd[indexPath.row].title
                selectedClass = allClassesArrFilterd[indexPath.row]
            } else {
                classText.text = allClassesArr[indexPath.row].title
                selectedClass = allClassesArr[indexPath.row]
            }
        }
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 82
//    }
}

extension AllClassesVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myClasses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myClasses[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedClass = myClasses[row]
        classText.text = selectedClass?.title
    }
}
