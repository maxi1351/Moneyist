//
//  ChartViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit
import Charts
import Alamofire

class ChartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {
    // UIPickerViewDelegate, UIPickerViewDataSource,
    
    @IBOutlet var pieChart: PieChartView!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var chartTable: UITableView!
    //@IBOutlet weak var monthAndYearLabel: UILabel!
    
    // Store data from server
    var pieChartData = [PieChart]()                          // Pie chart data
    var barChartData : BarChart? = nil                       // Bar chart data
    var spendingCategories = [SpendingCategory]()            // All spending categories
    var pieChartTableDetails = [ChartTableData]()            // Store data needed for pie chart table view
    var barChartTableDetails = [ChartTableData]()            // Store data needed bar chart table view
    
    let SERVER_ADDRESS_PIE_CHART = "http://localhost:4000/transaction/graph/pieChart"       // Get pie chart data
    let SERVER_ADDRESS_BAR_CHART = "http://localhost:4000/transaction/graph/barChart"       // Get bar chart data
    let SERVER_ADDRESS_ALL = "http://localhost:4000/spendingCategory/all"                   // Get all spending categories
    
    //let screenWidth = UIScreen.main.bounds.width - 10
    //let screenHeight = UIScreen.main.bounds.height / 2.5
    var chartType = "Pie Chart"
   // var months = [Month(month: "00", monthName: "--")]    // Months for picker view
    //let years = (1900...2200).map { String($0) }          // Years for picker view
   
    // Month name and number
    struct Month {
        var month : String
        var monthName : String
    }
    
    // All data needed for chart
    struct ChartTableData {
        var name : String
        var amount : String
        var percentage : String
        var color : UIColor
    }
    
    
   /* @IBAction func nextButton(_ sender: Any) {
        if(monthly == true) {
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
            monthAndYearLabel.text = getMonth(date: selectedDate, numberFormat: false) + " " + setLabelYear(date: selectedDate)
            date = setLabelYear(date: selectedDate) + "/" + getMonth(date: selectedDate, numberFormat: true)
        }
        else {
            selectedDate = calendar.date(byAdding: .year, value: 1, to: selectedDate)!
            monthAndYearLabel.text = setLabelYear(date: selectedDate)
            date = setLabelYear(date: selectedDate)
        }
        
        print("Start Date = " + getStartDate())
        print("End Date = " + getEndDate())
        //displayChart()
    }
    
    @IBAction func previousButton(_ sender: Any) {
        
        if(monthly == true) {
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
            monthAndYearLabel.text = getMonth(date: selectedDate, numberFormat: false) + " " + setLabelYear(date: selectedDate)
        }
        else {
            selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate)!
            monthAndYearLabel.text = getMonth(date: selectedDate, numberFormat: false) + " " + setLabelYear(date: selectedDate)
        }
        
        print("Start Date = " + getStartDate())
        print("End Date = " + getEndDate())
        //displayChart()
    }*/
    
    @IBAction func chartSegment(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == 0) {
            chartType = "Pie Chart"
        }
        
        else if(sender.selectedSegmentIndex == 1) {
            chartType = "Bar Chart"
        }
        
