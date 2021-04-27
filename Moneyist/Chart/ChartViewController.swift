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
    
    @IBOutlet weak var chartView: BarChartView!
    @IBOutlet weak var chartTable: UITableView!
    
    var pieChartData = [PieChart]()
    var barChartData : BarChart? = nil

    //let SERVER_ADDRESS_ALL = "http://localhost:4000/transaction/pieChart/" + UserDetails.sharedInstance.getUID()
    let SERVER_ADDRESS_PIE_CHART = "http://localhost:4000/transaction/pieChart/" + UserDetails.sharedInstance.getUID()
    let SERVER_ADDRESS_BAR_CHART = "http://localhost:4000/transaction/barChart/" + UserDetails.sharedInstance.getUID()

    struct BarChart : Codable {
        var incomeAmount: Double
        var outcomeAmount: Double
    }
    
    struct PieChart : Codable {
        var catgeory: String
        var amount: Int32
    }
    
    // MARK: - Chart view
    
    //var percentages = PieChartDataEntry(value: 0)
    var entries = [PieChartDataEntry]()
    var allPercentages = [BudgetPercentages]()
    var budgetDetails = [BudgetDetails]()
    let colors = [#colorLiteral(red: 0.03912452236, green: 0.3398694694, blue: 0.4359056056, alpha: 1), #colorLiteral(red: 0.153665185, green: 0.5830183625, blue: 0.4813076258, alpha: 1), #colorLiteral(red: 0.6497512167, green: 0.8048898964, blue: 0.1597088941, alpha: 1)]
    var totalAmount = 0.0
    //var selectedIndex = 0
    
    var barChartEntries = [BarChartDataEntry]()
    var barChartArray = [BarChartDetails]()
    var barChartColors = [#colorLiteral(red: 0.4794762726, green: 0.7111433768, blue: 1, alpha: 1), #colorLiteral(red: 0.8048898964, green: 0.561850013, blue: 0.7715510006, alpha: 1)]
    
    let colorsArray = [#colorLiteral(red: 0.03912452236, green: 0.3398694694, blue: 0.4359056056, alpha: 1), #colorLiteral(red: 0.2000421584, green: 0.6995770335, blue: 0.6809796691, alpha: 1), #colorLiteral(red: 0.153665185, green: 0.5830183625, blue: 0.4813076258, alpha: 1), #colorLiteral(red: 0.175951435, green: 0.6201614255, blue: 0.2976064565, alpha: 1), #colorLiteral(red: 0.7415904999, green: 0.9133911133, blue: 0.1858743429, alpha: 1)]
        
    struct Budget {
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
    }
    
    struct BarChartDetails {
        var label : String
        var amount : String
        var percentage : String
        var color : UIColor
    }
    
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
    
    // Get transactions associated with a category from server
    func getPieChartData() {
        
        let timePeriod: Parameters = ["startDate": "1991/01/01", "endDate": "2001/01/01"]
        
        //method: .get, parameters: timePeriod, encoding: URLEncoding.default

        AF.request(SERVER_ADDRESS_PIE_CHART, method: .get, parameters: timePeriod, encoding: URLEncoding.default)
            .responseJSON { response in
                print("SERVER RESPONSE PIE CHART")
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode([PieChart].self, from: response.data!)
                    
                    print(result)
                    
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.pieChartData = result
                        // Reload data
                        //self.reloadTable()
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

        AF.request(SERVER_ADDRESS_BAR_CHART, method: .get, parameters: timePeriod, encoding: URLEncoding.default)
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
                        // Reload data
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
        
        // Empty all arrays
        entries.removeAll()
        allPercentages.removeAll()
        budgetDetails.removeAll()
        
        // Test data
        chartView.chartDescription.text = ""
        let data : [Budget] = [Budget(name : "Label 1", amount: 2500), Budget(name : "Label 2", amount: 1500), Budget(name : "Label 3", amount: 1000),]
        
        for item in data {
            totalAmount += item.amount
        }
        
        for (budget, color) in zip(data, colors) {
            let label = budget.name
            let percentage = (budget.amount / totalAmount) * 100
            let colour = color
            
            
            let labelPercentage = BudgetPercentages(label: label, value: percentage)
            allPercentages.append(labelPercentage)
            let details = BudgetDetails(details: budget, percent: percentage, color: colour)
            budgetDetails.append(details)
        }
        
        entries = allPercentages.map { PieChartDataEntry(value: $0.value, label: $0.label)}
        
        //print("Entries = \(entries)")
        //print("All Spendings Categories = \(allSpendingCategories)")
    }
    
    //
   /* func pieChartProperties() {
        // Disable rotation
        chartView.rotationEnabled = false
        // Animate chart when view loads
        chartView.animate(xAxisDuration: 0.5, easingOption: .easeInOutCirc)
        // Hide labels on chart
        chartView.drawEntryLabelsEnabled = false
        // Display percentages on chart
        chartView.usePercentValuesEnabled = true
        // Disable colours and labels at the bottom
        chartView.legend.enabled = false
        // Set colour of hole to background colour of view
        chartView.holeColor = UIColor.systemBackground
        // Adjust size of chart center
        chartView.holeRadiusPercent = CGFloat(0.52)
        
        // Display category in the center
        //chartView.centerText = "£ " + String(Int(totalAmount))
        // Make sure text fits within the center
        //chartView.centerTextRadiusPercent = 0.95
        
        //chartView.centerAttributedText = String(Int(totalAmount))
        
        // When slice is tapped, category is displayed
        //chartView.description.text = category.rawValue.capitalized
        //chartView.description.font = UIFont.boldSystemFont(ofSize: 17)
    } */
    //
    func formatPieChartDataSet(dataSet: ChartDataSet) {
        // Display value inside the center when slice is selected
        // Disable values on chart
        dataSet.drawValuesEnabled = false
    }
    
    
    func updateChartData() -> ChartDataSet {
        let chartDataSet = PieChartDataSet(entries: entries, label: "")
        let chartData = PieChartData(dataSet: chartDataSet)
        
        // From assets
        //let colors = [UIColor(named: "iosColor"), UIColor(named: "macColor")]
        chartDataSet.colors = colors
        chartView.data = chartData
        
        return chartDataSet
    }
    
    func setBarChartData() {
        
        barChartEntries.removeAll()
        barChartArray.removeAll()
        
        let income = Double(barChartData?.incomeAmount ?? 0)
        let expenses = Double(barChartData?.outcomeAmount ?? 0)
        
        let incomeEntry = BarChartDataEntry(x: Double(1), y: income)
        let outcomeEntry = BarChartDataEntry(x: Double(2), y: expenses)
            barChartEntries.append(incomeEntry)
            barChartEntries.append(outcomeEntry)
                
        let barChartDataset = BarChartDataSet(entries: barChartEntries, label: "Amount")
        //let dataSet = BarChartDataSet(value: [entry1, entry2], label: "")
        let chartData = BarChartData(dataSet: barChartDataset)
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Income", "Expenses"])

        chartView.data = chartData
        
        barChartDataset.colors = barChartColors
        // Change bar width
        chartData.barWidth = Double(0.3)
        // Remove values above bars
        barChartDataset.drawValuesEnabled = false
        
        let total = income + expenses
        // Calculate percentages to 1 decimal place
        let incomePercent = round((income / total) * 100 * 10) / 10.0
        let expensePercent = round((expenses / total) * 100 * 10) / 10.0

        // Store income details
        let incomeDetails = BarChartDetails(label: "Income", amount: convertToDecimal(number: Int(income)), percentage: String(incomePercent), color: barChartColors[0])
        barChartArray.append(incomeDetails)
        
        // Store expense details
        let expenseDetails = BarChartDetails(label: "Expenses", amount: convertToDecimal(number: Int(expenses)), percentage: String(expensePercent), color: barChartColors[1])
        barChartArray.append(expenseDetails)
    }
    
    
    // Customise appearance of bar chart
    func barChartProperties() {
        // Remove legend under the bar chart
        chartView.legend.enabled = false
        // Remove the right y axis
        chartView.rightAxis.enabled = false
        // Move x axis to the bottom of the bar chart
        chartView.xAxis.labelPosition = .bottom
        // Remove vertical grid lines
        chartView.xAxis.drawGridLinesEnabled = false
        //barChartView.leftAxis.drawGridLinesEnabled = false
        
        // Change colour of horizontal grid lines, y axis and x axis
        let lightGrey = #colorLiteral(red: 0.7636238628, green: 0.8182056074, blue: 0.8185921308, alpha: 1)
        chartView.leftAxis.gridColor = lightGrey
        chartView.xAxis.axisLineColor = lightGrey
        chartView.leftAxis.axisLineColor = lightGrey
        
        // Remove axis lines
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        
        // Hide x axis labels
        chartView.xAxis.drawLabelsEnabled = false
        
        // Animate chart when it loads
        chartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
        // Disable user interaction with chart
        chartView.doubleTapToZoomEnabled = false
        chartView.highlightPerTapEnabled = false
        
        // Change colour of x and y axis labels
        chartView.leftAxis.labelTextColor = #colorLiteral(red: 0.5184787889, green: 0.5184787889, blue: 0.5184787889, alpha: 1)
        chartView.xAxis.labelTextColor = #colorLiteral(red: 0.5184787889, green: 0.5184787889, blue: 0.5184787889, alpha: 1)
        
        
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1.0
        //barChartView.xAxis.decimals = 0
        
        chartView.xAxis.axisMinimum = 0.0
        //chartView.xAxis.axisMaximum = 2.0
        chartView.xAxis.labelCount = 2
        chartView.fitBars = true
        chartView.xAxis.spaceMin = 0.5
        
        chartView.xAxis.centerAxisLabelsEnabled = true
        

        
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
        //return budgetDetails.count
        return barChartArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath) as! ChartTableViewCell
        
        /*cell.nameLabel.text = budgetDetails[indexPath.row].details.name
        cell.amountLabel.text = "£ " + String(Int(budgetDetails[indexPath.row].details.amount))
        let valueString = String(budgetDetails[indexPath.row].percent)
        cell.percentLabel.text = valueString + " %"
        cell.colourLabel.backgroundColor = budgetDetails[indexPath.row].color
        cell.colourLabel.layer.cornerRadius = 6
        cell.colourLabel.layer.masksToBounds = true*/
                
        cell.nameLabel.text = barChartArray[indexPath.row].label
        cell.amountLabel.text = "£ " + barChartArray[indexPath.row].amount
        cell.percentLabel.text = barChartArray[indexPath.row].percentage + " %"
        cell.colourLabel.backgroundColor = barChartArray[indexPath.row].color
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
        
        getPieChartData()
        getBarChartData()
    }
    
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        /*let chart = PieChartView(frame: self.view.frame)
        chart.delegate = self
        setPieChartData()
        let dataSet = updateChartData()
        pieChartProperties()
        formatPieChartDataSet(dataSet: dataSet)*/
        
        getPieChartData()
        getBarChartData()
        //setBarChartData()
        //customiseBarChart()
    }

}

