extends Node

var score: int = 0
var sala_atual: int = 1

func adicionar_pontos(valor: int) -> void:
	score += valor

func resetar() -> void:
	score = 0
	sala_atual = 1
