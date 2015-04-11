// Dungeon Romp - a traditional yet simple browser-based roguelike
// 2011-09-12 Felix Pleșoianu <felixp7@yahoo.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Park-Miller RNG - http://en.wikipedia.org/wiki/Park-Miller_RNG
function PMrng(seed) {
	this.seed = seed;
	this.next = function () {
		this.seed = (this.seed * 279470273) % 4294967291;
		return this.seed / 4294967291; // [0, 1)
	};
	this.nextInt = function (limit) {
		this.seed = (this.seed * 279470273) % 4294967291;
		return this.seed % limit; // [0, limit)
	};
	this.pick = function (list) {
		this.seed = (this.seed * 279470273) % 4294967291;
		return list[this.seed % list.length];
	};
}

var DungeonRomp = {
	SPACE: ' '.charCodeAt(0),
	AT: '@'.charCodeAt(0),
	DOT: '.'.charCodeAt(0),
	COMMA: ','.charCodeAt(0),
	VBAR: '|'.charCodeAt(0),
	CARET: '^'.charCodeAt(0),
	TILDA: '~'.charCodeAt(0),
	EQUAL: '='.charCodeAt(0),
	HASH: '#'.charCodeAt(0),
	GT: '>'.charCodeAt(0),
	LT: '<'.charCodeAt(0),
	
	RPAREN: ')'.charCodeAt(0),
	RBRACK: ']'.charCodeAt(0),
	PERCENT: '%'.charCodeAt(0),
	
	action_cost: 5,
	
	compass_dir: ['n', 's', 'e', 'w'],
	armor_slots: ["head", "body", "legs", "feet"],
	
	addToSet: function (set, element) {
		for (var i = 0; i < set.length; i++)
			if (set[i] == element) return;
		set.push(element);
	},
	
	removeFromSet: function (set, element) {
		for (var i = 0; i < set.length; i++)
			if (set[i] == element) set.splice(i, 1);
	},
	
	rollDice: function (num, faces) {
		var roll = 0;
		for (var i = 0; i < num; i++) {
			roll += Math.floor(Math.random() * faces) + 1;
		}
		return roll;
	},
	
	startMessage: [
		"It was the biggest flood you've ever seen.",
		"",
		"Your village... all the life you've even known... drowned.",
		"",
		"Traveled people used to talk of a big city to the east.",
		"",
		"But the way there is neither straight nor easy.",
		"",
		"Welcome to <b>Dungeon Romp</b>!"
	],
	
	helpText: [
		"<b>Dungeon Romp Keyboard Commands</b>",
		"",
		"Arrows or H,J,K,L to move/attack",
		"<b>&gt;</b> - go down (where possible)",
		"<b>&lt;</b> - go up (where possible)",
		"<b>?</b> - shows this page",
		"<b>m</b> - map legend",
		"<b>@</b> - character sheet",
		"<b>w</b> - wearing...",
		"<b>g</b> - get item",
		"<b>i</b> - inventory",
		"<b>e</b> - eat",
		"<b>.</b> - wait"
	],
	
	theEndMessage: [
		"Thanks for playing the Dungeon Romp demo.",
		"Stay tuned for the final version.",
		"",
		"-- Felix Pleșoianu &lt;felixp7@yahoo.com&gt;"
	],
	
	deathMessage: [
		"<b>You have died</b>",
		"",
		"Reload the page to play again."
	],
	
	_log: [],
	
	log: function (message) {
		DungeonRomp._log.push(message);
		while (DungeonRomp._log.length > 1000)
			DungeonRomp._log.shift();
	}
};

DungeonRomp.Terrain = {	forest: { }, cave: { } };
DungeonRomp.Terrain.forest[DungeonRomp.DOT] = {name: "grass"};
DungeonRomp.Terrain.forest[DungeonRomp.COMMA] = {name: "a dirt road"};
DungeonRomp.Terrain.forest[DungeonRomp.VBAR] = {name: "a tree"};
DungeonRomp.Terrain.forest[DungeonRomp.CARET] = {name: "a tree"};
DungeonRomp.Terrain.forest[DungeonRomp.TILDA] = {name: "water"};
DungeonRomp.Terrain.forest[DungeonRomp.EQUAL] = {name: "a wooden plank"};
DungeonRomp.Terrain.forest[DungeonRomp.HASH] = {name: "a cabin wall"};
DungeonRomp.Terrain.forest[DungeonRomp.GT] = {name: "a cave mouth"};
DungeonRomp.Terrain.forest.colorRE = /@|~+|#+|\^+|\|+|s+|=+|,+/g;
DungeonRomp.Terrain.forest.colorFunction =
function (match) { switch (match[0]) {
	case '@': return '<span style="Color: white;">@</span>';
	case '^': return '<span style="Color: green;">' + match + '</span>';
	case '|':
	case '#':
		return '<span style="Color: #a52a2a;">' + match + '</span>';
	case '~': return '<span style="Color: blue;">' + match + '</span>';
	case 's': return '<span style="Color: #0f0;">' + match + '</span>';
	case ',':
	case '=':
		return '<span style="Color: #f0e68c;">' + match + '</span>';
}};

DungeonRomp.Terrain.cave[DungeonRomp.DOT] = {name: "the cave floor"};
DungeonRomp.Terrain.cave[DungeonRomp.HASH] = {name: "the cave wall"};
DungeonRomp.Terrain.cave[DungeonRomp.VBAR] = {name: "a stalagmite"};
DungeonRomp.Terrain.cave[DungeonRomp.LT] = {name: "an exit tunnel"};
DungeonRomp.Terrain.cave[DungeonRomp.TILDA] = {name: "water"};
DungeonRomp.Terrain.cave.colorRE = /@|~+|#+|\|+/g;
DungeonRomp.Terrain.cave.colorFunction =
function (match) { switch (match[0]) {
	case '@': return '<span style="Color: white;">@</span>';
	case '|':
	case '#':
		return '<span style="Color: #404040;">' + match + '</span>';
	case '~': return '<span style="Color: blue;">' + match + '</span>';
}};

DungeonRomp.AI = {
	player: function () {
		if (this.action_queue.length == 0) {
			this.say("You don't know what to do!");
			return;
		}
		var action = this.action_queue.shift();
		switch (action) {
			case 'h': this.walk('w'); break;
			case 'j': this.walk('s'); break;
			case 'k': this.walk('n'); break;
			case 'l': this.walk('e'); break;
			case '>': this.travel('d'); break;
			case '<': this.travel('u'); break;
			case '.': this.wait(); break;
			case 'g': this.take(); break;
			default: throw "Unrecognized command: " + action;
		}
	},
	
	roamer: function () {
		if (!DungeonRomp.AI._player) {
			var c = this.level.content;
			for (var i = 0; i < c.length; i++) {
				var it = c[i];
				if (it.symbol == DungeonRomp.AT) {
					DungeonRomp.AI._player = it;
					break;
				}
			}
		}
		
		var p = DungeonRomp.AI._player;
		if (this.distanceTo(p.x, p.y) == 1) {
			this.attack(p);
		} else {
			var direction =
				DungeonRomp.compass_dir[
					Math.floor(Math.random() * 4)];
			this.walk(direction);
		}
	}
}

