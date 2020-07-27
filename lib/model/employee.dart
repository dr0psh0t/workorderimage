class Employee {

  final String employee;

  Employee({this.employee});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employee: json['employee'] as String,
    );
  }
}