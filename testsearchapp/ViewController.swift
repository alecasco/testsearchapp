//
//  ViewController.swift
//  testsearchapp
//
//  Created by Alejandro Casco on 4/7/20.
//  Copyright © 2020 meli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var queryInput: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    
    var pickerData: [String] = [String]()
    var selectedSite: String = "MLA"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
       
        pickerData = ["MLA","MLU","MLB","MLM"]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("PICKER: ", row, pickerData[row])
        selectedSite = pickerData[row]
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "search" {
            guard let listVC = segue.destination as? ListViewController else {
                return
            }
            
            listVC.queryInput = queryInput.text!
            listVC.site = selectedSite
        } else if segue.identifier == "history" {
            guard let listVC = segue.destination as? ListViewController else {
                return
            }
            listVC.mode = .history
        }
        
    }
}

