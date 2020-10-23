function TestResult(_testName, _passed, _message) constructor {
	testName = _testName;
	passed = _passed;
	msg = _message;
};

// Define test cases
function testListToStream() {
	var testName = "List to stream";
	
	var initialList = ds_list_create();
	ds_list_add(initialList, "A");
	ds_list_add(initialList, "B");
	ds_list_add(initialList, "C");

	var stream = stream_of(initialList);
	if (is_undefined(stream)) {
		return new TestResult(testName, false, "Returned stream did not exist");
	}
	stream.clean_up();
	
	return new TestResult(testName, true, "");
};
function testArrayToStream() {
	var testName = "Array to stream";
	
	var initialArray = ["A", "B", "C"];

	var stream = stream_of(initialArray);
	if (is_undefined(stream)) {
		return new TestResult(testName, false, "Returned stream did not exist");
	}
	stream.clean_up();
	
	return new TestResult(testName, true, "");
};

function testCollectList() {
	var testName = "Collect to List";
	
	var initialArray = ["A", "B", "C"];

	var result = stream_of(initialArray)
						.collectAsList();
	if (!ds_exists(result, ds_type_list)) {
		return new TestResult(testName, false, "result was not a list");
	}
	if (ds_list_size(result) != 3) {
		return new TestResult(testName, false, "result list size was incorrect");
	}
	
	return new TestResult(testName, true, "");
};

function testCollectArray() {
	var testName = "Collect to Array";
	
	var initialList = ds_list_create();
	ds_list_add(initialList, "A");
	ds_list_add(initialList, "B");
	ds_list_add(initialList, "C");

	var result = stream_of(initialList)
						.collectAsArray();
	if (!is_array(result)) {
		return new TestResult(testName, false, "result was not an array");
	}
	if (!array_length(result)) {
		return new TestResult(testName, false, "result array size was incorrect");
	}
	
	return new TestResult(testName, true, "");
};

function testDistinct() {
	var testName = "Make Distinct";
	
	var initialArray = ["A", "B", "B", "C"];

	var streamedList = stream_of(initialArray)
						.distinct()
						.collectAsList();
	if (ds_list_size(streamedList) != 3) {
		return new TestResult(testName, false, "result list size was incorrect");
	}
	
	return new TestResult(testName, true, "");
};

function testCount() {
	var testName = "Count";
	
	var initialArray = ["A", "B", "C"];
	
	var count = stream_of(initialArray)
				.count();
	if (count != 3) {
		return new TestResult(testName, false, "element count was incorrect");
	}
	
	return new TestResult(testName, true, "");
}

function testFilter() {
	var testName = "Filter";
	var initialArray = ["A", "B", "C", "D", "A"];
	
	var filterFunction = function(item) {
		return item == "A";	
	};
	
	var result = stream_of(initialArray)
				.filter(filterFunction)
				.collectAsList();
	if (ds_list_size(result) != 2) {
		return new TestResult(testName, false, "expected only two items to remain after filter");
	}
	if (result[| 0] != "A" || result[| 1] != "A") {
		return new TestResult(testName, false, "expected all items remaining to be 'A'");
	}
	
	return new TestResult(testName, true, "");
}

function testMap() {
	var testName = "Map";
	var initialArray = [1, 2, 3, 4];
	
	var mapFunction = function(item) {
		return item * 2;
	};
	var result = stream_of(initialArray)
					.map(mapFunction)
					.collectAsArray();
	for (var i = 0; i < array_length(initialArray); i++) {
		if (result[i] != initialArray[i] * 2) {
			return new TestResult(testName, false, "expected each mapped item to be double its original value");
		}
	}
	
	return new TestResult(testName, true, "");
}

