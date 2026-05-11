

## Primeira Entrega (22/05)
##### Criar a primeira fase
- Criar estrutura de nós para jogador, inimigo e disparos
- Criar lógica básica de movimentação com WASD
- Criar lógica de disparo de inimigos
- Criar contador de quantos inimigos restam
- Definir quando fase encerrou para abrir a porta/portal para nova fase
- Criar uma nova fase com qualquer coisa só para ver se está trocando corretamente.


## Arquitetura do Projeto (Godot)

### Conceito básico

No Godot, tudo é construído com **nodos**. Um nodo é a menor unidade do jogo — cada um faz uma coisa só. Uma **cena** é um grupo de nodos salvos juntos num arquivo `.tscn`, que pode ser reutilizado em qualquer parte do projeto.

### Estrutura de Cenas

```
Game.tscn                  ← raiz da run, "cola" de tudo
├── RoomManager (Node)     ← instancia e destrói salas
├── HUD (CanvasLayer)      ← vida e UI, fica colado na tela
└── Player (instância)     ← o João

Room.tscn                  ← cada sala da mansão
├── TileMapLayer           ← chão e paredes em tiles
├── Doors (Node2D)         ← saídas Norte/Sul/Leste/Oeste
├── EnemySpawner (Node)    ← controla spawn de inimigos
├── PortalPoints (Node2D)  ← posições válidas para portais
└── LootTable (Node)       ← itens dropados ao limpar a sala

Player.tscn
└── CharacterBody2D        ← nodo raiz: anda e colide
    ├── Sprite2D            ← imagem do João
    ├── CollisionShape2D    ← corpo invisível que bate nas paredes
    ├── StatsComponent      ← HP, velocidade, recursos
    ├── CameraWeapon        ← lógica da arma câmera
    ├── PortalWeapon        ← lógica d'O Limiar
    ├── Hurtbox (Area2D)    ← detecta dano recebido
    └── Camera2D            ← câmera que segue o jogador

Enemy.tscn
└── CharacterBody2D
    ├── Sprite2D
    ├── CollisionShape2D
    ├── StateMachine        ← Idle / Chase / Attack
    └── Hurtbox (Area2D)

Portal.tscn
└── Area2D                 ← detecta quando algo entra
    ├── Sprite2D + AnimationPlayer
    ├── CollisionShape2D
    └── @export exit_portal ← referência ao portal de saída
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
| `GameState.gd` | seed da run, score, wave atual |
| `UpgradeManager.gd` | pool de upgrades, lógica de seleção e aplicação |
| `EventBus.gd` | signals globais desacoplados entre cenas |
| `RoomRegistry.gd` | lista de cenas de salas disponíveis para sorteio |

### Fluxo de uma Run

```
1. GameState.new_run(seed)       → gera seed aleatória
2. RoomManager.build_run()       → sorteia e ordena salas do RoomRegistry
3. Room instanciada              → Player spawna na posição inicial
4. Combate                       → jogador limpa a sala
5. EventBus.room_cleared.emit()  → sinal dispara ao matar todos os inimigos
6. UpgradeScreen                 → jogador escolhe 1 de 3 upgrades
7. Próxima sala                  → repete até boss ou game over
```

### Movimento do Player (GDScript)

```gdscript
extends CharacterBody2D

var speed = 200

func _physics_process(delta):
    var direcao = Vector2.ZERO

    if Input.is_action_pressed("ui_right"):
        direcao.x = 1
    if Input.is_action_pressed("ui_left"):
        direcao.x = -1
    if Input.is_action_pressed("ui_up"):
        direcao.y = -1
    if Input.is_action_pressed("ui_down"):
        direcao.y = 1

    velocity = direcao.normalized() * speed
    move_and_slide()
```

### Ordem de implementação sugerida

1. Player se move nas 4 direções
2. Player bate nas paredes
3. Inimigo aparece na sala
4. Player atira
5. Tiro mata inimigo
6. Sala é gerada aleatoriamente
7. Sistema de upgrades
8. HUD e pontuação
9. Mecânica de portais

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
│   │   ├── BaseEnemy.tscn
│   │   ├── Capanga.tscn
│   │   └── Lider.tscn
│   ├── rooms/
│   │   ├── Room.tscn
│   │   ├── RoomCombate01.tscn
│   │   └── RoomBoss.tscn
│   ├── weapons/
│   │   ├── CameraWeapon.tscn
│   │   └── Projectile.tscn
│   └── ui/
│       ├── HUD.tscn
│       └── UpgradeScreen.tscn
├── scripts/
│   └── autoloads/
│       ├── GameState.gd
│       ├── EventBus.gd
│       ├── UpgradeManager.gd
│       └── RoomRegistry.gd
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── tilesets/
└── README.md
```
