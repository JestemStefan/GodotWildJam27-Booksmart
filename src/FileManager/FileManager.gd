extends Node



func save_to_json(file_path : String, content) -> void:
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(to_json(content))
	file.close()



func read_from_json(file_path : String): # Uknown return type
	var file = File.new()
	file.open(file_path, File.READ)
	var content = str2var(file.get_as_text())
	return content