DungeonRomp.Levels = [
	{
		name: "Abandoned village",
		generator: "Village",
		terrain: "forest",
		next_level_dir: 'd',
		wrap_around: "horizontal"
	},
	
	{
		name: "Grotto",
		generator: "Cave",
		terrain: "cave",
		prev_level_dir: 'u',
		next_level_dir: 'd'
	},
	
	{
		name: "Cavern",
		generator: "Cave",
		terrain: "cave",
		prev_level_dir: 'u',
		next_level_dir: 'e'
	}
]

DungeonRomp.Foods = {
	berries: {
		symbol: DungeonRomp.PERCENT,
		family: "berries",
		nutrition: 3
	},
	
	shrooms: {
		symbol: DungeonRomp.PERCENT,
		family: "mushrooms",
		nutrition: 5
	},
	
	fungi: {
		symbol: DungeonRomp.PERCENT,
		family: "foxfire fungus",
		nutrition: 5,
		
		light_level: 1,
		
		dps_amount: 1,
		dps_duration: 4,
		dps_effect: "poisoned"
	}
}

DungeonRomp.Weapons = {
	stick: {
		symbol: DungeonRomp.RPAREN,
		family: "stick",
		article: 'a',
		defense_bonus: 1, // It gives you a bit of reach.
		damage_bonus: 2, // Gives you a bit of leverage too.
		slot: "weapon",
		item_level: 1
	}
}

DungeonRomp.Armors = {
	shirt: {
		symbol: DungeonRomp.RBRACK,
		family: "torn shirt",
		article: 'a',
		item_level: 0,
		slot: "body"
	},
	
	sandals: {
		symbol: DungeonRomp.RBRACK,
		family: "wooden sandals",
		item_level: 0,
		slot: "feet"
	},
	
	pants1: {
		symbol: DungeonRomp.RBRACK,
		family: "canvas pants",
		defense_bonus: 2,
		item_level: 1,
		slot: "legs"
	},
	
	boots1: {
		symbol: DungeonRomp.RBRACK,
		family: "canvas boots",
		defense_bonus: 2,
		item_level: 1,
		slot: "feet"
	},
}

DungeonRomp.Mobs = {
	player: {
		symbol: DungeonRomp.AT,
		family: "human",
		name: "Hero",
		dice_size: 8,
		muscle: 3,
		agility: 3,
		stamina: 3,
		speed: 3,
		senses: 3,
		ai: DungeonRomp.AI.player,
		isEnemy: function () { return true; },
		natural_weapon: { family: "unarmed" },
		equipment: {
			body: DungeonRomp.Armors.shirt,
			feet: DungeonRomp.Armors.sandals
		}
	},
	
	snake: {
		symbol: 's'.charCodeAt(0),
		family: "snake",
		article: 'a',
		mob_level: 1,
		dice_size: 4,
		muscle: 5,
		agility: 5,
		stamina: 2,
		speed: 5,
		can_swim: true,
		ai: DungeonRomp.AI.roamer,
		say: function () {},
		isEnemy: function (mob) {
			return mob.symbol == DungeonRomp.AT;
		},
		natural_weapon: {
			family: "bite",
			hit_verb: "bites",
			miss_verb: "hisses at",
			
			damage_multiplier: 0,
			dps_amount: 2,
			dps_duration: -1, // Equal to the margin of success.
			dps_effect: "poisoned"
		}
	},
	
	rat: {
		symbol: 'r'.charCodeAt(0),
		family: 'rat',
		article: 'a',
		mob_level: 1,
		dice_size: 4,
		muscle: 5,
		agility: 5,
		stamina: 2,
		speed: 5,
		can_swim: true,
		ai: DungeonRomp.AI.roamer,
		say: function () {},
		isEnemy: function (mob) {
			return mob.symbol == DungeonRomp.AT;
		},
		natural_weapon: {
			family: "bite",
			hit_verb: "bites",
			miss_verb: "snaps at"
		}
	},
	
	bat: {
		symbol: 'b'.charCodeAt(0),
		family: 'vampire bat',
		article: 'a',
		mob_level: 2,
		dice_size: 4,
		muscle: 6,
		agility: 6,
		stamina: 3,
		speed: 6,
		can_fly: true,
		ai: DungeonRomp.AI.roamer,
		say: function () {},
		isEnemy: function (mob) {
			return mob.symbol == DungeonRomp.AT;
		},
		natural_weapon: {
			family: "bite",
			hit_verb: "bites",
			miss_verb: "flutters by"
		}
	},
	
	roach: {
		symbol: 'c'.charCodeAt(0),
		family: 'mutant cockroach',
		article: 'a',
		mob_level: 2,
		dice_size: 4,
		muscle: 5,
		agility: 6,
		stamina: 3,
		speed: 6,
		can_swim: true,
		ai: DungeonRomp.AI.roamer,
		say: function () {},
		isEnemy: function (mob) {
			return mob.symbol == DungeonRomp.AT;
		},
		natural_weapon: {
			family: "bite",
			hit_verb: "bites",
			miss_verb: "lashes at"
		},
		natural_armor: {
			family: "carapace",
			damage_soak: 4
		}
	},
	
	mole: {
		symbol: 'm'.charCodeAt(0),
		family: 'killer mole',
		article: 'a',
		mob_level: 2,
		dice_size: 6,
		muscle: 4,
		agility: 4,
		stamina: 2,
		speed: 4,
		ai: DungeonRomp.AI.roamer,
		say: function () {},
		isEnemy: function (mob) {
			return mob.symbol == DungeonRomp.AT;
		},
		natural_weapon: {
			family: "claws",
			hit_verb: "slashes",
			miss_verb: "rushes"
		}
	}
}

DungeonRomp.Level = function (width, height, name) {
	this.width = width;
	this.height = height;
	this.map = new Array(height);
	this.was_seen = new Array(height);
	this.light_level = 1;
	this.visited = false;

	for (var i = 0; i < height; i++) {
		this.map[i] = new Array(width);
		this.was_seen[i] = new Array(width);
		for (var j = 0; j < width; j++) {
			this.map[i][j] = DungeonRomp.SPACE;
			this.was_seen[i][j] = false;
		}
	}

	this.name = name;
	
	this.terrain = {};
	this.exits = {};
	this.entryPointFrom = {};
	this.content = [];
	
	this.isOnGrid = function (x, y) {
		return x >= 0 && y >= 0 && x < this.width && y < this.height;
	}
	
	this.terrainAt = function (x, y) {
		return this.terrain[this.map[y][x]];
	}
	
	this.itemsAt = function (x, y) {
		var items = [];
		for (var i = 0; i < this.content.length; i++) {
			var thing = this.content[i];
			if (thing.constructor == DungeonRomp.Item)
				if (thing.x == x && thing.y == y)
					items.push(thing);
		}
		return items;
	}
	
	this.mobAt = function (x, y) {
		for (var i = 0; i < this.content.length; i++) {
			var thing = this.content[i];
			if (thing.constructor == DungeonRomp.Mob)
				if (thing.x == x && thing.y == y)
					return thing;
		}
		return null;
	}
	
	this.loopOverMap = function (obj, code) {
		for (var y = 0; y < this.height; y++)
			for (var x = 0; x < this.width; x++)
				code.call(obj, x, y, this.map[y][x]);
	}
}

