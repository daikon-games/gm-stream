function GmStream(_data) constructor {
	data = _data;
	isDistinct = false;
	isSorted = false;
	
	clean_up = function() {
		ds_list_destroy(data);
	}
	
	/// Intermediate operations
	/// These all process the data in some way and return our stream instance for further work
	distinct = function() {
		if (isDistinct == false) {
			var seenItems = ds_list_create();
			for (var i = ds_list_size(data); i >= 0; i--) {
				var item = data[| i];
				if (ds_list_find_index(seenItems, item) < 0) {
					ds_list_add(seenItems, item);
				} else {
					ds_list_delete(data, i);
				}
			}
			ds_list_destroy(seenItems);
			isDistinct = true;
		}
		return self;
	}
	
	filter = function(filterFunction) {
		for (var i = ds_list_size(data) - 1; i >= 0; i--) {
			var item = data[| i];
			if (!filterFunction(item)) {
				ds_list_delete(data, i);
			}
		}
		return self;
	}
	
	map = function(mapFunction) {
		for (var i = ds_list_size(data) - 1; i >= 0; i--) {
			var item = data[| i];
			data[| i] = mapFunction(item);
		}
		isDistinct = false;
		return self;
	}
	
	sort = function(comparatorFunction) {
		if (is_undefined(comparatorFunction) && isSorted == false) {
			ds_list_sort(data, true);
			isSorted = true;
		} else {
			// Don't check or set isSorted in this case as a new comparator function could re-sort us
			var result = self.mergesort(data, comparatorFunction);
			ds_list_copy(data, result);
			ds_list_destroy(result);
		}
		return self;
	}
	
	/// Terminal operations
	/// These all return some type of desired result, and call our clean_up method to finish
	allMatch = function(predicateFunction) {
		var result = true;
		for (var i = 0; i < ds_list_size(data); i++) {
			var item = data[| i];
			if (!predicateFunction(item)) {
				result = false;
				break;
			}
		}
		self.clean_up();
		return result;
	}
	
	anyMatch = function(predicateFunction) {
		var result = false;
		for (var i = 0; i < ds_list_size(data); i++) {
			var item = data[| i];
			if (predicateFunction(item)) {
				result = true;
				break;
			}
		}
		self.clean_up();
		return result;
	}
	
	collectAsArray = function() {
		var listSize = ds_list_size(data);
		var result = array_create(listSize);
		for (var i = 0; i < listSize; i++) {
			result[i] = data[| i];
		}
		self.clean_up();
		return result;
	}
	
	collectAsList = function() {
		var result = ds_list_create();
		ds_list_copy(result, data);
		self.clean_up();
		return result; 
	}
	
	collectJoining = function(delimiter, prefix, suffix) {
		var result = "";
		
		if (!is_undefined(prefix)) {
			result += prefix;
		}
		
		var listSize = ds_list_size(data);
		for (var i = 0; i < listSize; i++) {
			var item = data[| i];
			result += string(item);
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
		var result = ds_list_size(data);
		self.clean_up();
		return result;
	}
	
	findFirst = function() {
		if (ds_list_size(data) == 0) {
			return noone;
		}
		var result = data[| 0];
		self.clean_up();
		return result;
	}
	
	forEach = function(forEachFunction) {
		for (var i = 0; i < ds_list_size(data); i++) {
			var item = data[| i];
			forEachFunction(item);
		}
		self.clean_up();
	}
	
	noneMatch = function(predicateFunction) {
		return !self.anyMatch(predicateFunction);
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
			if (comparatorFunction(leftList[|i], rightList[|j]) < 1) {
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

/// @function stream_of(dataStructure)
/// @param dataStructure A data-structure to be streamed
/// @return a GmStream of the given data structure
function stream_of(dataStructure) {
	if (is_array(dataStructure)) {
		var data = ds_list_create();
		for (var i = 0; i < array_length(dataStructure); i++) {
			ds_list_add(data, dataStructure[i]);
		}
		return new GmStream(data);
	} else if (ds_exists(dataStructure, ds_type_list)) {
		return new GmStream(dataStructure);
	}
}

