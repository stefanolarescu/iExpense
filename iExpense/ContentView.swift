//
//  ContentView.swift
//  iExpense
//
//  Created by Stefan Olarescu on 29.03.2025.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "expenses")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "expenses") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    
    @State private var showingAddExpense = false
    
    private var personalExpensesItems: [ExpenseItem] {
        expenses.items.filter { $0.type == "Personal" }
    }
    private var businessExpensesItems: [ExpenseItem] {
        expenses.items.filter { $0.type == "Business" }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if personalExpensesItems.count > .zero {
                    Section(header: Text("Personal")) {
                        ForEach(personalExpensesItems) { item in
                            ItemView(
                                name: item.name, type: item.type, amount: item.amount
                            )
                        }
                        .onDelete { indices in
                            removeItems(at: indices, type: "Personal")
                        }
                    }
                }
                
                if businessExpensesItems.count > .zero {
                    Section(header: Text("Business")) {
                        ForEach(businessExpensesItems) { item in
                            ItemView(
                                name: item.name, type: item.type, amount: item.amount
                            )
                        }
                        .onDelete { indices in
                            removeItems(at: indices, type: "Business")
                        }
                    }
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense.toggle()
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddView(expenses: expenses)
        }
    }
    
    func removeItems(at indices: IndexSet, type: String) {
        let filteredItems = expenses.items.filter { $0.type == type }
        
        let actualIndices = indices.compactMap { index in
            expenses.items.firstIndex(where: { $0.id == filteredItems[index].id })
        }
        
        expenses.items.remove(atOffsets: IndexSet(actualIndices))
    }
}

#Preview {
    ContentView()
}

struct ItemView: View {
    let name: String
    let type: String
    let amount: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(type)
            }
            
            Spacer()
            
            Text(
                amount,
                format: .currency(
                    code: Locale.current.currency?.identifier ?? "USD"
                )
            )
            .foregroundStyle(getColorBasedOnAmount(amount))
        }
    }
    
    func getColorBasedOnAmount(_ amount: Double) -> Color {
        switch amount {
        case ..<10: return .green
        case 10...100: return .yellow
        default: return .red
        }
    }
}
