# Pocket Balance - Dashboard Guide

## 🎨 Overview

The main dashboard (HomeView) has been successfully implemented with a beautiful, reusable card-based design that matches the reference screens perfectly.

---

## 📁 Files Created

### 1. DashboardCardView.swift
**Location:** `Pocket Balance/Views/Dashboard/DashboardCardView.swift`

A reusable card component that displays financial metrics with the following features:
- Title (gray, medium weight)
- Large metric value (bold, prominent)
- Context text (gray, smaller)
- Icon in a circular background
- Clean shadows and rounded corners
- Configurable colors and sizes

### 2. HomeView.swift
**Location:** `Pocket Balance/Views/Dashboard/HomeView.swift`

The main dashboard screen featuring:
- Dynamic greeting header
- Three financial summary cards (Income, Expenses, Balance)
- Recent activity list with transactions
- Floating action button (FAB)
- Pull-to-refresh capability

### 3. Updated ContentView.swift
**Location:** `Pocket Balance/ContentView.swift`

Added bottom tab navigation with three tabs:
- 🏠 Home
- 💳 Bills & Subs
- 👤 Profile

---

## 🎯 Component Details

### DashboardCardView

**Usage:**
```swift
DashboardCardView(
    title: "Total Income",
    metric: "£2,500.00",
    context: "from 2 sources",
    iconSystemName: "arrow.up.circle.fill",
    iconColor: .green
)
```

**Parameters:**
- `title: String` - Card title (e.g., "Total Income")
- `metric: String` - Main value (e.g., "£2,500.00")
- `context: String` - Additional info (e.g., "from 2 sources")
- `iconSystemName: String` - SF Symbol name
- `iconColor: Color` - Icon and background color (default: .blue)
- `isLargeMetric: Bool` - Makes metric text larger (default: false)

**Features:**
- Responsive layout with HStack
- Icon in circular background with opacity
- Shadow effects for depth
- Rounded corners (16pt radius)
- White background

---

## 📱 HomeView Layout

### Header Section
```
┌─────────────────────────────────┐
│ Good evening, Dami    🔔 ⚙️     │
└─────────────────────────────────┘
```

- Dynamic greeting based on time of day
- User name display
- Notification bell (with red badge)
- Settings gear icon

### Financial Cards Section

**1. Income Card**
- Title: "Total Income"
- Amount: £2,500.00
- Context: "from 2 sources"
- Icon: Green arrow up circle
- Color: Green

**2. Expenses Card**
- Title: "Expenses This Month"
- Amount: £1,230.50
- Context: "in 15 transactions"
- Icon: Red arrow down circle
- Color: Red

**3. Balance Card (Special)**
- Title: "Remaining Balance"
- Amount: £1,269.50 (larger font)
- Context: "left to spend"
- Icon: Owl emoji mascot 🦉
- Color: Blue background

### Recent Activity Section

**Header:**
- "Recent Activity" title
- "View All" button

**Transaction Rows:**
Each row displays:
- Icon in colored circular background
- Transaction title
- Date/time
- Amount (red for expenses, green for income)

**Sample Transactions:**
1. 💳 Credit Card Payment - Today - £150.00
2. 🎓 Student Loan - Yesterday - £200.00
3. 🚗 Car Payment - 2 days ago - £300.00
4. 💰 Personal Loan - 3 days ago - £100.00

### Floating Action Button (FAB)

- Blue circular button
- White plus icon
- Bottom-right corner placement
- Opens "Add Transaction" sheet
- Shadow effect for elevation

---

## 🎨 Design Specifications

### Colors
- **Background:** System grouped background
- **Cards:** White with subtle shadows
- **Text Primary:** Black
- **Text Secondary:** Gray
- **Accent:** Blue
- **Success/Income:** Green
- **Error/Expense:** Red

### Typography
- **Header:** 28pt, Bold
- **Card Title:** 14pt, Medium
- **Card Metric:** 32-36pt, Bold
- **Card Context:** 13pt, Regular
- **Section Title:** 20pt, Bold
- **Transaction Title:** 16pt, Semibold
- **Transaction Date:** 14pt, Regular

### Spacing
- **Card Padding:** 20pt
- **Card Spacing:** 16pt between cards
- **Section Spacing:** 24pt between sections
- **Horizontal Margin:** 24pt

### Shadows
- **Radius:** 10pt
- **Opacity:** 0.05 (black)
- **Offset:** (0, 4)

### Corners
- **Card Radius:** 16pt
- **Icon Circle:** 70pt diameter
- **FAB:** 60pt diameter

---

## 🔄 Tab Navigation

### Tab Bar Structure

```
┌─────────────────────────────────┐
│   🏠        💳         👤        │
│  Home   Bills & Subs  Profile   │
└─────────────────────────────────┘
```

**Tab 1: Home**
- Icon: house/house.fill
- Shows main dashboard
- Active by default

