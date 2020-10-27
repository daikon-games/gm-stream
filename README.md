## Meet gm-stream!
![Header](images/header-wide.png)
**gm-stream** provides a series of fluent APIs that can aid in performing powerful logic on data structures. gm-stream is heavily based on the concept of [Streams](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html) from the Java programming language, although it has been adapted to suit GameMaker Language.

Use of **gm-stream** requires GameMaker 2.3 or higher, as it makes use of many of that release's new language functions.

## Get gm-stream
### Manual Package Installation
You can download the latest release of **gm-stream** from the [GitHub Releases page](https://github.com/daikon-games/gm-stream/releases), or from our [itch.io page](https://nickavv.itch.io/gm-stream).

Once you have downloaded the the package, in GameMaker Studio click on the **Tools** menu and select **Import Local Package**. Choose the `.yymps` file you downloaded, and import all assets.

### GameMaker Marketplace
**gm-stream** can be downloaded directly from the GameMaker Marketplace. Simply visit the [Marketplace page](https://marketplace.yoyogames.com/assets/9500/gm-stream) and click the **Add to Account** button.

## Using gm-stream
### stream_of(dataStructure)
Before you can use **gm-stream**'s APIs you must create a `GmStream` from an existing data structure. Do this by calling the `stream_of` global function:
```
var myArray = [1, 2, 3, 4, 5];
var stream = stream_of(myArray);
```
The types of data structures that `stream_of` can handle are as follows:
* `array`
* `ds_list`
* `ds_queue`
* `ds_stack`

Passing any other type of data structures to `stream_of` will throw an error.

Once you have a `GmStream` instance you can manipulate it in a lot of different ways. **Intermediate Operations** will modify the stream's data in some way, and then return the same stream instance so you can chain calls together. **Terminal Operations** collect the data of the stream into some final result and return that, cleaning up the `GmStream` instance.

A summary of all the available Intermediate and Terminal operations is below, but full descriptions of each with example code can be found in the [API Guide](API.md).

### Intermediate Operations
#### [.distinct()](API.md#distinct)
Removes all duplicate items from the stream

#### [.filter(predicateFunction)](API.md#filterpredicatefunction)
Removes items from the stream which match the provided predicate function

#### [.map(mapFunction)](API.md#mapmapfunction)
Applies the provied map function to each item in the stream

#### [.sort([comparatorFunction])](API.md#sortcomparatorFunction)
Sorts the items in the stream according to the provided comparator function (optional).

If no comparator function is provided it will perform a `ds_list_sort` in the ascending direction on the data.
This is appropriate for sorting a stream of Strings alphabetically or a stream of numbers numerically, but for more complex
cases, providing a comparator yourself is recommended.

### Terminal Operations
#### [.allMatch(predicateFunction)](API.md#allmatchpredicatefunction)
Returns true if every item in the stream matches the provided predicate function, false if one or more items does not match.

#### [.anyMatch(predicateFunction)](API.md#anymatchpredicatefunction)
Returns true if one or more items in the stream match the provided predicate function, false if every item does not match it.

#### [.collectAsArray()](API.md#collectasarray)
Returns an array containing the items of the stream in their current order

#### [.collectAsList()](API.md#collectaslist)
Returns a `ds_list` containing the items of the stream in their current order

#### [.collectJoining([delimiter], [prefix], [suffix])](API.md#collectjoiningdelimiter-prefix-suffix)
Returns a string consisting of the items of the stream (passed through GameMaker's `string` function) concatenated.

Optional parameters `delimiter`, `prefix`, and `suffix` allow for the items to be separated by the given delimiter, and the entire string to be prefixed and suffixed by the given prefix and suffix.

#### [.count()](API.md#count)
Returns the number of items in the stream

#### [.findFirst()](API.md#findFirst)
Returns the first item encountered in the stream, or `noone` if the stream is empty

#### [.fold(initialValue, foldFunction)](API.md#foldinitialvalue-foldfunction)
Starting with the initial value, performs the provided fold function on each item in the stream to
combine them into some final result.

#### [.forEach(forEachFunction)](API.md#foreachforeachfunction)
Executes the provided function across each item in the stream.

#### [.noneMatch(predicateFunction)](API.md#nonematchpredicatefunction)
Returns true if no items in the stream match the provided predicate function, false if one or more items do match it.

#### [.reduce(foldFunction)](API.md#reducefoldfunction)
A variation of `fold` which takes the first item encountered in the stream and uses it as the
initial value for the folding operation.
