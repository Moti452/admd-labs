class BankAccount {
  late String accountNumber;
  String holderName;
  double balance;
  String? bankBranch;

  BankAccount({
    required this.holderName,
    this.balance = 0.0,
    this.bankBranch,
  });

  void initializeAccount(String number) {
    accountNumber = number;
  }

  bool isAccountSet() {
    try {
      // Încercăm să citim variabila. Dacă nu a fost inițializată, va arunca o eroare.
      var _ = accountNumber;
      return true;
    } catch (e) {
      return false;
    }
  }
}