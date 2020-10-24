# API Guide

A full guide, with examples, of each of the available APIs on a `GmStream` instance.<br>Remember, to get a `GmStream` instance, call `stream_of(dataStructure)` as described in the [main README page](README.md).

All of the provided examples below use an array as the initial data structure, just for simplicity, but will work with any type of supported data structure as the argument to `stream_of(dataStructure)`.

## Intermediate Operations
Intermediate operations modify the data in some way and return the same `GmStream` instance. You can therefore chain together one or more intermediate operations before finally calling a terminal operation to get out your result.

#### .distinct()
Removes all duplicate items from the stream

**Example**
```
var myArray = [1, 2, 2, 3];
var result = stream_of(myArray)
              .distinct()
              .collectAsArray();
```
In this example, the resulting array will contain `[1, 2, 3]`, the duplicate 2 having been removed.

#### .filter(predicateFunction)
Removes items from the stream which match the provided predicate function

**Example**
```
var myArray = ["a", "b", "test", "ab"];
var predicate = function(item) {
  return string_length(item) <= 3;
}
var result = stream_of(myArray)
              .filter(predicate)
              .collectAsArray();
```
In this example, the resulting array will contain `["a", "b", "ab"]`, as the string `test` fails the predicate by having more than 3 characters.

#### .map(mapFunction)
Applies the provied map function to each item in the stream

**Example**
```
var myArray = [1, 2, 3];
var mapFunction = function(item) {
    return item * 2;
}
var result = stream_of(myArray)
              .map(mapFunction)
              .collectAsArray();
```
In this example, the resulting array will contain `[2, 4, 6]`, as the mapping function multiplied each element by 2.

#### .sort([comparatorFunction])
Sorts the items in the stream according to the provided comparator function (optional).

If no comparator function is provided it will perform a `ds_list_sort` in the ascending direction on the data.
This is appropriate for sorting a stream of Strings alphabetically or a stream of numbers numerically, but for more complex
cases, providing a comparator yourself is recommended.

If a comparator function is provided, the items are sorted via a `mergesort` algorithm, using the comparator to determine the order. Comparator functions must take two arguments, and return a negative number if the first argument is lesser or equal to  the second, or a positive number if the first argument is greater than the second.

**Example (no comparator)**
```
var myArray = ["C", "A", "B"];
var result = stream_of(myArray)
                .sort()
                .collectAsArray();
```
In this example the resulting array will contain `["A", "B", "C"]`. As mentioned above, using `.sort()` this way with no comparator works fine for intial data structures containing only Strings or numeric values, as they have an implied natural sort order. To sort more complicated objects see the following example:

**Example (with comparator)**
```
var myArray = [{name: "Jim", age: 26}, {name: "Abi", age: 22}, {name: "Flora", age: 29}];
var nameComparator = function(o1, o2) {
    return (o1.name <= o2.name) ? -1 : 1;
}
var ageComparator = function(o1, o2) {
    return (o1.age <= o2.age) ? -1 : 1;
}

var sortedByName = stream_of(myArray)
                    .sort(nameComparator)
                    .map(function(item) { return item.name })
                    .collectAsArray();
var sortedByAge = stream_of(myArray)
                    .sort(ageComparator)
                    .map(function(item) { return item.name })
                    .collectAsArray();
```
In this example we are applying the sort twice, with a different comparator each time. In both cases we are using a `.map()` call afterwards to pluck out the name.

The first comparator function returns a -1 if the left item's name is lesser or equal to the right item's (alphabetically), and a 1 if it's not. This lets you sort the data alphabetically by the name field, so the resulting array `sortedByName` will look like `["Abi", "Flora", "Jim"]`.

The second comparator function does much the same, but looking at the item's `age` field instead of `name`. As a result the array `sortedByAge` will look like `["Abi", "Jim", "Flora"]`.

## Terminal Operations
Terminal operations clean up the internal data structures used by the `GmStream` and return a result as described by the function. You will typically call one of these functions as the final step of your chain of operations, as calling it renders the `GmStream` object unusable.

Once a terminal operation is called, if there are no remaining references to the `GmStream` object it will eventually be cleaned up by the garbage collector. Your original data structure that you pass into `stream_of` will never be destroyed by `GmStream`, its data is always non-destructively copied to create the `GmStream` instance.

#### .allMatch(predicateFunction)
Returns true if every item in the stream matches the provided predicate function, false if one or more items does not match.

