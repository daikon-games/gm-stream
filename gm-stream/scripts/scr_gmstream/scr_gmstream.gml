function GmStream(_gms_data) constructor {
	gms_data = _gms_data;
	isDistinct = false;
	isSorted = false;
	
	clean_up = function() {
		ds_list_destroy(gms_data);
	}
	
	/// Intermediate operations
	/// These all process the gms_data in some way and return our stream instance for further work
	distinct = function() {
		if (isDistinct == false) {
			var seengms_items = ds_list_create();
			for (var i = ds_list_size(gms_data); i >= 0; i--) {
				var gms_item = gms_data[| i];
				if (ds_list_find_index(seengms_items, gms_item) < 0) {
					ds_list_add(seengms_items, gms_item);
				} else {
					ds_list_delete(gms_data, i);
				}
			}
			ds_list_destroy(seengms_items);
			isDistinct = true;
		}
		return self;
	}
	
	filter = function(filterFunction) {
		for (var i = ds_list_size(gms_data) - 1; i >= 0; i--) {
			var gms_item = gms_data[| i];
			if (!filterFunction(gms_item)) {
				ds_list_delete(gms_data, i);
			}
		}
		return self;
	}
	
	map = function(mapFunction) {
		for (var i = ds_list_size(gms_data) - 1; i >= 0; i--) {
			var gms_item = gms_data[| i];
			gms_data[| i] = mapFunction(gms_item);
		}
		isDistinct = false;
		return self;
	}
	
	sort = function(comparatorFunction) {
		if (ds_list_size(gms_data) > 1) {
			if (is_undefined(comparatorFunction) && isSorted == false) {
				ds_list_sort(gms_data, true);
				isSorted = true;
			} else {
				// Don't check or set isSorted in this case as a new comparator function could re-sort us
				var result = self.mergesort(gms_data, comparatorFunction);
				ds_list_copy(gms_data, result);
				ds_list_destroy(result);
			}
		}
		return self;
	}
	
	/// Terminal operations
	/// These all return some type of desired result, and call our clean_up method to finish
	allMatch = function(predicateFunction) {
		var result = true;
		for (var i = 0; i < ds_list_size(gms_data); i++) {
			var gms_item = gms_data[| i];
			if (!predicateFunction(gms_item)) {
				result = false;
				break;
			}
		}
		self.clean_up();
		return result;
	}
	
	anyMatch = function(predicateFunction) {
		var result = false;
		for (var i = 0; i < ds_list_size(gms_data); i++) {
			var gms_item = gms_data[| i];
			if (predicateFunction(gms_item)) {
				result = true;
				break;
			}
		}
		self.clean_up();
		return result;
	}
	
	collectAsArray = function() {
		var listSize = ds_list_size(gms_data);
		var result = array_create(listSize);
		for (var i = 0; i < listSize; i++) {
			result[i] = gms_data[| i];
		}
		self.clean_up();
		return result;
	}
	
	collectAsList = function() {
		var result = ds_list_create();
		ds_list_copy(result, gms_data);
		self.clean_up();
		return result; 
	}
	
	collectJoining = function(delimiter, prefix, suffix) {
		var result = "";
		
		if (!is_undefined(prefix)) {
			result += prefix;
		}
		
		var listSize = ds_list_size(gms_data);
		for (var i = 0; i < listSize; i++) {
			var gms_item = gms_data[| i];
			result += string(gms_item);
			if (!is_undefined(delimiter) && i != listSize - 1) {
				result += delimiter;
			}
		}
		
		if (!is_undefined(suffix)) {
			result += suffix;
		}
		
		self.clean_up();
		return result;
	}
	
	count = function() {
		var result = ds_list_size(gms_data);
		self.clean_up();
		return result;
	}
	
	findFirst = function() {
		if (ds_list_size(gms_data) == 0) {
			return noone;
		}
		var result = gms_data[| 0];
		self.clean_up();
		return result;
	}
	
	fold = function(initialValue, foldFunction) {
		var result = initialValue;
		for (var i = 0; i < ds_list_size(gms_data); i++) {
			result = foldFunction(result, gms_data[| i]);
		}
		self.clean_up();
		return result;
	}
	
	forEach = function(forEachFunction) {
		for (var i = 0; i < ds_list_size(gms_data); i++) {
			var gms_item = gms_data[| i];
			forEachFunction(gms_item);
		}
		self.clean_up();
	}
	
	noneMatch = function(predicateFunction) {
		return !self.anyMatch(predicateFunction);
	}
	
	reduce = function(foldFunction) {
		if (ds_list_size(gms_data) == 0) {
			self.clean_up();
			throw "Cannot reduce an empty stream";
		}
		var result = gms_data[| 0];
		for (var i = 1; i < ds_list_size(gms_data); i++) {
			result = foldFunction(result, gms_data[| i]);
		}
		self.clean_up();
		return result;
	}
	
	/// Helper methods
	mergesort = function(list, comparatorFunction) {
		var listSize = ds_list_size(list);
		if (listSize <= 1) {
			return list;
		}
		var halfSize = ceil(listSize/2);
		var leftList = ds_list_create();
		var rightList = ds_list_create();
		
		for (var i = 0; i < listSize; i++) {
			if (i < halfSize) {
				ds_list_add(leftList, list[| i]);
			} else {
				ds_list_add(rightList, list[| i]);
			}
		}
		
		leftList = self.mergesort(leftList, comparatorFunction);
		rightList = self.mergesort(rightList, comparatorFunction);
		
		return self.merge(leftList, rightList, comparatorFunction);
	}
	merge = function(leftList, rightList, comparatorFunction) {
		var result = ds_list_create();
		var i = 0;
		var j = 0;
		
		while (i < ds_list_size(leftList) && j < ds_list_size(rightList)) {
			if (comparatorFunction(leftList[|i], rightList[|j]) <= 0) {
				ds_list_add(result, leftList[|i++]);
			} else {
				ds_list_add(result, rightList[|j++]);
			}
		}
		while (i < ds_list_size(leftList)) {
			ds_list_add(result, leftList[|i++]);
		}
		while (j < ds_list_size(rightList)) {
			ds_list_add(result, rightList[|j++]);
		}
		ds_list_destroy(leftList);
		ds_list_destroy(rightList);
		
		return result;
	}
}

