for (i = 0; i < ds_list_size(results); i++) {
	var result = results[| i];
	if (result.passed) {
		draw_set_color(c_green);
	} else {
		draw_set_color(c_red);
	}
	draw_rectangle(0, i * 18, 640, (i * 16) + 16, false);
}