**Example**
```
var myArray = [1, 1, 1];
var predicate = function(item) {
  return item == 1;
}
var result = stream_of(myArray)
              .allMatch(predicate);
```
In this example, `result` will be true, because all items in the stream match the predicate `item == 1`. If the initial array was instead `[1, 2, 1]`, the result would be false, as one item does not match the predicate.

#### .anyMatch(predicateFunction)
Returns true if one or more items in the stream match the provided predicate function, false if every item does not match it.

**Example**
```
var myArray = [1, 2, 3];
var predicate = function(item) {
    return item == 2;
}
var result = stream_of(myArray)
                .anyMatch(predicate);
```
In this example, `result` will be true, as the stream contains a `2` and thus the predicate `item == 2` matches for at least one item. If the initial array was `[1, 3]` then the result would be false as no items match the predicate.

#### .collectAsArray()
Returns an array containing the items of the stream in their current order

**Example**
```
var myArray = [1, 2, 3];
var result = stream_of(myArray)
                .filter(function(item) { return item != 2 })
                .collectAsArray();
```
Collecting is one of the most common terminal operations for a stream. After you have performed some intermediate functions on your initial data, it's useful to be able to get the remaining data back in the form of a data structure again. In this example we have filtered out the number 2 from the initial array, so the array we return from `collectAsArray()` will contain `[1, 3]`.

You don't need to perform any intermediate operations of course, in the example below for `collectAsList` you'll see the utility of simply using streams to change a dataset from one type of structure to another in very few lines of code.

#### .collectAsList()
Returns a `ds_list` containing the items of the stream in their current order

**Example**
```
var myArray = [1, 2, 3];
var result = stream_of(myArray)
                .collectAsList();
```
This example will create in result a `ds_list` whose items are the same as those of the initial array that was passed in. Note that this resulting data structure is your responsibility to free later, to prevent memory leaks, just as if you had called `ds_list_create` yourself. e.g. `ds_list_destroy(result)`;

#### .collectJoining([delimiter], [prefix], [suffix])
Returns a string consisting of the items of the stream (passed through GameMaker's `string` function) concatenated.

Optional parameters `delimiter`, `prefix`, and `suffix` allow for the items to be separated by the given delimiter, and the entire string to be prefixed and suffixed by the given prefix and suffix.

**Example**
```
var initialArray = ["a", "b", "c"];
var joinedSimple = stream_of(initialArray)
                    .collectJoining();
var joinedDelimited = stream_of(initialArray)
                    .collectJoining(",");
var joinedTheWorks = stream_of(initialArray)
                    .collectJoining(",", "<", ">");
```
This example shows the various ways to use `collectJoining`. The resulting string in `joinedSimple` will be `"abc"`, simply the elements of the initial array concatenated together. `joinedDelimited` will look like `"a,b,c"`, as we passed the comma string as our delimiter. `joinedTheWorks` will look like `"<a,b,c>"`, as we've passed in the angle bracket characters as a prefix and suffix.

#### .count()
Returns the number of items in the stream

**Example**
```
var initialArray = ["a", "b", "c"];
var count = stream_of(initialArray)
            .count();
```
In this example `count` will be 3, as that is the number of items in the initial array. If we had performed intermediate operations such as `filter` or `distinct` that can remove items from the dataset, this terminal operation can be useful to tell how many items are remaining.

#### .findFirst()
Returns the first item encountered in the stream, or `noone` if the stream is empty

**Example**
```
var initialArray = ["b", "a", "c"];
var result = stream_of(initialArray)
                .sort()
                .findFirst();
```
In this example, `result` will contain `"a"`. We used a `sort` operation which would put the strings in their natural ascending order, at which point `"a"` would be the first item found in the stream.

#### .forEach(forEachFunction)
Executes the provided function across each item in the stream.

**Example**
```
var initialArray = ["a", "b", "c"];
stream_of(initialArray)
    .forEach(function (item) {
        show_debug_message(item);
    });
```
In this example, our `forEachFunction` runs `show_debug_message` on the provided item. So the result of running this example would be to see
```
a
b
c
```
printed in your GameMaker console output.

#### .noneMatch(predicateFunction)
Returns true if no items in the stream match the provided predicate function, false if one or more items do match it.

**Example**
```
var myArray = [1, 2, 3];
var predicate = function(item) {
    return item == 4;
}
var result = stream_of(myArray)
                .noneMatch(predicate);
```
In this example, `result` will be true, as the stream does not contain a `4`, and `noneMatch` returns true if every item in the stream fails the predicate function. If our initial array was `[1, 2, 3, 4]` then this example would return false, as one of the items in our stream passes the predicate function.
