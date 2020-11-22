extends Control

onready var text_label := $Text
onready var anim_player := $AnimationPlayer
onready var hint := $hint

var text_blurbs := [
	"- Story -\n\nPaige, a tireless bibliophile, has just graduated top of her class from her librarianship degree program. Ever since she first learned to read, Paige has researched far and wide, scouring every piece of literature she’s gotten her hands on to learn how to run the world’s greatest book-house.",
	"- Story -\n\nEmbarking on the next chapter of her life, she’s just landed the highly coveted position of Book Dispatcher at an outlet of the acclaimed chain store, BooksMart. ",
	"- Story -\n\nHowever, Paige soon discovers that the previous Book Dispatcher suddenly ran away while alone on duty. Some say the customers were too harsh to him, but others claim a demonic barrel bin got him fired by stealing all the books.",
	"- Story -\n\nRegardless, Paige isn’t going to let some silly hearsay get in the way of her dream job. It’s not everyday you get the chance to work at BooksMart!",
	"- Story -\n\nWe join Paige on her first day at work, ready to show off her impressive graduate skills to her expectant customers. But has Paige’s years of book-learning provided her with the street-smarts to run a real book-house by herself?",
	"- Story -\n\nHelp Paige serve her customers the books they’re after, all the while watching out for your weird woody workmate. Who knows, maybe if you abate his hunger, he’ll give you a helping hand! The question is, are you smart enough?",
	"- How to play -\n\nThe aim of the game is to accumulate as many points as possible. To do so, when customers bring you books, place them on the highlighted shelf. However, customers also won't go away until you bring them new books. These new books the customer would like are highlighted with purple particles. Sometimes the places you need to reach are too high, so make sure you use the ladder!\nAnd don't forget, you can hold more than one book at a time!",
	"- Controls -\n\nWASD - Movement ground/ladder\nE - Pickup/Throw/Place book\nSpace - Climb up/Jump off ladder"
]

signal continue_pressed



func _ready() -> void:
	hint.visible = false
	
	for text in text_blurbs:
		text_label.text = text
		anim_player.play("in")
		yield(anim_player, "animation_finished")
		hint.visible = true
		yield(self, "continue_pressed")
		hint.visible = false
		anim_player.play("out")
		yield(anim_player, "animation_finished")
	
	get_tree().change_scene("res://levels/Test_Level.tscn")



func _input(event):
	if event.is_action_pressed("use"):
		emit_signal("continue_pressed")
