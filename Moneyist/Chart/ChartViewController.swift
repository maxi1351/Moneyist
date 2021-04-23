//
//  ChartViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit
import Charts

class ChartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate {
    
    @IBOutlet weak var chartView: PieChartView!
    
    @IBOutlet weak var chartTable: UITableView!
    
    // MARK: - Chart view
    
    //var percentages = PieChartDataEntry(value: 0)
    var entries = [PieChartDataEntry]()
    var allPercentages = [BudgetPercentages]()
    var budgetDetails = [BudgetDetails]()
    let colors = [#colorLiteral(red: 0.03912452236, green: 0.3398694694, blue: 0.4359056056, alpha: 1), #colorLiteral(red: 0.153665185, green: 0.5830183625, blue: 0.4813076258, alpha: 1), #colorLiteral(red: 0.6497512167, green: 0.8048898964, blue: 0.1597088941, alpha: 1)]
    var totalAmount = 0.0
    //var selectedIndex = 0
    
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
    
    
   /* func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] {
            let index: Int = dataSet.entryIndex(entry: entry)
            print("Selected index = \(index)")
        }
    } */
    
    func setData() {
        
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
    func chartProperties() {
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
    }
    
    //
    func chartCenter() {
        // Set colour of hole to background colour of view
        chartView.holeColor = UIColor.systemBackground
        // Adjust size of chart center
        chartView.holeRadiusPercent = CGFloat(0.52)
        
        // Display category in the center
        //chartView.centerText = "£ " + String(Int(totalAmount))
        // Make sure text fits within the center
        //chartView.centerTextRadiusPercent = 0.95
        
        //chartView.centerAttributedText = String(Int(totalAmount))
    }
    
    //
    func formatDescription() {
        // When slice is tapped, category is displayed
        //chartView.description.text = category.rawValue.capitalized
        //chartView.description.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    
    //
    func formatDataSet(dataSet: ChartDataSet) {
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
    
    
    
    // MARK: - Table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgetDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath) as! ChartTableViewCell
        
        cell.nameLabel.text = budgetDetails[indexPath.row].details.name
        cell.amountLabel.text = "£ " + String(Int(budgetDetails[indexPath.row].details.amount))
        let valueString = String(budgetDetails[indexPath.row].percent)
        cell.percentLabel.text = valueString + " %"
        cell.colourLabel.backgroundColor = budgetDetails[indexPath.row].color
        cell.colourLabel.layer.cornerRadius = 6
        cell.colourLabel.layer.masksToBounds = true

        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Reloading")
        //setData()
        //updateChartData()
    }
    
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        let chart = PieChartView(frame: self.view.frame)
        chart.delegate = self
        setData()
        let dataSet = updateChartData()
        chartProperties()
        chartCenter()
        //formatDescription()
        formatDataSet(dataSet: dataSet)
        
    }

}
