//  File Name: TrackingScreenViewController.swift

//  Authors: Himanshu (301296001)
//  Subject: MAPD714 iOS Development
//  Assignment: Final Exam

//  Task: Create BMI Calculator.

//  Date modified: 15/12/2022

import UIKit
import FirebaseCore
import FirebaseFirestore

class TrackingScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    /**
     * Variable declarations
     */
    var bmiList:[List] = []
    
    var list = ["Hello", "All"]
    
    let todoListTableIdentifier = "TodoListTableIdentifier"
    
    var weight: String = ""
    var height: String = ""
    var bmi: Float = 0
    var unit: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add gradient in background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).cgColor, #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        buildList()
        
        //tableView.reloadData()

    }
    
    /** Firebase initialization */
    var db = Firestore.firestore()
    
    /**
     * Function to build the table view and insert todos
     */
    func buildList() -> Void {
        
        let ref = db.collection("bmi")
        
        ref.getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                bmiList = []
                
                for document in querySnapshot!.documents {
                    print(document.data()["date"] as! String)
                    bmiList.append(List(
                        id: document.documentID,
                        bmi: (document.data()["bmi"] as! String),
                        weight: (document.data()["weight"] as! String),
                        date:(document.data()["date"] as! String)))
                }
                
                tableView.reloadData()
            }
            if (bmiList.count == 0) {
                self.dismiss(animated: true, completion: nil)
                // Show message to user
                let alert = UIAlertController(title: "Message", message: "Nothing to show, please add data", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        print("Inside buildList")
    }
    
    /**
        * Table View Code below
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bmiList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: todoListTableIdentifier)
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: todoListTableIdentifier)
        }
        
        //cell?.textLabel?.text = list[indexPath.row]
        cell?.textLabel?.text = "BMI: \(bmiList[indexPath.row].bmi)  -  \(bmiList[indexPath.row].date)"
        cell?.detailTextLabel?.text = "Weight: \(String(bmiList[indexPath.row].weight))"
        
        var cellFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
        cellFont = UIFont(name: "Futura", size: 18)!
        
        cell?.textLabel?.font = cellFont
        
        return cell!
        
    }
    
    /**
     * Swipe Action from right to left (complete todo and delete todo gestures)
     */
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "🗑️") { [weak self] (action, view, completionHandler) in
            self!.deletBmi(id: indexPath.row)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
    
    /**
     * Swipe Action from left to right (edit todo gesture)
     */
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "✎") { [weak self] (action, view, completionHandler) in
            self!.editBmi(id: indexPath.row)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        let config = UISwipeActionsConfiguration(actions: [editAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    /**
     * Function for performing delete bmi data
     */
    func deletBmi(id:Int) {
        print("Perform Delete")
        let bmiID = bmiList[id].id
        db.collection("bmi").document(bmiID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.buildList()
            }
        }
    }
    
    /**
     * Function for performing editing bmi
     */
    func editBmi(id:Int) {
        updateBmi(id: id)
    }
    
    /**
        * Function that allows to update an entry in the tracking screen
     */
    func updateBmi(id: Int) {
        
        let bmiID = bmiList[id].id
        
        let docRef = db.collection("bmi").document(bmiID)
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Update BMI", message: "Enter new weight", preferredStyle: .alert)
        
        //2. Add the text field
        alert.addTextField(configurationHandler: { [self] (textField) -> Void in
            docRef.getDocument { [self] (document, error) in
                if let document = document, document.exists {
                    unit = (((document.data()!["unit"])) as! Int)
                    if(unit == 1) {
                        textField.placeholder = "Enter Weight (kg)"
                    } else {
                        textField.placeholder = "Enter Weight (pounds)"
                    }
                } else {
                    print("Document does not exist")
                }
            }
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: { [self] (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { [self, weak alert] (action) -> Void in
            let textField = (alert?.textFields![0])! as UITextField
            if (textField.text == "" || textField.text == " ") {
                return
            } else {
                
                docRef.getDocument { [self] (document, error) in
                    if let document = document, document.exists {
                        
                        // Store data into varibales
                        weight = (document.data()!["weight"] as! String)
                        height = (document.data()!["height"] as! String)
                        
                        calculateAndUpdateData(id: id, unit: unit, height: height, weight: textField.text!)
                    } else {
                        print("Document does not exist")
                    }
                }
                
                tableView.reloadData()
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
        * Function to calculate new BMI and update it in firebase
     */
    func calculateAndUpdateData(id: Int, unit: Int, height: String, weight: String) {
        
        print("Inside update")
        
        let bmiID = bmiList[id].id
        
        var newBmi: Float = 0.0
        var newWeight: Float = Float(weight)!
        var newHeight: Float = Float(height)!
        
        if(unit == 1) {
            
            newHeight = newHeight * 0.01
            
            newBmi = newWeight / (newHeight * newHeight)
            
            newBmi = ceil(newBmi * 10) / 10.0
            
        } else if (unit == 0) {
            
            newHeight = newHeight * 0.0254
            
            newWeight = newWeight * 0.453592
            
            newBmi = newWeight / (newHeight * newHeight)
            
            newBmi = ceil(newBmi * 10) / 10.0
        }
        
        db.collection("bmi").document(bmiID).updateData([
            "bmi": String(newBmi),
            "weight": String(newWeight),
            "date": String(Date().formatted(date: .long, time: .omitted))
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.buildList()
            }
        }
        tableView.reloadData()
        print("New Data \(newBmi) , \(newWeight) , \(height), \(unit)")
        
    }
}