DungeonRomp.Item = function () {
	this.symbol = '?'.charCodeAt(0);
	this.family = "stuff";
	this.article = null;
	this.name = null;
	
	this.light_level = 0;
	this.portable = true;
	
	this.level = null;
	this.x = 0;
	this.y = 0;

	this.moveTo = function (x, y, parent) {
		if (arguments.length >= 3) {
			if (this.level)
				DungeonRomp.removeFromSet(
					this.level.content, this);
			if (parent)
				DungeonRomp.addToSet(parent.content, this);
			this.level = parent;
		}
		
		if (!this.level) return;

		if (this.level.isOnGrid(x, y)) {
			this.x = x;
			this.y = y;
		} else {
			throw "Can't move outside the level map.";
		}
	}
	
	// Manhattan distance, mind you.
	this.distanceTo = function (x, y) {
		return Math.abs(x - this.x) + Math.abs(y - this.y);
	}
	
	this.displayName = function (indefinite) {
		if (this.name)
			return this.name;
		else if (!indefinite)
			return "the " + this.family;
		else if (this.article)
			return this.article + " " + this.family;
		else
			return this.family;
	}
	
	this.applyTemplate = function (template) {
		for (var i in template) this[i] = template[i];
		return this;
	}
	
	this.toString = function () { return this.name || this.family; }
}

