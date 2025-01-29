enum FilterOperators { or, and }

extension FilterOperatorsExtension on FilterOperators {
  String get name => toString().split('.').last;
}
