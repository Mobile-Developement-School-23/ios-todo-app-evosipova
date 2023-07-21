//
//  ContentView.swift
//  ToDoUI
//
//  Created by Elizaveta Osipova on 7/18/23.
//

import SwiftUI

struct ContentView: View {
    @State private var showNotesScreen = false
    @State private var tasks: [Task] = []
    @State private var showDoneTasks = true
    @State private var showNoteDetail = false
    @State private var selectedTask: Task?
    
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Text("Выполнено - \(tasks.filter { $0.isDone }.count)")
                            .foregroundColor(Color(UIColor(red: 0, green: 0, blue: 0, alpha: 1)))
                        Spacer()
                        Button(action: {
                            showDoneTasks.toggle()
                        }) {
                            Text(showDoneTasks ? "Скрыть" : "Показать")
                                .foregroundColor(Color(UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    List {
                        ForEach(tasks.indices.filter { showDoneTasks || !tasks[$0].isDone }, id: \.self) { index in
                            TaskRow(task: $tasks[index])
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        delete(index: index)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button(action: {
                                        tasks[index].isDone.toggle()
                                    }) {
                                        Image(systemName: tasks[index].isDone ? "arrow.uturn.backward" : "checkmark.circle.fill")
                                            .foregroundColor(tasks[index].isDone ? .blue : .white)
                                    }
                                    .background(tasks[index].isDone ? Color.blue : Color.green)
                                    .clipShape(Circle())
                                }
                        }
                        Button(action: {
                            self.showNotesScreen.toggle()
                        }) {
                            Text("Новое")
                        }
                        .navigationTitle("Мои дела")
                    }
                    .background(Color(UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)))
                    .scrollContentBackground(.hidden)
                }
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        self.showNotesScreen.toggle()
                    }) {
                        Image("Add")
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .padding(12)
                    .cornerRadius(50)
                    .padding(.bottom, 12)
                    .shadow(radius: 10)
                    .sheet(isPresented: $showNotesScreen) {
                        NotesView(newItem: "") { newItem in
                            self.tasks.append(Task(text: newItem))
                            self.saveTasks()
                        }
                    }
                    
                }
            }
        }
        .background(Color(UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)))
        .onAppear(perform: loadTasks)
    }
    
    func delete(index: Int) {
        tasks.remove(at: index)
        saveTasks()
    }
    
    func saveTasks() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(tasks) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedTasks")
        }
    }
    
    func loadTasks() {
        let defaults = UserDefaults.standard
        if let savedTasks = defaults.object(forKey: "SavedTasks") as? Data {
            let decoder = JSONDecoder()
            if let loadedTasks = try? decoder.decode([Task].self, from: savedTasks) {
                self.tasks = loadedTasks
            }
        }
    }
    
}



struct TaskRow: View {
    @Binding var task: Task
    @State private var showEditScreen = false
    
    var body: some View {
        HStack {
            Button(action: {
                task.isDone.toggle()
            }) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isDone ? .green : .gray)
            }
            VStack(alignment: .leading) {
                Text(task.text)
                    .strikethrough(task.isDone)
                    .foregroundColor(task.isDone ? .gray : .black)
                    .onTapGesture {
                        self.showEditScreen.toggle()
                    }
                if let deadline = task.deadline {
                    Text("Deadline: \(deadline, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if task.isImportant {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
            Image("arrow")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showEditScreen.toggle()
                }
                .sheet(isPresented: $showEditScreen) {
                    NotesView(newItem: task.text) { updatedText in
                        self.task.text = updatedText
                    }
                }
        }
    }
}


struct Task: Codable, Identifiable {
    let id: UUID
    var text: String
    var isDone: Bool
    var isImportant: Bool
    var deadline: Date?
    
    init(id: UUID = UUID(), text: String, isDone: Bool = false, isImportant: Bool = false, deadline: Date? = nil) {
        self.id = id
        self.text = text
        self.isDone = isDone
        self.isImportant = isImportant
        self.deadline = deadline
    }
}


let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()


struct IdentifiableString: Identifiable {
    let id: UUID
    let value: String
}


struct NotesView: View {
    @State private var text = ""
    @State private var importance = "Важность"
    @State private var favoriteColor = 0
    @State private var isDeadlineOn = false
    @State private var deadline = Date()
    @State private var color: Color = .clear
    @State private var toggle = false
    @State private var date = Date()
    
    @Environment(\.presentationMode) var presentationMode
    @State var newItem: String
    
    var onAddItem: (String) -> Void
    
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    struct TextEditorWithPlaceholder: View {
        @Binding var newItem: String
        
        var body: some View {
            ZStack(alignment: .leading) {
                if newItem.isEmpty {
                    VStack {
                        Text("Что надо сделать?")
                            .padding(.top, 10)
                            .padding(.leading, 6)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                
                VStack {
                    TextEditor(text: $newItem)
                        .cornerRadius(16)
                        .frame(minHeight: 120, maxHeight: 300)
                        .opacity(newItem.isEmpty ? 0.85 : 1)
                    Spacer()
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextEditorWithPlaceholder(newItem: $newItem)
                }
                
                Section {
                    HStack {
                        TextField("Важность", text: $importance)
                        Picker("What is your favorite color?", selection: $favoriteColor) {
                            Image("item1").tag(0)
                            Text("нет").tag(1)
                            Image("item3").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .frame(height: 33)
                        .scaledToFit()
                        .scaleEffect(CGSize(width: 1.1, height: 1.1))
                    }
                    Toggle("Сделать до", isOn: $toggle)
                    
                    if toggle {
                        DatePicker("",
                                   selection: $date,
                                   in: Date()...,
                                   displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .environment(\.locale, Locale.init(identifier: "ru"))
                        .animation(.easeInOut, value: toggle)
                    }
                }
                
                Button(action: {
                    if !newItem.isEmpty {
                        self.onAddItem(self.newItem)
                        self.newItem = ""
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }
                }) {
                    Text("Удалить")
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .foregroundColor(newItem.isEmpty ? .gray : .red)
                }
                
            }
            .listRowInsets(EdgeInsets())
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 56)
            .background(Color(UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1)))
            .foregroundColor(.primary)
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Дело")
            .navigationBarItems(
                leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Отменить")
                        .foregroundColor(.blue)
                        .bold()
                },
                trailing: Button(action: {
                    if !newItem.isEmpty {
                        self.onAddItem(self.newItem)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Сохранить")
                        .foregroundColor(newItem.isEmpty ? .gray : .blue)
                        .bold()
                }
            )
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