DungeonRomp.Mob = function () {
	DungeonRomp.Item.apply(this);
	this.portable = false;
	
	this.equipment = {};
	this.content = [];
	this.effects = []; // Buffs and debuffs.
	
	this.dice_size = 6;
	this.muscle = 1;
	this.agility = 1;
	this.stamina = 1;
	this.speed = 1;
	this.senses = 1;
	
	this.can_swim = false;
	this.can_fly = false;

	this.hunger = 0;
	this.wounds = 0;
	this.healing_timer = 0;
	
	this.unused_xp = 0;
	
	this.action_queue = [];
	this.action_timer = 0;

	this.notify = function (subject, verb, object) {
		if (object) {
			this.say(subject.displayName()
				+ " " + verb
				+ " " + object.displayName()
				+ ". " + object.displayName()
				+ " is " + object.condition()
				+ "!");
		} else {
			this.say(subject.displayName() + " " + verb + ".");
		}
	}

	// These functions are placeholders! Override as needed.
	this.say = function (message) { alert(message); }
	
	this.isEnemy = function () { return false; }

	this.canEnter = function (x, y) {
		var tile = this.level.map[y][x];
		switch (tile) {
			case DungeonRomp.DOT:
			case DungeonRomp.COMMA:
			case DungeonRomp.EQUAL:
			case DungeonRomp.GT:
			case DungeonRomp.LT:
				return true;
			case DungeonRomp.TILDA:
				return this.can_swim || this.can_fly;
			default:
				return false;
		}
	}

	this.walk = function (direction) {
		if (!this.level) throw "Creature is out of play.";
		var new_x = this.x;
		var new_y = this.y;
		switch (direction) {
			case 'n': new_y -= 1; break;
			case 's': new_y += 1; break;
			case 'e': new_x += 1; break;
			case 'w': new_x -= 1; break;
			default: throw "Invalid compass direction";
		}
		var mob;
		if (!this.level.isOnGrid(new_x, new_y)) {
			this.travel(direction);
		} else if (mob = this.level.mobAt(new_x, new_y)) {
			if (this.isEnemy(mob))
				this.attack(mob);
			else
				this.say("You bump into " + mob.displayName());
		} else if (!this.canEnter(new_x, new_y)) {
			var t = this.level.terrainAt(new_x, new_y);
			if (t && t.name)
				this.say("The way is barred by " + t.name);
			else
				this.say("The way is barred.");
		} else {
			this.x = new_x;
			this.y = new_y;
			this.reportItemsHere();
		}
	}
	
	this.travel = function (direction) {
		var exit = this.level.exits[direction];
		var here = this.level.map[this.y][this.x];
		if (direction == 'd' && here != DungeonRomp.GT) {
			this.say("There is no way down here.");
		} else if (direction == 'u' && here != DungeonRomp.LT) {
			this.say("There is no way up here.");
		} else if (!exit) {
			this.say("You can't go that way.");
		} else if (exit.constructor == DungeonRomp.Level) {
			this.findEntranceAndGo(exit, direction);
		} else if (typeof exit == "function") {
			if (this.symbol == DungeonRomp.AT) {
				this.level.exits[direction] = exit();
				if (this.level.exits[direction])
					this.findEntranceAndGo(
						this.level.exits[direction],
						direction);
			}
		} else {
			throw "Invalid direction or exit.";
		}
	}
	
	this.findEntranceAndGo = function (level, direction) {
		if (level.entryPointFrom[direction]) {
			this.moveTo(
				level.entryPointFrom[direction].x,
				level.entryPointFrom[direction].y,
				level);
		} else {
			var new_x, new_y;
			switch (direction) {
				case 'u':
				case 'd':
					new_x = this.x;
					new_y = this.y;
					break;
				case 'n':
					new_x = this.x;
					new_y = level.height - 1;
					break;
				case 's':
					new_x = this.x;
					new_y = 0;
					break;
				case 'e':
					new_x = 0;
					new_y = this.y;
					break;
				case 'w':
					new_x = level.width - 1;
					new_y = this.y;
					break;
				default:
					throw "Invalid direction";
			}
			this.moveTo(new_x, new_y, level);
		}
		if (!this.level.visited) {
			this.unused_xp++;
			this.level.visited = true;
		}
	}
	
	this.attack = function (mob) {
		if (this.distanceTo(mob) > 1) {
			this.say("Too far away.");
		} else {
			var attack_roll = this.rollAttackAgainst(mob);
			var defense_roll = mob.rollDefenseAgainst(this);
			DungeonRomp.log(
				this.displayName()
				+ " rolls " + attack_roll + "; "
				+ mob.displayName()
				+ " rolls " + defense_roll + "; ");
			if (attack_roll > defense_roll) {
				var margin = attack_roll - defense_roll;
				mob.applyDamageFrom(this, margin);

				mob.notify(this, this.hitVerb(), mob);
				this.notify(this, this.hitVerb(), mob);
			} else {
				mob.notify(this, this.missVerb(), mob);
				this.notify(this, this.missVerb(), mob);
			}
		}
	}
	
	this.rollAttackAgainst = function (defender) {
		var roll = DungeonRomp.rollDice(this.agility, this.dice_size);
		if (this.hunger > this.dice_size)
			roll -= (this.hunger - this.dice_size);
		return roll + this.weapon().attack_bonus;
	}
	
	this.rollDefenseAgainst = function (attacker) {
		var roll = DungeonRomp.rollDice(this.speed, this.dice_size);
		if (this.hunger > this.dice_size)
			roll -= (this.hunger - this.dice_size);
		return roll + this.weapon().defense_bonus
			+ this.armorDefenseBonus();
	}
	
	this.applyDamageFrom = function (attacker, margin) {
		if (attacker.equipment.weapon)
			var weapon = attacker.equipment.weapon;
		else
			var weapon = attacker.natural_weapon;
		if (weapon.damage_multiplier > 0) {
			var damage = margin
				* weapon.damage_multiplier
				+ weapon.damage_bonus;
			damage += attacker.muscle * attacker.dice_size;
			damage -= this.muscle * this.dice_size;
			damage -= this.armorDamageSoak();
			if (damage > 0) this.wounds += damage;

			DungeonRomp.log(
				attacker.displayName()
				+ " hits " + this.displayName()
				+ " for " + damage + " damage.");
		}
		this.applyDPSfrom(weapon, margin);
	}
	
	this.applyDPSfrom = function (item, margin) {
		if (item.dps_amount > 0) {
			if (item.dps_duration == -1)
				var duration = margin;
			else
				var duration = item.dps_duration;
			this.effects.push({
				effect: item.dps_effect,
				turns_left: duration,
				wounds: item.dps_amount
			});

			DungeonRomp.log(
				this.displayName() + " is now "
				+ item.dps_effect + ".");
		}
	}
	
	this.healNaturally = function () {
		if (this.wounds == 0) return;
		this.healing_timer += this.stamina;
		if (this.healing_timer >= this.dice_size) {
			this.wounds -= 1;
			if (this.wounds < 0) this.wounds = 0;
			if (this.hunger < this.dice_size * this.stamina)
				this.hunger++;
			this.healing_timer -= this.dice_size;
			this.notify(this, "heals some");
		}
	}
	
	this.handleEffects = function () {
		for (var i = 0; i < this.effects.length; i++) {
			var e = this.effects[i];
			if (e.turns_left > 0) {
				this.wounds += e.wounds;
				e.turns_left--;
			} else {
				this.effects.splice(i, 1);
				i--;
			}
		}
	}
	
	this.getTurn = function () {
		this.action_timer += DungeonRomp.action_cost;
		if (this.action_timer >= this.speed * this.dice_size) {
			this.action_timer -= this.speed * this.dice_size;
			return false;
		} else {
			return true;
		}
	}
	
	this.loopItemsHere = function (process) {
		var items = this.level.content;
		for (var i = 0; i < items.length; i++) {
			var item = items[i];
			if (this.x == item.x && this.y == item.y)
				if (item != this) process.call(this, item);
		}
	}
	
	this.reportItemsHere = function () {
		this.loopItemsHere(function (item) {
			this.say("You see " + item.displayName(true) + ".");
		});
	}
	
	this.wait = function () {
		this.say("You wait. Time passes...");
	}
	
	this.take = function () {
		var taken = 0;
		this.loopItemsHere(function (item) {
			taken++;
			if (item.constructor == DungeonRomp.Armor) {
				this.keepBetterEquipment(item);
			} else if (item.constructor == DungeonRomp.Weapon) {
				this.keepBetterEquipment(item);
			} else if (item.portable) {
				item.moveTo(-1, -1, this);
				this.say("You pick up "
					+ item.displayName() + ".");
			} else {
				taken--;
			}
		});
		if (taken == 0) this.say("There's nothing portable here!");
	}
	
	this.keepBetterEquipment = function (item) {
		var eqpt = this.equipment;
		item.moveTo(-1, -1, null);
		if (!eqpt[item.slot]) {
			eqpt[item.slot] = item;
			this.say("You equip " + item.displayName(true) + ".");
		} else if (eqpt[item.slot].item_level >= item.item_level) {
			this.say("You discard " + item.displayName()
				+ " as you already have something better.");
		} else {
			this.say("You replace your " + eqpt[item.slot]
				+ " with " + item.displayName(true) + ".");
			eqpt[item.slot] = item;
		}
	}
	
	this.eat = function (index) {
		if (index >= 0 && index < this.content.length) {
			if (this.hunger == 0) {
				this.say("But you're not hungry!");
			} else if (this.content[index].nutrition > 0) {
				this.say("You eat "
					+ this.content[index].displayName()
					+ ". Mmm!");
				this.hunger -= this.content[index].nutrition;
				if (this.hunger < 0) hunger = 0;
				this.applyDPSfrom(this.content[index]);
				this.content.splice(index, 1);
			} else {
				this.say(this.content[index].displayName()
					+ "isn't edible!");
			}
		}
	}
	
	this.upgradeAttr = function (index) {
		if (this.unused_xp <= 0) return false;
		var attributes =
			["muscle", "stamina", "agility", "speed", "senses"];
		if (index < 0 || index >= attributes.length) {
			index = Math.floor(Math.random() * attributes.length);
		}
		this[attributes[index]]++;
		this.unused_xp--;
		return true;
	}
	
	this.isOnGrid = function (x, y) { return true; } // For taking objects.
	
	this.isDead = function () {
		return this.wounds >= (this.stamina * this.dice_size);
	}
	
	this.condition = function () {
		var life = this.dice_size * this.stamina;
		if (this.wounds == 0)
			return "unharmed";
		else if (this.wounds <= this.stamina)
			return "bruised";
		else if (this.isDead())
			return "dead";
		else if (this.wounds >= (life - this.dice_size))
			return "badly hurt";
		else
			return "hurt";
	}
	
	this.weapon = function () {
		if (this.equipment.weapon)
			return this.equipment.weapon;
		else
			return this.natural_weapon;
	}
	
	this.hitVerb = function () {
		if (this.equipment.weapon)
			return this.equipment.weapon.hit_verb;
		else
			return this.natural_weapon.hit_verb;
	}
	
	this.missVerb = function () {
		if (this.equipment.weapon)
			return this.equipment.weapon.miss_verb;
		else
			return this.natural_weapon.miss_verb;
	}
	
	this.armorDefenseBonus = function () {
		var slots = DungeonRomp.armor_slots;
		var bonus = 0;
		for (var i = 0; i < slots.length; i++)
			if (this.equipment[slots[i]])
				bonus += this.equipment[slots[i]].defense_bonus;
		if (this.natural_armor)
			bonus += this.natural_armor.defense_bonus;
		return bonus;
	}
	
	this.armorDamageSoak = function () {
		var slots = DungeonRomp.armor_slots;
		var bonus = 0;
		for (var i = 0; i < slots.length; i++)
			if (this.equipment[slots[i]])
				bonus += this.equipment[slots[i]].damage_soak;
		if (this.natural_armor)
			bonus += this.natural_armor.damage_soak;
		return bonus;
	}
	
	this.visibleArea = function () {
		if (!this.level) throw "Creature is out of play.";
		
		var radius = this.viewRadius();
		
		var x1 = Math.max(this.x - radius, 0);
		var y1 = Math.max(this.y - radius, 0);
		var x2 = Math.min(this.x + radius, this.level.width - 1);
		var y2 = Math.min(this.y + radius, this.level.height - 1);
		return [x1, y1, x2, y2];
	}
	
	this.viewRadius = function () {
		var my_light = 0;
		for (var i = 0; i < this.content.length; i++)
			if (this.content[i].light_level > my_light)
				my_light = this.content[i].light_level;
		
		if (this.level.light_level <= 0)
			return 1 + my_light;
		else if (this.level.light_level == 1)
			return this.senses + my_light;
		else if (this.level.light_level >= 2)
			return this.senses * 2;
	}
	
	this.applyTemplate = function (template) {
		for (var i in template) this[i] = template[i];
		if (template.natural_weapon) {
			this.natural_weapon = new DungeonRomp.Weapon();
			this.natural_weapon.applyTemplate(
				template.natural_weapon);
		}
		if (template.natural_armor) {
			this.natural_armor = new DungeonRomp.Armor();
			this.natural_armor.applyTemplate(
				template.natural_armor);
		}
		if (template.equipment) {
			var eqp = template.equipment;
			var slots = DungeonRomp.armor_slots;
			for (var i = 0; i < slots.length; i++) {
				if (eqp[slots[i]]) {
					var armor = new DungeonRomp.Armor();
					armor.applyTemplate(eqp[slots[i]]);
					this.equipment[slots[i]] = armor;
				}
			}
			if (eqp.weapon) {
				var weapon = new DungeonRomp.Weapon();
				weapon.applyTemplate(eqp.weapon);
				this.equipment.weapon = weapon;
			}
		}
		return this;
	}
}

