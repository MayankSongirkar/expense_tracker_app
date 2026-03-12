import 'package:uuid/uuid.dart';
import '../../features/expenses/domain/entities/expense.dart';

/// Dummy data for testing and demonstration
class DummyData {
  static List<Expense> getDummyExpenses() {
    final uuid = const Uuid();
    final now = DateTime.now();
    
    return [
      Expense(
        id: uuid.v4(),
        title: 'Grocery Shopping',
        amount: 85.50,
        category: 'Food',
        date: now.subtract(const Duration(days: 1)),
        notes: 'Weekly groceries from supermarket',
      ),
      Expense(
        id: uuid.v4(),
        title: 'Gas Station',
        amount: 45.00,
        category: 'Travel',
        date: now.subtract(const Duration(days: 2)),
        notes: 'Fuel for car',
      ),
      Expense(
        id: uuid.v4(),
        title: 'Coffee Shop',
        amount: 12.75,
        category: 'Food',
        date: now.subtract(const Duration(days: 3)),
      ),
      Expense(
        id: uuid.v4(),
        title: 'Online Shopping',
        amount: 129.99,
        category: 'Shopping',
        date: now.subtract(const Duration(days: 5)),
        notes: 'New headphones from Amazon',
      ),
      Expense(
        id: uuid.v4(),
        title: 'Electricity Bill',
        amount: 78.30,
        category: 'Bills',
        date: now.subtract(const Duration(days: 7)),
        notes: 'Monthly electricity payment',
      ),
      Expense(
        id: uuid.v4(),
        title: 'Restaurant Dinner',
        amount: 65.20,
        category: 'Food',
        date: now.subtract(const Duration(days: 10)),
        notes: 'Dinner with friends at Italian restaurant',
      ),
      Expense(
        id: uuid.v4(),
        title: 'Uber Ride',
        amount: 18.50,
        category: 'Travel',
        date: now.subtract(const Duration(days: 12)),
      ),
      Expense(
        id: uuid.v4(),
        title: 'Phone Bill',
        amount: 55.00,
        category: 'Bills',
        date: now.subtract(const Duration(days: 15)),
        notes: 'Monthly mobile phone bill',
      ),
    ];
  }
}