function testAllMatchTrue() {
	var testName = "All Match Positive Case";
	var initialArray = ["A", "A", "A"];
	
	var matchFunction = function(item) {
		return string_lower(item) == "a";
	}
	var result = stream_of(initialArray)
					.allMatch(matchFunction);
	if (result != true) {
		return new TestResult(testName, false, "expected all items to match the match function");
	}
	
	return new TestResult(testName, true, "");
}

function testAllMatchFalse() {
	var testName = "All Match Negative Case";
	var initialArray = ["A", "B", "A"];
	
	var matchFunction = function(item) {
		return string_lower(item) == "a";
	}
	var result = stream_of(initialArray)
					.allMatch(matchFunction);
	if (result == true) {
		return new TestResult(testName, false, "expected one item to not match the match function");
	}
	
	return new TestResult(testName, true, "");
}

function testAnyMatchTrue() {
	var testName = "Any Match Positive Case";
	var initialArray = ["C", "B", "A"];
	
	var matchFunction = function(item) {
		return string_lower(item) == "a";
	}
	var result = stream_of(initialArray)
					.anyMatch(matchFunction);
	if (result != true) {
		return new TestResult(testName, false, "expected at least one item to match the match function");
	}
	
	return new TestResult(testName, true, "");
}

function testAnyMatchFalse() {
	var testName = "Any Match Negative Case";
	var initialArray = ["B", "C", "D"];
	
	var matchFunction = function(item) {
		return string_lower(item) == "a";
	}
	var result = stream_of(initialArray)
					.anyMatch(matchFunction);
	if (result == true) {
		return new TestResult(testName, false, "expected no items to match the match function");
	}
	
	return new TestResult(testName, true, "");
}

function testForEach() {
	var testName = "For Each";
	var initialArray = ["A", "B", "C"];
	
	seenCount = 0;
	var forEachFunction = function(item) {
		seenCount += 1;
	}
	stream_of(initialArray)
		.forEach(forEachFunction);
	if (seenCount != 3) {
		return new TestResult(testName, false, "expected the forEach function to run on each item");
	}
	
	return new TestResult(testName, true, "");
}

function testCollectJoining() {
	var testName = "Collect Joining";
	var initialArray = ["A", "B", "C"];
	
	var result = stream_of(initialArray)
					.collectJoining();
	if (result != "ABC") {
		return new TestResult(testName, false, "expected the result to be a string of the items concatenated");
	}
	
	return new TestResult(testName, true, "");
}

function testCollectJoiningDelimiter() {
	var testName = "Collect Joining with Delimiter";
	var initialArray = ["A", "B", "C"];
	
	var result = stream_of(initialArray)
					.collectJoining(",");
	if (result != "A,B,C") {
		return new TestResult(testName, false, "expected the result to be a string of the items joined with commas");
	}
	
	return new TestResult(testName, true, "");
}

function testCollectJoiningDelimiterPrefix() {
	var testName = "Collect Joining with Delimiter and Prefix";
	var initialArray = ["A", "B", "C"];
	
	var result = stream_of(initialArray)
					.collectJoining(",", ">");
	if (result != ">A,B,C") {
		return new TestResult(testName, false, "expected the result to be a string of the items joined with commas and prefixed");
	}
	
	return new TestResult(testName, true, "");
}

function testCollectJoiningDelimiterPrefixSuffix() {
	var testName = "Collect Joining with Delimiter, Prefix, and Suffix";
	var initialArray = ["A", "B", "C"];
	
	var result = stream_of(initialArray)
					.collectJoining(",", "[", "]");
	if (result != "[A,B,C]") {
		return new TestResult(testName, false, "expected the result to be a string of the items joined with commas and prefixed/suffixed");
	}
	
	return new TestResult(testName, true, "");
}

function testFindFirstEmpty() {
	var testName = "Find First, empty Stream";
	var initialArray = [];
	
	var result = stream_of(initialArray)
					.findFirst();
					
	if (result != noone) {
		return new TestResult(testName, false, "expected result of findFirst on empty stream to be noone");
	}
	
	return new TestResult(testName, true, "");
}