DungeonRomp.Weapon = function () {
	DungeonRomp.Item.apply(this);

	this.hit_verb = "strikes";
	this.miss_verb = "swings at";
	
	this.attack_bonus = 0;
	this.defense_bonus = 0;
	this.damage_bonus = 0;
	this.damage_multiplier = 1;
	
	this.dps_amount = 0;
	this.dps_duration = 0;
	this.dps_effect = "";
}

DungeonRomp.Armor = function () {
	DungeonRomp.Item.apply(this);
	
	this.defense_bonus = 0;
	this.damage_soak = 0;
	this.slot = null;
}

DungeonRomp.thingFactory = function () {
	this.mkMob = function (tplname) {
		var mob = new DungeonRomp.Mob();
		return mob.applyTemplate(DungeonRomp.Mobs[tplname]);
	}
	this.mkFood = function (tplname) {
		var food = new DungeonRomp.Item();
		return food.applyTemplate(DungeonRomp.Foods[tplname]);
	}
	this.mkWeapon = function (tplname) {
		var weapon = new DungeonRomp.Weapon();
		return weapon.applyTemplate(DungeonRomp.Weapons[tplname]);
	}
	this.mkArmor = function (tplname) {
		var armor = new DungeonRomp.Armor();
		return armor.applyTemplate(DungeonRomp.Armors[tplname]);
	}
}

DungeonRomp.LevelGen = {};
DungeonRomp.LevelGen.Village = function (rng) {
	this.rng = rng;
	this.road_coords = [];
	
	this.populate = function (level) {
		level.light_level = 2;
		
		var w = level.width;
		var h = level.height;
		
		for (var x = 0; x < w; x++)
			for (var y = 0; y < h; y++)
				level.map[y][x] = DungeonRomp.DOT;

		this.makeTrees(level);
		this.makeRoad(level);
		this.makeRiver(level);
		this.placeBuildings(level);
		this.placeWildlife(level);
		this.placeItems(level);
	}
	
	this.makeTrees = function (level) {
		var w = level.width;
		var h = level.height;
		var size = w * h;
		
		for (var i = 0; i < size * 0.2; i++) {
			var position = this.rng.nextInt(size);
			var x = position % w;
			var y = Math.floor(position / w);
			if (position % 2 == 0)
				var tree = DungeonRomp.VBAR;
			else
				var tree = DungeonRomp.CARET;
			level.map[y][x] = tree;
		}
	}
	
	this.makeRoad = function (level) {
		var w = level.width;
		var h = level.height;
		
		var y = Math.floor(h * 0.5) - 1;
		
		for (var x = 0; x < w; x++) {
			level.map[y][x] = DungeonRomp.COMMA;
			level.map[y + 1][x] = DungeonRomp.COMMA;
			
			this.road_coords[x] = y;
			
			if (y <= 3)
				y += this.rng.pick([0, 0, 0, 0, 0, 0, 1]);
			else if (y >= h - 3)
				y += this.rng.pick([-1, 0, 0, 0, 0, 0, 0]);
			else
				y += this.rng.pick([-1, 0, 0, 0, 0, 0, 1]);
		}
	}
	
	this.makeRiver = function (level) {
		var w = level.width;
		var h = level.height;
		
		var x = Math.floor(w * 0.4);
		
		for (var y = 0; y < h; y++) {
			if (level.map[y][x] == DungeonRomp.COMMA)
				level.map[y][x] = DungeonRomp.EQUAL;
			else
				level.map[y][x] = DungeonRomp.TILDA;
			var delta_x = this.rng.nextInt(3);
			if (delta_x == 2) delta_x = 1;
			x += delta_x;
		}
	}
	
	this.placeBuildings = function (level) {
		var w = level.width;
		
		// West of the river.
		this.placeBuildingCluster(level, w * 0.1, w * 0.4);
		// East of the river.
		this.placeBuildingCluster(level, w * 0.6, w * 0.9);
	}
	
	this.placeBuildingCluster = function (level, from, to) {
		var h = level.height;

		var x = from;
		while (x < to) {
			var radius = this.rng.nextInt(2) + 1;
			x += radius;
			var road_y = this.road_coords[x];
			if (road_y < h * 0.5)
				var y = road_y + h * 0.4;
			else
				var y = road_y - h * 0.4;
			this.makeBuilding(level, x, y, radius);
			x += radius + 4;
		}
	}
	
	this.makeBuilding = function (level, x, y, radius) {
		for (var i = x - radius; i <= x + radius; i++) {
			for (var j = y - radius; j <= y + radius; j++) {
				level.map[j][i] = DungeonRomp.HASH;
			}
		}
		// Make a door and clear the space in front of it.
		if (y < level.height * 0.5) {
			level.map[y + radius][x] = DungeonRomp.DOT;
			level.map[y + radius + 1][x] = DungeonRomp.DOT;
		} else {
			level.map[y - radius][x] = DungeonRomp.DOT;
			level.map[y - radius - 1][x] = DungeonRomp.DOT;
		}
		
		if (radius == 1) {
			level.map[y][x] = DungeonRomp.GT;
			return;
		}
		
		radius -= 1;
		for (var i = x - radius; i <= x + radius; i++) {
			for (var j = y - radius; j <= y + radius; j++) {
				level.map[j][i] = DungeonRomp.EQUAL;
			}
		}
	}
	
	this.placeWildlife = function (level) {
		level.loopOverMap(this, function (x, y, tile) {
			if (tile == DungeonRomp.DOT) {
				if (this.rng.next() < 0.02)
					this.mkMob("snake")
						.moveTo(x, y, level);
			} else if (tile == DungeonRomp.EQUAL) {
				if (this.rng.next() < 0.2)
					this.mkMob("rat")
						.moveTo(x, y, level);
			}
		});
	}
	
	this.placeItems = function (level) {
		level.loopOverMap(this, function (x, y, tile) {
			if (tile != DungeonRomp.DOT) return;
			var roll = this.rng.next();
			if (roll < 0.0011)
				this.mkFood("shrooms").moveTo(x, y, level);
			else if (roll < 0.0066)
				this.mkFood("berries").moveTo(x, y, level);
			else if (roll < 0.01)
				this.mkWeapon("stick").moveTo(x, y, level);
		});

		level.loopOverMap(this, function (x, y, tile) {
			if (tile != DungeonRomp.EQUAL) return;
			var roll = this.rng.next();
			if (roll < 0.05)
				this.mkArmor("pants1").moveTo(x, y, level);
			else if (roll < 0.1)
				this.mkArmor("boots1").moveTo(x, y, level);
		});
	}
}
DungeonRomp.thingFactory.apply(DungeonRomp.LevelGen.Village.prototype);

