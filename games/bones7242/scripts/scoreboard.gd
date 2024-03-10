extends RichTextLabel

var outs = 0
var strikes = 0
var runs = 0

func increase_runs ():
	runs += 1
	#tbd: some sort of animation
	pass
	
func reset_strikes ():
	strikes = 0
	#tbd: some sort of animation
	pass

func increase_strikes():
	strikes += 1
	#tbd: some sort of animation
	pass
	
func increase_outs():
	outs += 1
	#tbd: some sort of animation
	pass

func new_out ():
	increase_outs()
	reset_strikes()
	#if 3 outs, game over
	if (outs >= 3) :
		print("that's three outs")
		#TBD: show game over screen
	pass
	
func new_strike ():
	increase_strikes() #increment strikes
	#if 3 strikes, reset strikes, increment outs
	if (strikes >= 3) :
		print("that's three strikes")
		new_out()
		reset_strikes()
	pass

func new_run ():
	increase_runs()
	reset_strikes()
	pass

func _process(delta):
	set_text("Strikes: " + str(strikes))
	newline()
	add_text("Outs: " + str(outs))
	newline()
	add_text("Home Runs: " + str(runs))
	pass
