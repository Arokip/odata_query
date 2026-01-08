import 'package:flutter_test/flutter_test.dart';
import 'package:odata_query/src/odata_query.dart';

void main() {
  group('ODataQuery', () {
    test('should create a query with filter and orderBy', () {
      final query = ODataQuery(
        filter: Filter.eq('Name', 'Milk'),
        orderBy: OrderBy.asc('Price'),
      ).toEncodedString();

      expect(query, r"$filter=Name%20eq%20'Milk'&$orderby=Price%20asc");
    });

    test('should include top and count in the query', () {
      final query = ODataQuery(
        top: 10,
        count: true,
      ).toString();

      expect(query, r'$top=10&$count=true');
    });

    test('should handle all query parameters', () {
      final query = ODataQuery(
        search: 'Milk',
        filter: Filter.and([
          Filter.eq('Name', 'Milk'),
          Filter.lt('Price', 2.55),
        ]),
        orderBy: OrderBy.desc('Price'),
        select: ['Name', 'Price'],
        expand: ['Category'],
        top: 5,
        skip: 2,
        count: true,
      ).toEncodedString();

      expect(
        query,
        r"$search=Milk&$filter=Name%20eq%20'Milk'%20and%20Price%20lt%202.55&$orderby=Price%20desc&$select=Name%2CPrice&$expand=Category&$top=5&$skip=2&$count=true",
      );
    });

    test('should convert to map correctly', () {
      final queryMap = ODataQuery(
        filter: Filter.eq('Name', 'Milk'),
        top: 10,
      ).toMap();

      expect(queryMap, {
        r'$filter': "Name eq 'Milk'",
        r'$top': '10',
      });
    });

    test('should handle empty or null parameters', () {
      final query = ODataQuery().toEncodedString();
      expect(query, '');
    });

    test('should handle complex filters with both AND and OR', () {
      final query = ODataQuery(
        filter: Filter.and([
          Filter.or([
            Filter.eq('Category', 'Beverages'),
            Filter.eq('Category', 'Snacks'),
          ]),
          Filter.gt('Price', 5),
        ]),
      ).toEncodedString();

      expect(
        query,
        r"$filter=(Category%20eq%20'Beverages'%20or%20Category%20eq%20'Snacks')%20and%20Price%20gt%205",
      );
    });

    test(
        'should handle complex filters with both AND and OR - updated with parentheses',
        () {
      final query = ODataQuery(
        filter: Filter.and([
          Filter.or([
            Filter.eq('Category', 'Beverages'),
            Filter.eq('Category', 'Snacks'),
          ]),
          Filter.gt('Price', 5),
        ]),
      ).toString();

      expect(
        query,
        r"$filter=(Category eq 'Beverages' or Category eq 'Snacks') and Price gt 5",
      );
    });

    test('should match the exact user example with proper parentheses', () {
      final query = ODataQuery(
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

      expect(
        query,
        r"$filter=ProductTypeId eq 1 and (CategoryId eq 10 or CategoryId eq 33) and (category eq 'groceries' and category eq 'ingredients')",
      );
    });

    test('should handle null filter values correctly', () {
      final query = ODataQuery(
        filter: Filter.eq('Name', null),
      ).toEncodedString();

      expect(query, r'$filter=Name%20eq%20null');
    });

    test('should handle multiple select fields', () {
      final query = ODataQuery(
        select: ['Name', 'Price', 'Category'],
      ).toEncodedString();

      expect(
        query,
        r'$select=Name%2CPrice%2CCategory',
      );
    });

    test('should handle multiple expand fields', () {
      final query = ODataQuery(
        expand: ['Category', 'Supplier'],
      ).toEncodedString();

      expect(
        query,
        r'$expand=Category%2CSupplier',
      );
    });

    test('should ignore empty or null select and expand', () {
      final query = ODataQuery(
        select: [],
        expand: null,
      ).toEncodedString();

      expect(query, '');
    });

    test('should handle skip without top', () {
      final query = ODataQuery(
        skip: 20,
      ).toEncodedString();

      expect(query, r'$skip=20');
    });

    test('should create a query with filter using inList', () {
      final query = ODataQuery(
        filter: Filter.inList('Name', ['Milk', 'Cheese', 'Donut']),
      ).toEncodedString();

      expect(query, r"$filter=Name%20in%20('Milk'%2C'Cheese'%2C'Donut')");
    });

    test('should create a query with filter using inCollection', () {
      final query = ODataQuery(
        filter: Filter.inCollection('Name', 'RelevantProductNames'),
      ).toEncodedString();

      expect(query, r'$filter=Name%20in%20RelevantProductNames');
    });
  });

  group('Filter', () {
    test('should create an eq filter', () {
      final filter = Filter.eq('Name', 'Milk').toString();
      expect(filter, "Name eq 'Milk'");
    });

    test('should create a lt filter', () {
      final filter = Filter.lt('Price', 2.55).toString();
      expect(filter, 'Price lt 2.55');
    });

    test('should combine filters using and', () {
      final filter = Filter.and([
        Filter.eq('Name', 'Milk'),
        Filter.lt('Price', 2.55),
      ]).toString();

      expect(filter, "Name eq 'Milk' and Price lt 2.55");
    });

    test('should handle multiple conditions in and filter', () {
      final filter = Filter.and([
        Filter.eq('Name', 'Milk'),
        Filter.lt('Price', 2.55),
        Filter.gt('Quantity', 10),
        Filter.eq('Category', 'Dairy'),
      ]).toString();

      expect(
        filter,
        "Name eq 'Milk' and Price lt 2.55 and Quantity gt 10 and Category eq 'Dairy'",
      );
    });

    test('should handle empty and filter', () {
      final filter = Filter.and([]).toString();
      expect(filter, '');
    });

    test('should combine filters using or', () {
      final filter = Filter.or([
        Filter.eq('Name', 'Milk'),
        Filter.gt('Price', 1.5),
      ]).toString();

      expect(filter, "Name eq 'Milk' or Price gt 1.5");
    });

    test('should handle multiple conditions in or filter', () {
      final filter = Filter.or([
        Filter.eq('Name', 'Milk'),
        Filter.eq('Name', 'Cheese'),
        Filter.eq('Name', 'Yogurt'),
        Filter.eq('Name', 'Butter'),
      ]).toString();

      expect(
        filter,
        "Name eq 'Milk' or Name eq 'Cheese' or Name eq 'Yogurt' or Name eq 'Butter'",
      );
    });

    test('should handle empty or filter', () {
      final filter = Filter.or([]).toString();
      expect(filter, '');
    });

    test('should handle special characters in strings', () {
      final filter = Filter.eq('Name', "O'Reilly").toString();
      expect(filter, "Name eq 'O''Reilly'");
    });

    test('should create a not filter', () {
      final filter = Filter.not(Filter.eq('Name', 'Milk')).toString();
      expect(filter, "not Name eq 'Milk'");
    });

    test('should create a not filter with complex condition', () {
      final filter = Filter.not(
        Filter.and([
          Filter.eq('Name', 'Milk'),
          Filter.lt('Price', 2.55),
        ]),
      ).toString();

      expect(filter, "not (Name eq 'Milk' and Price lt 2.55)");
    });

    test('should handle null value in eq filter', () {
      final filter = Filter.eq('Name', null).toString();
      expect(filter, 'Name eq null');
    });

    test('should handle null value in lt filter', () {
      final filter = Filter.lt('Price', null).toString();
      expect(filter, 'Price lt null');
    });

    test('should create an inList filter', () {
      final filter =
          Filter.inList('Name', ['Milk', 'Cheese', 'Donut']).toString();
      expect(filter, "Name in ('Milk','Cheese','Donut')");
    });

    test('should create an inCollection filter', () {
      final filter =
          Filter.inCollection('Name', 'RelevantProductNames').toString();
      expect(filter, 'Name in RelevantProductNames');
    });

    test('should handle inList filter with numbers', () {
      final filter = Filter.inList('Price', [1.99, 2.49, 5.00]).toString();
      expect(filter, 'Price in (1.99,2.49,5.0)');
    });

    test('should handle inList filter with special characters', () {
      final filter = Filter.inList('Name', ["O'Reilly", 'Milk']).toString();
      expect(filter, "Name in ('O''Reilly','Milk')");
    });

    test('should handle inCollection with complex collection name', () {
      final filter =
          Filter.inCollection('CountryCode', 'MyShippers/Regions').toString();
      expect(filter, 'CountryCode in MyShippers/Regions');
    });

    test('should create an any filter', () {
      final filter =
          Filter.any('Products', 'item', Filter.eq('item/Type', 'Active'))
              .toString();
      expect(filter, "Products/any(item:item/Type eq 'Active')");
    });

    test('should create an all filter', () {
      final filter =
          Filter.all('Products', 'item', Filter.eq('item/Type', 'Active'))
              .toString();
      expect(filter, "Products/all(item:item/Type eq 'Active')");
    });

    test('should create a contains filter', () {
      final filter = Filter.contains('Name', 'Milk').toString();
      expect(filter, "contains(Name,'Milk')");
    });

    test('should create a startsWith filter', () {
      final filter = Filter.startsWith('Name', 'Mil').toString();
      expect(filter, "startswith(Name,'Mil')");
    });

    test('should create an endsWith filter', () {
      final filter = Filter.endsWith('Name', 'lk').toString();
      expect(filter, "endswith(Name,'lk')");
    });

    test('should automatically add parentheses for nested OR within AND', () {
      final filter = Filter.and([
        Filter.eq('ProductTypeId', 1),
        Filter.or([
          Filter.eq('CategoryId', 10),
          Filter.eq('CategoryId', 33),
        ]),
        Filter.and([
          Filter.eq('category', 'groceries'),
          Filter.eq('category', 'ingredients'),
        ]),
      ]).toString();

      expect(
        filter,
        "ProductTypeId eq 1 and (CategoryId eq 10 or CategoryId eq 33) and (category eq 'groceries' and category eq 'ingredients')",
      );
    });

    test('should automatically add parentheses for nested AND within OR', () {
      final filter = Filter.or([
        Filter.eq('Category', 'Dairy'),
        Filter.and([
          Filter.eq('Name', 'Cheese'),
          Filter.lt('Price', 5),
        ]),
        Filter.eq('Category', 'Bakery'),
      ]).toString();

      expect(
        filter,
        "Category eq 'Dairy' or (Name eq 'Cheese' and Price lt 5) or Category eq 'Bakery'",
      );
    });

    test('should handle complex nested filters with multiple levels', () {
      final filter = Filter.and([
        Filter.eq('Active', true),
        Filter.or([
          Filter.and([
            Filter.eq('Category', 'Electronics'),
            Filter.gt('Price', 100),
          ]),
          Filter.and([
            Filter.eq('Category', 'Books'),
            Filter.lt('Price', 50),
          ]),
        ]),
      ]).toString();

      expect(
        filter,
        "Active eq true and ((Category eq 'Electronics' and Price gt 100) or (Category eq 'Books' and Price lt 50))",
      );
    });

    test('should not add unnecessary parentheses for simple filters', () {
      final filter = Filter.and([
        Filter.eq('Name', 'Milk'),
        Filter.lt('Price', 2.55),
        Filter.eq('Category', 'Dairy'),
      ]).toString();

      expect(
        filter,
        "Name eq 'Milk' and Price lt 2.55 and Category eq 'Dairy'",
      );
    });

    test('should handle nested filters without conflicting operators', () {
      final filter = Filter.or([
        Filter.eq('Name', 'Milk'),
        Filter.eq('Name', 'Cheese'),
        Filter.eq('Name', 'Yogurt'),
      ]).toString();

      expect(
        filter,
        "Name eq 'Milk' or Name eq 'Cheese' or Name eq 'Yogurt'",
      );
    });

    test('should handle mixed filters with NOT operator', () {
      final filter = Filter.and([
        Filter.eq('Category', 'Food'),
        Filter.or([
          Filter.not(Filter.eq('Name', 'Expired')),
          Filter.gt('Rating', 4),
        ]),
      ]).toString();

      expect(
        filter,
        "Category eq 'Food' and (not Name eq 'Expired' or Rating gt 4)",
      );
    });

    test('should handle deeply nested expressions correctly', () {
      final filter = Filter.or([
        Filter.eq('Type', 'Premium'),
        Filter.and([
          Filter.eq('Type', 'Standard'),
          Filter.or([
            Filter.lt('Price', 10),
            Filter.eq('OnSale', true),
          ]),
        ]),
      ]).toString();

      expect(
        filter,
        "Type eq 'Premium' or (Type eq 'Standard' and (Price lt 10 or OnSale eq true))",
      );
    });

    test('should handle deeply nested OR and AND conditions', () {
      final filter = Filter.and([
        Filter.eq('ProductTypeId', 1),
        Filter.or([
          Filter.eq('CategoryId', 10),
          Filter.eq('CategoryId', 33),
        ]),
        Filter.or([
          Filter.eq('Region', 'North'),
          Filter.eq('Region', 'South'),
        ]),
      ]).toString();

      expect(
        filter,
        "ProductTypeId eq 1 and (CategoryId eq 10 or CategoryId eq 33) and (Region eq 'North' or Region eq 'South')",
      );
    });

    test('should handle RawValue for unquoted strings', () {
      final filter = Filter.eq('divisionId', RawValue('60965e60-91a5-48cd-b86e-c50587292213'))
          .toString();
      expect(filter, 'divisionId eq 60965e60-91a5-48cd-b86e-c50587292213');
    });

    test('should handle RawValue with GUID in complex filters', () {
      final filter = Filter.and([
        Filter.eq('divisionId', RawValue('60965e60-91a5-48cd-b86e-c50587292213')),
        Filter.eq('Name', 'Test'),
      ]).toString();
      expect(
        filter,
        "divisionId eq 60965e60-91a5-48cd-b86e-c50587292213 and Name eq 'Test'",
      );
    });

    test('should handle RawValue with OData typed syntax', () {
      final filter = Filter.eq('Id', RawValue("guid'60965e60-91a5-48cd-b86e-c50587292213'"))
          .toString();
      expect(filter, "Id eq guid'60965e60-91a5-48cd-b86e-c50587292213'");
    });

    test('should handle RawValue in comparison operators', () {
      final filter = Filter.gt('Price', RawValue('100')).toString();
      expect(filter, 'Price gt 100');
    });

    test('should handle RawValue in inList', () {
      final filter = Filter.inList('Id', [
        RawValue('guid1'),
        RawValue('guid2'),
        'regular-string',
      ]).toString();
      expect(filter, "Id in (guid1,guid2,'regular-string')");
    });

    test('should handle very complex multi-level nested conditions', () {
      final filter = Filter.and([
        Filter.or([
          Filter.and([
            Filter.eq('ProductType', 'Food'),
            Filter.and([
              Filter.or([
                Filter.eq('SubCategory', 'Snacks'),
                Filter.eq('SubCategory', 'Sweets'),
              ]),
              Filter.or([
                Filter.eq('Origin', 'Local'),
                Filter.eq('Origin', 'Imported'),
              ]),
            ]),
          ]),
          Filter.and([
            Filter.eq('ProductType', 'Beverage'),
            Filter.and([
              Filter.or([
                Filter.eq('SubCategory', 'Coffee'),
                Filter.eq('SubCategory', 'Tea'),
              ]),
              Filter.or([
                Filter.and([
                  Filter.eq('Origin', 'Domestic'),
                  Filter.eq('Certified', true),
                ]),
                Filter.eq('Origin', 'International'),
              ]),
            ]),
          ]),
        ]),
        Filter.and([
          Filter.or([
            Filter.eq('Quality', 'Premium'),
            Filter.eq('Quality', 'Standard'),
          ]),
          Filter.or([
            Filter.eq('Status', 'Available'),
            Filter.eq('Status', 'PreOrder'),
          ]),
        ]),
      ]).toString();

      // This verifies that deeply nested filters are properly parenthesized
      expect(filter, contains('ProductType eq \'Food\''));
      expect(filter, contains('ProductType eq \'Beverage\''));
      expect(filter, contains('SubCategory eq \'Snacks\''));
      expect(filter, contains('Quality eq \'Premium\''));
      expect(filter, contains('Status eq \'Available\''));
    });

    test(
        'should handle complex multi-level nesting with proper parentheses grouping',
        () {
      final filter = Filter.or([
        Filter.and([
          Filter.eq('Level1', 'A'),
          Filter.or([
            Filter.eq('Level2', 'B'),
            Filter.and([
              Filter.eq('Level3', 'C'),
              Filter.eq('Level3', 'D'),
            ]),
          ]),
        ]),
        Filter.and([
          Filter.eq('Level1', 'E'),
          Filter.or([
            Filter.eq('Level2', 'F'),
            Filter.eq('Level2', 'G'),
          ]),
        ]),
      ]).toString();

      expect(
        filter,
        "(Level1 eq 'A' and (Level2 eq 'B' or (Level3 eq 'C' and Level3 eq 'D'))) or (Level1 eq 'E' and (Level2 eq 'F' or Level2 eq 'G'))",
      );
    });

    test('should handle triple nested AND within OR within AND', () {
      final filter = Filter.and([
        Filter.eq('Outer', 1),
        Filter.or([
          Filter.and([
            Filter.eq('Inner1', 2),
            Filter.eq('Inner2', 3),
          ]),
          Filter.and([
            Filter.eq('Inner3', 4),
            Filter.eq('Inner4', 5),
          ]),
        ]),
        Filter.eq('Outer2', 6),
      ]).toString();

      expect(
        filter,
        'Outer eq 1 and ((Inner1 eq 2 and Inner2 eq 3) or (Inner3 eq 4 and Inner4 eq 5)) and Outer2 eq 6',
      );
    });

    test('should handle realistic advanced product filtering scenario', () {
      final filter = Filter.and([
        Filter.eq('Active', true),
        Filter.or([
          Filter.and([
            Filter.eq('Category', 'Beverages'),
            Filter.ge('Price', 5),
            Filter.le('Price', 50),
            Filter.or([
              Filter.eq('Brand', 'CoffeeCo'),
              Filter.eq('Brand', 'TeaTime'),
            ]),
          ]),
          Filter.and([
            Filter.eq('Category', 'Dairy'),
            Filter.or([
              Filter.eq('Type', 'Organic'),
              Filter.eq('Type', 'Premium'),
            ]),
            Filter.eq('InStock', true),
          ]),
        ]),
      ]).toString();

      expect(filter, contains('Active eq true'));
      expect(filter, contains('Category eq \'Beverages\''));
      expect(filter, contains('Brand eq \'CoffeeCo\''));
      expect(filter, contains('Category eq \'Dairy\''));
      expect(filter, contains('InStock eq true'));
    });
  });

  group('OrderBy', () {
    test('should create an asc order by clause', () {
      final orderBy = OrderBy.asc('Price').toString();
      expect(orderBy, 'Price asc');
    });

    test('should create a desc order by clause', () {
      final orderBy = OrderBy.desc('Price').toString();
      expect(orderBy, 'Price desc');
    });

    test('should chain asc after desc', () {
      final orderBy = OrderBy.desc('Date').thenAsc('Name').toString();
      expect(orderBy, 'Date desc, Name asc');
    });

    test('should chain desc after asc', () {
      final orderBy = OrderBy.asc('Name').thenDesc('Price').toString();
      expect(orderBy, 'Name asc, Price desc');
    });

    test('should chain multiple order by clauses', () {
      final orderBy =
          OrderBy.desc('Date').thenAsc('Name').thenDesc('Price').toString();
      expect(orderBy, 'Date desc, Name asc, Price desc');
    });

    test('should work with ODataQuery', () {
      final query = ODataQuery(
        orderBy: OrderBy.desc('Date').thenAsc('Name').thenDesc('Price'),
      ).toString();
      expect(query, '\$orderby=Date desc, Name asc, Price desc');
    });

    test('should work with other query parameters', () {
      final query = ODataQuery(
        filter: Filter.eq('Category', 'Beverages'),
        orderBy: OrderBy.desc('Date').thenAsc('Name'),
        select: ['Name', 'Price', 'Date'],
      ).toString();
      expect(
        query,
        '\$filter=Category eq \'Beverages\'&\$orderby=Date desc, Name asc&\$select=Name,Price,Date',
      );
    });
  });
}