DungeonRomp.LevelGen.Cave = function (rng, prev_level) {
	this.rng = rng;
	this.prev_level = prev_level;
	
	this.entrances = [];
	
	this.populate = function (level) {
		if (level.number >= 3)
			level.light_level = 0;
		
		var w = level.width;
		var h = level.height;
		
		for (var x = 0; x < w; x++)
			for (var y = 0; y < h; y++)
				level.map[y][x] = DungeonRomp.HASH;

		this.placeStairsUp(level);
		if (this.next_level_dir == 'd')
			this.placeStairsDown(level);
		else if (this.next_level_dir == 'e')
			this.placeTunnelEast(level);
		else
			throw "Invalid next level direction.";

		this.makeWater(level);
		if (level.number <= 2)
			this.placeShallowWildlife(level);
		else
			this.placeDeepWildlife(level);
		this.placeItems(level);
	}
	
	this.placeStairsUp = function (level) {
		if (this.prev_level) {
			// Assume previous level is the same size.
			this.prev_level.loopOverMap(this, function (x, y, tile) {
				if (tile == DungeonRomp.GT) {
					level.map[y][x] = DungeonRomp.LT;
					this.digRoomFrom(x, y, level);
					this.entrances.push([x, y]);
				}
			});
		} else {
			throw "Previous level needed for generation.";
		}
	}
	
	this.digRoomFrom = function (x, y, level) {
		var halfw = level.width * 0.5;
		var halfh = level.height * 0.5;
		
		for (var i = 0; i < halfh; i++) {
			var new_x = x;
			var new_y = y;
			for (var j = 0; j < halfw; j++) {
				var direction =
					this.rng.pick(
						DungeonRomp.compass_dir);
				switch (direction) {
					case 'n': new_y -= 1; break;
					case 's': new_y += 1; break;
					case 'e': new_x += 1; break;
					case 'w': new_x -= 1; break;
					default: throw "Invalid compass direction";
				}
				if (!this.advanceCorridor(new_x, new_y, level))
					break;
				if (direction == 'e') {
					new_x += 1;
					if (!this.advanceCorridor(
						new_x, new_y, level))
							break;
				} else if (direction == 'w') {
					new_x -= 1;
					if (!this.advanceCorridor(
						new_x, new_y, level))
							break;
				}
			}
		}
	}
	
	this.advanceCorridor = function (x, y, level) {
		if (x <= 0 || x >= level.width - 1
			|| y <= 0 || y >= level.height - 1)
				return false;
		if (level.map[y][x] == DungeonRomp.HASH)
			level.map[y][x] = DungeonRomp.DOT;
		return true;
	}
	
	this.makeWater = function (level) {
		var min_x = 1;
		var min_y = 1;
		var max_x = level.width - 2;
		var max_y = level.height - 2;
		
		var water_tiles = [];
		for (var y = min_y; y <= max_y; y++) {
			for (var x = min_x; x <= max_x; x++) {
				if (level.map[y][x] != DungeonRomp.HASH)
					continue;
				if (this.countNeighborTiles(
					x, y, level, DungeonRomp.HASH) < 5)
						water_tiles.push([x, y]);
			}
		}
		for (i = 0; i < water_tiles.length; i++) {
			var x = water_tiles[i][0];
			var y = water_tiles[i][1];
			level.map[y][x] = DungeonRomp.TILDA;
		}
	}
	
	this.countNeighborTiles = function (x, y, level, kind) {
		var count = 0;
		for (var i = y - 1; i <= y + 1; i++) {
			for (var j = x - 1; j <= x + 1; j++) {
				if (level.map[i][j] == kind) count++;
			}
		}
		return count;
	}
	
	this.placeShallowWildlife = function (level) {
		level.loopOverMap(this, function (x, y, tile) {
			if (tile != DungeonRomp.DOT) return;
			var roll = this.rng.next();
			if (roll < 0.01)
				this.mkMob("rat").moveTo(x, y, level);
			else if (roll < 0.02)
				this.mkMob("bat").moveTo(x, y, level);
			else if (roll < 0.03)
				this.mkMob("roach").moveTo(x, y, level);
		});
	}
	
	this.placeDeepWildlife = function (level) {
		level.loopOverMap(this, function (x, y, tile) {
			if (tile != DungeonRomp.DOT) return;
			var roll = this.rng.next();
			if (roll < 0.01)
				this.mkMob("mole").moveTo(x, y, level);
			else if (roll < 0.02)
				this.mkMob("roach").moveTo(x, y, level);
		});
	}

	this.placeItems = function (level) {
		level.loopOverMap(this, function (x, y, tile) {
			if (tile != DungeonRomp.DOT) return;
			var roll = this.rng.next();
			if (roll < 0.005)
				this.mkFood("shrooms").moveTo(x, y, level);
			else if (roll < 0.01)
				this.mkFood("fungi").moveTo(x, y, level);
		});
	}
	
	this.placeStairsDown = function (level) {
		if (this.entrances.length == 0) {
			throw "Assertion failed: no entrances to level?";
		} else if (this.entrances.length == 1) {
			this.entrances.unshift([0, 0]);
			this.entrances.push(
				[level.width - 1, level.height - 1]);
		}
		
		for (var i = 0; i < this.entrances.length - 1; i++) {
			var x1 = this.entrances[i][0];
			var y1 = this.entrances[i][1];
			var x2 = this.entrances[i + 1][0];
			var y2 = this.entrances[i + 1][1];
			var mean_x = Math.round((x1 + x2) / 2);
			var mean_y = Math.round((y1 + y2) / 2);
			
			// If it's already connected, don't bother digging.
			if (level.map[mean_y][mean_x] != DungeonRomp.DOT)
				this.digRoomFrom(mean_x, mean_y, level);
			level.map[mean_y][mean_x] = DungeonRomp.GT;
		}
	}
	
	this.placeTunnelEast = function (level) {
		var last_stairs = this.entrances[this.entrances.length - 1];
		var x = last_stairs[0];
		var y = last_stairs[1];
		
		for (var x = 0; x < level.width; x++) {
			level.map[y][x] = DungeonRomp.DOT;
			level.map[y + 1][x] = DungeonRomp.DOT;
			
			if (y <= 3)
				y += this.rng.pick([0, 0, 0, 0, 0, 0, 1]);
			else if (y >= level.height - 3)
				y += this.rng.pick([-1, 0, 0, 0, 0, 0, 0]);
			else
				y += this.rng.pick([-1, 0, 0, 0, 0, 0, 1]);
		}
	}
}
DungeonRomp.thingFactory.apply(DungeonRomp.LevelGen.Cave.prototype);

