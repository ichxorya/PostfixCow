extends Control

# Visualizer States.
enum State {INFIX2POSTFIX = 0, POSTFIX2RESULT = 1}

var current_state : State = State.INFIX2POSTFIX
var is_audio_on : bool = true
var del = 1


# Called when the button is pressed.
func _button_pressed():
	$SFX.play(1.44)
	var output : Label = $OutputExpression
	var converted_expression : String = ""
	
	if current_state == State.INFIX2POSTFIX:
		converted_expression = await _convert_infix2postifx($InputExpression.text)
	elif current_state == State.POSTFIX2RESULT:
		converted_expression = await _convert_postfix2result($InputExpression.text)
	output.text = converted_expression
	

# Convert an infix expression to its postfix version.
func _convert_infix2postifx(input : String) -> String:
	input = _clean_whitespaces(input)
	if (_only_valid_chars(input)):
		var output : String = await _infix2postfix(input)
		return output
	else:
		return "Error"

# Convert a postfix expression to a result.
func _convert_postfix2result(input : String) -> String:
	input = _clean_whitespaces_pf(input)
	if (_only_valid_chars_pf(input)):
		var output : String = await _postfix2result(input)
		return output
	else:
		return "Error"

func _postfix2result(expression: String):
	var delay = del
	
	var output: String = ""
	var output_expr = $OutputExpression
	output_expr.text = output
	
	var stack: Array = []
	var stack_str: String = "Stack: "
	var stack_rep = $StackRepresentation
	stack_rep.text = stack_str
	
	# Tokenize the input expression
	var tokens: Array = tokenize(expression)
	var tokens_str: String = "Tokens: "
	for x in tokens:
		if x != " " and x != "":
			tokens_str += x + " | "
	var tokens_rep = $TokensRepresentation
	tokens_rep.text = tokens_str
	
	for idx in range(tokens.size()):
		var token = tokens[idx]
		
		# Token visualizer
		tokens_rep.clear()
		tokens_str = "Tokens: "
		for i in range(tokens.size()):
			var x = tokens[i]
			if i == idx:
				if x != " " and x != "":
					tokens_str += "[color=blue]" + tokens[i] + "[/color] | "
			else:
				if x != " " and x != "":
					tokens_str += tokens[i] + " | "
		tokens_rep.append_text(tokens_str)

		# Add to output if token is a number
		if is_number(token):
			stack.append(token)
			stack_str = "Stack: " + _stack2string(stack)
			stack_rep.text = stack_str
			await get_tree().create_timer(delay).timeout

		# Do stuff if token is + - * /
		elif is_operator(token):
			if stack.size() < 2:
				return "Error"

			var operand2 = int(stack.pop_back())
			stack_str = "Stack: " + _stack2string(stack)
			stack_rep.text = stack_str
			await get_tree().create_timer(delay).timeout
			var operand1 = int(stack.pop_back())
			stack_str = "Stack: " + _stack2string(stack)
			stack_rep.text = stack_str
			await get_tree().create_timer(delay).timeout
	
			if token == "+":
				stack.append(str(operand1 + operand2))
			elif token == "-":
				stack.append(str(operand1 - operand2))
			elif token == "*":
				stack.append(str(operand1 - operand2))
			else:
				if (operand2 != 0):
					stack.append(str(operand1 / operand2))
				else:
					return "Error"
			stack_str = "Stack: " + _stack2string(stack)
			stack_rep.text = stack_str
			await get_tree().create_timer(delay).timeout
			
		# End of token visualizer
		tokens_rep.clear()
		tokens_str = "Tokens: "
		for i in range(tokens.size()):
			if tokens[i] != "" and tokens[i] != " ":		
				tokens_str += tokens[i] + " | "
		tokens_rep.append_text(tokens_str)
	
	# The final result is the only element left in the stack
	if stack.size() != 1:
		return "Error"
		
	# Output is the remaining element
	output = stack[0]
	
	# Trim the trailing whitespace from the output
	output = output.strip_edges()
	
	# Check if the output is empty (incomplete expression)
	if output == "":
		return "Empty"
	
	$Copy.set_self_modulate(Color("ffffff"))
	return "Final result: " + output
		
