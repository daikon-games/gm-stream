function TestResult(_testName, _passed, _message) constructor {
	testName = _testName;
	passed = _passed;
	msg = _message;
};
results = ds_list_create();

function testListStreamCollectList() {
	var testName = "List to Stream, Collect to List";
	
	var initialList = ds_list_create();
	ds_list_add(initialList, "A");
	ds_list_add(initialList, "B");
	ds_list_add(initialList, "C");

	var streamedList = stream_of(initialList)
						.collectAsList();
	if (!ds_exists(streamedList, ds_type_list)) {
		return new TestResult(testName, false, "result was not a list!");
	}
	if (ds_list_size(streamedList) != 3) {
		return new TestResult(testName, false, "result list size was incorrect");
	}
	
	return new TestResult(testName, true, "");
};

function testListStreamDistinctCollectList() {
	var testName = "List to Stream, Make Distinct, Collect to List";
	
	var initialList = ds_list_create();
	ds_list_add(initialList, "A");
	ds_list_add(initialList, "B");
	ds_list_add(initialList, "B");
	ds_list_add(initialList, "C");

	var streamedList = stream_of(initialList)
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

function testArrayStreamCollectList() {
	var testName = "Array to Stream, Collect to List";
	
	var initialArray = ["A", "B", "C"];

	var streamedList = stream_of(initialArray)
						.collectAsList();
	if (!ds_exists(streamedList, ds_type_list)) {
		return new TestResult(testName, false, "result was not a list!");
	}
	if (ds_list_size(streamedList) != 3) {
		return new TestResult(testName, false, "result list size was incorrect");
	}
	
	return new TestResult(testName, true, "");
};

function testArrayStreamDistinctCollectList() {
	var testName = "Array to Stream, Make Distinct, Collect to List";
	
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

testSuite = [testListStreamCollectList, testListStreamDistinctCollectList, testArrayStreamCollectList, testArrayStreamDistinctCollectList];
for (var i = 0; i < array_length(testSuite); i++) {
	var test = testSuite[i];
	var result = test();
	ds_list_add(results, result);
}

display_set_gui_size(640, 320);