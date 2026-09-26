import 'package:expense_app/models/expense.dart';
import 'package:expense_app/widgets/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const new({super.key, required this.expenses, required this.onDismiss});
  final List<Expense> expenses;

  final void Function(Expense expense) onDismiss;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, i) => Dismissible(
        background: Container(
          color: Theme.of(context).colorScheme.error,
          // margin: EdgeInsets.symmetric(
          //   horizontal: Theme.of(context).cardTheme.margin!.horizontal,
          // ),
        ),
        key: ValueKey(expenses[i]),
        onDismissed: (ignoredDirection) => onDismiss(expenses[i]),
        child: ExpenseItem(expense: expenses[i]),
      ),
    );
  }
}