DungeonRomp.GameWorld = function () {
	var seed = Math.floor(Math.random() * 2000000000);
	this.rng = new PMrng(seed);
	DungeonRomp.log("You are playing game #" + seed + ".");

	this.the_end = false;
	this.levels = [];
	this.player = new DungeonRomp.Mob();
	this.player.applyTemplate(DungeonRomp.Mobs.player);

	this.createLevelNumber = function (number) {
		if (number >= DungeonRomp.Levels.length) {
			this.the_end = true;
			return false;
		}
		var template = DungeonRomp.Levels[number];
		var level = new DungeonRomp.Level(80, 20, template.name);
		level.terrain = DungeonRomp.Terrain[template.terrain];
		level.number = number + 1;
		
		var generator =
			new DungeonRomp.LevelGen[template.generator](
				this.rng, this.levels[number - 1]);
		generator.next_level_dir = template.next_level_dir;
		generator.prev_level_dir = template.prev_level_dir;
		generator.populate(level);
		
		if (template.next_level_dir) {
			var bind = function(obj, fn, arg) {
				return function ()
					{ return fn.call(obj, arg); };
			}
			level.exits[template.next_level_dir] =
				bind(this, this.createLevelNumber, number + 1);
		}
		
		if (template.prev_level_dir) {
			level.exits[template.prev_level_dir] =
				this.levels[number - 1];
		}
		
		if (template.wrap_around) {
			if (template.wrap_around != "vertical") {
				level.exits.e = level.exits.w = level;
			}
			if (template.wrap_around != "horizontal") {
				level.exits.n = level.exits.s = level;
			}
		}

		return this.levels[number] = level;
	}

	this.createLevelNumber(0);
	this.levels[0].visited = true;
	this.player.moveTo(0, 10, this.levels[0]);
	
	this.update = function () {
		var mobs = this.player.level.content;
		while (this.player.action_queue.length > 0) {
			for (var i = 0; i < mobs.length; i++) {
				if (mobs[i].constructor != DungeonRomp.Mob) {
					continue;
				} else if (mobs[i].ai && mobs[i].getTurn()) {
					mobs[i].ai();
				}
			}
			for (var i = 0; i < mobs.length; i++) {
				if (mobs[i].constructor != DungeonRomp.Mob) {
					continue;
				} else if (mobs[i].isDead()) {
					mobs.splice(i, 1);
					i--;
				} else {
					mobs[i].handleEffects();
					mobs[i].healNaturally();
				}
			}
		}
		this.updateSeen();
	}
	
	this.updateSeen = function () {
		var visible = this.player.visibleArea();
		var was_seen = this.player.level.was_seen;
		for (var x = visible[0]; x <= visible[2]; x++)
			for (var y = visible[1]; y <= visible[3]; y++)
				was_seen[y][x] = true;
	}
}