**Tab 2: Bills & Subs**
- Icon: creditcard/creditcard.fill
- Placeholder view (coming soon)

**Tab 3: Profile**
- Icon: person/person.fill
- Placeholder view (coming soon)

---

## 💡 Features Implemented

### ✅ Reusable Components
- `DashboardCardView` - Used 3 times on home screen
- `TransactionRow` - Reusable transaction list item
- `AddTransactionSheet` - Modal for adding transactions

### ✅ Interactive Elements
- Notification button (with badge)
- Settings button
- "View All" transactions button
- Individual transaction rows (tappable)
- Floating Action Button
- Tab bar navigation

### ✅ UI/UX Details
- ScrollView for content overflow
- Shadow effects for depth
- Icon backgrounds with opacity
- Color coding (green=income, red=expense)
- Responsive layout
- Clean separation of concerns

---

## 🚀 How to Use

### Displaying Different Data

To show real data instead of placeholders, simply pass dynamic values:

```swift
DashboardCardView(
    title: "Total Income",
    metric: "£\(totalIncome, specifier: "%.2f")",
    context: "from \(incomeSourceCount) sources",
    iconSystemName: "arrow.up.circle.fill",
    iconColor: .green
)
```

### Adding Transaction Functionality

The FAB opens a sheet. Update `AddTransactionSheet` to:
1. Add form fields (amount, category, date)
2. Connect to your data model
3. Save to Supabase
4. Refresh the dashboard

### Making Transactions Interactive

Add navigation to transaction details:

```swift
TransactionRow(/* params */)
    .onTapGesture {
        // Navigate to transaction detail
        selectedTransaction = transaction
        showDetail = true
    }
```

---

## 📊 Data Flow (Future Implementation)

```
HomeView
    ↓
@StateObject viewModel
    ↓
Fetch from Supabase
    ↓
Update @Published properties
    ↓
UI Auto-updates
```

**Recommended Structure:**
```swift
class DashboardViewModel: ObservableObject {
    @Published var totalIncome: Double = 0
    @Published var totalExpenses: Double = 0
    @Published var recentTransactions: [Transaction] = []
    
    func fetchDashboardData() async {
        // Fetch from Supabase
    }
}
```

---

## 🎯 Next Steps

### Immediate Enhancements
1. **Connect to Real Data**
   - Create Transaction model
   - Fetch from Supabase
   - Display actual user data

2. **Add Transaction Form**
   - Income/Expense toggle
   - Amount input
   - Category picker
   - Date selector
   - Save to database

3. **Transaction Details**
   - Detail view on tap
   - Edit functionality
   - Delete option

### Future Features
1. **Charts & Graphs**
   - Spending by category
   - Income vs. Expenses
   - Monthly trends

2. **Filtering & Sorting**
   - Date range filter
   - Category filter
   - Search functionality

3. **Bills & Subscriptions**
   - Recurring payment tracking
   - Due date reminders
   - Payment history

4. **Profile Screen**
   - User settings
   - Account management
   - Export data
   - Sign out

---

## 🐛 Troubleshooting

### Cards Not Displaying
- Check that `HomeView` is used in `ContentView`
- Verify tab navigation is set up
- Ensure preview works in Xcode

### Icons Not Showing
- Verify SF Symbol names are correct
- Check iOS version compatibility
- Use fallback icons if needed

### Layout Issues
- Check padding and spacing values
- Verify ScrollView hierarchy
- Test on different device sizes

---

## 📱 Preview Tips

**In Xcode:**
1. Use Canvas preview for rapid iteration
2. Test different device sizes
3. Preview dark mode support
4. Check accessibility features

**Preview Options:**
```swift
#Preview("Light Mode") {
    HomeView()
}

#Preview("Dark Mode") {
    HomeView()
        .preferredColorScheme(.dark)
}

#Preview("iPhone SE") {
    HomeView()
        .previewDevice("iPhone SE (3rd generation)")
}
```

---

## ✅ Implementation Checklist

- [x] Created reusable `DashboardCardView`
- [x] Built main `HomeView` layout
- [x] Added header with greeting and icons
- [x] Implemented three financial cards
- [x] Created recent activity list
- [x] Added floating action button
- [x] Integrated tab navigation
- [x] Added placeholder tabs
- [x] Implemented transaction rows
- [x] Added modal for add transaction
- [x] Applied proper styling and shadows
- [x] Used SF Symbols for icons
- [x] Maintained consistency with design

---

## 🎉 Summary

The dashboard is **100% complete** with:
- ✅ Beautiful, reusable card components
- ✅ Clean, modern design matching reference
- ✅ Full tab navigation structure
- ✅ Interactive elements ready for data
- ✅ Proper spacing and shadows
- ✅ Owl mascot integration
- ✅ Ready for real data integration

**Total Components:** 6
- DashboardCardView
- HomeView
- TransactionRow
- AddTransactionSheet
- BillsAndSubscriptionsView
- ProfileView

**Next:** Connect to Supabase and display real user data!
