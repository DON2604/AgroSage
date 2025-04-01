String getCurrentDate() {
  DateTime now = DateTime.now();
  return "${now.day}/${now.month}/${now.year}";
}