DungeonRomp.Renderer = function (model, container) {
	this.model = model;
	this.container = container;

	if (this.container.style.position != "absolute")
		this.container.style.position = "relative";
	this.statusLine = document.createElement("div");
	container.appendChild(this.statusLine);
	this.statusLine.style.height = "1em";
	this.mapDisplay = document.createElement("pre");
	this.mapDisplay.style.overflow = "hidden";
	container.appendChild(this.mapDisplay);
	this.messageBox = document.createElement("div");
	container.appendChild(this.messageBox);
	this.messageBox.style.height = "4em";
	this.messageBox.style.overflow = "hidden";
	this.helpLine = document.createElement("div");
	container.appendChild(this.helpLine);
	
	this.dialogue = document.createElement("pre");
	this.dialogue.style.position = "absolute";
	this.dialogue.style.top = "5em";
	this.dialogue.style.left = "10ex";
	this.dialogue.style.background = "inherit";
	this.dialogue.style.padding = "1ex";
	this.dialogue.style.display = "none";
	this.dialogue.style.overflow = "hidden";
	this.container.appendChild(this.dialogue);
	
	this.color = true;
	
	this.messages = [];
	var msgs = this.messages;
	this.model.player.say = function (message) {
		msgs.push(message);
		while (msgs.length > 3) msgs.shift();
	}
	
	this.render = function () {
		this.renderMap();
		this.renderStatus();
		this.renderMessages();
		this.renderHelpLine();
		if (this.model.the_end) {
			this.showDialogue(DungeonRomp.theEndMessage);
		} else if (this.model.player.isDead()) {
			this.showDialogue(DungeonRomp.deathMessage);
		} else if (this.model.player.unused_xp > 0) {
			this.showDialogue(this.attrInventory());
			this.inAttrInventory = true;
		}
	}
	
	this.renderMap = function () {
		var player = this.model.player;
		var level = player.level;

		var buffer = new Array(level.height);
		for (var i = 0; i < buffer.length; i++) {
			buffer[i] = new Array(level.width);
			for (j = 0; j < buffer[i].length; j++) {
				if (player.level.was_seen[i][j])
					buffer[i][j] = level.map[i][j];
				else
					buffer[i][j] = DungeonRomp.SPACE;
			}
		}
		
		var content = level.content;
		var radius = player.viewRadius();
		for (var i = 0; i < content.length; i++) {
			if (content[i].constructor == DungeonRomp.Mob)
				continue; // Draw items first.
			var x = content[i].x;
			var y = content[i].y;
			if (player.distanceTo(x, y) <= radius)
				buffer[y][x] = content[i].symbol;
		}
		for (var i = 0; i < content.length; i++) {
			if (content[i].constructor != DungeonRomp.Mob)
				continue; // Draw only mobs in second pass.
			var x = content[i].x;
			var y = content[i].y;
			if (player.distanceTo(x, y) <= radius)
				buffer[y][x] = content[i].symbol;
		}
		
		var viewport = "";
		for (var i = 0; i < buffer.length; i++) {
			viewport +=
				String.fromCharCode.apply(null, buffer[i])
				+ "\n";
		}
		if (this.color) {
			this.mapDisplay.innerHTML = viewport.replace(
				level.terrain.colorRE,
				level.terrain.colorFunction);
		} else {
			this.mapDisplay.innerHTML = viewport;
		}
	}
	
	this.renderStatus = function () {
		var player = this.model.player;
		var t = player.level.terrainAt(player.x, player.y);
		
		var status = player.level.name;
		if (t && t.name) status += " - on " + t.name;
		status += " - " + player.condition();
		if (player.hunger >= player.dice_size * player.stamina)
			status += " - starving";
		else if (player.hunger > player.dice_size)
			status += " - hungry";
		for (var i = 0; i < player.effects.length; i++)
			status += " - " + player.effects[i].effect;

		this.statusLine.innerHTML = "<b>" + status + "</b>";
	}
	
	this.renderMessages = function () {
		this.messageBox.innerHTML = this.messages.join("<br>\n");
	}
	
	this.renderHelpLine = function () {
		if (this.dialogue.style.display == "none")
			this.helpLine.innerHTML =
				"<b>Arrows or H,J,K,L to move/attack,"
				+ " ? for help.</b>";
		else
			this.helpLine.innerHTML =
				"<b>Press any key to close dialogue.</b>";
	}
	
	this.showDialogue = function (messages) {
		this.dialogue.innerHTML = messages.join("\n");
		this.dialogue.style.display = "table-cell";
	}
	
	this.inDialogue = function () {
		return this.dialogue.style.display != "none";
	}
	
	this.hideDialogue = function () {
		this.dialogue.style.display = "none";
	}
	
	this.characterSheet = function () {
		var player = this.model.player;
		var life = player.stamina * player.dice_size;
		return [
			"<b>" + player.name + "</b>",
			"",
			"Dice size: " + player.dice_size,
			"",
			"Muscle:    " + player.muscle,
			"Stamina:   " + player.stamina,
			"Agility:   " + player.agility,
			"Speed:     " + player.speed,
			"Senses:    " + player.senses,
			"",
			"Wounds:    " + player.wounds + "/" + life,
			"Hunger:    " + player.hunger + "/" + life,
		];
	}
	
	this.mapLegend = function () {
		var terrain = this.model.player.level.terrain;
		var legend = ["<b>Map legend</b>", ""];
		for (i in terrain) {
			var symbol = String.fromCharCode(i);
			var name = terrain[i].name;
			legend.push("<b>" + symbol + "</b> - " + name);
		}
		return legend;
	}
	
	this.equipmentSheet = function () {
		var player = this.model.player;
		var equipment = player.equipment;
		var eqlist = ["<b>" + player.name + "</b>", ""];
		var slots = DungeonRomp.armor_slots;
		for (var i = 0; i < slots.length; i++) {
			if (equipment[slots[i]])
				eqlist.push(slots[i] + ": "
					+ equipment[slots[i]]
						.displayName(true));
			else
				eqlist.push(slots[i] + ": (bare)");
		}
		eqlist.push("");
		if (equipment.weapon)
			eqlist.push("Weapon: "
				+ equipment.weapon.displayName(true));
		else
			eqlist.push("Weapon: your empty hands");
		return eqlist;
	}
	
	this.inventory = function () {
		var player = this.model.player;
		var items = player.content;
		var inventory = ["<b>You are carrying:</b>", ""];
		for (var i = 0; i < items.length; i++) {
			if (i >= 15) break;
			inventory.push(
				String.fromCharCode(i + 97)
				+ ") "
				+ items[i].displayName(true));
		}
		return inventory;
	}
	
	this.foodInventory = function () {
		var player = this.model.player;
		var items = player.content;
		var inventory = ["<b>Choose what to eat:</b>", ""];
		for (var i = 0; i < items.length; i++) {
			if (i >= 15) break;
			if (!items[i].nutrition) continue;
			inventory.push(
				String.fromCharCode(i + 97)
				+ ") "
				+ items[i].displayName(true));
		}
		inventory.push("", "Press any other key to cancel.");
		return inventory;
	}
	
	this.attrInventory = function () {
		var player = this.model.player;
		var life = player.stamina * player.dice_size;
		return [
			"<b>Choose attribute to upgrade</b>",
			"",
			"a) Muscle  (you have " + player.muscle + ")"
				+ ": how much damage you deal and take",
			"b) Stamina (you have " + player.stamina + ")"
				+ ": how fast you heal; how much you can take",
			"c) Agility (you have " + player.agility + ")"
				+ ": how well you attack",
			"d) Speed   (you have " + player.speed + ")"
				+ ": how fast you move; how well you defend",
			"e) Senses  (you have " + player.senses + ")"
				+ ": how far and how well you notice things",
			"",
			"Press any other key to choose at random."
		];
	}
}

DungeonRomp.Game = function (container) {
	this.model = new DungeonRomp.GameWorld();
	this.renderer = new DungeonRomp.Renderer(this.model, container);
	this.model.updateSeen();
	this.renderer.showDialogue(DungeonRomp.startMessage);
	this.renderer.render();

	var m = this.model;
	var r = this.renderer;

	window.addEventListener("keypress", function (event) {
		var key = String.fromCharCode(
			event.charCode || event.keyCode);

		if (m.the_end || m.player.isDead()) {
			return;
		} else if (r.inDialogue()) {
			if (r.inFoodInventory) {
				m.player.eat(key.charCodeAt(0) - 97);
				r.inFoodInventory = false;
			} else if (r.inAttrInventory) {
				m.player.upgradeAttr(key.charCodeAt(0) - 97);
				r.inAttrInventory = false;
			}
			r.hideDialogue();
			r.render();
			return;
		}

		var is_meta = false;
		switch (key) {
			case 'h':
			case "%":
				m.player.action_queue.push('h');
				break;
			case 'j':
			case "(":
				m.player.action_queue.push('j');
				break;
			case 'k':
			case "&":
				m.player.action_queue.push('k');
				break;
			case 'l':
			case "'":
				m.player.action_queue.push('l');
				break;
			case '>':
				m.player.action_queue.push('>');
				break;
			case '<':
				m.player.action_queue.push('<');
				break;
			case '.':
				m.player.action_queue.push('.');
				break;
			case 'g':
				m.player.action_queue.push('g');
				break;
			case '?':
				r.showDialogue(DungeonRomp.helpText);
				is_meta = true;
				break;
			case '@':
				r.showDialogue(r.characterSheet());
				is_meta = true;
				break;
			case 'w':
				r.showDialogue(r.equipmentSheet());
				is_meta = true;
				break;
			case 'i':
				r.showDialogue(r.inventory());
				is_meta = true;
				break;
			case 'e':
				r.showDialogue(r.foodInventory());
				r.inFoodInventory = true;
				is_meta = true;
				break;
			case 'm':
				r.showDialogue(r.mapLegend());
				is_meta = true;
				break;
			case 'D':
				r.showDialogue(DungeonRomp._log.slice(-15));
				is_meta = true;
				break;
			case 'C':
				r.color = !r.color;
				is_meta = true;
				break;
			default:
				is_meta = true;
		}
		if (!is_meta) m.update();
		r.render();
	}, false);
}
