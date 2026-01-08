# OData Query Builder

[![pub package](https://img.shields.io/pub/v/odata_query.svg)](https://pub.dev/packages/odata_query)

**OData Query Builder** is a Dart package designed for building OData query strings for REST API endpoints. It provides a clean, declarative API to construct complex queries efficiently.

---

## 🚀 Features

✅ **Build OData Queries**: Supports `$filter`, `$orderby`, `$select`, `$expand`, `$top`, `$skip`, and `$count`.  
✅ **Programmatic Filter Construction**: Build OData filters with logical operators like `eq`, `lt`, `gt`, `and`, `or`, `not`, etc.  
✅ **URL Encoding**: Automatically encodes query parameters for safe use in URLs with `toEncodedString()`.  
✅ **Map Conversion**: Convert query parameters into a `Map<String, String>` format for flexible API integration.  
✅ **Chained OrderBy**: Chain multiple sort orders with a fluent API.  

📚 **For detailed OData query options, see:**  
[OData Query Options Overview](https://learn.microsoft.com/en-us/odata/concepts/queryoptions-overview)

---

## 📌 Examples

### **🔹 Example 1: Basic Filtering, Sorting, Selecting, Expanding, using `.toEncodedString()`**
```dart
ODataQuery(
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

// $filter=Name%20eq%20'Milk'%20and%20Price%20lt%202.55%20and%20Category%20eq%20'Dairy'%20and%20ShouldShowHidden%20eq%20true&$orderby=Price%20desc&$select=Name%2CPrice&$expand=Category&$top=10&$count=true
```

---

### **🔹 Example 2: Filtering with Logical Operators, using `.toMap()`**
```dart
ODataQuery(
  filter: Filter.and([
    Filter.or([
      Filter.eq('Category', 'Beverages'),
      Filter.eq('Category', 'Snacks'),
    ]),
    Filter.gt('Price', 5),
  ]),
  select: ['Name', 'Price', 'Category'],
  expand: ['Supplier', 'Category'],
).toMap();

// {
//   '$filter': "(Category eq 'Beverages' or Category eq 'Snacks') and Price gt 5",
//   '$select': 'Name,Price,Category',
//   '$expand': 'Supplier,Category',
// }
```

---

### **🔹 Example 2.1: Automatic Parentheses for Complex Nested Filters**

The package automatically adds parentheses around nested expressions to ensure proper OData operator precedence and avoid logic errors:

```dart
ODataQuery(
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

// $filter=ProductTypeId eq 1 and (CategoryId eq 10 or CategoryId eq 33) and (category eq 'groceries' and category eq 'ingredients')
```

**Why this matters:** According to the OData specification, parentheses are required to override the default precedence of logical operators (AND binds tighter than OR). Without parentheses, filters with mixed AND/OR may not return expected results from an OData service.

```dart
// Complex OR with nested AND expressions
ODataQuery(
  filter: Filter.or([
    Filter.eq('Category', 'Premium'),
    Filter.and([
      Filter.eq('Category', 'Standard'),
      Filter.lt('Price', 50),
      Filter.gt('Rating', 4),
    ]),
    Filter.eq('OnSale', true),
  ]),
);

// $filter=Category eq 'Premium' or (Category eq 'Standard' and Price lt 50 and Rating gt 4) or OnSale eq true
```

---

### **🔹 Example 2.2: Real-World Complex Nested Queries**

The package handles arbitrarily deep nesting with automatic parenthesization:

```dart
// Product filtering with multiple conditions
ODataQuery(
  filter: Filter.and([
    Filter.eq('ProductTypeId', 1),
    Filter.or([
      Filter.eq('CategoryId', 10),
      Filter.eq('CategoryId', 33),
    ]),
    Filter.or([
      Filter.eq('Region', 'North'),
      Filter.eq('Region', 'South'),
    ]),
  ]),
).toString();

// Result:
// $filter=ProductTypeId eq 1 and (CategoryId eq 10 or CategoryId eq 33) and (Region eq 'North' or Region eq 'South')
```

**Complex multi-level nesting:**

```dart
// Advanced product filtering
ODataQuery(
  filter: Filter.and([
    Filter.eq('Active', true),
    Filter.or([
      // Beverages with specific conditions
      Filter.and([
        Filter.eq('Category', 'Beverages'),
        Filter.ge('Price', 5),
        Filter.le('Price', 50),
        Filter.or([
          Filter.eq('Brand', 'CoffeeCo'),
          Filter.eq('Brand', 'TeaTime'),
        ]),
      ]),
      // Dairy with different conditions
      Filter.and([
        Filter.eq('Category', 'Dairy'),
        Filter.or([
          Filter.eq('Type', 'Organic'),
          Filter.eq('Type', 'Premium'),
        ]),
        Filter.eq('InStock', true),
      ]),
    ]),
  ]),
);

// The package automatically generates properly parenthesized OData filter expressions
// that correctly represent your business logic
```

**Key Benefits:**
- ✅ No manual parentheses management needed
- ✅ Guaranteed correct OData operator precedence
- ✅ Clean, readable Dart code that matches your business logic
- ✅ Prevents logic errors from incorrect grouping
- ✅ Works with arbitrarily deep nesting levels

---

### **🔹 Example 3: Nested Query, using `.toString()`**
```dart
ODataQuery(
  select: ['Name', 'Price'],
  expand: [
    'Category(${ODataQuery(
      select: ['Type'],
    )};${ODataQuery(
      orderBy: OrderBy.asc('DateCreated'),
    )})',
  ],
).toString();

// $select=Name,Price&$expand=Category($select=Type;$orderby=DateCreated asc)
```

---

### **🔹 Example 4: Using `inList` for Multiple Values**
```dart
ODataQuery(
  filter: Filter.inList('Name', ['Milk', 'Cheese', 'Donut']),
  select: ['Name', 'Price'],
)
```

---

### **🔹 Example 5: Using `inCollection` for Collection Reference**
```dart
ODataQuery(
  filter: Filter.inCollection('Name', 'RelevantProductNames'),
  select: ['Name', 'Price'],
)
```

---

### **🔹 Example 6: `any` Filter**
```dart
ODataQuery(
  filter: Filter.any('Products', 'item', Filter.eq('item/Type', 'Active')),
)
```

---

### **🔹 Example 7: `all` Filter**
```dart
ODataQuery(
  filter: Filter.all('Products', 'item', Filter.eq('item/Type', 'Active')),
)
```

---

### **🔹 Example 8: Using `startsWith`, `endsWith`, `contains`, and `not`**
```dart
ODataQuery(
  filter: Filter.or([
    Filter.and([
      Filter.startsWith('Name', 'Choco'),
      Filter.endsWith('Name', 'Bar'),
    ]),
    Filter.not(
      Filter.contains('Name', 'Sugar'),
    ),
  ]),
)
```

---

### **🔹 Example 9: Chained OrderBy for Multiple Sort Fields**
```dart
ODataQuery(
  filter: Filter.eq('Category', 'Beverages'),
  orderBy: OrderBy.desc('Date').thenAsc('Name').thenDesc('Price'),
  select: ['Name', 'Price', 'Date'],
).toString();

// $filter=Category eq 'Beverages'&$orderby=Date desc, Name asc, Price desc&$select=Name,Price,Date
```

---

### **🔹 Example 10: Using `RawValue` for Unquoted Strings (GUIDs, Identifiers)**

Some OData backends expect GUIDs or identifiers without quotes. The `RawValue` class allows you to pass unquoted string values:

```dart
// Using RawValue for a GUID (unquoted)
ODataQuery(
  filter: Filter.eq('divisionId', RawValue('60965e60-91a5-48cd-b86e-c50587292213')),
  select: ['Name', 'Price'],
).toString();

// $filter=divisionId eq 60965e60-91a5-48cd-b86e-c50587292213&$select=Name,Price
```

**With OData typed syntax:**
```dart
// Some OData implementations require the guid'...' syntax
ODataQuery(
  filter: Filter.eq('Id', RawValue("guid'60965e60-91a5-48cd-b86e-c50587292213'")),
).toString();

// $filter=Id eq guid'60965e60-91a5-48cd-b86e-c50587292213'
```

**Mixing RawValue with regular strings:**
```dart
ODataQuery(
  filter: Filter.and([
    Filter.eq('divisionId', RawValue('60965e60-91a5-48cd-b86e-c50587292213')),
    Filter.eq('Name', 'Test Product'),
    Filter.gt('Price', RawValue('100')),
  ]),
).toString();

// $filter=divisionId eq 60965e60-91a5-48cd-b86e-c50587292213 and Name eq 'Test Product' and Price gt 100
```

**Why use RawValue?**
- Some OData backends (especially OData V3 or specific V4 configurations) expect GUIDs without quotes
- Allows you to use OData typed syntax like `guid'...'` or other custom formats
- Useful for identifiers, numeric strings, or any value that should not be quoted

---

## 📚 API Overview

### **ODataQuery Parameters**
| Parameter | Description                                                  |
| --------- | ------------------------------------------------------------ |
| `search`  | Free-text search across multiple fields.                     |
| `filter`  | Apply filters using conditions like `eq`, `lt`, `gt`, `not`. |
| `orderBy` | Sort results by ascending (`asc`) or descending (`desc`).    |
| `select`  | Choose specific fields to return.                            |
| `expand`  | Include related entities in the response.                    |
| `top`     | Limit the number of records returned.                        |
| `skip`    | Skip a specified number of records (for pagination).         |
| `count`   | Include total count of matching records.                     |

### **Filter Operators**
| Operator       | Description                                                            |
| -------------- | ---------------------------------------------------------------------- |
| `eq`           | Equals (`Name eq 'Milk'`)                                              |
| `ne`           | Not equals                                                             |
| `lt` / `gt`    | Less than / Greater than                                               |
| `le` / `ge`    | Less than or equal / Greater than or equal                             |
| `and` / `or`   | Combine filters                                                        |
| `inList`       | Check if a value is in a list                                          |
| `inCollection` | Check if a value exists in a collection                                |
| `any` / `all`  | Apply filters on collections                                           |
| `not`          | Negate a condition (`not(contains(Name, 'Sugar'))`)                    |
| `contains`     | Check if a value contains a substring (`contains(Name, 'Choco')`)      |
| `startsWith`   | Check if a value starts with a substring (`startswith(Name, 'Choco')`) |
| `endsWith`     | Check if a value ends with a substring (`endswith(Name, 'Bar')`)       |
| `RawValue`     | Pass unquoted string values (useful for GUIDs, identifiers)             |

---

## ⭐ Support the Package

If you find this package useful and want to help other developers discover it, please consider giving it a like on [pub.dev](https://pub.dev/packages/odata_query). Your support helps build trust in the package and makes it easier for other developers to find reliable solutions.

---

## 🤝 Contributing
Contributions are welcome! Feel free to submit issues or pull requests.
