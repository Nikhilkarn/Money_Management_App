import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Management App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double initialBudget = 0.0;
  List<Transaction> transactions = [];
  double remainingBudget = 0.0;

  @override
  Widget build(BuildContext context) {
    double totalExpenses = transactions
        .where((transaction) => !transaction.isSavings)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    double totalSavings = transactions
        .where((transaction) => transaction.isSavings)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    remainingBudget = initialBudget + totalSavings - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Money Management'),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://example.com/national_bank_logo.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BudgetDisplay(remainingBudget),
                SizedBox(height: 16),
                TransactionList(transactions),
                SizedBox(height: 16),
                TransactionForm(addTransaction),
                SizedBox(height: 16),
                BudgetForm(setInitialBudget),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        displayBudgets(context);
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text('Display Budgets'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        generateFinancialReport(context);
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.blue),
                      child: Text('Generate Report'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        saveAndExit();
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      child: Text('Save and Exit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: TransactionDrawer(transactions),
    );
  }

  void addTransaction(String title, double amount, bool isSavings) {
    setState(() {
      transactions.add(Transaction(title, amount, isSavings: isSavings));
    });
  }

  void setInitialBudget(double newBudget) {
    setState(() {
      initialBudget = newBudget;
    });
  }

  void displayBudgets(BuildContext context) {
    double budgetAfterSavings = initialBudget +
        transactions
            .where((transaction) => transaction.isSavings)
            .fold(0.0, (sum, transaction) => sum + transaction.amount) -
        transactions
            .where((transaction) => !transaction.isSavings)
            .fold(0.0, (sum, transaction) => sum + transaction.amount);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Budget Information'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Initial Budget: \$${initialBudget.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text('Budget After Savings: \$${budgetAfterSavings.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void generateFinancialReport(BuildContext context) {
    double totalExpenses = transactions
        .where((transaction) => !transaction.isSavings)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    double totalSavings = transactions
        .where((transaction) => transaction.isSavings)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Financial Report'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Initial Budget: \$${initialBudget.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text('Total Savings: \$${totalSavings.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text('Remaining Budget: \$${remainingBudget.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void saveAndExit() {
    Map<String, dynamic> data = {
      'initialBudget': initialBudget,
      'transactions': transactions
          .map((t) => {'title': t.title, 'amount': t.amount, 'isSavings': t.isSavings})
          .toList(),
    };

    File file = File('money_management_data.json');
    file.writeAsStringSync(jsonEncode(data));

    exit(0);
  }
}

class Transaction {
  final String title;
  final double amount;
  final bool isSavings;

  Transaction(this.title, this.amount, {required this.isSavings});
}

class BudgetDisplay extends StatelessWidget {
  final double remainingBudget;

  BudgetDisplay(this.remainingBudget);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.black, // Set the background color to black
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remaining Budget:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white
              ),
            ),
            SizedBox(height: 8),
            Text(
              '\$${remainingBudget.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionList(this.transactions);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.black, // Set the background color to black
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transactions',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white
              ),
            ),
            SizedBox(height: 8),
            if (transactions.isEmpty)
              Text('No transactions yet.', style: TextStyle(color: Colors.white))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: transactions.map((transaction) {
                  return ListTile(
                    title: Text(transaction.title, style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '\$${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: transaction.isSavings
                        ? Icon(Icons.arrow_upward, color: Colors.green)
                        : Icon(Icons.arrow_downward, color: Colors.red),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  final Function(String, double, bool) addTransaction;

  TransactionForm(this.addTransaction);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  bool isSavings = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Transaction',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Savings Transaction:'),
                Switch(
                  value: isSavings,
                  onChanged: (value) {
                    setState(() {
                      isSavings = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;

                if (title.isNotEmpty && amount > 0) {
                  widget.addTransaction(title, amount, isSavings);
                  titleController.clear();
                  amountController.clear();
                  setState(() {
                    isSavings = false;
                  });
                }
              },
              child: Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetForm extends StatefulWidget {
  final Function(double) setInitialBudget;

  BudgetForm(this.setInitialBudget);

  @override
  _BudgetFormState createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set Initial Budget',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: budgetController,
              decoration: InputDecoration(labelText: 'Initial Budget'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final initialBudget = double.tryParse(budgetController.text) ?? 0.0;
                widget.setInitialBudget(initialBudget);
                budgetController.clear();
              },
              child: Text('Set Initial Budget'),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionDrawer extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionDrawer(this.transactions);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
            child: Text(
              'Transactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          if (transactions.isEmpty)
            ListTile(
              title: Text('No transactions yet.'),
            )
          else
            ...transactions.map((transaction) {
              return ListTile(
                title: Text(transaction.title),
                subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                trailing: transaction.isSavings
                    ? Icon(Icons.arrow_upward, color: Colors.green)
                    : Icon(Icons.arrow_downward, color: Colors.red),
              );
            }).toList(),
        ],
      ),
    );
  }
}
