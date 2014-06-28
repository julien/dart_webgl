


void main() {
  
  var data = [1, 2, 3, 4, 5, 6, 7],
      cloned = data.toList();
  
  
  
  data.clear();
  
  data.addAll(cloned.getRange(0, 2));
  
  print(data);
}