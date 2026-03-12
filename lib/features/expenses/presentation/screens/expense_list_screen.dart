import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import 'expense_details_screen.dart';

/// Screen displaying list of all expenses with filtering
class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String? selectedCategory;
  DateTimeRange? selectedDateRange;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    
    if (expenseState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredExpenses = _getFilteredExpenses(expenseState.expenses);

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: filteredExpenses.isEmpty
              ? const Center(child: Text('No expenses found'))
              : ListView.builder(
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return ExpenseCard(
                      expense: expense,
                      onTap: () => _navigateToDetails(expense),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search expenses',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...AppConstants.expenseCategories.map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      selectedDateRange == null
                          ? 'Date Range'
                          : 'Selected Range',
                    ),
                  ),
                ),
              ],
            ),
            if (selectedCategory != null || selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear Filters'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List _getFilteredExpenses(List expenses) {
    var filtered = expenses;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = ref.read(expenseProvider.notifier).searchExpenses(searchQuery);
    }

    // Apply category filter
    if (selectedCategory != null) {
      filtered = filtered.where((e) => e.category == selectedCategory).toList();
    }

    // Apply date range filter
    if (selectedDateRange != null) {
      filtered = filtered.where((e) {
        return e.date.isAfter(selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               e.date.isBefore(selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedDateRange = null;
      searchQuery = '';
      _searchController.clear();
    });
  }

  void _navigateToDetails(expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsScreen(expense: expense),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}