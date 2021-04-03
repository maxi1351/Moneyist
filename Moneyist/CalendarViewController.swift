//
//  CalendarViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var monthAndYearLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    
    var selectedDate = Date()
    var totalDays = [String]()
    let calendar = Calendar.current
    
    // MARK: - Buttons
    
    @IBAction func nextMonth(_ sender: Any) {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
        loadCalendarMonth()
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
        loadCalendarMonth()
    }
    
    @IBAction func createReminderButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toCreateReminder", sender: nil)
    }
    
    // MARK: - Calendar collection view
    
    //func collectionViewLayout {}
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let calendarCell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        // Set day of month for each calendar cell
        calendarCell.dayOfMonth.text = totalDays[indexPath.item]
        
        // Change label shape to circle
        calendarCell.dayOfMonth.layer.cornerRadius = calendarCell.dayOfMonth.frame.width/2
        calendarCell.dayOfMonth.layer.masksToBounds = true
        
        // Disable empty cells and highlight today's date on calendar
        calendarCell.disableEmptyCells()
        highlightTodaysDate(calendarLabel: calendarCell.dayOfMonth)
        
        return calendarCell
    }
    
    func highlightTodaysDate(calendarLabel: UILabel) {
        let today = getTodaysDate()
        let calendarLabelDate = "\(calendarLabel.text ?? "") \(monthAndYearLabelDetails())"
        if (calendarLabelDate == today) {
            calendarLabel.backgroundColor = UIColor.black
            calendarLabel.textColor = UIColor.white
        }
    }
    
    func getTodaysDate() -> String {
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d LLLL YYYY"
        let currentDay = dateFormatter.string(from: todaysDate)
        
        return currentDay
    }
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // --------- Remove if 0 not needed
        var selectedDay = totalDays[indexPath.item]
        
        // Add 0 in front of days with one digit
        if(Int(selectedDay) ?? 0 < 10) {
            selectedDay = "0\(selectedDay)"
        }
        // ---------
        
        let dateSelected = selectedDateDetails(day: selectedDay)
        print("\(dateSelected)")
    }
    
    // Load the collection view
    func loadCalendarMonth() {
        
        totalDays.removeAll()
        
        var count = 1
        let startDay = firstDayOfMonth()
        let startWeekdayCell = firstWeekdayOfMonth(date: startDay)
        let daysInMonth = totalDaysInMonth()
        
        while(count <= 42) {
            if(count <= startWeekdayCell || count - startWeekdayCell > daysInMonth) {
                totalDays.append("")
            }
            
            else {
                let day = String(count - startWeekdayCell)
                totalDays.append(day)
            }
            
            count += 1
        }
       
        // Show the month and year currently displayed by the calendar
        monthAndYearLabel.text = monthAndYearLabelDetails()
        reloadCalendar()
    }
    
    
    // MARK: - Functions for getting calendar data
    
    // Total number of days in the month
    func totalDaysInMonth() -> Int {
        let days = calendar.range(of: .day, in: .month, for: selectedDate)
        
        return days!.count
    }
    
    // Starting date of the month
    func firstDayOfMonth() -> Date {
        let component = calendar.dateComponents([.year, .month], from: selectedDate)
        let firstDay = calendar.date(from: component)
        
        return firstDay!
    }
    
    // Starting cell number of the month
    func firstWeekdayOfMonth(date: Date) -> Int {
        let component = calendar.dateComponents([.weekday], from: date)
        let firstWeekday = component.weekday! - 1
        
        return firstWeekday
    }
    
    // Month and year currently displayed by calendar
    func monthAndYearLabelDetails() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL YYYY"
        
        return dateFormatter.string(from: selectedDate)
    }
    
    // Date selected by user from calendar
    func selectedDateDetails(day: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "-MM-yyyy"       // Change to format required by server
        let selectedDateString = day + dateFormatter.string(from: selectedDate)
        
        return selectedDateString
    }
    
    
    func reloadCalendar() {
        calendarCollectionView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        reloadCalendar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        loadCalendarMonth()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
