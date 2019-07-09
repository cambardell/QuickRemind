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
            Text("Remind me to \(reminderText) on \(reminderDate)")
                .lineLimit(nil)
                .padding()
            
            DatePicker($reminderDate)
           
            HStack{
                addTimeButton(reminderDate: reminderDate, timeToAdd: "Hour")
                addTimeButton(reminderDate: reminderDate, timeToAdd: "Day")
                addTimeButton(reminderDate: reminderDate, timeToAdd: "Week")
                Spacer()
            }.padding()
            
            TextField("Remind me to...", text: $reminderText)
                .padding()
                .lineLimit(nil)
            

            withAnimation{
                Button(action: {
                    self.saveReminder()
                    
                }) {
                    Text("Save")
                        .color(.black)
                    
                }
                .padding()
                    .background(Color.orange)
                    .cornerRadius(20)
            }
            
            
           Spacer()
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

}


struct addTimeButton : View {
    var reminderDate: Date
    var timeToAdd: String
    
    var body: some View {
        return Button(action: {
    
        }) {
            Text("Add \(timeToAdd)").color(.black)
            }
            .padding()
            .background(Color(red: 99/255, green: 193/255, blue: 178/255, opacity: 1.0))
            .cornerRadius(20)
    }
    
   
}




#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

