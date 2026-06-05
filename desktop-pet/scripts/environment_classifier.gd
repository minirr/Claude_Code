extends Node
## Environment classifier — placeholder implementation for MVP
## In production, this would use TensorFlow Lite EfficientNet-Lite0
## For MVP, uses a simple color analysis approach to guess environment

const ENVIRONMENTS = ["forest", "desert", "ocean", "city", "snow"]

## Classify an image file into one of 5 environments
## Returns environment key string (forest/desert/ocean/city/snow)
func classify(image_path: String) -> String:
	var img = load(image_path)
	if img == null:
		return _fallback_classify()

	var image_data: Image
	if img is Texture2D:
		image_data = img.get_image()
	else:
		return _fallback_classify()

	if image_data == null:
		return _fallback_classify()

	# Resize for analysis
	image_data.resize(64, 64, Image.INTERPOLATE_LANCZOS)

	# Analyze average color
	var avg_color = _get_average_color(image_data)
	var hue = avg_color.h
	var saturation = avg_color.s
	var value = avg_color.v

	# Simple heuristic classification based on color characteristics
	# Green hues → forest
	# Sandy/brown hues → desert
	# Blue/cyan hues → ocean
	# Gray/low saturation → city
	# White/high value low saturation → snow

	# Green range: 0.15 - 0.45
	if hue > 0.15 and hue < 0.45 and saturation > 0.2:
		return "forest"
	# Blue range: 0.5 - 0.7
	if hue > 0.5 and hue < 0.7 and saturation > 0.15:
		return "ocean"
	# Brown/Orange range: 0.05 - 0.15
	if hue > 0.05 and hue < 0.15 and saturation > 0.2 and value < 0.8:
		return "desert"
	# High value, low saturation → snow
	if value > 0.75 and saturation < 0.15:
		return "snow"
	# Low saturation gray → city
	if saturation < 0.2:
		return "city"

	# Default fallback
	return "forest"


func _get_average_color(image: Image) -> Color:
	var total_r = 0.0
	var total_g = 0.0
	var total_b = 0.0
	var pixel_count = 0

	var width = image.get_width()
	var height = image.get_height()

	# Sample every 4th pixel for performance
	for y in range(0, height, 4):
		for x in range(0, width, 4):
			var pixel = image.get_pixel(x, y)
			total_r += pixel.r
			total_g += pixel.g
			total_b += pixel.b
			pixel_count += 1

	if pixel_count == 0:
		return Color.BLACK

	return Color(
		total_r / pixel_count,
		total_g / pixel_count,
		total_b / pixel_count
	)


func _fallback_classify() -> String:
	# If classification fails, pick a random environment
	var idx = randi() % ENVIRONMENTS.size()
	return ENVIRONMENTS[idx]
