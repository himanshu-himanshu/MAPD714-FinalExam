//  File Name: ViewController.swift

//  Authors: Himanshu (301296001)
//  Subject: MAPD714 iOS Development
//  Assignment: Final Exam

//  Task: Create BMI Calculator.

//  Date modified: 15/12/2022


import UIKit
import FirebaseCore
import FirebaseFirestore

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    /** UI Connections below */
    @IBOutlet var backgroundColorView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var ageSlider: UISlider!
    
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var unitSelector: UISegmentedControl!
    
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var bmiTextLabel: UILabel!
    
    @IBOutlet weak var resetBtnConn: UIButton!
    
    @IBOutlet weak var doneBtnConn: UIButton!
    
    let genders = ["Male", "Female"]
    
    var placeHolder = ""
    
    var bmiMessage = ""
    
    var pickerView = UIPickerView()
    
    var heightM:Float = 0.0
    
    var weightKg:Float = 0.0
    
    var bmi:Float = 0.0
    
    override func viewDidLoad() {
        
        // Connections
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        genderTextField.inputView = pickerView
        ageLabel.text =  String(Int(ageSlider.value.rounded()))
        heightTextField.delegate = self
        weightTextField.delegate = self
        bmiTextLabel.text = ""
        resetBtnConn.isEnabled = false
        
        // Add data into fields on main screen after reloading the app
        loadDataFromFirebase()
        
        // Add gradient in background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1).cgColor, #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        backgroundColorView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // Firebase initialization
    var db = Firestore.firestore()
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == heightTextField || textField == weightTextField {
            let allowedChars = "+1234567890"
            let allowrdCharSet = CharacterSet(charactersIn: allowedChars)
            let typedCharSet = CharacterSet(charactersIn: string)
            return allowrdCharSet.isSuperset(of: typedCharSet)
        }
        return true
    }
    
    /**
        * Calculate function for calculating the Body Mass Index for the user after he clicks the button
     */
    @IBAction func calculateBtn(_ sender: UIButton) {
        
        if (nameTextField.text!.isEmpty || Int(ageSlider.value.rounded()) == 0 || heightTextField.text!.isEmpty || weightTextField.text!.isEmpty || genderTextField.text!.isEmpty) {
            
            // Show alert if fields are empty
            let alert = UIAlertController(title: "Alert", message: "Fields cannot be empty!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            // BMI Calculation Logic
            
            if (unitSelector.selectedSegmentIndex == 0) {
                
                /** If Imperial Unit is selected convert to kg and meter */
                weightKg = (Float(weightTextField.text!)?.rounded())!
                weightKg = weightKg * 0.453592
                heightM = (Float(heightTextField.text!)?.rounded())!
                heightM = heightM * 0.0254
                
            } else {
                
                /** If Metric Unit is selected convert height to meter and leave weight as it is */
                weightKg = (Float(weightTextField.text!)?.rounded())!
                heightM = (Float(heightTextField.text!)?.rounded())!
                heightM = heightM * 0.01
                
            }
            
            bmi = weightKg / (heightM * heightM)
            
            bmi = ceil(bmi * 10) / 10.0
            
            print(bmi)
            
            bmiTextLabel.text = "Your BMI: \(bmi)"
           
            assignBMIMessage(bmi: bmi)  // Call function to assign the category according to bmi
            
            saveDataToFirebase() // Function to save data into firebase
            
            resetBtnConn.isEnabled = true
            
            // Show message to user
            let alert = UIAlertController(title: "Body Mass Index", message: "Your BMI: \(bmi), Category: \(bmiMessage)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Got it", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
           
            print("BMI is: \(ceil(bmi * 10) / 10.0) and height is: \(heightM) and Weight is: \(weightKg)")
            
            addBMIDataToFirebase()
        }
    }
    
    /**
        * Assign message after bmi is calculated
     */
    func assignBMIMessage(bmi: Float) {
        
        if bmi < 16 {
            bmiMessage = "Severe Thinness"
        } else if bmi >= 16 && bmi <= 17 {
            bmiMessage = "Moderate Thinness"
        } else if bmi >= 17 && bmi <= 18.5 {
            bmiMessage = "Mild Thinness"
        } else if bmi >= 18.5 && bmi <= 25 {
            bmiMessage = "Normal"
        } else if bmi >= 25 && bmi <= 30 {
            bmiMessage = "Overweight"
        } else if bmi >= 30 && bmi <= 35 {
            bmiMessage = "Obese I"
        } else if bmi >= 35 && bmi <= 40 {
            bmiMessage = "Obese II"
        } else if bmi > 40 {
            bmiMessage = "Obese III"
        }
    }
    
    /**
        * Function for saving the data from fields and labels to firebase
     */
    func saveDataToFirebase() {
       
        db.collection("user").document("User").setData([
            "name": nameTextField.text!,
            "age": Float(ageLabel.text!)!,
            "gender": genderTextField.text!,
            "unit": unitSelector.selectedSegmentIndex,
            "height": heightTextField.text!,
            "weight": weightTextField.text!,
            "bmi": bmiTextLabel.text!,
            "ageText": ageLabel.text!
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
    }
    
    /**
        * Function for loading the data into the main screen after app restarts
     */
    func loadDataFromFirebase() {
        let ref = db.collection("user")
        ref.getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    nameTextField.text = (document.data()["name"] as! String);
                    ageLabel.text = (document.data()["ageText"] as! String);
                    ageSlider.value = (document.data()["age"] as! Float);
                    genderTextField.text = (document.data()["gender"] as! String);
                    unitSelector.selectedSegmentIndex = (document.data()["unit"] as! Int);
                    weightTextField.text = (document.data()["weight"] as! String);
                    heightTextField.text = (document.data()["height"] as! String);
                    bmiTextLabel.text = (document.data()["bmi"] as! String);
                }
                resetBtnConn.isEnabled = true
            }
        }
    }
    
    /**
        * Function for clearing all the fields on the screen as well as it deletes data from firebase
     */
    @IBAction func resetBtn(_ sender: UIButton) {
        nameTextField.text = ""
        heightTextField.text = ""
        weightTextField.text = ""
        bmiTextLabel.text = ""
        unitSelector.selectedSegmentIndex = 0
        genderTextField.text = ""
        ageSlider.value = 18
        
        db.collection("user").document("User").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    /**
        * Function for handling the unit selection
     */
    @IBAction func unitSelectorAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            weightTextField.placeholder = "Enter Weight (pounds)"
            heightTextField.placeholder = "Enter Height (inches)"
        }
        
        if sender.selectedSegmentIndex == 1 {
            weightTextField.placeholder = "Enter Weight (kg)"
            heightTextField.placeholder = "Enter Height (cm)"
        }
        
    }
    
    /**
        * Function for handling data saving and transiting to second screen
     */
    @IBAction func doneBtn(_ sender: UIButton) {
        
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        let stoaryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = stoaryboard.instantiateViewController(withIdentifier: "TrackingScreenViewController") as! TrackingScreenViewController
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.present(secondController, animated: false, completion: nil);
    }
    
    /**
        * Function for handling data saving
     */
    func addBMIDataToFirebase() {
    
        // Firebase Code
        var ref: DocumentReference? = nil
        ref = db.collection("bmi").addDocument(data: [
            "bmi": String(bmi),
            "weight": weightTextField.text!,
            "height": heightTextField.text!,
            "unit": unitSelector.selectedSegmentIndex,
            "date": String(Date().formatted(date: .long, time: .omitted))
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
    }
    
    override var shouldAutorotate: Bool {
           return false
    }
    
    @IBAction func ageSliderAction(_ sender: UISlider) {
        ageLabel.text = String(Int(ageSlider.value.rounded()))
    }
    
    /**
        * Code for picker view
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genders[row]
        genderTextField.resignFirstResponder()
    }
}

