import 'package:odata_query/src/utils/filter_operators_enum.dart';

/// ODataQuery helps build OData query strings by combining various parameters
/// like $filter, $orderby, $select, and more in a declarative way.
///
/// Example:
/// ```dart
/// final query = ODataQuery(
///   filter: Filter.and(
///     Filter.eq('Name', 'Milk'),
///     Filter.lt('Price', 2.55),
///   ),
///   orderBy: OrderBy.desc('Price'),
///   top: 10,
///   count: true,
/// ).build();
///
/// print(query);
/// Output: "$filter=Name%20eq%20%27Milk%27%20and%20Price%20lt%202.55&$orderby=Price%20desc&$top=10&$count=true"
/// ```
class ODataQuery {
  ODataQuery({
    this.search,
    this.filter,
    this.orderBy,
    this.select,
    this.expand,
    this.top,
    this.skip,
    this.count,
  });

  /// The `$search` parameter allows searching for specific values across multiple fields.
  /// It supports free-text search, and the search string must be URL-encoded.

  final String? search;

  /// The `$filter` parameter is used to apply specific conditions or filters to the query.
  /// It helps to narrow down the results by specifying logical operations like `eq`, `ne`, `lt`, `gt`, etc.
  ///
  /// Example:
  /// ```dart
  /// filter: Filter.eq('Name', 'Milk')
  /// ```
  final Filter? filter;

  /// The `$orderby` parameter is used to specify sorting of the results based on one or more fields.
  /// You can sort the results in ascending or descending order.
  ///
  /// Example:
  /// ```dart
  /// orderBy: OrderBy.desc('Price')
  /// ```
  final OrderBy? orderBy;

  /// The `$select` parameter allows selecting specific fields to be returned in the result set.
  /// This reduces the payload size by fetching only the required properties.
  ///
  /// Example:
  /// ```dart
  /// select: ['Name', 'Price']
  /// ```
  final List<String>? select;

  /// The `$expand` parameter is used to include related entities in the query response.
  /// It allows for expanding related entities, typically in a parent-child relationship.
  ///
  /// Example:
  /// ```dart
  /// expand: ['Category', 'Item']
  /// ```
  final List<String>? expand;

  /// The `$top` parameter limits the number of records returned by the query.
  /// It is useful for pagination or retrieving a fixed number of results.
  final int? top;

  /// The `$skip` parameter is used to skip a specified number of records from the result set.
  /// It is useful for implementing pagination alongside `$top`.
  final int? skip;

  /// The `$count` parameter determines whether the total count of records should be included in the response.
  /// When set to `true`, the count of the matching entities will be returned along with the result.
  final bool? count;

  Map<String, String> get _params => {
        if (search case final search?) r'$search': search,
        if (filter case final filter?) r'$filter': filter.toString(),
        if (orderBy case final orderBy?) r'$orderby': orderBy.toString(),
        if (select case final select? when select.isNotEmpty)
          r'$select': select.join(','),
        if (expand case final expand? when expand.isNotEmpty)
          r'$expand': expand.join(','),
        if (top case final top?) r'$top': top.toString(),
        if (skip case final skip?) r'$skip': skip.toString(),
        if (count case final count?) r'$count': count.toString().toLowerCase(),
      };

  /// Builds the final OData query string by combining all provided options.
  ///
  /// Example:
  /// ```dart
  /// final query = ODataQuery(
  ///   filter: Filter.eq('Name', 'Milk'),
  ///   orderBy: OrderBy.asc('Price'),
  /// ).build();
  ///
  /// print(query);
  /// Output: "$filter=Name eq 'Milk'&$orderby=Price asc"
  /// ```
  @override
  String toString() =>
      _params.entries.map((entry) => '${entry.key}=${entry.value}').join('&');

  /// Builds the final OData query string by combining all provided options.
  /// It constructs a URL-friendly string with encoded values.
  ///
  /// Example:
  /// ```dart
  /// final query = ODataQuery(
  ///   filter: Filter.eq('Name', 'Milk'),
  ///   orderBy: OrderBy.asc('Price'),
  /// ).build();
  ///
  /// print(query);
  /// Output: "$filter=Name%20eq%20%27Milk%27&$orderby=Price%20asc"
  /// ```
  String toEncodedString() => _params.entries
      .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
      .join('&');

