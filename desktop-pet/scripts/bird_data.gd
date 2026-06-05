class_name BirdData
extends Node
## Bird species data — static definitions for all 5 environments

const SPECIES = {
	"forest": {
		"name": "森林翠鸟",
		"body_color": Color(0.18, 0.65, 0.3),
		"belly_color": Color(0.55, 0.92, 0.55),
		"beak_color": Color(1.0, 0.75, 0.2),
		"wing_color": Color(0.12, 0.48, 0.2),
		"beak_length": 8,
		"beak_width": 6,
		"body_width": 38,
		"body_height": 28,
		"head_radius": 14,
		"crest": true,
		"crest_color": Color(0.1, 0.45, 0.2),
		"fatness": 1.0,
	},
	"desert": {
		"name": "沙漠角鸟",
		"body_color": Color(0.72, 0.55, 0.35),
		"belly_color": Color(0.88, 0.75, 0.55),
		"beak_color": Color(0.9, 0.6, 0.15),
		"wing_color": Color(0.55, 0.4, 0.22),
		"beak_length": 14,
		"beak_width": 5,
		"body_width": 36,
		"body_height": 30,
		"head_radius": 13,
		"crest": true,
		"crest_color": Color(0.6, 0.4, 0.2),
		"fatness": 0.9,
	},
	"ocean": {
		"name": "海蓝鸥",
		"body_color": Color(0.85, 0.9, 0.95),
		"belly_color": Color(0.95, 0.97, 1.0),
		"beak_color": Color(1.0, 0.55, 0.1),
		"wing_color": Color(0.6, 0.7, 0.85),
		"beak_length": 12,
		"beak_width": 5,
		"body_width": 40,
		"body_height": 24,
		"head_radius": 12,
		"crest": false,
		"crest_color": Color.BLACK,
		"fatness": 0.8,
	},
	"city": {
		"name": "城市灰雀",
		"body_color": Color(0.5, 0.5, 0.55),
		"belly_color": Color(0.7, 0.7, 0.75),
		"beak_color": Color(0.95, 0.75, 0.25),
		"wing_color": Color(0.35, 0.35, 0.4),
		"beak_length": 6,
		"beak_width": 7,
		"body_width": 34,
		"body_height": 32,
		"head_radius": 15,
		"crest": false,
		"crest_color": Color.BLACK,
		"fatness": 1.2,
	},
	"snow": {
		"name": "雪山团子",
		"body_color": Color(0.9, 0.92, 0.95),
		"belly_color": Color(1.0, 1.0, 1.0),
		"beak_color": Color(1.0, 0.65, 0.2),
		"wing_color": Color(0.8, 0.82, 0.88),
		"beak_length": 7,
		"beak_width": 5,
		"body_width": 42,
		"body_height": 34,
		"head_radius": 15,
		"crest": false,
		"crest_color": Color.BLACK,
		"fatness": 1.4,
	},
}

## Default species when no classification has been done
const DEFAULT_ENVIRONMENT = "forest"

## Returns the species data for a given environment key
static func get_species(environment: String) -> Dictionary:
	if SPECIES.has(environment):
		return SPECIES[environment]
	return SPECIES[DEFAULT_ENVIRONMENT]

## Returns all available environment keys
static func get_all_environments() -> Array:
	var keys = []
	for k in SPECIES:
		keys.append(k)
	return keys
