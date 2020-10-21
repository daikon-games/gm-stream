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

function testStreamDistinctCollectList() {
	var testName = "Stream, Make Distinct, Collect to List";
	
	var initialArray = ["A", "B", "B", "C"];

	var streamedList = stream_of(initialArray)
						.distinct()
						.collectAsList();
	if (!ds_exists(streamedList, ds_type_list)) {
		return new TestResult(testName, false, "result was not a list!");
	}
	if (ds_list_size(streamedList) != 3) {
		return new TestResult(testName, false, "result list size was incorrect");
	}
	
	return new TestResult(testName, true, "");
};

// Run the test suite, print out the results
totalCount = 0;
failedCount = 0;
testSuite = [testListToStream, testArrayToStream, testStreamDistinctCollectList];
show_debug_message("\nBeginning test suite\n");
for (var i = 0; i < array_length(testSuite); i++) {
	var test = testSuite[i];
	var result = test();
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