function testFindFirst() {
	var testName = "Find First";
	var initialArray = ["A", "B", "C"];
	
	var result = stream_of(initialArray)
					.findFirst();
					
	if (result != "A") {
		return new TestResult(testName, false, "expected result of findFirst to be A");
	}
	
	return new TestResult(testName, true, "");
}

function testSort() {
	var testName = "Sort Simple";
	var initialArray = ["C", "A", "B"];
	
	var result = stream_of(initialArray)
					.sort()
					.collectJoining();
					
	if (result != "ABC") {
		return new TestResult(testName, false, "expected result to be sorted alphabetically");
	}
	
	return new TestResult(testName, true, "");
}

function testSortNumeric() {
	var testName = "Sort Simple (Numeric)";
	var initialArray = [3, 1, 20];
	
	var result = stream_of(initialArray)
					.sort()
					.collectJoining(",");
					
	if (result != "1,3,20") {
		return new TestResult(testName, false, "expected result to be sorted numerically");
	}
	
	return new TestResult(testName, true, "");
}

function testSortComparator() {
	var testName = "Sort with Comparator";
	var initialArray = [{a: 1, b: "hello"}, {a: 3, b: "value"}, {a: 2, b: "another"}, {a: 0, b: "hey"}];
	var comparator = function(o1, o2) {
		if (o1.a < o2.a) {
			return -1;
		} else if (o1.a == o2.a) {
			return 0;
		} else {
			return 1;
		}
	}
	
	var result = stream_of(initialArray)
					.sort(comparator)
					.map(function(item) { return item.a })
					.collectJoining(",");
					
	if (result != "0,1,2,3") {
		return new TestResult(testName, false, "expected comparator to correctly sort entries by property a.\n     actual: " + result);
	}
	
	return new TestResult(testName, true, "");
}

function testNoneMatchTrue() {
	var testName = "None Match Positive Case";
	var initialArray = ["A", "B", "C"];
	
	var predicateFunction = function(item) {
		return item == "D";
	}
	var result = stream_of(initialArray)
					.noneMatch(predicateFunction);
					
	return new TestResult(testName, result, "expected no items to match the predicate");
}

function testNoneMatchFalse() {
	var testName = "None Match Negative Case";
	var initialArray = ["A", "B", "C"];
	
	var predicateFunction = function(item) {
		return item == "A";
	}
	var result = stream_of(initialArray)
					.noneMatch(predicateFunction);
					
	return new TestResult(testName, !result, "expected some items to match the predicate");
}

// Run the test suite, print out the results
totalCount = 0;
failedCount = 0;
testSuite = [testListToStream, testArrayToStream, testCollectList, testCollectArray, testDistinct, testCount, testFilter, testMap, testAllMatchTrue, testAllMatchFalse,
			 testAnyMatchTrue, testAnyMatchFalse, testForEach, testCollectJoining, testCollectJoiningDelimiter, testCollectJoiningDelimiterPrefix, 
			 testCollectJoiningDelimiterPrefixSuffix, testFindFirstEmpty, testFindFirst, testSort, testSortNumeric, testSortComparator, testNoneMatchTrue, 
			 testNoneMatchFalse];
show_debug_message("\nBeginning test suite\n");
for (var i = 0; i < array_length(testSuite); i++) {
	var test = testSuite[i];
	var result = noone;
	try {
		result = test();
	} catch (_e) {
		result = new TestResult("EXCEPTION", false, _e.message);
	}
	totalCount += 1;
	if (!result.passed) {
		failedCount += 1;
		show_debug_message("FAILED: " + result.testName);
		show_debug_message("    -> " + result.msg);
	} else {
		show_debug_message("PASSED: " + result.testName);
	}
}

show_debug_message("\nTotal tests run: " + string(totalCount) + ", Failures: " + string(failedCount));
show_debug_message(failedCount > 0 ? "FAILED" : "PASSED");
game_end();

