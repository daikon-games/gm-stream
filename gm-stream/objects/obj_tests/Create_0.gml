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

function testStreamCollectList() {
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

function testStreamCollectArray() {
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

function testStreamDistinct() {
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

// Run the test suite, print out the results
totalCount = 0;
failedCount = 0;
testSuite = [testListToStream, testArrayToStream, testStreamCollectList, testStreamCollectArray, testStreamDistinct, testCount, testFilter, testMap];
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
