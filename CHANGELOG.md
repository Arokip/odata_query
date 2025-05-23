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
