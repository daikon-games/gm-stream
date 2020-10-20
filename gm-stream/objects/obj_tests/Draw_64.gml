draw_set_font(font_test);

for (i = 0; i < ds_list_size(results); i++) {
	var result = results[| i];
	if (result.passed) {
		draw_set_color(c_green);
	} else {
		draw_set_color(c_red);
	}
	draw_rectangle(0, (i * 24) + 2, 640, (i * 24) + 24, false);
	draw_set_color(c_white);
	draw_text(4, (i * 24) + 4, result.testName);
}