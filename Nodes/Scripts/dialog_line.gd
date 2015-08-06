extends GraphNode

var nbBlockLines = 0
var nodes_lines = []

func _ready():
	_add_line()
	pass
	

func _add_line():
	var node = load("res://Nodes/SubNodes/dialog_line_block.scn").instance()
	node.set_id(nbBlockLines)
		
	node.add_rembutton(self)
	if nbBlockLines+1 <= 1:
		node.hide_rembutton()
	
	node.add_addbutton(self)
	
	# add new line block to the main container
	get_node("vbox_main_container").add_child(node)
	nodes_lines.append(node)
	nbBlockLines += 1
	
	# at least 2 variables, add remove button to first variable so it can be deleted
	if nbBlockLines > 1:
		nodes_lines[0].show_rembutton()


func _on_remove_pressed(node):
	get_node("vbox_main_container").remove_child(node)
	nodes_lines.remove( nodes_lines.find(node) )
	nbBlockLines -= 1
	
	if nbBlockLines == 1:
		nodes_lines[0].hide_rembutton()
	
	var resize = get_node("vbox_main_container").get_size()
	set_size( Vector2(resize.x+32, resize.y ) )
	
func _on_add_pressed():
	_add_line()


func _on_close_request():
	queue_free()

func save_data(node_list):
	var nodeDict = {
			"type": "dialog_line",
			"id": get_name(),
			"x": get_offset().x,
			"y": get_offset().y
			}
	for i in range(0, nbBlockLines):
		var block = nodes_lines[i]
		nodeDict["lines"+str(block.get_id())] = block.get_node("vbox_block/lines").get_text().percent_encode()
		nodeDict["anim"+str(block.get_id())] = block.get_node("vbox_block/anim").get_text().percent_encode()
		
	node_list.push_back(nodeDict)

func load_data(data):
	_on_remove_pressed(nodes_lines[0])
	set_name( data["id"])
	set_offset( Vector2(data["x"], data["y"]))

	var currentBlock = 0
	var keyLine = "lines" 
	var keyAnim = "anim"
	while data.has( keyLine + str(currentBlock)) and data.has( keyAnim + str(currentBlock)):
		_add_line()
		nodes_lines[currentBlock].get_node("vbox_block/lines").set_text(data[keyLine + str(currentBlock)])
		nodes_lines[currentBlock].get_node("vbox_block/anim").set_text(data[keyAnim + str(currentBlock)])
		currentBlock += 1
	
	

func export_data(file, connections, labels):
	file.store_line("func " + get_name() + "(c):")
	var statement = get_node("vbox/statement").get_text()
	if statement == "":
		statement = "true"
	var branch_true = ""
	var branch_false = ""
	for conn in connections:
		if conn["from_port"] == 1:
			branch_true = conn["to"]
		if conn["from_port"] == 2:
			branch_false = conn["to"]
	file.store_line("\tif " + statement + ":")
	if branch_true != "":
		file.store_line("\t\t" + branch_true + "(c)")
	else:
		file.store_line("\t\tpass")
	if branch_false != "":
		file.store_line("\telse:")
		file.store_line("\t\t" + branch_false + "(c)")
