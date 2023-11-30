extends Control

# Visualizer States.
enum State {INFIX2POSTFIX = 0, POSTFIX2RESULT = 1}

var current_state : State = State.INFIX2POSTFIX
var is_audio_on : bool = true


# Called when the button is pressed.
func _button_pressed():
	var output : Label = $OutputExpression
	var converted_expression : String = ""
	
	if current_state == State.INFIX2POSTFIX:
		converted_expression = _convert_infix2postifx($InputExpression.text)
	elif current_state == State.POSTFIX2RESULT:
		converted_expression = "Not implemented yet."
	output.text = converted_expression
	
# Precedence of operators.
func _precedence(c : String) -> int:
	if (c == "+" or c == "-"):
		return 1
	elif (c == "*" or c == "/"):
		return 2
	else:
		return -1

# Convert an infix expression to its postfix version.
func _convert_infix2postifx(input : String) -> String:
	input = _clean_whitespaces(input)
	if (_only_valid_chars(input)):
		var output : String = _infix2postfix(input)
		return output
	else:
		return "Error"

func _infix2postfix(expression: String):
	var stack_string : String = "Stack: "
	var output: String = ""
	var operators: Array = []
	
	# Tokenize the input expression
	var tokens: Array = tokenize(expression)
	
	# Operator precedence dictionary
	var precedence: Dictionary = {
		"+" : 1,
		"-" : 1,
		"*" : 2,
		"/" : 2
	}
	
	var open_brackets_count: int = 0
	
	for token in tokens:
		if is_number(token):
			# If the token is a number, append it to the output
			output += token + " "
		elif token == "(":
			# If the token is an opening parenthesis, push it onto the stack
			operators.append(token)
			open_brackets_count += 1
		elif token == ")":
			# If the token is a closing parenthesis, pop operators from the stack
			# and append them to the output until an opening parenthesis is encountered
			while operators.size() > 0 and operators[-1] != "(":
				output += operators.pop_back() + " "
			
			# Pop the opening parenthesis from the stack
			operators.pop_back()
			
			# Decrease the count of open brackets
			open_brackets_count -= 1
		elif is_operator(token):
			# If the token is an operator, pop operators from the stack
			# and append them to the output until an operator with lower precedence
			# or an opening parenthesis is encountered
			while operators.size() > 0 and operators[-1] != "(" and precedence[operators[-1]] >= precedence[token]:
				output += operators.pop_back() + " "
			
			# Push the current operator onto the stack
			operators.append(token)
	
	# Check for unmatched parentheses
	if open_brackets_count > 0:
		return "Unmatched opening parenthesis"
	elif open_brackets_count < 0:
		return "Unmatched closing parenthesis"
	
	# Pop any remaining operators from the stack and append them to the output
	while operators.size() > 0:
		output += operators.pop_back() + " "
	
	# Trim the trailing whitespace from the output
	output = output.strip_edges()
	
	# Check if the output is empty (incomplete expression)
	if output == "":
		return "Empty"
	
	return output


func tokenize(expression: String) -> Array:
	# Tokenize the expression into numbers, operators, and parentheses
	var tokens: Array = []
	var current_token: String = ""
	
	for x in expression:
		if x.is_valid_int() or x == ".":
			# If the current character is a digit or a dot, add it to the current token
			current_token += x
		#elif char.is_alpha():
			# Invalid character (e.g., letters are not allowed)
		#	return ["Error"]
		elif current_token != "":
			# If the current character is not a digit or dot, and there is a current token,
			# add the current token to the tokens array and reset the current token
			tokens.append(current_token)
			current_token = ""
			
			# Add the current non-numeric character as a separate token
			tokens.append(str(x))
		else:
			# If the current character is not a digit or dot, and there is no current token,
			# add the current non-numeric character as a separate token
			tokens.append(str(x))
	
	# If there is a remaining current token, add it to the tokens array
	if current_token != "":
		tokens.append(current_token)
	
	return tokens

func is_number(token: String) -> bool:
	# Check if a token is a number
	return token.is_valid_float()

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

	# Replace multiple consecutive whitespaces with a single whitespace
	var collapsed_string = regex.sub(input, "", true)

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
	if current_state == State.INFIX2POSTFIX:
		current_state = State.POSTFIX2RESULT
		$InputExpression.placeholder_text = "Input your postfix mathematical expression"
		$OutputExpression.text = ""
		$SubmitExpression.text = "EVALUATE THIS!"
		
	# else if current_state == State.POSTFIX2RESULT
	#	current_state = State.INFIX2POSTFIX
	else:
		current_state = State.INFIX2POSTFIX
		$InputExpression.placeholder_text = "Input your infix mathematical expression"
		$OutputExpression.text = ""
		$SubmitExpression.text = "TO POSTFIX!"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CowSprite.play()
	
	var do_stuffs : Button = $SubmitExpression
	do_stuffs.pressed.connect(self._button_pressed)
	
	var audio_onoff : Button = $AudioSprite/ToggleThemeSong
	audio_onoff.pressed.connect(self._audio_button_pressed)
	
	var state_changer : Button = $CowSprite/SwitchState
	state_changer.pressed.connect(self._state_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:	
	pass