        chartTable.isHidden = true
        barChart.isHidden = true
        pieChart.isHidden = true
        displayChart()
    }
    
    func displayChart() {
        if(chartType == "Pie Chart") {
            getPieChartData()
        }
        else if(chartType == "Bar Chart") {
            getBarChartData()
        }
    }
    
    // MARK: - Chart view
    
   /* func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] {
            let index: Int = dataSet.entryIndex(entry: entry)
            print("Selected index = \(index)")
        }
    } */
    
    func handleValidationError(data: Data) {
        
        struct error: Codable {
            var msg: String
        }
        
        struct errorValidation: Codable {
            var errors: [error]
            //var param: String
        }
        
        //let errorsArray = [errorValidation]()

        let decoder = JSONDecoder()
        
        do {
            let result = try decoder.decode(errorValidation.self, from: data)
            
            /*for entry in result {
                print(entry.msg)
            }*/
            print("ERRORS FOUND: ")
            
            for e in result.errors {
                // Ask user if they are sure using an alert
                let alert = UIAlertController(title: "Error", message: e.msg, preferredStyle: .alert)
                
                // Controls what happens after the user presses YES
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                   
                }
               
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
            }
            
            
        } catch {
            print(error)
        }
    }
    
    // Get all spending categories from server
    func getSpendingCategories() {
        AF.request(SERVER_ADDRESS_ALL, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print("SERVER RESPONSE")
                //print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode([SpendingCategory].self, from: response.data!)
                                        
                    DispatchQueue.main.async {
                        // Save result of request
                        self.spendingCategories = result
                        // Reload data
                        //self.reloadTable()
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }

    // Get transactions associated with a category from server
    func getPieChartData() {

        AF.request(SERVER_ADDRESS_PIE_CHART, method: .post, encoding: JSONEncoding.default)
            .responseJSON { response in
                print("SERVER RESPONSE PIE CHART")
                print(response)
                //debugPrint(response)

                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode([PieChart].self, from: response.data!)
                    print("Pie chart result")
                    print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.pieChartData = result
                        let dataSet = self.setPieChartData()
                        self.pieChartProperties()
                        self.formatPieChartDataSet(dataSet: dataSet)
                        self.pieChart.isHidden = false
                        self.chartTable.isHidden = false
                        self.reloadTable()
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    // Get income and expenses from server
    func getBarChartData() {
        
        AF.request(SERVER_ADDRESS_BAR_CHART, method: .post, encoding: JSONEncoding.default)
            .responseJSON { response in
                print("SERVER RESPONSE BAR CHART")
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode(BarChart.self, from: response.data!)
                    
                    print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.barChartData = result
                        
                        /*if(self.barChartData?.incomeAmount == 0 && self.barChartData?.outcomeAmount == 0) {
                            self.barChart.isHidden = true
                        }*/
                        
                        self.setBarChartData()
                        self.barChartProperties()
                        self.barChart.isHidden = false
                        self.chartTable.isHidden = false
                        self.reloadTable()
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    func setPieChartData() -> ChartDataSet {
        
        let colours = UserDetails.sharedInstance.getColours()      // Get all spending category colours
        var pieChartEntries = [PieChartDataEntry]()                // Store pie chart data entries
        var pieChartColours = [UIColor]()                          // Store colours needed for pie chart
        var totalAmount = 0.0
        
        pieChartData.sort { $0.amount > $1.amount }         // Sort descendig order
        
        // Empty all arrays
        pieChartTableDetails.removeAll()
        pieChartColours.removeAll()
        
        // Calculate sum of all categories
        for transaction in pieChartData {
            totalAmount += Double(transaction.amount)
        }
        
        // Store data for pie chart and table
        for transaction in pieChartData {
            let label = transaction.name
            let amount = transaction.amount
            let percentage = round((Double(amount) / totalAmount) * 100 * 10) / 10.0
            var colourName = ""
            var categoryColour = UIColor.clear
            
            // Find category colour name from category id
            for category in spendingCategories {
                if(transaction.categoryId == category._id) {
                    colourName = category.colour
                }
            }
            
            // Find category UIColour from colour name
            for colour in colours {
                if(colourName == colour.name) {
                    categoryColour = colour.colour
                }
            }
            
            guard percentage > 0 else { continue }
            // Store data for pie chart
            let dataEntry = PieChartDataEntry(value: percentage, label: label)
            pieChartEntries.append(dataEntry)
            
            // Store data for pie chart table view
            let tableDetails = ChartTableData(name: label, amount: convertToDecimal(number: Int(amount)), percentage: String(percentage), color: categoryColour)
            pieChartTableDetails.append(tableDetails)
            pieChartColours.append(categoryColour)
        }
        
        //pieChartEntries.sort { $0.value > $1.value }
        //pieChartTableDetails.sort { $0.percentage > $1.percentage }
        
        let chartDataSet = PieChartDataSet(entries: pieChartEntries, label: "")
        let chartData = PieChartData(dataSet: chartDataSet)
        pieChart.data = chartData
                
        // Store colours for pie chart
        chartDataSet.colors = pieChartColours
        
        return chartDataSet
    }
    
    //
    func pieChartProperties() {
        pieChart.rotationEnabled = false                                      // Disable rotation
        pieChart.animate(xAxisDuration: 0.5, easingOption: .easeInOutCirc)    // Animate chart when view loads
        pieChart.drawEntryLabelsEnabled = false                               // Hide labels on chart
        pieChart.usePercentValuesEnabled = true                               // Display percentages on chart
        pieChart.legend.enabled = false                                       // Disable colours and labels at the bottom
        pieChart.holeColor = UIColor.systemBackground                         // Set colour of hole to background colour of view
        pieChart.holeRadiusPercent = CGFloat(0.52)                            // Adjust size of chart center
        
        pieChart.highlightPerTapEnabled = false         // Disabkle highlighting when tapped
        
        //chartView.centerText = "£ " + String(Int(totalAmount))              // Display category in the center
        //chartView.centerTextRadiusPercent = 0.95                            // Make sure text fits within the center

        //chartView.centerAttributedText = String(Int(totalAmount))
        
        // When slice is tapped, category is displayed
        //chartView.description.text = category.rawValue.capitalized
        //chartView.description.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    //
    func formatPieChartDataSet(dataSet: ChartDataSet) {
        // Display value inside the center when slice is selected
        
        dataSet.drawValuesEnabled = false           // Disable values on chart
    }
    
    
    func setBarChartData() {
        
        let barChartColors = [#colorLiteral(red: 0.4409350055, green: 0.74609375, blue: 0.03125605582, alpha: 1), #colorLiteral(red: 0.6575858161, green: 0.03585042212, blue: 0.1424569237, alpha: 1)]                     // Colours for bar chart
        var barChartEntries = [BarChartDataEntry]()       // Store bar chart data entries

        // Empty array
        barChartTableDetails.removeAll()
        
        let income = Double(barChartData?.incomeAmount ?? 0)
        let expenses = Double(barChartData?.outcomeAmount ?? 0)
        
        let incomeEntry = BarChartDataEntry(x: Double(1), y: income)
        let outcomeEntry = BarChartDataEntry(x: Double(2), y: expenses)
            barChartEntries.append(incomeEntry)
            barChartEntries.append(outcomeEntry)
        
        // Store data for bar chart
        let barChartDataset = BarChartDataSet(entries: barChartEntries, label: "Amount")
        let chartData = BarChartData(dataSet: barChartDataset)
        barChart.data = chartData
        
        barChartDataset.colors = barChartColors             // Store colours for bar chart
        chartData.barWidth = Double(0.4)                    // Change bar width
        barChartDataset.drawValuesEnabled = false           // Remove values above bars
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Income", "Expenses"])       // Label X axis
        
        // Calculate percentages to 1 decimal place
        let total = income + expenses
        let incomePercent = round((income / total) * 100 * 10) / 10.0
        let expensePercent = round((expenses / total) * 100 * 10) / 10.0

        // Store income details for table view
        let incomeDetails = ChartTableData(name: "Income", amount: convertToDecimal(number: Int(income)), percentage: String(incomePercent), color: barChartColors[0])
        barChartTableDetails.append(incomeDetails)
        
        // Store expense details for table view
        let expenseDetails = ChartTableData(name: "Expenses", amount: convertToDecimal(number: Int(expenses)), percentage: String(expensePercent), color: barChartColors[1])
        barChartTableDetails.append(expenseDetails)
    }
    
    
    // Customise appearance of bar chart
    func barChartProperties() {

        barChart.legend.enabled = false                     // Remove legend under the bar chart
        barChart.rightAxis.enabled = false                  // Remove the right y axis
        barChart.xAxis.labelPosition = .bottom              // Move x axis to the bottom of the bar chart
        barChart.xAxis.drawGridLinesEnabled = false         // Remove vertical grid lines
        //barChart.leftAxis.drawGridLinesEnabled = false
        
        
        // Change colour of horizontal grid lines, y axis and x axis
        let lightGrey = #colorLiteral(red: 0.7636238628, green: 0.8182056074, blue: 0.8185921308, alpha: 1)
        let grey = #colorLiteral(red: 0.8182362719, green: 0.8735225065, blue: 0.8735225065, alpha: 1)
        barChart.leftAxis.gridColor = grey
        barChart.xAxis.axisLineColor = lightGrey
        barChart.leftAxis.axisLineColor = lightGrey
        
        // Remove axis lines
        barChart.leftAxis.drawAxisLineEnabled = false
        //barChart.xAxis.drawAxisLineEnabled = false
        
        barChart.xAxis.drawLabelsEnabled = false                        // Hide x axis labels
        barChart.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)        // Animate chart when it loads
        
        // Disable user interaction with chart
        barChart.doubleTapToZoomEnabled = false
        barChart.highlightPerTapEnabled = false
        
        // Change colour of x and y axis labels
        barChart.leftAxis.labelTextColor = #colorLiteral(red: 0.5184787889, green: 0.5184787889, blue: 0.5184787889, alpha: 1)
        barChart.xAxis.labelTextColor = #colorLiteral(red: 0.5184787889, green: 0.5184787889, blue: 0.5184787889, alpha: 1)
        
        barChart.xAxis.granularityEnabled = true
        barChart.xAxis.granularity = 1.0
        //barChartView.xAxis.decimals = 0
        
        barChart.xAxis.axisMinimum = 0.0
        //chartView.xAxis.axisMaximum = 2.0
        barChart.xAxis.labelCount = 2
        barChart.fitBars = true
        barChart.xAxis.spaceMin = 0.0
        
        barChart.xAxis.centerAxisLabelsEnabled = true
        // barChart.xAxis.labelPosition = .topInside
        
        barChart.leftAxis.axisMinimum = 0.0
    }
    
    // Add commas to integer
    func convertToDecimal(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let convertedNumber = numberFormatter.string(from: NSNumber(value: number)) ?? ""
        
        return convertedNumber
    }
    
    // MARK: - Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0;
        
        if(chartType == "Pie Chart") { rows = pieChartTableDetails.count }
        else if(chartType == "Bar Chart") { rows = barChartTableDetails.count }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath) as! ChartTableViewCell
        
        if(chartType == "Pie Chart") {
            cell.nameLabel.text = pieChartTableDetails[indexPath.row].name
            cell.amountLabel.text = "£ " + pieChartTableDetails[indexPath.row].amount
            let valueString = String(pieChartTableDetails[indexPath.row].percentage)
            cell.percentLabel.text = valueString + " %"
            cell.colourLabel.backgroundColor = pieChartTableDetails[indexPath.row].color
        }
        
        else if(chartType == "Bar Chart") {
            cell.nameLabel.text = barChartTableDetails[indexPath.row].name
            cell.amountLabel.text = "£ " + barChartTableDetails[indexPath.row].amount
            cell.percentLabel.text = barChartTableDetails[indexPath.row].percentage + " %"
            cell.colourLabel.backgroundColor = barChartTableDetails[indexPath.row].color
        }
        
        // Change colour label shape to circle
        cell.colourLabel.layer.cornerRadius = 6
        cell.colourLabel.layer.masksToBounds = true
        
        return cell
    }
    
    // Refresh chart table
    func reloadTable() {
        chartTable.reloadData()
    }
    
    
    // MARK: - Month and Year Picker View

  /*  func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var rows = 0
        
        if(component == 0) { rows = months.count }
        else { rows = years.count }
        
        return rows
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        
        if(component == 0) {
            label.text = months[row].monthName
        }
        else if(component == 1) {
            label.text = years[row]
        }

        label.sizeToFit()
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    // Display a pop up picker view with months and years when user clicks on the month and year label
    func displayMonthAndYearPicker() {
        
        var selectedMonthRow = 5
        var selectedYearRow = 121
        var selectedMonth = ""
        var selectedYear = ""
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let monthAndYearPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        monthAndYearPicker.dataSource = self
        monthAndYearPicker.delegate = self
        monthAndYearPicker.selectRow(selectedMonthRow, inComponent: 0, animated: false)
        monthAndYearPicker.selectRow(selectedYearRow, inComponent: 1, animated: false)
        
        vc.view.addSubview(monthAndYearPicker)
        monthAndYearPicker.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        monthAndYearPicker.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "DATE", message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = monthAndYearLabel
        alert.popoverPresentationController?.sourceRect = monthAndYearLabel.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        // 'Cancel' button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            self.monthAndYearLabel.endEditing(true)
        }))
        
        // 'Select' button to confirm user's selection
        alert.addAction(UIAlertAction(title: "Select", style: .default , handler: { (UIAlertAction) in
            selectedMonthRow = monthAndYearPicker.selectedRow(inComponent: 0)
            selectedYearRow = monthAndYearPicker.selectedRow(inComponent: 1)
            selectedMonth = self.months[selectedMonthRow].monthName
            selectedYear = self.years[selectedYearRow]
                            
            if(selectedMonth == "--") {
                self.monthAndYearLabel.text = selectedYear
                self.monthly = false
                self.date = selectedYear
                print("Start Date = " + self.getStartDate())
                print("End Date = " + self.getEndDate())
            }
            else {
                self.monthAndYearLabel.text = selectedMonth + " " + selectedYear
                self.monthly = true
                self.date = selectedYear + "/" + self.months[selectedMonthRow].month
                print("Start Date = " + self.getStartDate())
                print("End Date = " + self.getEndDate())
            }
    
            self.monthAndYearLabel.endEditing(true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Display month and year inside label
    func setLabelMonthAndYear(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func getMonth(date: Date, numberFormat: Bool) -> String {
        let dateFormatter = DateFormatter()
        if(numberFormat == false) {
            dateFormatter.dateFormat = "LLLL"
        }
        else {
            dateFormatter.dateFormat = "MM"
        }
        
        return dateFormatter.string(from: date)
    }
    
    // Display only year inside label
    func setLabelYear(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    // Total number of days in the month
    func totalDaysInMonth() -> Int {
        let days = calendar.range(of: .day, in: .month, for: selectedDate)
        
        return days!.count
    }
    
    // Pass global var date as a parameter instead
    // Change into a function that returns a dictionary of start and end date (timePeriod)
    
    func getStartDate() -> String {
        var startDate = ""
        
        if(monthly == true) {
            startDate = date + "/01"
        }
        else {
            startDate = date + "/01/01"
        }
        
        return startDate
    }
    
    func getEndDate() -> String {
        var endDate = ""
        let startDate = getStartDate()
        
        if(monthly == true) {
            //let lastDay = convertToDate(date: startDate)
            endDate = date + "/" + String(totalDaysInMonth())
        }
        else {
            endDate = date + "/12/31"
        }
        
        return endDate
    }
    
   /* func monthAndYear(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL YYYY"
        
        return dateFormatter.string(from: date)
    }*/
    
    func convertToDate(date: String) -> String {
        print("Start date parameter = \(date)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let convertedDate = dateFormatter.date(from: date)!
        print("converted string to date = \(convertedDate)")
        let days = calendar.range(of: .day, in: .month, for: convertedDate)
        
        return String(days!.count)
    }
    
    
    func getStartDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/mm/dd"
        
        return dateFormatter.date(from: date)!
    }
   
    // MARK: - Month and Year Label
    
    func addTapToLabel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        monthAndYearLabel.isUserInteractionEnabled = true
        monthAndYearLabel.addGestureRecognizer(tap)
    }
    
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        displayMonthAndYearPicker()
    }*/
    
    // Create array with all the months in a year
    /*func createMonthArray() {
        
        let calendar = Calendar.current
        let allMonths = calendar.monthSymbols
        
        for i in 1...12 {
            var j = "\(i)"
            
            if(i < 10) {
                j = "0\(i)"
            }
            
            let month = Month(month: j, monthName: allMonths[i-1])
            months.append(month)
        }
    }*/
    
    // MARK: - View controller

    override func viewWillAppear(_ animated: Bool) {
        print("Reloading Chart VC")

        getSpendingCategories()
        
        if(chartType == "Pie Chart") { getPieChartData() }
        else { getBarChartData() }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chart"
        print(self.title! + " loaded!")
        getSpendingCategories()

        // Set month & year button title
        //monthAndYearLabel.text = setLabelMonthAndYear(date: selectedDate)
        
        barChart.isHidden = true
        
        if(chartType == "Pie Chart") { getPieChartData() }
        else { getBarChartData() }
        
        //addTapToLabel()
        
        //createMonthArray()
        //testDate(date: "January")
        
    }
    
    func testDate(date: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL"
        
        formatter.dateFormat = "MM"
        let result = formatter.string(from: formatter.date(from: date)!)
        
        print("Converted String to Date = " + result)
    }
    
}
