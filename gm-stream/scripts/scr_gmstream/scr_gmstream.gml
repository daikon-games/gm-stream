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
		for (var i = ds_list_size(data); i >= 0; i--) {
			var item = data[| i];
			if (!filterFunction(item)) {
				ds_list_delete(data, i);
			}
		}
		return self;
	}
	
	map = function(mapFunction) {
		for (var i = ds_list_size(data); i >= 0; i--) {
			var item = data[| i];
			data[| i] = mapFunction(item);
		}
		return self;
	}
	
	/// Terminal operations
	/// These all return some type of desired result, and call our clean_up method to finish
	collectAsList = function() {
		var result = ds_list_create();
		ds_list_copy(result, data);
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
	
	count = function() {
		var result = ds_list_size(data);
		self.clean_up();
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

