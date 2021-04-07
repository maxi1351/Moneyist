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
    var reminderID = ""                         // reminderID of selected reminder
    var weekDay = ""                            // Weekday of date selected on calendar
    
    let SERVER_ADDRESS_ALL = "http://localhost:4000/reminder/all/" + UserDetails.sharedInstance.getUID()
    let SERVER_ADDRESS_SPECIFIC = "http://localhost:4000/reminder/"   // + reminderID
    
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
        performSegue(withIdentifier: "toReminderCreate", sender: nil)
    }
    
    @IBAction func viewAllRemindersButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toReminders", sender: nil)
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
        
        //remindersTable.isHidden = true
        specificDayReminders.removeAll()
        
        for reminder in allReminders {
            let reminderDate = convertReminderDate(date: reminder.date)

            if dateSelected == reminderDate {
                specificDayReminders.append(reminder)
                weekDay = getWeekday(date: reminder.date)
            }
        }
        //if !specificDayReminders.isEmpty { remindersTable.isHidden = false }
        reloadTable()
    }
    
    // Reload collection view
    func reloadCalendar() {
        calendarCollectionView.reloadData()
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
        
        // Store days to display on calendar
        while(count <= 42) {
            event = "false"
            
            if(count <= startWeekdayCell || count - startWeekdayCell > daysInMonth) {
                day = ""
            }
            
            else {
                day = String(count - startWeekdayCell)
                let date = day + " " + monthAndYearLabelDetails()
                
                for reminder in allReminders {
                    let reminderDate = convertReminderDate(date: reminder.date)
                    if date == reminderDate { event = "true" }
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
        dateFormatter.dateFormat = "d LLLL yyyy"
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
        dateFormatter.dateFormat = "LLLL yyyy"
        let monthAndYear = dateFormatter.string(from: selectedDate)
        
        return monthAndYear
    }
    
    // Convert date from server to format suitable for user
    func convertReminderDate(date: String) -> String {
        let convertedDate = UserDetails.sharedInstance.convertISOTime(date: date)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "d LLLL yyyy"
        let reminderDate = dateFormatter.string(from: convertedDate)

        return reminderDate
    }
    
    // MARK: - Functions for reminder details
    
    // Get all reminders from server
    func getReminders() {
        
        AF.request(SERVER_ADDRESS_ALL, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                //print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
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
    
    // Delete reminder requested by user
    func deleteReminder(index: Int) {
        // Send reminder deletion request
        AF.request(self.SERVER_ADDRESS_SPECIFIC + self.specificDayReminders[index].reminderId, method: .delete, encoding: JSONEncoding.default)
            .responseString { response in
                print("Delete Reminder Response:")
                print(response)
            }
        print("Reminder DELETED!")
        // Refresh data after deletion
        
        // FIX - highlighting of cell
        specificDayReminders.remove(at: index)
        self.getReminders()
        self.reloadTable()
        self.loadCalendarMonth()
    }
    
    // Get weekday for the date
    func getWeekday(date: String) -> String {
        let convertedDate = UserDetails.sharedInstance.convertISOTime(date: date)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: convertedDate)

        return weekday
    }
    
    // MARK: Reminders table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !specificDayReminders.isEmpty { return 1 }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var headerTitle = ""
        
        if !specificDayReminders.isEmpty {
            headerTitle = weekDay + " " + dateSelected
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reminderID = specificDayReminders[indexPath.row].reminderId
        performSegue(withIdentifier: "toReminderEdit", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //self.deleteReminder(index: indexPath.row)
            //remindersTable.deleteRows(at: [indexPath], with: .fade)
            
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete the reminder?", preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("Yes Pressed")
                
                // Delete reminder from database
                self.deleteReminder(index: indexPath.row)
            }
            
            // Controls what happens after the user presses NO
            let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
                    UIAlertAction in
                    NSLog("No Pressed")
                }
            
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            self.present(alert, animated: true)
        }
    }
    
    // Reload table view
    func reloadTable() {
        remindersTable.reloadData()
    }
    
   /* func addShadow() {
        remindersTable.layer.shadowColor = UIColor.darkGray.cgColor
        remindersTable.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        remindersTable.layer.shadowOpacity = 0.6
        remindersTable.layer.shadowRadius = 5.0
    } */
    
    // MARK: - View controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(self.title! + " reloading!")
        getReminders()
        //reloadCalendar()
        print("Total reminder count = \(allReminders.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        specificDayReminders.removeAll()
        reloadTable()
        getReminders()
        reloadCalendar()
        //reloadTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.title! + " loaded!")
        loadCalendarMonth()
        specificDayReminders.removeAll()
        reloadTable()
        getReminders()
        //remindersTable.tableFooterView = UIView()
    }
    
     // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let destinationVC = segue.destination as! RemindersViewController
        //destinationVC.reminders = self.allReminders
        if segue.identifier == "toReminderEdit" {
            let destinationVC = segue.destination as! ReminderEditViewController
            destinationVC.reminderID = self.reminderID
        }
     
     }
    
}
