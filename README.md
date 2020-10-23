## Meet gm-stream!
**gm-stream** provides a series of fluent APIs that can aid in performing powerful logic on data structures. gm-stream is heavily based on the concept of [Streams](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html) from the Java programming language, although it has been adapted to suit GameMaker Language.

Use of **gm-stream** requires GameMaker 2.3 or higher, as it makes use of many of that release's new language functions.

## Get gm-stream
### Manual Package Installation
You can download the latest release of **gm-stream** from the GitHub Releases page, or from our itch.io page.

Once you have downloaded the the package, in GameMaker Studio click on the **Tools** menu and select **Import Local Package**. Choose the `.yymps` file you downloaded, and import all assets.

### GameMaker Marketplace
**gm-stream** can be downloaded directly from the GameMaker Marketplace. Simply visit the Marketplace page and click the **Add to Account** button.

## Using gm-stream
#### stream_of(dataStructure)
Before you can use **gm-stream**'s APIs you must create a `GmStream` from an existing data structure. Do this by calling the `stream_of` global function:
```
var myArray = [1, 2, 3, 4, 5];
var stream = stream_of(myArray);
```
This function takes any `ds_list` or `array`, and returns a `GmStream` object which all the other APIs can be called on.
Note, most of the code examples below will use arrays because it's more compact, but they will all work with any supported data structure.

### Intermediate Operations
Each of these intermediate operations does something to the `GmStream` and returns that same stream. You can therefore chain together one or more intermediate operations before finally calling a terminal operation to get out your result.

#### .distinct()
Removes all duplicate items from the `GmStream`.
```
var myArray = [1, 2, 2, 3];
var result = stream_of(myArray)
              .distinct()
              .collectAsArray();
```
In this example, the resulting array will contain `[1, 2, 3]`, the duplicate 2 having been removed.

#### .filter(predicateFunction)
Removes all items which do not match a given predicate function.
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

### Terminal Operations
Each of these terminal operations cleans up the internal data structures used by the `GmStream` and returns a result as described by the function. You will typically call one of these functions as the final step of your chain of operations, as calling it renders the `GmStream` object unusable. Once a terminal operation is called, if there are no remaining references to the `GmStream` object it will eventually be cleaned up by the garbage collector.

#### .allMatch(predicateFunction)
Returns true if every item in the stream matches the given predicate, and false if even one item does not match it.
```
var myArray = [1, 1, 1];
var predicate = function(item) {
  return item == 1;
}
var result = stream_of(myArray)
              .allMatch(predicate);
```
In this example, `result` will be true, because all items in the stream match the predicate `item == 1`. If the initial array was instead `[1, 2, 1]`, the result would be false, as one item does not match the predicate.
