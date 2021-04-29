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
    
    @IBOutlet var pieChart: PieChartView!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var chartTable: UITableView!
    
    @IBAction func chartSegment(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == 0) {
            chartType = "Pie Chart"
            barChart.isHidden = true
            pieChart.isHidden = false
            getPieChartData()
        }
        
        else if(sender.selectedSegmentIndex == 1) {
            chartType = "Bar Chart"
            pieChart.isHidden = true
            barChart.isHidden = false
            getBarChartData()
        }
    }
    
    // Store the colour name and the associated colour to be displayed to user
    let colours: [Colour] = [Colour(name : "Red", colour : #colorLiteral(red: 0.672542908, green: 0.02437681218, blue: 0, alpha: 1)), Colour(name : "Pink", colour : #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)), Colour(name : "Purple", colour : #colorLiteral(red: 0.4643272758, green: 0.3070220053, blue: 0.7275875211, alpha: 1)), Colour(name : "Blue", colour : #colorLiteral(red: 0.2000421584, green: 0.6995770335, blue: 0.6809796691, alpha: 1)), Colour(name : "Dark Blue", colour : #colorLiteral(red: 0.06944768974, green: 0.02640548434, blue: 0.5723825901, alpha: 1)), Colour(name : "Green", colour : #colorLiteral(red: 0.5690675291, green: 0.8235294223, blue: 0.294384024, alpha: 1)), Colour(name : "Dark Green", colour : #colorLiteral(red: 0.06251720995, green: 0.44866765, blue: 0.1985127027, alpha: 1)), Colour(name : "Yellow", colour : #colorLiteral(red: 0.9764705896, green: 0.8267891201, blue: 0.0127835515, alpha: 1)), Colour(name : "Orange", colour : #colorLiteral(red: 0.8495022058, green: 0.4145209409, blue: 0.07371198884, alpha: 1)), Colour(name : "Grey", colour : #colorLiteral(red: 0.7645047307, green: 0.7686187625, blue: 0.772662282, alpha: 1)), Colour(name : "Lilac", colour : #colorLiteral(red: 0.8340004433, green: 0.75248796, blue: 0.9177663536, alpha: 1))]
    
    //var pieChartData = [PieChart]()          // Store pie chart data from server
    var pieChartData : PieChart? = nil         // Store pie chart data from server
    var barChartData : BarChart? = nil          // Store bar chart data from server
    var spendingCategories = [SpendingCategory]()      // Store all categories
    
    //var transactions = [Transaction]()
    var chartType = "Pie Chart"
    
    // Server address to get pie chart data
    let SERVER_ADDRESS_PIE_CHART = "http://localhost:4000/transaction/graph/pieChart"
    // Server address to get bar chart data
    let SERVER_ADDRESS_BAR_CHART = "http://localhost:4000/transaction/graph/barChart"
    // Server address to get all spending categories
    let SERVER_ADDRESS_ALL = "http://localhost:4000/spendingCategory/all/" //+ UserDetails.sharedInstance.getUID()


   /* struct PieChart : Codable {
        var categoryId : String
        var name : String
        var amount : Int32
    }*/
   
    // Pie chart data received from server
    /*struct PieChart : Codable {
        var catgeory : String
        var amount: String
    }*/
    
    // Bar chart data received from server
   /* struct BarChart : Codable {
        var incomeAmount: Int32
        var outcomeAmount: Int32
    } */
    
    // All data needed for chart
    struct ChartTableData {
        var name : String
        var amount : String
        var percentage : String
        var color : UIColor
    }
    
    struct PieChartPercentage{
        var label : String
        var value : Double
    }
    
    
    var pieChartEntires = [PieChartDataEntry]()   // Store pie chart data entries
    var pieChartTableDetails = [ChartTableData]()          // Store data needed for pie chart table view
    var pieChartPercentages = [PieChartPercentage]()
    var pieChartColours = [UIColor]()
    var barChartEntries = [BarChartDataEntry]()   // Store bar chart data entries
    var barChartTableDetails = [ChartTableData]()          // Store data needed bar chart table view
    var barChartColors = [#colorLiteral(red: 0.4794762726, green: 0.7111433768, blue: 1, alpha: 1), #colorLiteral(red: 0.8048898964, green: 0.561850013, blue: 0.7715510006, alpha: 1)]                 // Colours for bar chart
    
    
    let array = [PieChart]()                // CHANGE!!!

    //****************************************************
    
    //var percentages = PieChartDataEntry(value: 0)
    //var allPercentages = [BudgetPercentages]()
    //let colors = [#colorLiteral(red: 0.03912452236, green: 0.3398694694, blue: 0.4359056056, alpha: 1), #colorLiteral(red: 0.153665185, green: 0.5830183625, blue: 0.4813076258, alpha: 1), #colorLiteral(red: 0.6497512167, green: 0.8048898964, blue: 0.1597088941, alpha: 1)]
    //var selectedIndex = 0
    let colorsArray = [#colorLiteral(red: 0.03912452236, green: 0.3398694694, blue: 0.4359056056, alpha: 1), #colorLiteral(red: 0.2000421584, green: 0.6995770335, blue: 0.6809796691, alpha: 1), #colorLiteral(red: 0.153665185, green: 0.5830183625, blue: 0.4813076258, alpha: 1), #colorLiteral(red: 0.175951435, green: 0.6201614255, blue: 0.2976064565, alpha: 1), #colorLiteral(red: 0.7415904999, green: 0.9133911133, blue: 0.1858743429, alpha: 1)]
    
   /* struct Budget {
        var name : String
        var amount : Double
    }
    
    struct BudgetPercentages {
        var label : String
        var value : Double
    }
    
    struct BudgetDetails {
        var details : Budget
        var percent : Double
        var color : UIColor
    }*/
    
    //****************************************************
    
    
    
    // MARK: - Chart view
    
   /* func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] {
            let index: Int = dataSet.entryIndex(entry: entry)
            print("Selected index = \(index)")
        }
    } */
    
     /*var timePeriod = [
         "startDate" : "",
         "endDate" : ""
     ]*/
    
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
                print("SERVER RESPONSE")
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode([SpendingCategory].self, from: response.data!)
                    
                    print(result)
                    
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
        
        let timePeriod: Parameters = ["startDate": "2021/05/01", "endDate": "2021/06/01"]
        
        //method: .get, parameters: timePeriod, encoding: URLEncoding.default

        AF.request(SERVER_ADDRESS_PIE_CHART, method: .get, parameters: timePeriod, encoding: URLEncoding.default)
            .responseJSON { response in
                print("1")
                print(response.error as Any)
                print("2")
                print(response.data as Any)
                print("SERVER RESPONSE PIE CHART")
                print(response.description)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode(PieChart.self, from: response.data!)
                    
                    print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.pieChartData = result
                        self.setPieChartData()
                        self.pieChartProperties()
                        self.reloadTable()
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    // Get income and expenses from server
    func getBarChartData() {
        
        let timePeriod: Parameters = ["startDate": "1991/01/01", "endDate": "2001/01/01"]
        
        //method: .get, parameters: timePeriod, encoding: URLEncoding.default

        AF.request(SERVER_ADDRESS_BAR_CHART, encoding: JSONEncoding.default)
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
                        
                        if(self.barChartData?.incomeAmount == 0 && self.barChartData?.outcomeAmount == 0) {
                            self.barChart.isHidden = true
                        }
                        
                        self.setBarChartData()
                        self.barChartProperties()
                        self.reloadTable()
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    func setPieChartData() {
        
        var totalAmount = 0.0
        
        // Empty all arrays
        pieChartEntires.removeAll()
        pieChartTableDetails.removeAll()
        
        // Replace 'array' with info from server
        for transaction in array {
            totalAmount += Double(transaction.amount)
        }
        
        // Replace 'array' with info from server
        for (transaction, colour) in zip(array, colours) {
            let label = transaction.name
            let amount = transaction.amount
            let percentage = (Double(amount) / totalAmount) * 100
            var colourName = ""
            var categoryColour = UIColor.clear
            
            for category in spendingCategories {
                if(transaction.categoryId == category._id) {
                    colourName = category.colour
                }
            }
            
            for colour in colours {
                if(colourName == colour.name) {
                    categoryColour = colour.colour
                }
            }
            
            // Store data for chart
            let dataEntry = PieChartDataEntry(value: percentage, label: label)
            pieChartEntires.append(dataEntry)
            // Store data for table view
            let tableDetails = ChartTableData(name: label, amount: convertToDecimal(number: Int(amount)), percentage: String(percentage), color: categoryColour)
            pieChartTableDetails.append(tableDetails)
            pieChartColours.append(categoryColour)
        }

        
        
       /* allPercentages.removeAll()
        budgetDetails.removeAll()
        
        
        
        // Test data
        pieChart.chartDescription.text = ""
        let data : [Budget] = [Budget(name : "Label 1", amount: 2500), Budget(name : "Label 2", amount: 1500), Budget(name : "Label 3", amount: 1000),]
        
        for item in data {
            totalAmount += item.amount
        }
        
        for (budget, color) in zip(data, colors) {
            let label = budget.name
            let percentage = round((budget.amount / totalAmount) * 100 * 10) / 10.0
            let colour = color
            
            
            let labelPercentage = BudgetPercentages(label: label, value: percentage)
            allPercentages.append(labelPercentage)
            let details = BudgetDetails(details: budget, percent: percentage, color: colour)
            budgetDetails.append(details)
        }
        
        pieChartEntires = allPercentages.map { PieChartDataEntry(value: $0.value, label: $0.label)}
         */
        
        //print("Entries = \(entries)")
        //print("All Spendings Categories = \(allSpendingCategories)")
    }
    
    //
    func pieChartProperties() {
        // Disable rotation
        pieChart.rotationEnabled = false
        // Animate chart when view loads
        pieChart.animate(xAxisDuration: 0.5, easingOption: .easeInOutCirc)
        // Hide labels on chart
        pieChart.drawEntryLabelsEnabled = false
        // Display percentages on chart
        pieChart.usePercentValuesEnabled = true
        // Disable colours and labels at the bottom
        pieChart.legend.enabled = false
        // Set colour of hole to background colour of view
        pieChart.holeColor = UIColor.systemBackground
        // Adjust size of chart center
        pieChart.holeRadiusPercent = CGFloat(0.52)
        
        // Display category in the center
        //chartView.centerText = "£ " + String(Int(totalAmount))
        // Make sure text fits within the center
        //chartView.centerTextRadiusPercent = 0.95
        
        //chartView.centerAttributedText = String(Int(totalAmount))
        
        // When slice is tapped, category is displayed
        //chartView.description.text = category.rawValue.capitalized
        //chartView.description.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    //
    func formatPieChartDataSet(dataSet: ChartDataSet) {
        // Display value inside the center when slice is selected
        // Disable values on chart
        dataSet.drawValuesEnabled = false
    }
    
    
    func updatePieChartData() -> ChartDataSet {
        let chartDataSet = PieChartDataSet(entries: pieChartEntires, label: "")
        let chartData = PieChartData(dataSet: chartDataSet)
        
        // From assets
        //let colors = [UIColor(named: "iosColor"), UIColor(named: "macColor")]
        chartDataSet.colors = pieChartColours
        pieChart.data = chartData
        
        return chartDataSet
    }
    
    func setBarChartData() {
        
        // Empty all arrays
        barChartEntries.removeAll()
        barChartTableDetails.removeAll()
        
        let income = Double(barChartData?.incomeAmount ?? 0)
        let expenses = Double(barChartData?.outcomeAmount ?? 0)
        
        let incomeEntry = BarChartDataEntry(x: Double(1), y: income)
        let outcomeEntry = BarChartDataEntry(x: Double(2), y: expenses)
            barChartEntries.append(incomeEntry)
            barChartEntries.append(outcomeEntry)
                
        let barChartDataset = BarChartDataSet(entries: barChartEntries, label: "Amount")
        //let dataSet = BarChartDataSet(value: [entry1, entry2], label: "")
        let chartData = BarChartData(dataSet: barChartDataset)
        
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Income", "Expenses"])

        barChart.data = chartData
        
        barChartDataset.colors = barChartColors
        // Change bar width
        chartData.barWidth = Double(0.3)
        // Remove values above bars
        barChartDataset.drawValuesEnabled = false
        
        let total = income + expenses
        // Calculate percentages to 1 decimal place
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
        // Remove legend under the bar chart
        barChart.legend.enabled = false
        // Remove the right y axis
        barChart.rightAxis.enabled = false
        // Move x axis to the bottom of the bar chart
        barChart.xAxis.labelPosition = .bottom
        // Remove vertical grid lines
        barChart.xAxis.drawGridLinesEnabled = false
        //barChartView.leftAxis.drawGridLinesEnabled = false
        
        // Change colour of horizontal grid lines, y axis and x axis
        let lightGrey = #colorLiteral(red: 0.7636238628, green: 0.8182056074, blue: 0.8185921308, alpha: 1)
        barChart.leftAxis.gridColor = lightGrey
        barChart.xAxis.axisLineColor = lightGrey
        barChart.leftAxis.axisLineColor = lightGrey
        
        // Remove axis lines
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.xAxis.drawAxisLineEnabled = false
        
        // Hide x axis labels
        barChart.xAxis.drawLabelsEnabled = false
        
        // Animate chart when it loads
        barChart.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
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
        barChart.xAxis.spaceMin = 0.5
        
        barChart.xAxis.centerAxisLabelsEnabled = true
                
        //chartView.xAxis.labelPosition = .topInside
    }
    
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
        
        cell.colourLabel.layer.cornerRadius = 6
        cell.colourLabel.layer.masksToBounds = true
        
        return cell
    }
    
    func reloadTable() {
        chartTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Reloading Chart VC")
        //setData()
        //updateChartData()
        
        if(chartType == "Pie Chart") { getPieChartData() }
        else { getBarChartData() }
        //getBarChartData()
    }
    
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chart"

        print(self.title! + " loaded!")
        /*let chart = PieChartView(frame: self.view.frame)
        chart.delegate = self
        setPieChartData()
        let dataSet = updateChartData()
        pieChartProperties()
        formatPieChartDataSet(dataSet: dataSet)*/
        
        barChart.isHidden = true
        
        if(chartType == "Pie Chart") { getPieChartData() }
        else { getBarChartData() }
        //getBarChartData()
        
        //setBarChartData()
        //customiseBarChart()
    }

}
