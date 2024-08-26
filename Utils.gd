extends Node
class_name Utils


static func big_int_to_human_format(value: int)-> String:
	var string_value := str(value)
	var string_formatted := ""
	
	for i in range(string_value.length()):
		if 0 < i and 0 == i % 3:
			string_formatted = " " + string_formatted
		string_formatted = string_value[-i - 1] + string_formatted
	
	return string_formatted
