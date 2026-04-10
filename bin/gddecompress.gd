extends SceneTree

func _initialize():
	var args := OS.get_cmdline_user_args()
	printerr(args)
	if args.size() != 2:
		printerr("Usage: gddecompress <input> <output>")
		quit(1)
		return

	var in_path := args[0]
	var out_path := args[1]

	var f := FileAccess.open_compressed(in_path, FileAccess.READ)
	if f == null:
		printerr("Failed to open compressed file: ", in_path)
		quit(1)
		return

	var data := f.get_buffer(f.get_length())
	f.close()

	var out := FileAccess.open(out_path, FileAccess.WRITE)
	if out == null:
		printerr("Failed to open output file: ", out_path)
		quit(1)
		return

	out.store_buffer(data)
	out.close()

	print("Decompressed to: ", out_path)
	quit(0)
