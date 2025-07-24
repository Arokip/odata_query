import 'package:odata_query/odata_query.dart';

void main() {
  // Example 1: Build a query to filter products where the name is 'Milk' and price is less than 2.55.
  // Then order by 'Price' in descending order, select 'Name' and 'Price', expand the 'Category',
  // retrieve the top 10 items, and include the total count of records.
  final queryString = ODataQuery(
    filter: Filter.and([
      Filter.eq('Name', 'Milk'),
      Filter.lt('Price', 2.55),
      Filter.eq('Category', 'Dairy'),
      if (0 != 1) Filter.eq('ShouldShowHidden', true),
    ]),
    orderBy: OrderBy.desc('Price'),
    select: ['Name', 'Price'],
    expand: ['Category'], // Expanding related entities
    top: 10,
    count: true,
  ).toEncodedString();

  print('Query 1 (toEncodedString): $queryString');
  // Result:
  // "$filter=Name%20eq%20'Milk'%20and%20Price%20lt%202.55%20and%20Category%20eq%20'Dairy'%20and%20ShouldShowHidden%20eq%20true&$orderby=Price%20desc&$select=Name%2CPrice&$expand=Category&$top=10&$count=true"

  // Example 2: Build a query to search for products in the 'Bakery' category,
  // return the top 5 results, skip the first 10 items, and order by 'Name' in ascending order.
  final queryMap = ODataQuery(
    search: 'Bakery',
    top: 5,
    skip: 10,
    orderBy: OrderBy.asc('Name'),
  ).toMap();

  print('Query 2 (toMap): $queryMap');
  // Result:
  // {
  //   '$search': "Bakery",
  //   '$orderby': "Name asc",
  //   '$top': "5",
  //   '$skip': "10"
  // }

  // Example 3: Build a nested query to select 'Name' and 'Price', and expand the 'Category'
  // with a sub-query that selects only the 'Type' field from 'Category' and orders by 'DateCreated' in ascending order.
  //
  // Warning: the nested ODataQueries must be separated by a colon.
  final queryNested = ODataQuery(
    select: ['Name', 'Price'],
    expand: [
      'Category(${ODataQuery(
        select: ['Type'],
      )};${ODataQuery(
        orderBy: OrderBy.asc('DateCreated'),
      )})',
    ],
  ).toString();

  print('Query 3 (nested): $queryNested');
  // Result:
  // "$select=Name,Price&$expand=Category($select=Type;$orderby=DateCreated asc)"

  // Example 4: Using inList to filter products where the 'Name' is one of several values.
  // This query filters items whose name is either 'Milk', 'Cheese', or 'Donut', and selects 'Name' and 'Price'.
  final queryInList = ODataQuery(
    filter: Filter.inList('Name', ['Milk', 'Cheese', 'Donut']),
    select: ['Name', 'Price'],
  ).toEncodedString();

  print('Query 4 (inList): $queryInList');
  // Result:
  // "$filter=Name%20in%20('Milk'%2C'Cheese'%2C'Donut')&$select=Name%2CPrice"

  // Example 5: Using inCollection to filter products where the 'Name' exists in a predefined collection.
  // This query filters items whose name is part of the 'RelevantProductNames' collection and selects 'Name' and 'Price'.
  final queryInCollection = ODataQuery(
    filter: Filter.inCollection('Name', 'RelevantProductNames'),
    select: ['Name', 'Price'],
  ).toString();

  print('Query 5 (inCollection): $queryInCollection');
  // Result:
  // "$filter=Name in RelevantProductNames&$select=Name,Price"

  // Example 6: Using any to filter products with a collection property.
  // This filters items where there is at least one product that have the value 'Active' for the 'Type' property.
  final queryAny = ODataQuery(
    filter: Filter.any('Products', 'item', Filter.eq('item/Type', 'Active')),
  ).toString();

  print('Query 6 (any): $queryAny');
  // Result:
  // "$filter=Products/any(item:item/Type eq 'Active')"

  // Example 7: Using all to filter products where all items in a collection satisfy a condition.
  // This filters items where all products that have the value 'Active' for the 'Type' property.
  final queryAll = ODataQuery(
    filter: Filter.all('Products', 'item', Filter.eq('item/Type', 'Active')),
  ).toString();

  print('Query 7 (all): $queryAll');
  // Result:
  // "$filter=Products/all(item:item/Type eq 'Active')"

  // Example 8: Filtering products where the 'Name' does NOT contain 'Sugar',
  // does start with 'Choco', and does end with 'Bar'.
  final searchQuery = ODataQuery(
    filter: Filter.or([
      Filter.and([
        Filter.startsWith('Name', 'Choco'),
        Filter.endsWith('Name', 'Bar'),
      ]),
      Filter.not(
        Filter.contains('Name', 'Sugar'),
      ),
    ]),
  ).toString();

  print('Query 8 (search): $searchQuery');
  // Expected Result:
  // "$filter=startswith(Name,'Choco') and endswith(Name,'Bar') or not contains(Name,'Sugar')"

  // Example 9: Using chained OrderBy to sort by multiple fields
  final queryChainedOrderBy = ODataQuery(
    filter: Filter.eq('Category', 'Beverages'),
    orderBy: OrderBy.desc('Date').thenAsc('Name').thenDesc('Price'),
    select: ['Name', 'Price', 'Date'],
  ).toString();

  print('Query 9 (chained OrderBy): $queryChainedOrderBy');
  // Result:
  // "$filter=Category eq 'Beverages'&$orderby=Date desc, Name asc, Price desc&$select=Name,Price,Date"

  // Example 10: Complex nested filters with automatic parentheses
  // This demonstrates how the package automatically adds parentheses around nested
  // expressions to ensure proper OData operator precedence.
  final queryNestedFilters = ODataQuery(
    filter: Filter.and([
      Filter.eq('ProductTypeId', 1),
      Filter.or([
        Filter.eq('CategoryId', 10),
        Filter.eq('CategoryId', 33),
      ]),
      Filter.and([
        Filter.eq('category', 'groceries'),
        Filter.eq('category', 'ingredients'),
      ]),
    ]),
  ).toString();

  print('Query 10 (nested filters with parentheses): $queryNestedFilters');
  // Result:
  // "$filter=ProductTypeId eq 1 and (CategoryId eq 10 or CategoryId eq 33) and (category eq 'groceries' and category eq 'ingredients')"

  // Example 11: Another complex filter showing OR with nested AND expressions
  final queryComplexOr = ODataQuery(
    filter: Filter.or([
      Filter.eq('Category', 'Premium'),
      Filter.and([
        Filter.eq('Category', 'Standard'),
        Filter.lt('Price', 50),
        Filter.gt('Rating', 4),
      ]),
      Filter.eq('OnSale', true),
    ]),
    select: ['Name', 'Category', 'Price', 'Rating'],
  ).toString();

  print('Query 11 (OR with nested AND): $queryComplexOr');
  // Result:
  // "$filter=Category eq 'Premium' or (Category eq 'Standard' and Price lt 50 and Rating gt 4) or OnSale eq true&$select=Name,Category,Price,Rating"
}
