//
//  FilterPopupViewController.swift
//  Penny Ops 2
//
//  Created by Joe Satow on 4/2/20.
//  Copyright © 2020 Joe Satow. All rights reserved.
//

import UIKit
import SwiftRangeSlider

class FilterPopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0){
            return minDateArray.count
        } else {
            return expiryDates.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 0){
            if ((row != 0 && datesPicker.selectedRow(inComponent: 1) != 0)  && row >= datesPicker.selectedRow(inComponent: 1)){
                datesPicker.selectRow(row + 1, inComponent: 1, animated: true)
                maxExpiryDateChosenIndex = datesPicker.selectedRow(inComponent: 1)
                }
            minExpiryDateChosenIndex = row
        }
        if (component == 1){
            if (row != 0 && row <= datesPicker.selectedRow(inComponent: 0)){
                datesPicker.selectRow(row - 1, inComponent: 0, animated: true)
                minExpiryDateChosenIndex = datesPicker.selectedRow(inComponent: 0)
            }
            maxExpiryDateChosenIndex = row
        }
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0){
            return minDateArray[row]
        }
        else {
            return expiryDates[row]
        }
    }
    
    var currentConTypeIndex = Int()
    var expiryDates = [String]()
    var minDateArray = [String]()
    var minExpiryDateChosenIndex = Int()
    var maxExpiryDateChosenIndex = Int()
    
    var contractRSLowerSet = 0.01
    var contractRSUpperSet = 0.5
    var underlyingRSLowerSet = 0.00
    var underlyingRSUpperSet = Double()
    var underlyingRSMaxVal = Double()
    
    
    @IBOutlet weak var viewRef: UIView!
    @IBOutlet weak var conTypePicker: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var datesPicker: UIPickerView!
    @IBOutlet weak var contractRangeSlider: RangeSlider!
    @IBOutlet weak var underlyingRangeSlider: RangeSlider!
    @IBOutlet weak var restoreDefaultsButton: UIButton!
    
    func restoreDefaults(){
        conTypePicker.selectedSegmentIndex = 0
        currentConTypeIndex = 0
        
        self.datesPicker.selectRow(0, inComponent: 0, animated: true)
        self.datesPicker.selectRow(0, inComponent: 1, animated: true)
        minExpiryDateChosenIndex = 0
        maxExpiryDateChosenIndex = 0
        
        contractRangeSlider.lowerValue = 0.01
        contractRangeSlider.upperValue = 0.5
        contractRSLowerSet = 0.01
        contractRSUpperSet = 0.5
        
        underlyingRangeSlider.lowerValue = 0
        underlyingRangeSlider.upperValue = underlyingRSMaxVal
        underlyingRSUpperSet = 0
        underlyingRSUpperSet = underlyingRSMaxVal
    }
    
    @IBAction func restoreDefaultsButton(_ sender: Any) {
        restoreDefaults()
    }
    
    @IBAction func backButton(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.checkEmptyData, object: self)
        dismiss(animated: true)
    }
    
    @IBAction func conTypePickerTapped(_ sender: UISegmentedControl) {
       // self.current
        currentConTypeIndex = conTypePicker.selectedSegmentIndex
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        contractRSLowerSet = contractRangeSlider.getLowerLabel()
        contractRSUpperSet = contractRangeSlider.getUpperLabel()
        underlyingRSLowerSet = underlyingRangeSlider.getLowerLabel()
        underlyingRSUpperSet = underlyingRangeSlider.getUpperLabel()
        
        NotificationCenter.default.post(name: Notification.Name.saveFilters, object: self)
        dismiss(animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewRef.layer.borderWidth = 5
        viewRef.layer.cornerRadius = 10
        viewRef.layer.borderColor = UIColor.white.cgColor
        restoreDefaultsButton.titleLabel?.textAlignment = .center
        
        //setupViewDismissRecognizer()
        
        //contract type
        conTypePicker.selectedSegmentIndex = currentConTypeIndex
        
        // expiry date
        self.datesPicker.delegate = self
        self.datesPicker.dataSource = self
        self.datesPicker.selectRow(minExpiryDateChosenIndex, inComponent: 0, animated: false)
        self.datesPicker.selectRow(maxExpiryDateChosenIndex, inComponent: 1, animated: false)
        
        // contract range slider
        contractRangeSlider.lowerValue = contractRSLowerSet
        contractRangeSlider.upperValue = contractRSUpperSet
        
        // underlying range slider
        underlyingRangeSlider.setNumDecimals(num: 0)
        underlyingRangeSlider.maximumValue = underlyingRSMaxVal
        underlyingRangeSlider.lowerValue = underlyingRSLowerSet
        underlyingRangeSlider.upperValue = underlyingRSUpperSet
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
