extends Node

var jumpHeight = 80.0
var airTime = 0.5
var jumpingDistance = 80.0

var gravity = -(2*jumpHeight)/pow((airTime/2),2)
#var vertical_speed = -(2*jumpHeight)/(airTime/2)
var vertical_speed = gravity*(airTime/2)
var horizontal_speed = -jumpingDistance*vertical_speed/(4*jumpHeight)


signal stateEntry
signal stateExit


func reload_Speed():
	vertical_speed = gravity*(airTime/2)
	horizontal_speed = -jumpingDistance*vertical_speed/(4*jumpHeight)


func subscribeEntry(target,method):
	connect("stateEntry",target,method)
	
func subscribeExit(target,method):
	connect("stateExit",target,method)
