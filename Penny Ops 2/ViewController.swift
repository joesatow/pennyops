//
//  ViewController.swift
//  Penny Ops 2
//
//  Created by Joe Satow on 3/14/20.
//  Copyright © 2020 Joe Satow. All rights reserved.
//

import UIKit
import SpreadsheetView
import RappleProgressHUD

class ViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 7
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + data.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if case 0 = column {
            return 200
        } else if case 1 = column {
            return 80
        } else if case 2 = column {
            return 70
        } else if case 3 = column {
            return 70
        } else if case 4 = column {
            return 70
        } else if case 5 = column {
            return 80
        } else {
            return 100
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 40
        } else {
            return 20
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    enum Sorting {
        case ascending
        case descending
        
        var symbol: String {
            switch self {
            case .ascending:
                return "\u{25B2}"
            case .descending:
                return "\u{25BC}"
            }
        }
    }
    
    var sortedColumn = (column: 1, sorting: Sorting.descending)
    
    func sortVol(){
        data.sort {
            let ascending = $0[sortedColumn.column].compare($1[sortedColumn.column], options: .numeric) == .orderedAscending
            return sortedColumn.sorting == .ascending ? ascending : !ascending
        }
        print("sorted")
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            //cell.label.text = header[indexPath.column]
            
            if case 0 = indexPath.column {
                cell.label.text = "Description"
            }
            if case 1 = indexPath.column {
                cell.label.text = "Volume"
            }
            if case 2 = indexPath.column {
                cell.label.text = "Last Price"
            }
            if case 3 = indexPath.column {
                cell.label.text = "Bid"
            }
            if case 4 = indexPath.column {
                cell.label.text = "Ask"
            }
            if case 5 = indexPath.column {
                cell.label.text = "Open Interest"
            }
            if case 6 = indexPath.column{
                cell.label.text = "Underlying Price"
            }
            
            let temp = cell.label.text
            if case indexPath.column = sortedColumn.column {
                //cell.sortArrow.text = sortedColumn.sorting.symbol
                cell.label.text = cell.label.text! + " " + sortedColumn.sorting.symbol
            } else {
                //cell.sortArrow.text = ""
                cell.label.text = temp
            }
            cell.backgroundColor = headerColor
            cell.label.textColor = UIColor.white
            cell.setNeedsLayout()
            
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            cell.label.text = data[indexPath.row - 1][indexPath.column]
            if (indexPath.row % 2 == 0){
                cell.backgroundColor = evenRowColor
            }
            else {cell.backgroundColor = oddRowColor}
            return cell
        }
    }
    
    /// Delegate
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if case 0 = indexPath.row {
            //old sorting method
            /*
            if sortedColumn.column == indexPath.column {
                sortedColumn.sorting = sortedColumn.sorting == .ascending ? .descending : .ascending
            } else {
                sortedColumn = (indexPath.column, .descending)
            }
            data.sort {
                let ascending = $0[sortedColumn.column].compare($1[sortedColumn.column], options: .numeric) == .orderedAscending
                return sortedColumn.sorting == .ascending ? ascending : !ascending
            } */
            
            //new sorting method
            if (sortedColumn.column == indexPath.column) {
                if (sortedColumn.sorting == Sorting.descending){
                    data.sort{$0[sortedColumn.column].compare($1[sortedColumn.column], options: .numeric) == .orderedAscending}
                    sortedColumn.sorting = Sorting.ascending
                }
                else {
                    data.sort{$0[sortedColumn.column].compare($1[sortedColumn.column], options: .numeric) == .orderedDescending}
                    sortedColumn.sorting = Sorting.descending
                }
            } else {
                sortedColumn.sorting = Sorting.descending
                sortedColumn.column = indexPath.column
                data.sort{$0[sortedColumn.column].compare($1[sortedColumn.column], options: .numeric) == .orderedDescending}
            }
            spreadsheetView.reloadData()
        }
    }
    
    
    //Properties
    var maxPrice = Double()
    
    var currentConTypeIndexVC = Int()
    var minExpiryDateChosenVC = Int()
    var maxExpiryDateChosenVC = Int()
    
    var contractRSLowerSetVC = 0.01
    var contractRSUpperSetVC = 0.5
    var underlyingRSLowerSetVC = 0.00
    var underlyingRSUpperSetVC = Double()
    var underlyingRSUpperSetMaxVC = Double()
    
    var header = [String]()
    var expiryDates = [String]()
    var expiryDatesNumeric = [String]()
    var data = [[String]]()
    var allData = [[String]]()
    var callsOnlyData = [[String]]()
    var putsOnlyData = [[String]]()
    var downloadResult: String = ""
    
    let evenRowColor = UIColor(red: 0.914, green: 0.914, blue: 0.906, alpha: 1)
    let oddRowColor: UIColor = .white
    let headerColor: UIColor = .darkGray
    
    //url session
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?

   
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    let urlPath = "http://pennyops.duckdns.org/tsvOutput.tsv"
    let datesUrlPath = "http://pennyops.duckdns.org/dates.tsv"
    let datesNumericUrlPath = "http://pennyops.duckdns.org/datesNumeric.tsv"
    let timeUrlPath = "http://pennyops.duckdns.org/penniesWriteTime.txt"
    var currentDateTime = ""

    @IBAction func filterButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "filterSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let fpVC = segue.destination as! FilterPopupViewController
        
        //SET max of underlying range slider
        fpVC.underlyingRSMaxVal = self.underlyingRSUpperSetMaxVC
        
        //contract type
        fpVC.currentConTypeIndex = self.currentConTypeIndexVC
        
        //expiry date
        fpVC.expiryDates = self.expiryDates
        var tempArray = self.expiryDates
        tempArray.removeFirst()
        fpVC.minDateArray = tempArray
        fpVC.minExpiryDateChosenIndex = self.minExpiryDateChosenVC
        fpVC.maxExpiryDateChosenIndex = self.maxExpiryDateChosenVC
        
        // contract range slider
        fpVC.contractRSLowerSet = self.contractRSLowerSetVC
        fpVC.contractRSUpperSet = self.contractRSUpperSetVC
        
        //underlying range slider
        fpVC.underlyingRSLowerSet = self.underlyingRSLowerSetVC
        fpVC.underlyingRSUpperSet = self.underlyingRSUpperSetVC
        
    }
    
    func showEmptyDataAlert(){
        let alert = UIAlertController(title: "Error", message: "No results for this filter query", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Back to filter", style: .default, handler: { action in
            self.performSegue(withIdentifier: "filterSegue", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Restore defaults", style: .cancel, handler: { action in
            
            RappleActivityIndicatorView.startAnimatingWithLabel("Restoring...", attributes: RappleAppleAttributes)
            DispatchQueue.global(qos: .userInteractive).async {
                // Background Thread
                // put your image loading here (for-loop)
                self.data = self.allData
                self.sortVol()
                
                DispatchQueue.main.async {
                    // Run UI Updates
                    
                    self.spreadsheetView.reloadData()
                    RappleActivityIndicatorView.stopAnimation()
                    
                    // restore defaults on sorter
                    self.currentConTypeIndexVC = 0
                    
                    self.minExpiryDateChosenVC = 0
                    self.maxExpiryDateChosenVC = 0
                    
                    self.contractRSLowerSetVC = 0.01
                    self.contractRSUpperSetVC = 0.5
                    
                    self.underlyingRSLowerSetVC = 0
                    self.underlyingRSUpperSetVC = self.underlyingRSUpperSetMaxVC
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        
        
        NotificationCenter.default.addObserver(forName: .saveFilters, object: nil, queue: OperationQueue.main) { (notification) in
            let filterVC = notification.object as! FilterPopupViewController
            
            // contract type
            if (self.currentConTypeIndexVC != filterVC.currentConTypeIndex){
                self.currentConTypeIndexVC = filterVC.currentConTypeIndex
            }
            
            // min expiry date
            if (self.minExpiryDateChosenVC != filterVC.minExpiryDateChosenIndex){
                self.minExpiryDateChosenVC = filterVC.minExpiryDateChosenIndex
            }
            
            // max expiry date
            if (self.maxExpiryDateChosenVC != filterVC.maxExpiryDateChosenIndex){
                self.maxExpiryDateChosenVC = filterVC.maxExpiryDateChosenIndex
            }
            
            // contract range slider
            if (self.contractRSLowerSetVC != filterVC.contractRSLowerSet){
                self.contractRSLowerSetVC = filterVC.contractRSLowerSet
            }
            
            if (self.contractRSUpperSetVC != filterVC.contractRSUpperSet){
                self.contractRSUpperSetVC = filterVC.contractRSUpperSet
            }
            
            // underlying range slider
            if (self.underlyingRSLowerSetVC != filterVC.underlyingRSLowerSet){
                self.underlyingRSLowerSetVC = filterVC.underlyingRSLowerSet
            }
            
            if (self.underlyingRSUpperSetVC != filterVC.underlyingRSUpperSet){
                self.underlyingRSUpperSetVC = filterVC.underlyingRSUpperSet
            }
           
            RappleActivityIndicatorView.startAnimatingWithLabel("Filtering...", attributes: RappleAppleAttributes)
            DispatchQueue.global(qos: .userInteractive).async {
                // Background Thread
                // put your image loading here (for-loop)
                
                ///////  ultimate filter  ////////
                
                //contract type
                self.data = self.allData
                let index = self.currentConTypeIndexVC
                
                if (index == 1){
                    self.data = self.data.filter {$0[0].contains("Call")}
                }
                else if (index == 2){
                    self.data = self.data.filter {$0[0].contains("Put")}
                }
                
                //min expiry date
                self.data = self.data.filter {$0[7] >= self.expiryDatesNumeric[self.minExpiryDateChosenVC]}
                
                //max expiry date
                if (self.maxExpiryDateChosenVC != 0){
                    self.data = self.data.filter {$0[7] <= self.expiryDatesNumeric[self.maxExpiryDateChosenVC - 1]}
                }
                
                //contract range slider
                self.data = self.data.filter {($0[2] as NSString).doubleValue >= self.contractRSLowerSetVC}
                self.data = self.data.filter {($0[2] as NSString).doubleValue <= self.contractRSUpperSetVC}
                
                //underlying range slider
                self.data = self.data.filter {($0[6] as NSString).doubleValue >= self.underlyingRSLowerSetVC}
                self.data = self.data.filter {($0[6] as NSString).doubleValue <= self.underlyingRSUpperSetVC}
                
                //final sort
                self.sortVol()
                
                DispatchQueue.main.async {
                    // Run UI Updates
                    
                    //reload
                    self.spreadsheetView.reloadData()
                    
                    RappleActivityIndicatorView.stopAnimation()
                    if (self.data.count == 0){
                        self.showEmptyDataAlert()
                    }
                }
            }
        }
        
         NotificationCenter.default.addObserver(forName: .checkEmptyData, object: nil, queue: OperationQueue.main) { (notification) in
            let filterVC = notification.object as! FilterPopupViewController
            
            if (self.data.count == 0){
                filterVC.dismiss(animated: true){
                    self.showEmptyDataAlert()
                }
            }
        }
        
        //spreadsheet view
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
    }
   
    func getExpiryDates(){
        let url: URL = URL(string: self.datesUrlPath)!
        let configuration = URLSessionConfiguration.ephemeral
        let defaultSession = Foundation.URLSession(configuration: configuration)
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Error")
            }else {
                print("dates downloaded")
                self.downloadResult = String(data: data!, encoding: String.Encoding.utf8) as String!
                //print(self.downloadResult)
                self.expiryDates = self.downloadResult
                    .components(separatedBy: "\n")
                self.expiryDates = Array(self.expiryDates.dropFirst())
                self.expiryDates = Array(self.expiryDates.dropLast())
                self.expiryDates.insert("(none)", at: 0)
                semaphore.signal()
            }
            
        }
        task.resume()
        semaphore.wait()
    }
    
    func getExpiryDatesNumeric(){
        let url: URL = URL(string: self.datesNumericUrlPath)!
        let configuration = URLSessionConfiguration.ephemeral
        let defaultSession = Foundation.URLSession(configuration: configuration)
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Error")
            }else {
                print("numeric dates downloaded")
                self.downloadResult = String(data: data!, encoding: String.Encoding.utf8) as String!
                //print(self.downloadResult)
                self.expiryDatesNumeric = self.downloadResult
                    .components(separatedBy: "\n")
                self.expiryDatesNumeric = Array(self.expiryDatesNumeric.dropFirst())
                self.expiryDatesNumeric = Array(self.expiryDatesNumeric.dropLast())
                semaphore.signal()
            }
            
        }
        task.resume()
        semaphore.wait()
    }
    
    func getMaxUnderlying(){
        //get max underlying for range slider
        var tempMaxUnderlyingArray = self.allData
        tempMaxUnderlyingArray.sort{$0[6].compare($1[6], options: .numeric) == .orderedDescending}
        let toDouble = ((tempMaxUnderlyingArray[0][6] as NSString).doubleValue) * 1.05
        let newMaxNum = Double(10 * Int(ceil(toDouble / 10.0)))
        self.underlyingRSUpperSetMaxVC = newMaxNum
        self.underlyingRSUpperSetVC = newMaxNum
    }
    
    func getData(){
        let url: URL = URL(string: self.urlPath)!
        let configuration = URLSessionConfiguration.ephemeral
        let defaultSession = Foundation.URLSession(configuration: configuration)
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Error")
            }else {
                print("stocks downloaded")
                self.downloadResult = String(data: data!, encoding: String.Encoding.utf8) as String!
                
               
                self.data = self.downloadResult
                    .components(separatedBy: "\n")
                    .map { $0.components(separatedBy: "\t") }
                self.header = self.data[0]
                self.data = Array(self.data.dropFirst())
                self.data = Array(self.data.dropLast())
                self.allData = self.data
                self.getMaxUnderlying()
                semaphore.signal()
            }
            
        }
        
        task.resume()
        semaphore.wait()
    }
    
    func getLastTime()
    {
        let url: URL = URL(string: self.timeUrlPath)!
        let configuration = URLSessionConfiguration.ephemeral
        let defaultSession = Foundation.URLSession(configuration: configuration)
        let semaphore = DispatchSemaphore(value: 0)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Error")
            }else {
                print("time downloaded")
                let lastTime = String(data: data!, encoding: String.Encoding.utf8) as String!
                
                
                self.currentDateTime = lastTime!
                semaphore.signal()
            }
            
        }
        
        task.resume()
        semaphore.wait()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spreadsheetView.flashScrollIndicators()
    }
}

