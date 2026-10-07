extends HBoxContainer

const HEART_GUI_CLASS = preload("res://scenes/hearts_gui.tscn")
func setMaxHearts(max:int):
	for i in range(max):
		var heart = HEART_GUI_CLASS.instantiate()
		add_child(heart)
		
func updateHearts(currentHealth:int):
	var hearts = get_children()
	#更新所有剩余血量
	for i in range(currentHealth):
		hearts[i].update(true)
	#更新所有失去血量
	for i in range(currentHealth,hearts.size()):
		hearts[i].update(false)
#
