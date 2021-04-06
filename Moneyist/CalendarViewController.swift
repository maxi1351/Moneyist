//
//  CalendarViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit
import Alamofire

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var monthAndYearLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var remindersTable: UITableView!
    
    let calendar = Calendar.current
    var selectedDate = Date()                   // Date selected on calendar
    var allDaysInMonth = [CalendarDay]() 
    var allReminders = [Reminder]()             // All reminders from backend
    var specificDayReminders = [Reminder]()     // Reminders for the selected date
    var dateSelected = ""                       // String of the date selected
    
    let SERVER_ADDRESS = "http://localhost:4000/reminder/all/" + UserDetails.sharedInstance.getUID()
    
    struct CalendarDay {
        var day : String       // The day on the calendar
        var event : String     // Indicates wether a reminder is associated with that day
    }
    
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
        allDaysInMonth.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let calendarCell = calendarCollectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell
        
        // Set day of month for each calendar cell
        calendarCell.dayOfMonth.text = allDaysInMonth[indexPath.item].day
        
        // Change label shape to circle
        calendarCell.dayOfMonth.layer.cornerRadius = calendarCell.dayOfMonth.frame.width/2
        calendarCell.dayOfMonth.layer.masksToBounds = true
       
        showEventIndicator(index: indexPath.item, cell: calendarCell)
        // Disable empty cells and highlight today's date on calendar
        calendarCell.disableEmptyCells()
        highlightTodaysDate(calendarLabel: calendarCell.dayOfMonth)
        
        return calendarCell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedDay = allDaysInMonth[indexPath.item].day
        
        dateSelected = selectedDay + " " + monthAndYearLabelDetails()
        print("\(dateSelected)")
        
        specificDayReminders.removeAll()
        
        for reminder in allReminders {
            let convertedDate = convertISOTime(date: reminder.date)
            let reminderDate = convertReminderDate(date: convertedDate)
            //print("Reminder date = \(reminderDate)")
            //print("Selected date = \(dateSelected)")
            if dateSelected == reminderDate {
                specificDayReminders.append(reminder)
            }
        }
        
        print("Specific day reminders = \(specificDayReminders)")
        
        reloadTable()
    }
    
    // Load the collection view
    func loadCalendarMonth() {
        
        allDaysInMonth.removeAll()
        
        var count = 1
        let startDay = firstDayOfMonth()
        let startWeekdayCell = firstWeekdayOfMonth(date: startDay)
        let daysInMonth = totalDaysInMonth()
        var day = ""
        var event = ""
        
        while(count <= 42) {
            event = "false"
            
            if(count <= startWeekdayCell || count - startWeekdayCell > daysInMonth) {
                day = ""
            }
            
            else {
                
                day = String(count - startWeekdayCell)
                let date = day + " " + monthAndYearLabelDetails()
                
                for reminder in allReminders {
                    let reminderDate = convertReminderDate(date: convertISOTime(date: reminder.date))
                    //print("date = \(date)")
                    //print("reminder Date = \(reminderDate)")
                    if date == reminderDate {
                        event = "true"
                    }
                }
            }
            
            let dayDetails = CalendarDay(day: day, event: event)
            allDaysInMonth.append(dayDetails)
            count += 1
            
        }
        
        // Show the month and year currently displayed by the calendar
        monthAndYearLabel.text = monthAndYearLabelDetails()
        reloadCalendar()
    }
    
    // Mark the current date on the calendar
    func highlightTodaysDate(calendarLabel: UILabel) {
        let today = getTodaysDate()
        let calendarLabelDate = "\(calendarLabel.text ?? "") \(monthAndYearLabelDetails())"
        if (calendarLabelDate == today) {
            calendarLabel.backgroundColor = UIColor.black
            calendarLabel.textColor = UIColor.white
        }
    }
    
    // Show the event indicator under the calendar days associated with a reminder
    func showEventIndicator(index: Int, cell: CalendarCollectionViewCell) {
        if allDaysInMonth[index].event == "true" {
            //calendarCell.eventIndicator.isHidden = false
            cell.eventIndicator.textColor = UIColor.lightGray
        }
        else {
            //calendarCell.eventIndicator.isHidden = true
            cell.eventIndicator.textColor = UIColor.clear
        }
    }
    
    // MARK: - Functions for getting calendar data
    
    func getTodaysDate() -> String {
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d LLLL YYYY"
        let currentDay = dateFormatter.string(from: todaysDate)
        
        return currentDay
    }
    
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
        let monthAndYear = dateFormatter.string(from: selectedDate)
        
        return monthAndYear
    }
    
    // Date of the reminder
    func convertReminderDate(date: Date) -> String {
        // TODO: Fix. Gives the next day's date
        
        //print("Date before = \(date)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd LLLL YYYY"
        let reminderDate = dateFormatter.string(from: date)
        //let reminderDate = dateFormatter.string(from: date-1)
        //print("Date after = \(reminderDate)")

        return reminderDate
    }
    
    
    func getReminders() {
        
        AF.request(SERVER_ADDRESS, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print("Reminder response:")
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decode")
                    let result = try decoder.decode([Reminder].self, from: response.data!)
                    
                    print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.allReminders = result
                        self.reloadTable()
                        self.loadCalendarMonth()
                        //self.reloadCalendar()
                                            }
                } catch {
                    print(error)
                }
            }.resume()
        
    }
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    
    
    func reloadCalendar() {
        calendarCollectionView.reloadData()
    }
    
    func reloadTable() {
        remindersTable.reloadData()
    }
    
    // MARK: Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !specificDayReminders.isEmpty { return 1 }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var headerTitle = ""
        
        if !specificDayReminders.isEmpty {
            headerTitle = dateSelected
        }
    
        return headerTitle
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.center

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specificDayReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reminderCell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath)
        
        reminderCell.textLabel?.text = specificDayReminders[indexPath.row].title
        reminderCell.detailTextLabel?.text = specificDayReminders[indexPath.row].date
        
        return reminderCell
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //reloadCalendar()
        //print("Total reminder count = \(allReminders.count)") */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadCalendar()
        reloadTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.title! + " loaded!")
        //reloadCalendar()
        loadCalendarMonth()
        getReminders()
        reloadTable()
        //self.view.addSubview(remindersTable)
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