  /// Converts the current ODataQuery instance into a Map of query parameters.
  /// Each key represents an OData parameter like `$filter`, `$orderby`, etc.,
  /// and the corresponding value is the associated string for that parameter.
  ///
  /// Example:
  /// ```dart
  /// final query = ODataQuery(
  ///   filter: Filter.eq('Name', 'Milk'),
  ///   top: 10,
  /// ).toMap();
  ///
  /// print(query);
  /// Output: {'$filter': "Name eq 'Milk'", '$top': '10'}
  /// ```
  ///
  /// This is useful if you want to manipulate the query parameters as a Map.
  Map<String, String> toMap() => _params;
}

/// The Filter class is used to construct OData $filter expressions programmatically.
/// It provides methods to create filters like eq (equals), ne (not equals), gt (greater than),
/// lt (less than), and allows combining filters using logical AND/OR.
///
/// Example:
/// ```dart
/// final filter = Filter.and(
///   Filter.eq('Name', 'Milk'),
///   Filter.lt('Price', 2.55),
/// );
///
/// print(filter.toString());
/// Output: "Name eq 'Milk' and Price lt 2.55"
/// ```
class Filter {
  Filter._(this._expression);

  final String _expression;

  /// Creates an equality filter (e.g., "Name eq 'Milk'").
  static Filter eq(String field, dynamic value) =>
      Filter._('$field eq ${_encode(value)}');

  /// Creates a non-equality filter (e.g., "Name ne 'Milk'").
  static Filter ne(String field, dynamic value) =>
      Filter._('$field ne ${_encode(value)}');

  /// Creates a greater-than filter (e.g., "Price gt 2.55").
  static Filter gt(String field, dynamic value) =>
      Filter._('$field gt ${_encode(value)}');

  /// Creates a less-than filter (e.g., "Price lt 2.55").
  static Filter lt(String field, dynamic value) =>
      Filter._('$field lt ${_encode(value)}');

  /// Creates a greater-than or equal-to filter.
  static Filter ge(String field, dynamic value) =>
      Filter._('$field ge ${_encode(value)}');

  /// Creates a less-than or equal-to filter.
  static Filter le(String field, dynamic value) =>
      Filter._('$field le ${_encode(value)}');

  /// Combines two filters using a logical AND (e.g., "Name eq 'Milk' and Price lt 2.55").
  static Filter and(Filter left, Filter right) =>
      Filter._('${left._expression} and ${right._expression}');

  /// Combines two filters using a logical OR (e.g., "Name eq 'Milk' or Price lt 2.55").
  static Filter or(Filter left, Filter right) =>
      Filter._('${left._expression} or ${right._expression}');

  /// Creates an `in` filter for matching a field against a list of values.
  ///
  /// Example:
  /// ```dart
  /// filter: Filter.inList('Name', ['Milk', 'Cheese', 'Donut'])
  /// // Produces: Name in ('Milk','Cheese','Donut')
  /// ```
  static Filter inList(String field, List<dynamic> values) {
    final encodedValues = values.map(_encode).join(',');
    return Filter._('$field in ($encodedValues)');
  }

  /// Creates an `in` filter for matching a field against another collection or expression.
  ///
  /// Example:
  /// ```dart
  /// filter: Filter.inCollection('Name', 'RelevantProductNames')
  /// // Produces: "Name in RelevantProductNames"
  /// ```
  static Filter inCollection(String field, String collection) {
    return Filter._('$field in $collection');
  }

  /// Creates a filter using the `any` operator.
  ///
  /// Example:
  /// ```dart
  /// Filter.any('collection', 'item', Filter.eq('item/subProperty', 'value'))
  /// // Produces: "collection/any(item:item/subProperty eq 'value')"
  /// ```
  static Filter any(String collection, String variable, Filter condition) =>
      Filter._('$collection/any($variable:${condition._expression})');

  /// Creates a filter using the `all` operator.
  ///
  /// Example:
  /// ```dart
  /// Filter.all('collection', 'item', Filter.eq('item/subProperty', 'value'))
  /// // Produces: "collection/all(item:item/subProperty eq 'value')"
  /// ```
  static Filter all(String collection, String variable, Filter condition) =>
      Filter._('$collection/all($variable:${condition._expression})');

