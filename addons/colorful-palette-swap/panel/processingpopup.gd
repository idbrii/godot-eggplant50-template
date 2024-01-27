tool
extends WindowDialog

func _on_process_complete(output_file: String):
	# Close the popup when processing completes.
	queue_free()

