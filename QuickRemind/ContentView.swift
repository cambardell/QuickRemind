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
    @ObjectBinding private var kGuardian = KeyboardGuardian(textFieldCount: 1)
    @State private var name = Array<String>.init(repeating: "", count: 1)
    
    @State var reminderText: String = ""
    @State var reminderDate: Date = Date()

    var eventStore = EKEventStore()
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Add a reminder")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            
            
            Text("Remind me to \(formatReminderText()) on \(formatDate()).")
                .lineLimit(nil)
                .padding()
                .background(Color(red: 30/255, green: 225/255, blue: 230/255, opacity: 0.4))
                .cornerRadius(20)
            
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
                .background(GeometryGetter(rect: $kGuardian.rects[0]))
            
           Spacer()
        }.offset(y: kGuardian.slide).animation(.basic(duration: 1.0))
            .background(Color(red: 250/255, green: 250/255, blue: 250/255))
        
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
            if reminderText != "" {
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

// ¯\_(ツ)_/¯ from stackoverflow
struct GeometryGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { geometry in
            Group { () -> ShapeView<Rectangle, Color> in
                DispatchQueue.main.async {
                    self.rect = geometry.frame(in: .global)
                }
                
                return Rectangle().fill(Color.clear)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