func _infix2postfix(expression: String):
	var delay = del
	
	var output: String = ""
	var output_expr = $OutputExpression
	output_expr.text = output
	
	var stack: Array = []
	var stack_str: String = "Stack: "
	var stack_rep = $StackRepresentation
	stack_rep.text = stack_str
	
	# Tokenize the input expression
	var tokens: Array = tokenize(expression)
	var tokens_str: String = "Tokens: "
	for x in tokens:
		if x != " ":
			tokens_str += x + " | "
	var tokens_rep = $TokensRepresentation
	tokens_rep.text = tokens_str
	
	# Operator precedence dictionary
	var precedence: Dictionary = {
		"+" : 1,
		"-" : 1,
		"*" : 2,
		"/" : 2
	}
	
	for idx in range(tokens.size()):
		var token = tokens[idx]
		
		# Token visualizer
		tokens_rep.clear()
		tokens_str = "Tokens: "
		for i in range(tokens.size()):
			if i == idx:
				tokens_str += "[color=blue]" + tokens[i] + "[/color] | "
			else:
				tokens_str += tokens[i] + " | "
		tokens_rep.append_text(tokens_str)

		# Add to output if token is a number
		if is_number(token):
			output += token + " "
			output_expr.text = output
			await get_tree().create_timer(delay).timeout

		# Add to stack if token is (
		elif token == "(":
			stack.append(token)
			stack_str = "Stack: " + _stack2string(stack)
			stack_rep.text = stack_str
			await get_tree().create_timer(delay).timeout

		# Do stuff if token is )
		elif token == ")":
			while stack.size() > 0 and stack[-1] != "(":
				var x = stack.pop_back()
				output += x + " "
				output_expr.text = output
				await get_tree().create_timer(delay).timeout
				stack_str = "Stack: " + _stack2string(stack)
				stack_rep.text = stack_str
				await get_tree().create_timer(delay).timeout

			stack.pop_back()
			stack_str = "Stack: " + _stack2string(stack)
			stack_rep.text = stack_str
			await get_tree().create_timer(delay).timeout

		# Do stuff if token is + - * /
		elif is_operator(token):
			while stack.size() > 0 and stack[-1] != "(" and precedence[stack[-1]] >= precedence[token]:
				output += stack.pop_back() + " "
				output_expr.text = output
				stack_str = "Stack: " + _stack2string(stack)
				stack_rep.text = stack_str
				await get_tree().create_timer(delay).timeout

			stack.append(token)
			stack_str = "Stack: " + _stack2string(stack)
			stack_rep.text = stack_str
			await get_tree().create_timer(delay).timeout
			
		# End of token visualizer
		tokens_rep.clear()
		tokens_str = "Tokens: "
		for i in range(tokens.size()):
				tokens_str += tokens[i] + " | "
		tokens_rep.append_text(tokens_str)
	
	
	# Pop the rest of the stack
	while stack.size() > 0:
		var pop = stack[-1]
		if stack[-1] != "(" and stack[-1] != ")":
			output += pop + " "
			output_expr.text = output
			await get_tree().create_timer(del).timeout
		else:
			return "Error"
		stack.pop_back()
		stack_str =  "Stack: " + _stack2string(stack)
		stack_rep.text = stack_str
		await get_tree().create_timer(del).timeout
	
			
	# Trim the trailing whitespace from the output
	output = output.strip_edges()
	
	# Check if the output is empty (incomplete expression)
	if output == "":
		return "Empty"
	
	$Copy.set_self_modulate(Color("ffffff"))
	return "Final result: " + output

func _stack2string(stack):
	var strx = ""
	for x in stack:
		strx += x + " | "
	return strx

func tokenize(expression: String) -> Array:
	# Tokenize the expression into numbers, operators, and parentheses
	var tokens: Array = []
	var current_token: String = ""
	
	for x in expression:
		if x.is_valid_int():
			# If the current character is a digit, add it to the current token
			current_token += x
		elif current_token != "":		
			# If the current character is not a digit, and there is a current token,
			# add the current token to the tokens array and reset the current token
			tokens.append(current_token)
			current_token = ""
			
			# Add the current non-numeric character as a separate token
			tokens.append(str(x))
		else:
			# If the current character is not a digit, and there is no current token,
			# add the current non-numeric character as a separate token		
			tokens.append(str(x))
	
	# If there is a remaining current token, add it to the tokens array
	if current_token != "":
		tokens.append(current_token)
	
	return tokens
	

func is_number(token: String) -> bool:
	# Check if a token is a number
	return token.is_valid_int()

func is_operator(token: String) -> bool:
	# Check if a token is an operator
	return token in ["+", "-", "*", "/"]


		
