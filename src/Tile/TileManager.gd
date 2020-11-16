extends Node



func create_tile(set_translation : Vector3, tile_type : String) -> Tile:
	var tile = Tile.new()
	
	if Tile.TILES.get(tile_type).script != "":
		tile.set_script(load(Tile.TILES.get(tile_type).script))
	
	var set_dimensions : Vector3 = Tile.TILES.get(tile_type).dimensions
	var set_mesh_resource : String = Tile.TILES.get(tile_type).mesh
	var set_mesh_texture : String = Tile.TILES.get(tile_type).texture
	
	tile.translation = set_translation
	tile.dimensions = set_dimensions
	tile.mesh_texture = set_mesh_texture
	tile.mesh_resource = set_mesh_resource
	
	return tile
