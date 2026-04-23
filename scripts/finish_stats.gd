# Label that displays game completion statistics (orbs, time, knockouts).
extends Label


# Initialize and display final game stats
func _ready() -> void:
	var orbs: String = "Orbs Found: " + str(GameManager.total_orbs) + "/" + str(GameManager.max_orbs) + "\n"
	var seconds: int = int(GameManager.total_time_taken/1000.0)
	var time: String = "Time Taken: " + str(seconds) + "s\n"
	var knockouts: String = "Knocked out " + str(GameManager.total_knock_outs) + " times"
	self.text =  orbs + time + knockouts
	