# Remove all whitespaces.
func _clean_whitespaces(input: String) -> String:
	# Trim the string.
	input = input.strip_edges(true, true)
	
	# Define the regular expression pattern
	var pattern := "\\s"

	# Create a regular expression object
	var regex := RegEx.new()

	# Compile the pattern
	regex.compile(pattern)

	# Replace whitespaces with no whitespace
	var collapsed_string = regex.sub(input, "", true)

	return collapsed_string
	
# Remove neccessary whitespaces.
func _clean_whitespaces_pf(input: String) -> String:
	# Trim the string.
	input = input.strip_edges(true, true)
	
	# Define the regular expression pattern
	var pattern := "\\s"

	# Create a regular expression object
	var regex := RegEx.new()

	# Compile the pattern
	regex.compile(pattern)

	# Replace multiple consecutive whitespaces with a single whitespace
	var collapsed_string = regex.sub(input, " ", true)

	return collapsed_string

# Check if a string contains only valid characters.
func _only_valid_chars(input : String) -> bool:
	# Define the regular expression pattern
	var pattern := "^[0-9()+\\-*/\\s]+$"

	# Create a regular expression object
	var regex := RegEx.new()

	# Compile the pattern
	regex.compile(pattern)
	
	# Test if the input string matches the pattern
	return regex.search(input) != null

# Check if a string contains only valid characters (postfix)
func _only_valid_chars_pf(input : String) -> bool:
	# Define the regular expression pattern
	var pattern := "^[0-9+\\-*/\\s]+$"

	# Create a regular expression object
	var regex := RegEx.new()

	# Compile the pattern
	regex.compile(pattern)
	
	# Test if the input string matches the pattern
	return regex.search(input) != null

func _audio_button_pressed() -> void:
	var master_sound = AudioServer.get_bus_index("Master")
	if is_audio_on == true:
		is_audio_on = false
		AudioServer.set_bus_mute(master_sound, true)
		$AudioSprite.set_frame_and_progress(1, 0)
		$CowSprite.pause()
	else:
		is_audio_on = true
		AudioServer.set_bus_mute(master_sound, false)
		$AudioSprite.set_frame_and_progress(0, 0)
		$CowSprite.play()

func _state_button_pressed():
	$SFX.play(0.9)
	if current_state == State.INFIX2POSTFIX:
		current_state = State.POSTFIX2RESULT
		$InputExpression.placeholder_text = "Input your postfix mathematical expression"
		$OutputExpression.text = ""
		$SubmitExpression.text = "EVALUATE THIS!"
		$TokensRepresentation.text = ""
		$StackRepresentation.text = ""
		$Copy.set_self_modulate(Color("ffffff00"))
		
	# else if current_state == State.POSTFIX2RESULT
	#	current_state = State.INFIX2POSTFIX
	else:
		current_state = State.INFIX2POSTFIX
		$InputExpression.placeholder_text = "Input your infix mathematical expression"
		$OutputExpression.text = ""
		$SubmitExpression.text = "TO POSTFIX!"
		$TokensRepresentation.text = ""
		$StackRepresentation.text = ""
		$Copy.set_self_modulate(Color("ffffff00"))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CowSprite.play()
	
	var do_stuffs : Button = $SubmitExpression
	do_stuffs.pressed.connect(self._button_pressed)
	
	var audio_onoff : Button = $AudioSprite/ToggleThemeSong
	audio_onoff.pressed.connect(self._audio_button_pressed)
	
	var state_changer : Button = $CowSprite/SwitchState
	state_changer.pressed.connect(self._state_button_pressed)
	
	var faster = $Faster
	faster.pressed.connect(self._fast_button_pressed)
	var slower = $Slower
	slower.pressed.connect(self._slow_button_pressed)
	
	var copy = $Copy
	copy.set_self_modulate(Color("ffffff00"))
	copy.pressed.connect(self._copy_button_pressed)

func _slow_button_pressed():
	if (del < 5.0):
		del += 0.5
		$SFX.play(1.5)
	else:
		del = 5.0
		
func _fast_button_pressed():
	if (del > 1):
		del -= 0.5
		$SFX.play(1.5)
	else:
		del = 1.0
		
func _copy_button_pressed():
	var t = $OutputExpression.text
	var t2 = t.substr(13)
	if t2 != "":
		DisplayServer.clipboard_set(t2)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass
