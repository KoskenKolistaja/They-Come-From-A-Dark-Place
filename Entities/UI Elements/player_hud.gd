extends Control

var player_id






func update_name(player_id):
	$Panel/PlayerName.text = "Player" + str(player_id)


func update_money(amount):
	$Panel/Money.text = str(amount) + "$"

func update_health(amount):
	$Panel/ProgressBar.value = amount


func update_bullets(amount: int):
	$Panel/HBoxContainer/TextureRect/AmmoBullets.text = str(amount)

func update_rockets(amount: int):
	$Panel/HBoxContainer/TextureRect2/AmmoRockets.text = str(amount)
