import 'package:flutter/material.dart';
import 'models/user.dart';
import 'models/bank_account.dart';
import 'models/library.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Lab2Presentation(),
    );
  }
}

class Lab2Presentation extends StatelessWidget {
  const Lab2Presentation({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      User(name: "Bogdan", age: 21, email: "bogdan@example.com"),
      User(name: "Andrei", age: 25),
      User(name: "Maria"),
    ];

    final accounts = [
      BankAccount(holderName: 'Bogdan', bankBranch: 'București')..initializeAccount('RO12345'),
      BankAccount(holderName: 'Andrei'),
    ];

    final library = Library();
    final book = Book(title: "Flutter Basics", author: "Google", pageCount: 300);
    final magazine = Magazine(title: "Dart Weekly", issueNumber: 42);
    
    library.addItem(book);
    library.addItem(magazine);
    
    library.borrowItem(book, users[0], DateTime.now().add(const Duration(days: 14)));

    return Scaffold(
      appBar: AppBar(title: const Text('Lab 2 - Prezentare')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          const Text('--- Task I: Users ---', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...users.map((u) => ListTile(
            title: Text(u.name),
            subtitle: Text("Vârstă: ${u.getDisplayAge()} | Email: ${u.email ?? 'Not provided'}"),
          )),
          const Divider(),

          const Text('--- Task II: Bank Accounts ---', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...accounts.map((a) {
            final accountInfo = a.isAccountSet() ? a.accountNumber : 'Cont neinițializat';
            return ListTile(
              title: Text('${a.holderName} ($accountInfo)'),
              subtitle: Text(a.bankBranch ?? 'Not provided'),
            );
          }),
          const Divider(),

          const Text('--- Task III: Library ---', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...library.items.map((item) {
            final status = item.borrower != null 
                ? 'Împrumutat de ${item.borrower!.name}' 
                : 'Disponibil';
            return ListTile(
              title: Text(item.title),
              subtitle: Text("Autor: ${item.author ?? 'Necunoscut'} | Status: $status"),
            );
          }),
        ],
      ),
    );
  }
}