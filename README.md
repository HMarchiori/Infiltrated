
## Primeira Entrega (22/05)
##### Criar a primeira fase
- Criar estrutura de nós para jogador, inimigo e disparos
- Criar lógica básica de movimentação com WASD (8 direções)
- Criar lógica de disparo de inimigos
- Criar contador de quantos inimigos restam
- Definir quando fase encerrou para spawnar o portal de saída
- Criar uma segunda sala qualquer só para confirmar que a troca funciona


## Arquitetura do Projeto (Godot)

### Conceito básico

No Godot, tudo é construído com **nodos**. Um nodo é a menor unidade do jogo — cada um faz uma coisa só. Uma **cena** é um grupo de nodos salvos juntos num arquivo `.tscn`, que pode ser reutilizado em qualquer parte do projeto.

### Estrutura de Cenas

```
Game.tscn                  ← raiz da run, "cola" de tudo
├── RoomManager (Node)     ← instancia e destrói salas
├── HUD (CanvasLayer)      ← score e UI, fica colado na tela
└── Player (instância)     ← o João

Room.tscn                  ← base para todas as salas
├── TileMapLayer           ← chão e paredes em tiles
├── EnemySpawner (Node)    ← spawna os inimigos da sala
├── SpawnPoint (Marker2D)  ← posição inicial do jogador
└── PortalSpawn (Marker2D) ← onde o portal de saída aparece ao limpar a sala

Player.tscn
└── CharacterBody2D        ← nodo raiz: anda e colide
    ├── Sprite2D            ← imagem do João
    ├── CollisionShape2D    ← corpo invisível que bate nas paredes
    ├── CameraWeapon (Node) ← lógica da arma câmera
    ├── Hurtbox (Area2D)    ← detecta dano recebido
    └── Camera2D            ← câmera que segue o jogador

Enemy.tscn
└── CharacterBody2D
    ├── Sprite2D
    ├── CollisionShape2D
    ├── StateMachine (Node) ← Idle / Chase / Attack
    └── Hurtbox (Area2D)   ← detecta dano recebido

Projectile.tscn
└── Area2D                 ← detecta colisão com Hurtbox
    ├── Sprite2D
    └── CollisionShape2D

PortalSaida.tscn           ← spawna ao limpar a sala, leva à próxima
└── Area2D                 ← detecta quando o jogador entra
    ├── Sprite2D
    ├── AnimationPlayer     ← animação de pulsar/brilhar
    └── CollisionShape2D
```

### Nodo raiz por tipo de cena

| Cena | Nodo raiz | Por quê |
|------|-----------|---------|
| Player / Inimigo | `CharacterBody2D` | precisa andar e colidir |
| Sala | `Node2D` | só precisa existir no mundo |
| Projétil / Portal | `Area2D` | só detecta colisão, não anda |
| HUD | `CanvasLayer` | fica fixo na tela, não no mundo |
| Jogo (raiz geral) | `Node2D` | apenas segura o resto |

### Autoloads (Singletons)

Singletons são scripts que ficam sempre vivos durante o jogo inteiro, acessíveis de qualquer cena. Configurados em **Projeto > Configurações do Projeto > Autoload**.

| Singleton | Responsabilidade |
|-----------|-----------------|
| `GameState.gd` | score, sala atual, upgrades acumulados da run |
| `EventBus.gd` | signals globais desacoplados entre cenas |

### Fluxo de uma Run

```
1. Game.tscn carrega          → RoomManager instancia a Sala 1 (Sala de Rituais, sempre fixa)
2. Player spawna no SpawnPoint
3. Combate                    → jogador elimina todos os inimigos
4. EventBus.sala_limpa.emit() → contador de inimigos chega a zero
5. PortalSaida spawna no centro da sala
6. UpgradeScreen              → jogador escolhe 1 de 3 upgrades
7. Jogador passa pelo portal  → RoomManager carrega próxima sala (aleatória)
8. Repete até a Sala 5        → boss final
9. Game over ou vitória
```

### Salas

| Sala | Tipo | Inimigos |
|------|------|----------|
| 1 | Sala de Rituais (sempre fixa) | 6 |
| 2 | Aleatória | 8 |
| 3 | Aleatória | 10 |
| 4 | Aleatória | 12 |
| 5 | Boss | 14 + boss |

### Upgrades (escolha 1 ao concluir cada sala)

- +25% fire rate da câmera
- +20% velocidade de movimento
- +20% dano nos projéteis

Os upgrades acumulam durante a run e resetam ao morrer.

### Pontuação

- +100 pontos por inimigo abatido
- Score exibido no HUD e na tela de vitória/game over

### Movimento do Player (GDScript)

```gdscript
extends CharacterBody2D

var speed = 200

func _physics_process(delta):
    var direcao = Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down")
    )

    velocity = direcao.normalized() * speed
    move_and_slide()
```

### Ordem de implementação sugerida

1. Player se move nas 8 direções
2. Player bate nas paredes
3. Player atira (CameraWeapon)
4. Inimigo aparece na sala e persegue o jogador
5. Inimigo atira no jogador
6. Tiro mata inimigo (Hurtbox + contador)
7. Portal de saída spawna ao zerar inimigos
8. Portal leva para a próxima sala (RoomManager)
9. Tela de upgrade entre salas
10. HUD com score e a tela de game over / vitória

---

## Estrutura de Pastas Sugerida

```
infiltrated/
├── scenes/
│   ├── game/
│   │   ├── Game.tscn
│   │   └── RoomManager.gd
│   ├── player/
│   │   ├── Player.tscn
│   │   └── Player.gd
│   ├── enemies/
│   │   ├── Enemy.tscn
│   │   ├── Capanga.tscn
│   │   └── Lider.tscn
│   ├── rooms/
│   │   ├── Room.tscn
│   │   ├── Sala1Rituais.tscn
│   │   ├── Sala2.tscn
│   │   ├── Sala3.tscn
│   │   ├── Sala4.tscn
│   │   └── Sala5Boss.tscn
│   ├── weapons/
│   │   ├── CameraWeapon.gd
│   │   └── Projectile.tscn
│   ├── portal/
│   │   └── PortalSaida.tscn
│   └── ui/
│       ├── HUD.tscn
│       ├── UpgradeScreen.tscn
│       └── GameOver.tscn
├── scripts/
│   └── autoloads/
│       ├── GameState.gd
│       └── EventBus.gd
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── tilesets/
└── README.md
```
