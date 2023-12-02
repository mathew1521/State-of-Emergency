# This is going to serve as a game manager of sorts. I'll have a look at it tomorrow
# if I have some time. Sometimes I wish I had the schedule that 8 year old me did.
# I sure could use all that time on my hands now.
extends Node
enum STATE {
	PLAYING,
	MENU,
	INVENTORY,
	CONSOLE,
}
var currentSTATE: STATE = STATE.PLAYING

