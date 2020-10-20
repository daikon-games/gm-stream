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
	
	/// Terminal operations
	/// These all return some type of desired result, and call our clean_up method to finish
	collectAsList = function(collector) {
		var result = ds_list_create();
		ds_list_copy(result, data);
		self.clean_up();
		return result; 
	}
}

/// @function stream_of(dataStructure)
/// @param dataStructure A data-structure to be streamed
/// @return a GmStream of the given data structure
function stream_of(dataStructure) {
	if (ds_exists(dataStructure, ds_type_list)) {
		return new GmStream(dataStructure);
	}
}

