// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class _InvocationMirror implements Invocation {
  // Constants describing the invocation type.
  // _FIELD cannot be generated by regular invocation mirrors.
  static const int _METHOD = 0;
  static const int _GETTER = 1;
  static const int _SETTER = 2;
  static const int _FIELD = 3;
  static const int _TYPE_SHIFT = 0;
  static const int _TYPE_BITS = 2;
  static const int _TYPE_MASK = (1 << _TYPE_BITS) - 1;

  // These values, except _DYNAMIC and _SUPER, are only used when throwing
  // NoSuchMethodError for compile-time resolution failures.
  static const int _DYNAMIC = 0;
  static const int _SUPER = 1;
  static const int _STATIC = 2;
  static const int _CONSTRUCTOR = 3;
  static const int _TOP_LEVEL = 4;
  static const int _CALL_SHIFT = _TYPE_BITS;
  static const int _CALL_BITS = 3;
  static const int _CALL_MASK = (1 << _CALL_BITS) - 1;

  // Internal representation of the invocation mirror.
  final String _functionName;
  final List _argumentsDescriptor;
  final List _arguments;
  final bool _isSuperInvocation;

  // External representation of the invocation mirror; populated on demand.
  Symbol _memberName;
  int _type;
  List _positionalArguments;
  Map<Symbol, dynamic> _namedArguments;

  void _setMemberNameAndType() {
    if (_functionName.startsWith("get:")) {
      _type = _GETTER;
      _memberName =
          new _collection_dev.Symbol.unvalidated(_functionName.substring(4));
    } else if (_functionName.startsWith("set:")) {
      _type = _SETTER;
      _memberName =
          new _collection_dev.Symbol.unvalidated(
              _functionName.substring(4) + "=");
    } else {
      _type = _isSuperInvocation ? (_SUPER << _CALL_SHIFT) | _METHOD : _METHOD;
      _memberName = new _collection_dev.Symbol.unvalidated(_functionName);
    }
  }

  Symbol get memberName {
    if (_memberName == null) {
      _setMemberNameAndType();
    }
    return _memberName;
  }

  List get positionalArguments {
    if (_positionalArguments == null) {
      int numPositionalArguments = _argumentsDescriptor[1];
      // Don't count receiver.
      if (numPositionalArguments == 1) {
        return _positionalArguments = const [];
      }
      // Exclude receiver.
      _positionalArguments =
          new _ImmutableList._from(_arguments, 1, numPositionalArguments - 1);
    }
    return _positionalArguments;
  }

  Map<Symbol, dynamic> get namedArguments {
    if (_namedArguments == null) {
      int numArguments = _argumentsDescriptor[0] - 1;  // Exclude receiver.
      int numPositionalArguments = _argumentsDescriptor[1] - 1;
      int numNamedArguments = numArguments - numPositionalArguments;
      if (numNamedArguments == 0) {
        return _namedArguments = const <Symbol, dynamic>{};
      }
      _namedArguments = new Map<Symbol, dynamic>();
      for (int i = 0; i < numNamedArguments; i++) {
        String arg_name = _argumentsDescriptor[2 + 2*i];
        var arg_value = _arguments[_argumentsDescriptor[3 + 2*i]];
        _namedArguments[new _collection_dev.Symbol.unvalidated(arg_name)] =
            arg_value;
      }
    }
    return _namedArguments;
  }

  bool get isMethod {
    if (_type == null) {
      _setMemberNameAndType();
    }
    return (_type & _TYPE_MASK) == _METHOD;
  }

  bool get isAccessor {
    if (_type == null) {
      _setMemberNameAndType();
    }
    return (_type & _TYPE_MASK) != _METHOD;
  }

  bool get isGetter {
    if (_type == null) {
      _setMemberNameAndType();
    }
    return (_type & _TYPE_MASK) == _GETTER;
  }

  bool get isSetter {
    if (_type == null) {
      _setMemberNameAndType();
    }
    return (_type & _TYPE_MASK) == _SETTER;
  }

  _InvocationMirror(this._functionName,
                    this._argumentsDescriptor,
                    this._arguments,
                    this._isSuperInvocation);

  static _allocateInvocationMirror(String functionName,
                                   List argumentsDescriptor,
                                   List arguments,
                                   bool isSuperInvocation) {
    return new _InvocationMirror(functionName,
                                 argumentsDescriptor,
                                 arguments,
                                 isSuperInvocation);
  }
}
