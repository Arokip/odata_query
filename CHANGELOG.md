## 2.9.0

* **Added `RawValue` class**: Allows passing unquoted string values to Filter operations. This is essential for GUIDs, identifiers, or other values that should not be wrapped in single quotes in OData queries.
* **Use case**: Some OData backends (especially OData V3 or specific V4 configurations) expect GUIDs without quotes or with typed syntax like `guid'...'`. The `RawValue` class enables this functionality.
* **Example**: `Filter.eq('divisionId', RawValue('60965e60-91a5-48cd-b86e-c50587292213'))` produces `divisionId eq 60965e60-91a5-48cd-b86e-c50587292213` (unquoted).

## 2.8.0

* **Enhanced automatic parentheses handling**: Improved algorithm for `Filter.and` and `Filter.or` to intelligently add parentheses only where needed for compound expressions.
* **Improved NOT filter**: `Filter.not` now correctly wraps compound expressions in parentheses (e.g., `not (A and B)` instead of `not A and B`).


## 2.7.0

* Automatic parentheses for nested filter expressions. `Filter.and` and `Filter.or` now automatically add grouping parentheses around sub-expressions that contain logical operators (AND/OR) to ensure proper OData operator precedence and avoid logic errors.
* This ensures compliance with OData specification requirements for logical operator precedence.
* Complex nested filters now generate correct query strings that return expected results from OData services.

## 2.6.0

* Filters `Filter.and` and `Filter.or` now accepts lists for more flexible queries. If the list is empty, the filter is omitted.
  
## 2.5.0

* Added OrderBy chaining: `thenAsc` and `thenDesc`. 
  
## 2.4.0

* Added `contains` filter.
* Added `startsWith` and `endsWith` filters.
* Added negation `not`.
* Updated readme and example.
  
## 2.3.0

* Added `any` and `all` filters.
* Updated readme and example.

## 2.2.0

* Added `inList` and `inCollection` filters.
* Updated readme and example.

## 2.1.0

* Added `toEncodedString()` and normal `toString()` does not encode the query.
* Fixed typo in `scr` -> `src` folder.
* Example for nested odata queries.

## 2.0.0

* `toString()` and `toMap()` functions instead of `build()`.

## 1.0.0

* Initial release of odata_query package.
