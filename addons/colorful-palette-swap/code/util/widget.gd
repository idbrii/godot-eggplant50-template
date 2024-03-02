static func setup_dropdown_from_enum(dropdown: OptionButton, enum_type):
	dropdown.clear()
	for k in enum_type.keys():
		dropdown.add_item(k.capitalize())