  /// Creates an 'or' filter with multiple 'eq' filters
  ///
  /// Example:
  /// ```dart
  /// Filter.orEqList('Name', ['Khaled', 'Ahmad'])
  /// Produces: "Name eq 'Khaled' or Name eq 'Ahmad'"
  /// ```
  static Filter orEqList(String field, List<dynamic> values) => Filter._(
        _encodeEqList(
          field,
          values,
          FilterOperators.or,
        ),
      );

  /// Creates an 'and' filter with multiple 'eq' filters
  ///
  /// Example:
  /// ```dart
  /// Filter.andEqList('Name', ['Khaled', 'Ahmad'])
  /// Produces: "Name eq 'Khaled' and Name eq 'Ahmad'"
  /// ```
  static Filter andEqList(String field, List<dynamic> values) =>
      Filter._(_encodeEqList(field, values, FilterOperators.and));

  /// Creates an 'and' filter with multiple 'eq' conditions for different fields
  ///
  /// Example:
  /// ```dart
  /// Filter.andEqListDiffFields({'Name': 'Khaled', 'Age': 30})
  /// Produces: "Name eq 'Khaled' and Age eq 30"
  /// ```
  static Filter andEqListDiffFields(
    Map<String, dynamic> values,
  ) =>
      Filter._(_encodeEqListWDiffFields(values, FilterOperators.and));

  /// Creates an 'or' filter with multiple 'eq' conditions for different fields
  ///
  /// Example:
  /// ```dart
  /// Filter.orEqListDiffFields({'Name': 'Khaled', 'Age': 30})
  /// Produces: "Name eq 'Khaled' or Age eq 30"
  /// ```
  static Filter orEqListDiffFields(
    Map<String, dynamic> values,
  ) =>
      Filter._(_encodeEqListWDiffFields(values, FilterOperators.or));

  /// Creates a 'contains' filter for a specific field and value
  ///
  /// Example:
  /// ```dart
  /// Filter.contains('Name', 'Khaled')
  /// Produces: "contains(Name, 'Khaled')"
  /// ```
  static Filter contains(
    String field,
    String value,
  ) =>
      Filter._('contains($field,${_encode(value)})');

  /// Combines multiple filters using the specified operator ('and' or 'or')
  ///
  /// Example:
  /// ```dart
  /// Filter.multiFilters([
  ///   Filter.contains('Name', 'Khaled'),
  ///   Filter.orEqList('Age', [25, 30])
  /// ], FilterOperators.and)
  /// Produces: "contains(Name, 'Khaled') and Age eq 25 or Age eq 30"
  /// ```
  static Filter multiFilters(
    List<Filter> filters,
    FilterOperators operator,
  ) =>
      Filter._(
        filters.map((e) => e.toString()).join(' ${operator.name} '),
      );

  /// Helper method to encode values like strings or numbers.
  static String _encode(dynamic value) {
    if (value is String) {
      return "'${value.replaceAll("'", "''")}'";
    }
    return value.toString();
  }

  /// Helper method to encode list values.
  static String _encodeEqList(
    String field,
    List<dynamic> values,
    FilterOperators operator,
  ) {
    return values
        .map((e) => '$field eq ${_encode(e)}')
        .join(' ${operator.name} ');
  }

  /// Helper method to encode map values.
  static String _encodeEqListWDiffFields(
    Map<String, dynamic> map,
    FilterOperators operator,
  ) {
    return map.entries
        .map((entry) => '${entry.key} eq ${_encode(entry.value)}')
        .join(' ${operator.name} ');
  }

  /// Converts the filter to a string for query usage.
  @override
  String toString() => _expression;
}

/// The OrderBy class is used to create OData $orderby expressions, allowing sorting
/// by fields in either ascending or descending order.
///
/// Example:
/// ```dart
/// final orderBy = OrderBy.desc('Price');
/// print(orderBy.toString());
/// Output: "Price desc"
/// ```
class OrderBy {
  OrderBy._(this._expression);

  final String _expression;

  /// Sorts results by a field in ascending order (e.g., "Price asc").
  static OrderBy asc(String field) => OrderBy._('$field asc');

  /// Sorts results by a field in descending order (e.g., "Price desc").
  static OrderBy desc(String field) => OrderBy._('$field desc');

  /// Converts the order-by clause to a string for query usage.
  @override
  String toString() => _expression;
}
