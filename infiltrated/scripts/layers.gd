class_name Layers
extends RefCounted

## Named physics collision layers, shared by code that configures masks at
## runtime. Keep in sync with [layer_names] in project.godot.

const ENVIRONMENT := 1 << 0   # walls, decorations, tilemaps
const PLAYER := 1 << 1
const ENEMY := 1 << 2
const PLAYER_PROJECTILE := 1 << 3
const ENEMY_PROJECTILE := 1 << 4
const PICKUP := 1 << 5         # power-ups and the exit portal
