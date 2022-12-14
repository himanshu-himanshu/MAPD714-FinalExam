//
//  ViewController.swift
//  MAPD714-Final-Exam
//
//  Created by Himanshu on 2022-12-14.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var backgroundColorView: UIView!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var ageSlider: UISlider!
    
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var unitSelector: UISegmentedControl!
    
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var heightTextField: UITextField!
    
    let genders = ["Male", "Female"]
    
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        genderTextField.inputView = pickerView
        
        ageLabel.text =  String(Int(ageSlider.value.rounded()))
       
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1).cgColor, #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor]
        gradientLayer.shouldRasterize = true
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        backgroundColorView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    @IBAction func unitSelectorAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            weightTextField.placeholder = "Enter Weight (pounds)"
            heightTextField.placeholder = "Enter Height (inches)"
        }
        
        if sender.selectedSegmentIndex == 1 {
            weightTextField.placeholder = "Enter Weight (kg)"
            heightTextField.placeholder = "Enter Height (meter)"
        }
        
    }
    
    override var shouldAutorotate: Bool {
           return false
    }
    
    @IBAction func ageSliderAction(_ sender: UISlider) {
        ageLabel.text = String(Int(ageSlider.value.rounded()))
    }
    
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

