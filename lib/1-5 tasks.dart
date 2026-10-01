bool isLeapYear(int year) {
  if (year % 400 == 0) return true;
  if (year % 100 == 0) return false;
  return year % 4 == 0;
}

void main() {
  // TASK 1
  for (int i = 1; i <= 10; i++) {
    print('$i:');
    for (int j = 1; j <= 10; j++) {
      print('$i * $j = ${i * j}');
    }
    print('');
  }

  // TASK 2
  void printNextDay(int day, int month, int year) {
    List<int> daysInMonths = [
      31,
      isLeapYear(year) ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];

    if (year < 1 || month < 1 || month > 12 || day < 1 || day > daysInMonths[month - 1]) {
      print('$day.$month.$year -> invalid date');
      return;
    }

    int nextDay = day + 1;
    int nextMonth = month;
    int nextYear = year;

    if (nextDay > daysInMonths[month - 1]) {
      nextDay = 1;
      nextMonth++;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
    }

    String dStr = nextDay < 10 ? '0$nextDay' : '$nextDay';
    String mStr = nextMonth < 10 ? '0$nextMonth' : '$nextMonth';
    String originalD = day < 10 ? '0$day' : '$day';
    String originalM = month < 10 ? '0$month' : '$month';

    print('$originalD.$originalM.$year -> $dStr.$mStr.$nextYear');
  }

  printNextDay(5, 9, 2400);
  printNextDay(28, 2, 2024);
  printNextDay(28, 2, 2000);
  printNextDay(29, 2, 2026);
  printNextDay(28, 2, 2100);
  printNextDay(31, 12, 2025);
//TASK 3
  String sentence = "flutter mobile development";
  int vowelCount = 0;
  String vowels = "aeiouAEIOU";

  for (int i = 0; i < sentence.length; i++) {
    if (vowels.contains(sentence[i])) {
      vowelCount++;
    }
  }
  print('String: "$sentence" -> Vowels: $vowelCount');

  // TASK 4
  List<int> numbers = [1, 8, 3, 42, 99, 12, 67];

  int maxVal = numbers[0];
  int minVal = numbers[0];

  for (int i = 1; i < numbers.length; i++) {
    if (numbers[i] > maxVal) {
      maxVal = numbers[i];
    }
    if (numbers[i] < minVal) {
      minVal = numbers[i];
    }
  }
  print('Numbers: $numbers -> max: $maxVal, min: $minVal');

  // TASK 5
  bool checkPrime(int n) {
    if (n <= 1) return false;
    for (int i = 2; i <= n ~/ 2; i++) {
      if (n % i == 0) return false;
    }
    return true;
  }

  int test1 = 3;
  int test2 = 6;
  print('$test1 -> ${checkPrime(test1) ? "prime number" : "not prime number"}');
  print('$test2 -> ${checkPrime(test2) ? "prime number" : "not prime number"}');
}