extends Node



func save_to_json(file_path : String, content) -> void:
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(to_json(content))
	file.close()



func load_from_json(file_path : String): # Uknown return type
	var file = File.new()
	file.open(file_path, File.READ)
	var content = str2var(file.get_as_text())
	return content



func str2vec2(string : String) -> Vector2:
	var register := ""
	for character in string:
		if character in "-0123456789,":
			register += character
	
	var split := register.split(",")
	
	var x = int(split[0])
	var y = int(split[1])
	
	return Vector2(x, y)