/// @function stream_of(gms_dataStructure)
/// @param gms_dataStructure A gms_data-structure to be streamed
/// @return a GmStream of the given gms_data structure
function stream_of(gms_dataStructure) {
	if (is_array(gms_dataStructure)) {
		// Create a stream from an array
		var gms_data = ds_list_create();
		for (var i = 0; i < array_length(gms_dataStructure); i++) {
			ds_list_add(gms_data, gms_dataStructure[i]);
		}
		return new GmStream(gms_data);
	} else if (ds_exists(gms_dataStructure, ds_type_list)) {
		// Create a stream from a ds_list
		var gms_data = ds_list_create();
		ds_list_copy(gms_data, gms_dataStructure);
		return new GmStream(gms_data);
	} else if (ds_exists(gms_dataStructure, ds_type_queue)) {
		// Create a stream from a ds_queue
		var gms_data = ds_list_create();
		var tempQueue = ds_queue_create();
		ds_queue_copy(tempQueue, gms_dataStructure);
		var gms_item = ds_queue_dequeue(tempQueue);
		while (!is_undefined(gms_item)) {
			ds_list_add(gms_data, gms_item);
			gms_item = ds_queue_dequeue(tempQueue);
		}
		ds_queue_destroy(tempQueue);
		return new GmStream(gms_data);
	} else if (ds_exists(gms_dataStructure, ds_type_stack)) {
		// Create a stream from a ds_stack
		var gms_data = ds_list_create();
		var tempStack = ds_stack_create();
		ds_stack_copy(tempStack, gms_dataStructure);
		var gms_item = ds_stack_pop(tempStack);
		while (!is_undefined(gms_item)) {
			ds_list_add(gms_data, gms_item);
			gms_item = ds_stack_pop(tempStack);
		}
		ds_stack_destroy(tempStack);
		return new GmStream(gms_data);
	}
}

