extends Node2D

@onready var dialogue_player: DialoguePlayer = $DialoguePlayer

func play_dialogue() -> void:
	var sequence: DialogueSequence = load("res://assets/dialogue/sequence/ch_1_1.tres")
	await dialogue_player.play(sequence)
	sequence = load("res://assets/dialogue/sequence/ch_1_2.tres")
	await dialogue_player.play(sequence)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_dialogue()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
