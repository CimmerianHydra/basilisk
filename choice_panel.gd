class_name ChoicePanel
extends VBoxContainer

## A deliberately generic UI widget: given a title and a list of labels, show a
## button per label and emit the chosen index. It knows nothing about the game —
## not targets, not Lock On — so it serves every future choice. The caller formats
## the labels and interprets the index.

signal selected(index: int)


## Show a title and one button per label. Hidden until called.
func present(title: String, labels: Array[String]) -> void:
	_clear()

	var heading := Label.new()
	heading.text = title
	add_child(heading)

	for i in labels.size():
		var button := Button.new()
		button.text = labels[i]
		button.pressed.connect(_choose.bind(i))
		add_child(button)

	visible = true


func _choose(index: int) -> void:
	visible = false
	_clear()
	selected.emit(index)

func _clear() -> void:
	for child in get_children():
		child.queue_free()
