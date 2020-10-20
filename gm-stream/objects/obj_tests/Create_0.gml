function TestResult(_passed, _message) constructor {
	passed = _passed;
	msg = _message;
};
results = ds_list_create();

function testListStreamCollectList() {
	var initialList = ds_list_create();
	ds_list_add(initialList, "A");
	ds_list_add(initialList, "B");
	ds_list_add(initialList, "C");

	var streamedList = stream_of(initialList)
						.collectAsList();
	if (!ds_exists(streamedList, ds_type_list)) {
		return new TestResult(false, "result was not a list!");
	}
	if (ds_list_size(streamedList) != 3) {
		return new TestResult(false, "result list size was incorrect");
	}
	
	return new TestResult(true, "");
};

function testListStreamDistinctCollectList() {
	var initialList = ds_list_create();
	ds_list_add(initialList, "A");
	ds_list_add(initialList, "B");
	ds_list_add(initialList, "B");
	ds_list_add(initialList, "C");

	var streamedList = stream_of(initialList)
						.distinct()
						.collectAsList();
	if (!ds_exists(streamedList, ds_type_list)) {
		return new TestResult(false, "result was not a list!");
	}
	if (ds_list_size(streamedList) != 3) {
		return new TestResult(false, "result list size was incorrect");
	}
	
	return new TestResult(true, "");
};

testSuite = [testListStreamCollectList, testListStreamDistinctCollectList];
for (var i = 0; i < array_length(testSuite); i++) {
	var test = testSuite[i];
	var result = test();
	ds_list_add(results, result);
}

display_set_gui_size(640, 320);