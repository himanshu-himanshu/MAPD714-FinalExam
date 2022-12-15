//
//  TrackingScreenViewController.swift
//  MAPD714-Final-Exam
//
//  Created by Himanshu on 2022-12-15.
//

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
            self!.deleteTodo(id: indexPath.row)
              completionHandler(true)
           }
        deleteAction.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
    
    /**
        * Function for performing delete todo when user long swipes from right to left
        * :param: id -> Integer to hold todo id
        * :returns: void
     */
    func deleteTodo(id:Int) {
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
}
