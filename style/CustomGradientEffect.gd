tool
extends RichTextEffect
class_name RichTextGradient

var bbcode = "gradient"
var color1 = 0.2
var color2 = 0.8
var up = true
var a = 0
var b = 0

func _process_custom_fx(char_fx : CharFXTransform) -> bool:
	if up == true:
		color1+=0.0005;
		color2-=0.0005;
		char_fx.set_color(Color(color1,0.2,color2))
		if color1>0.8:
			up = false;
	if up == false:
		color1-=0.0005;
		color2+=0.0005;
		char_fx.set_color(Color(color1,0.2,color2))
		if color2>0.8:
			up = true;
	return true
