# OData Query Builder

[![pub package](https://img.shields.io/pub/v/odata_query.svg)](https://pub.dev/packages/odata_query)

**OData Query Builder** is a Dart package designed for building OData query strings for REST API endpoints. It provides a clean, declarative API to construct complex queries efficiently.

---

## 🚀 Features

✔ **Build OData Queries**: Supports `$filter`, `$orderby`, `$select`, `$expand`, `$top`, `$skip`, and `$count`.  
✔ **Programmatic Filter Construction**: Build OData filters with logical operators like `eq`, `lt`, `gt`, `and`, `or`, `not`, etc.  
✔ **URL Encoding**: Automatically encodes query parameters for safe use in URLs with `toEncodedString()`.  
✔ **Map Conversion**: Convert query parameters into a `Map<String, String>` format for flexible API integration.  

📚 **For detailed OData query options, see:**  
[OData Query Options Overview](https://learn.microsoft.com/en-us/odata/concepts/queryoptions-overview)

---

## 📌 Examples

### **🔹 Example 1: Basic Filtering, Sorting, Selecting, Expanding, using `.toEncodedString()`**
```dart
final queryString = ODataQuery(
  filter: Filter.and(
    Filter.eq('Name', 'Milk'),
    Filter.lt('Price', 2.55),
  ),
  orderBy: OrderBy.desc('Price'),
  select: ['Name', 'Price'],
  expand: ['Category'],
  top: 10,
  count: true,
).toEncodedString();

// $filter=Name%20eq%20'Milk'%20and%20Price%20lt%202.55&$orderby=Price%20desc&$select=Name%2CPrice&$expand=Category&$top=10&$count=true
```

---

### **🔹 Example 2: Filtering with Logical Operators, using `.toMap()`**
```dart
ODataQuery(
  filter: Filter.and(
    Filter.or(
      Filter.eq('Category', 'Beverages'),
      Filter.eq('Category', 'Snacks'),
    ),
    Filter.gt('Price', 5),
  ),
  select: ['Name', 'Price', 'Category'],
  expand: ['Supplier', 'Category'],
).toMap();

// {
//   '$filter': "Category eq 'Beverages' or Category eq 'Snacks' and Price gt 5",
//   '$select': 'Name,Price,Category',
//   '$expand': 'Supplier,Category',
// }
```

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
final queryInList = ODataQuery(
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
  filter: Filter.or(
    Filter.and(
      Filter.startsWith('Name', 'Choco'),
      Filter.endsWith('Name', 'Bar'),
    ),
    Filter.not(
      Filter.contains('Name', 'Sugar'),
    ),
  ),
)
```

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

---

## 🤝 Contributing
Contributions are welcome! Feel free to submit issues or pull requests.
