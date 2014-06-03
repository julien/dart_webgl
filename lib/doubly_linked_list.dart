/**
 * Ported from
 * https://github.com/nzakas/computer-science-in-javascript/blob/master/data-structures/doubly-linked-list/doubly-linked-list.js
 */

part of dart_webgl;

class DoublyLinkedList {
  
  Map<String, dynamic> _head = {
    'data': null,
    'next': null,
    'prev': null
  };
  
  Map<String, dynamic> _tail = {
    'data': null,
    'next': null,
    'prev': null
  };
  
  int _length = 0;
  
  void add(dynamic data) {
    var node = {
      'data': data,
      'next': null,
      'prev': null
    };
    
    if (_length == 0) {
      _head = node;
      _tail = node;
    } else {
      _tail['next'] = node;
      node['prev'] = _tail;
      _tail = node;
    }
    _length++;
  }
  
  dynamic item(int index) {
    if (index > -1 && index < _length) {
      var current = _head, i = 0;
      
      while (i++ < index) {
        current = current['next'];
      }
      return current['data'];
    } else {
      return null;
    }
  }
  
  dynamic remove(int index) {
    if (index > -1 && index < _length) {
      
      var current = _head, i = 0;
      
      if (index == 0) {
        _head = current['next'];
        
        if (_head == null) {
          _tail = null;
        } else {
          _head['prev'] = null;
        }
        
      } else if (index == _length) {
        current = _tail;
        _tail = current['prev'];
        _tail['next'] = null;
      
      } else {
        
        while (i++ < index) {
          current = current['next'];
        }
        current['prev']['next'] = current['next'];
      }
      
      _length--;
      return current['data'];
       
    } else {
      return null;
    }
  }
  
  int size() => _length;
  
  List<dynamic> toArray() {
    var result = [], current = _head;
    
    while (current != null) {
      result.add(current['data']);
      current = current['next'];
    }
    return result;
  }
  
  String toString() => toArray().toString();
  
}