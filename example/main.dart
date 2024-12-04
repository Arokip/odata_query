import 'package:odata_query/odata_query.dart';

void main() {
  // Example 1: Build a query to filter products where the name is 'Milk' and price is less than 2.55.
  // Then order by 'Price' in descending order, select 'Name' and 'Price', expand the 'Category',
  // retrieve the top 10 items, and include the total count of records.
  final queryString = ODataQuery(
    filter: Filter.and(
      Filter.eq('Name', 'Milk'),
      Filter.lt('Price', 2.55),
    ),
    orderBy: OrderBy.desc('Price'),
    select: ['Name', 'Price'],
    expand: ['Category'], // Expanding related entities
    top: 10,
    count: true,
  ).toEncodedString();

  print('Query 1 (toEncodedString): $queryString');
  // Result:
  // "$filter=Name%20eq%20'Milk'%20and%20Price%20lt%202.55&$orderby=Price%20desc&$select=Name%2CPrice&$expand=Category&$top=10&$count=true"

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
  ).toEncodedString();

  print('Query 5 (inCollection): $queryInCollection');
  // Result:
  // "$filter=Name%20in%20RelevantProductNames&$select=Name%2CPrice"
}
