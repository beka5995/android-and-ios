void checkBalance({required String name, required double balance}) =>
    print('$balance');

double deposit({required double currentBalance, double? amount}) {
  double validAmount = amount ?? 0.0;
  double updatedBalance = currentBalance + validAmount;
  print('$updatedBalance');
  return updatedBalance;
}

double withdraw({
  required String name,
  required double currentBalance,
  double? amount,
  int? pinCode,
}) {
  int verifiedPin = pinCode ?? 0000;
  if (verifiedPin != 1234) {
    print('$currentBalance');
    return currentBalance;
  }

  double validAmount = amount ?? 0.0;

  if (validAmount > currentBalance) {
    print('$currentBalance');
    return currentBalance;
  }

  double updatedBalance = currentBalance - validAmount;
  print('$updatedBalance');
  return updatedBalance;
}

void main() {
  String accountName = 'Bekzhan Mashat';
  double myBalance = 500.0;

  checkBalance(name: accountName, balance: myBalance);

  myBalance = deposit(currentBalance: myBalance, amount: 150.0);
  myBalance = deposit(currentBalance: myBalance);

  myBalance = withdraw(
    name: accountName,
    currentBalance: myBalance,
    amount: 100.0,
    pinCode: 9999,
  );

  myBalance = withdraw(
    name: accountName,
    currentBalance: myBalance,
    amount: 1000.0,
    pinCode: 1234,
  );

  myBalance = withdraw(
    name: accountName,
    currentBalance: myBalance,
    amount: 200.0,
    pinCode: 1234,
  );

  checkBalance(name: accountName, balance: myBalance);
}