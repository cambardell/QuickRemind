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

    var eventStore = EKEventStore()
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("Remind me to \(reminderText) on \(formatDate())")
                .lineLimit(nil)
                .padding()
            
            DatePicker($reminderDate)
            
            HStack {
                    Button(action: {
                        self.addTime(time: "Hour")
                    }, label: {
                            Text("Add Hour")
                    }).buttonStyle(.addTime)
                
                    Button(action: {
                       self.addTime(time: "Day")
                    }, label: {
                        Text("Add Day")
                    }).buttonStyle(.addTime)
                
                    Button(action: {
                        self.addTime(time: "Week")
                    }, label: {
                        Text("Add Week")
                    }).buttonStyle(.addTime)
                }
            
            TextField("Remind me to...", text: $reminderText)
                .padding()
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
        
      
        do {
            try eventStore.save(reminder,
                                commit: true)
        } catch let error {
            print("Reminder failed with error \(error.localizedDescription)")
        }
        withAnimation(.spring()){
            reminderText = ""
        }

        reminderDate = Date()
    }
    
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: reminderDate)
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
            .padding()
            .background(Color(red: 99/255, green: 193/255, blue: 178/255, opacity: 1.0))
            .cornerRadius(20)
            .accentColor(.black)
            .scaleEffect(isPressed ? 0.9 : 1.0)

    }
}

public struct saveButton:ButtonStyle   {
    public func body(configuration: Button<Self.Label>, isPressed: Bool) -> some View {
        configuration
            .padding()
            .background(Color.orange)
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

