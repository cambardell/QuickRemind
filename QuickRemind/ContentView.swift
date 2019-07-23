//
//  ContentView.swift
//  QuickRemind
//
//  Created by Cameron Bardell on 2019-07-04.
//  Copyright © 2019 Cameron Bardell. All rights reserved.
//

import SwiftUI
import EventKit

struct ContentView : View {
    
    @State var reminderText: String = ""
    @State var reminderDate: Date = Date()
    
    let notificationCenter = UNUserNotificationCenter.current()

    var eventStore = EKEventStore()
    
    var body: some View {
        
        // Note: Dark mode doesn't work properly in current beta
        
        VStack {
            HStack {
                Text("Add a reminder")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            
            
            Text("Remind me to \(formatReminderText()) on \(formatDate()).")
                .foregroundColor(.black)
                .lineLimit(nil)
                .padding()
                .background(Color(red: 30/255, green: 225/255, blue: 230/255, opacity: 0.4))
                .cornerRadius(20)
            
            DatePicker($reminderDate)
            
            HStack {
                    Button(action: {
                        self.addTime(time: "Hour")
                    }, label: {
                            Text("+Hour")
                    }).buttonStyle(.addTime)
                
                    Button(action: {
                        self.addTime(time: "Six")
                    }, label: {
                        Text("+6 Hours")
                    }).buttonStyle(.addTime)
                
                    Button(action: {
                       self.addTime(time: "Day")
                    }, label: {
                        Text("+Day")
                    }).buttonStyle(.addTime)
                
                    Button(action: {
                        self.addTime(time: "Week")
                    }, label: {
                        Text("+Week")
                    }).buttonStyle(.addTime)
                }.padding()
            
            TextField("Take out the trash", text: $reminderText)
                .textFieldStyle(.roundedBorder)
                .padding(.trailing)
                .padding(.leading)
                .padding(.bottom)
                .lineLimit(nil)
            
            
            
            Button(action: {
                self.saveReminder()
            }, label: {
                Text("Save")
            }).buttonStyle(.save)
                
            Spacer()
      
        }
    }

    
    func addTime(time: String) {
        if time == "Hour" {
            let date = reminderDate.advanced(by: 3600)
            reminderDate = date
        }
        if time == "Six" {
            let date = reminderDate.advanced(by: 60*60*6)
            reminderDate = date
        }
        if time == "Day" {
            let date = reminderDate.advanced(by: 86400)
            reminderDate = date
        }
        if time == "Week" {
            let date = reminderDate.advanced(by: 604800)
            reminderDate = date
        }
    }
    
    func saveReminder() {
        
        let reminder = EKReminder(eventStore: self.eventStore)
        let components = Calendar.current.dateComponents([Calendar.Component.minute, Calendar.Component.hour, Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: reminderDate)
        reminder.title = reminderText
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        reminder.dueDateComponents = components
        
        if !reminderText.isEmpty {
            scheduleNotification()
        }
      
        do {
            if !reminderText.isEmpty {
                try eventStore.save(reminder,
                                    commit: true)
            }
            
        } catch let error {
            print("Reminder failed with error \(error.localizedDescription)")
        }
        
        reminderText = ""
        reminderDate = Date()
    }
    
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: reminderDate)
    }
    
    func formatReminderText() -> String {
        if reminderText == "" {
            return "take out the trash"
        } else {
            return reminderText.lowercased()
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = reminderText
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .hour, .minute], from: reminderDate), repeats: false)

        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}

extension StaticMember where Base: ButtonStyle {
    static var addTime: StaticMember<addTimeButton> {
        return .init(addTimeButton())
    }
    static var save: StaticMember<saveButton> {
        return .init(saveButton())
    }
}

public struct addTimeButton:ButtonStyle   {
   public func body(configuration: Button<Self.Label>, isPressed: Bool) -> some View {
        configuration
            .padding(11.0)
            .background(Color(red: 88/255, green: 231/255, blue: 252/255, opacity: 1.0))
            .cornerRadius(20)
            .accentColor(.black)
            .scaleEffect(isPressed ? 0.9 : 1.0)
    }
}

public struct saveButton:ButtonStyle   {
    public func body(configuration: Button<Self.Label>, isPressed: Bool) -> some View {
        configuration
            .padding()
            .background(Color(red: 50/255, green: 200/255, blue: 220/255))
            .cornerRadius(20)
            .accentColor(.black)
            .scaleEffect(isPressed ? 0.9 : 1.0)
    }
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

