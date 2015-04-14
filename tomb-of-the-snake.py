#!/usr/bin/env python
# coding=utf-8

# Tomb of the Snake -- a coffeebreak roguelike for the Linux console
# 2015-04-09 Felix Pleșoianu <felix@plesoianu.ro>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

from __future__ import division

import random

import curses
from curses.textpad import rectangle

WHITE = 0
RED = 1
GREEN = 2
BLUE = 3
YELLOW = 4

dirkeys = {
	ord('h'): 'w', ord('j'): 's', ord('k'): 'n', ord('l'): 'e',
	curses.KEY_LEFT: 'w', curses.KEY_DOWN: 's',
	curses.KEY_UP: 'n', curses.KEY_RIGHT: 'e',
}

fxdescs = {"fire": "on fire", "poison": "poisoned"}

traitadjs = {"muscle": "stronger", "stamina": "sturdier",
	"agility": "nimbler", "speed": "faster", "senses": "sharper"}

blurb = [
	"You are lost in the woods.",
	"Dark clouds hang in the sky.",
	"The day has turned to night.",
	"Now you will have to brave the..."
]

title_banner = [
" ______           __          ___  __  __         ____          __      ",
"/_  __/__  __ _  / /    ___  / _/ / /_/ /  ___   / __/__  ___ _/ /_____ ",
" / / / _ \/  ' \/ _ \  / _ \/ _/ / __/ _ \/ -_) _\ \/ _ \/ _ `/  '_/ -_)",
"/_/  \___/_/_/_/_.__/  \___/_/   \__/_//_/\__/ /___/_//_/\_,_/_/\_\\__/ "
]

help_text = [
	"Dive to level 10 of the dungeon",
	"and bring the idol back above the ground.",
	"",
	"Arrow keys or h-j-k-l to move.",
	"< and > to go up/down a level.",
	". to wait.",
	"",
	"? to show instructions during the game.",
	"@ to show the character sheet.",
	"",
	"Click a map square to look at it.",
	"Double-click to shoot."
]

ending_text = [
	"As fresh surface air touches the idol,",
	"its golden shine quickly becomes tarnished.",
	"Vile gasses spew out of the idol. You drop it,",
	"and it tumbles back down the stairs.",
	"The entrance to the catacomb collapses, then...",
	"...the clouds part and the sun comes out!",
	"",
	"You have won!"
]

death_banner = [
"__  __               __                            ___          ____",
"\ \/ /___  __  __   / /_  ____ __   _____     ____/ (_)__  ____/ / /",
" \  / __ \/ / / /  / __ \/ __ `/ | / / _ \   / __  / / _ \/ __  / / ",
" / / /_/ / /_/ /  / / / / /_/ /| |/ /  __/  / /_/ / /  __/ /_/ /_/  ",
"/_/\____/\__,_/  /_/ /_/\__,_/ |___/\___/   \__,_/_/\___/\__,_(_)   "
]

terrain = {
	"village": {
		ord('.'): {"name": "grass", "color": WHITE},
		ord(','): {"name": "a dirt road", "color": YELLOW},
		ord('#'): {"name": "a cabin wall", "color": RED},
		ord('='): {"name": "a wooden plank", "color": YELLOW},
		ord('|'): {"name": "a tree", "color": RED},
		ord('^'): {"name": "a tree", "color": GREEN},
		ord('~'): {"name": "water", "color": BLUE},
		ord('>'): {"name": "a way down", "color": WHITE}
	},
	
	"cave": {
		ord('.'): {"name": "the cave floor", "color": WHITE},
		ord('#'): {"name": "the cave wall", "color": WHITE},
		ord('~'): {"name": "water", "color": BLUE},
		ord('>'): {"name": "a way down", "color": WHITE},
		ord('<'): {"name": "a way up", "color": WHITE}
	},
	
	"tomb": {
		ord('.'): {"name": "the catacomb floor", "color": WHITE},
		ord('#'): {"name": "the catacomb wall", "color": RED},
		ord('|'): {"name": "a pillar", "color": YELLOW},
		ord('+'): {"name": "a stone coffin", "color": WHITE},
		ord('>'): {"name": "a way down", "color": WHITE},
		ord('<'): {"name": "a way up", "color": WHITE}
	}
}

weapons = {
	"stone": {
		"char": "o",
		"color": RED,
		"name": "stone",
		"ammo": 1,
		"weight": 1,
		"damage": 2
	},
	
	"pickaxe": {
		"char": "/",
		"color": BLUE,
		"name": "pickaxe",
		"attack": 1,
		"damage": 4,
		"weight": 6
	},

	"bullet": {
		"char": "o",
		"color": BLUE,
		"name": "sling bullet",
		"ammo": 2,
		"weight": 2,
		"damage": 6
	},
	
	"sword": {
		"char": ")",
		"color": BLUE,
		"name": "short sword",
		"attack": 4,
		"damage": 4,
		"weight": 4
	},
	
	"mace": {
		"char": ")",
		"color": YELLOW,
		"name": "mace",
		"attack": 4,
		"damage": 6,
		"weight": 4
	},
	
	"staff": {
		"char": "/",
		"color": RED,
		"name": "staff",
		"attack": 8,
		"damage": 4,
		"weight": 8
	},
	
	"spear": {
		"char": "/",
		"color": YELLOW,
		"name": "spear",
		"attack": 8,
		"damage": 6,
		"weight": 8
	}
}

armor = {
	"cloth": {
		"char": "[",
		"color": WHITE,
		"name": "thick cloak",
		"armor": 4,
		"weight": 6
	},
	
	"leather": {
		"char": "[",
		"color": RED,
		"name": "leather coat",
		"armor": 6,
		"weight": 8
	},
	
	"chainmail": {
		"char": "]",
		"color": BLUE,
		"name": "chainmail",
		"armor": 8,
		"weight": 10
	},
	
	"scalemail": {
		"char": "]",
		"color": YELLOW,
		"name": "scale mail",
		"armor": 10,
		"weight": 12
	},
	
	"splintmail": {
		"char": "]",
		"color": RED,
		"name": "splint mail",
		"armor": 12,
		"weight": 20
	}
}

shields = {
	"leather": {
		"char": "(",
		"color": RED,
		"name": "leather shield",
		"defense": 4,
		"weight": 4
	},
	
	"wood": {
		"char": "(",
		"color": YELLOW,
		"name": "wooden shield",
		"defense": 6,
		"weight": 6
	},
	
	"bronze": {
		"char": "(",
		"color": GREEN,
		"name": "bronze shield",
		"defense": 10,
		"weight": 10
	}
}

items = {
	"berries": {
		"char": "%",
		"color": BLUE,
		"name": "berries",
		"article": "none",
		"food": 4,
		"weight": 1
	},
	
	"mushroom": {
		"char": "%",
		"color": WHITE,
		"name": "mushroom",
		"food": 8,
		"weight": 1
	},
	
	"ration": {
		"char": "%",
		"color": YELLOW,
		"name": "iron ration",
		"food": 12,
		"weight": 1
	},
	
	"torch": {
		"char": "\\",
		"color": RED,
		"name": "torch",
		"light": 80,
		"weight": 1,
		"attack": 1,
		"defense": 1,
		"damage": 1,
		"special": ("fire", 6, 6)
	},
	
	"idol": {
		"char": "&",
		"color": YELLOW,
		"name": "golden snake idol",
		"weight": 3
	}
}

trophies = {
	"gem": {
		"char": "$",
		"color": GREEN,
		"name": "snake eye gem",
	},

	"bones": {
		"char": "$",
		"color": WHITE,
		"name": "bone necklace",
	},

	"gold": {
		"char": "$",
		"color": YELLOW,
		"name": "gold coin",
	},

	"key": {
		"char": "?",
		"color": BLUE,
		"name": "clock key",
	},

	"ember": {
		"char": "?",
		"color": RED,
		"name": "glowing ember",
	},

	"awakening": {
		"char": "?",
		"color": YELLOW,
		"name": "gold coin",
	}
}

creatures = {
	"human": {
		"char": "@",
		"color": WHITE,
		"name": "human",
		"dice_size": 8,
		"muscle": 3,
		"stamina": 3,
		"agility": 3,
		"speed": 3,
		"senses": 3
	},

	"snake": {
		"char": "s",
		"color": GREEN,
		"name": "snake",
		"dice_size": 4,
		"muscle": 3,
		"stamina": 3,
		"agility": 5,
		"speed": 5,
		"can_swim": True,
		"drops": [trophies["gem"], None],
		"mind": "animal",
		"special": ("poison", 4, 4)
	},

	"rat": {
		"char": "r",
		"color": RED,
		"name": "rat",
		"dice_size": 4,
		"muscle": 3,
		"stamina": 3,
		"agility": 5,
		"speed": 5,
		"can_swim": True,
		"mind": "animal"
	},
	
	"bat": {
		"char": "b",
		"color": RED,
		"name": "vampire bat",
		"dice_size": 4,
		"muscle": 4,
		"stamina": 4,
		"agility": 5,
		"speed": 5,
		"can_fly": True,
		"mind": "animal"
	},
	
	"centipede": {
		"char": "c",
		"color": YELLOW,
		"name": "centipede",
		"dice_size": 4,
		"muscle": 2,
		"stamina": 2,
		"agility": 6,
		"speed": 6,
		"mind": "animal",
		"special": ("poison", 4, 4)
	},
	
	"worms": {
		"char": "w",
		"color": YELLOW,
		"name": "mass of worms",
		"dice_size": 6,
		"muscle": 5,
		"stamina": 6,
		"agility": 5,
		"speed": 5,
		"mind": "animal"
	},

	"zombie": {
		"char": "Z",
		"color": GREEN,
		"name": "zombie",
		"dice_size": 8,
		"muscle": 5,
		"stamina": 6,
		"agility": 4,
		"speed": 3,
		"mind": "undead"
	},

	"skeleton": {
		"char": "K",
		"color": WHITE,
		"name": "skeleton",
		"dice_size": 8,
		"muscle": 5,
		"stamina": 4,
		"agility": 5,
		"speed": 5,
		"drops": [trophies["bones"], None],
		"mind": "undead"
	},

	"mummy": {
		"char": "M",
		"color": YELLOW,
		"name": "mummy",
		"dice_size": 8,
		"muscle": 5,
		"stamina": 5,
		"agility": 5,
		"speed": 6,
		"drops": [trophies["gold"], None],
		"mind": "undead"
	},

	"ghoul": {
		"char": "G",
		"color": GREEN,
		"name": "ghoul",
		"dice_size": 10,
		"muscle": 5,
		"stamina": 5,
		"agility": 4,
		"speed": 4,
		"mind": "undead"
	},

	"clockwork": {
		"char": "A",
		"color": BLUE,
		"name": "animated armor",
		"dice_size": 10,
		"muscle": 5,
		"stamina": 5,
		"agility": 5,
		"speed": 5,
		"drops": [trophies["key"], None],
		"mind": "undead"
	},
	
	"hellhound": {
		"char": "h",
		"color": RED,
		"name": "hellhound",
		"dice_size": 6,
		"muscle": 6,
		"stamina": 6,
		"agility": 6,
		"speed": 6,
		"drops": [trophies["ember"], None],
		"mind": "undead",
		"special": ("fire", 6, 6)
	},

	"nightmare": {
		"char": "N",
		"color": RED,
		"name": "nightmare",
		"dice_size": 12,
		"muscle": 4,
		"stamina": 4,
		"agility": 4,
		"speed": 4,
		"drops": [trophies["awakening"], None],
		"mind": "undead"
	}
}

levels = [
	{
		"terrain": terrain["village"],
		"name": "Abandoned village",
		"items": [items["berries"], items["berries"], items["mushroom"],
			weapons["stone"], weapons["stone"]],
		"creatures": [creatures["snake"], creatures["rat"]]
	},

	{
		"terrain": terrain["cave"],
		"name": "Shallow cave",
		"items": [items["ration"], items["mushroom"],
			items["torch"], items["torch"],
			armor["cloth"], weapons["pickaxe"], weapons["pickaxe"],
			weapons["stone"], weapons["stone"]],
		"creatures": [creatures["bat"], creatures["rat"],
			creatures["centipede"]]
	},
	{
		"terrain": terrain["cave"],
		"name": "Cave",
		"items": [items["ration"], items["mushroom"],
			items["torch"], items["torch"],
			armor["cloth"], armor["leather"],
			weapons["pickaxe"], weapons["pickaxe"],
			weapons["stone"], weapons["stone"]],
		"creatures": [creatures["worms"], creatures["centipede"]]
	},
	{
		"terrain": terrain["cave"],
		"name": "Deep cave",
		"items": [items["ration"], items["mushroom"],
			items["torch"], items["torch"], armor["leather"],
			weapons["pickaxe"], weapons["pickaxe"],
			weapons["stone"], weapons["stone"]],
		"creatures": [creatures["worms"], creatures["zombie"],
			creatures["centipede"]]
	},

	{
		"terrain": terrain["tomb"],
		"name": "Catacomb",
		"cellsize": (7, 7),
		"items": [items["torch"], items["torch"],
			weapons["stone"], weapons["bullet"],
			weapons["pickaxe"], weapons["pickaxe"], weapons["mace"],
			armor["chainmail"], shields["leather"]],
		"creatures": [creatures["skeleton"], creatures["worms"],
			creatures["zombie"]]
	},
	{
		"terrain": terrain["tomb"],
		"name": "Catacomb",
		"cellsize": (7, 7),
		"items": [items["torch"], items["torch"], weapons["pickaxe"],
			weapons["bullet"], weapons["mace"], weapons["sword"],
			armor["chainmail"], shields["leather"]],
		"creatures": [creatures["skeleton"], creatures["mummy"],
			creatures["hellhound"]]
	},
	{
		"terrain": terrain["tomb"],
		"name": "Catacomb",
		"cellsize": (7, 7),
		"items": [items["torch"], items["torch"], weapons["pickaxe"],
			weapons["bullet"], weapons["mace"], weapons["sword"],
			armor["chainmail"], shields["leather"]],
		"creatures": [creatures["skeleton"], creatures["mummy"],
			creatures["ghoul"]]
	},
	{
		"terrain": terrain["tomb"],
		"name": "Catacomb",
		"cellsize": (5, 5),
		"items": [items["torch"], items["torch"], weapons["pickaxe"],
			weapons["bullet"], weapons["sword"], weapons["staff"],
			armor["scalemail"], shields["wood"]],
		"creatures": [creatures["ghoul"], creatures["mummy"],
			creatures["hellhound"]]
	},
	{
		"terrain": terrain["tomb"],
		"name": "Catacomb",
		"cellsize": (5, 5),
		"items": [items["torch"], items["torch"], weapons["pickaxe"],
			weapons["bullet"], weapons["spear"], weapons["staff"],
			armor["scalemail"], shields["wood"]],
		"creatures": [creatures["ghoul"], creatures["mummy"],
			creatures["clockwork"]]
	},
	{
		"terrain": terrain["tomb"],
		"name": "Catacomb",
		"cellsize": (5, 5),
		"items": [items["torch"], items["torch"], weapons["pickaxe"],
			weapons["bullet"], weapons["spear"], weapons["staff"],
			armor["scalemail"], shields["wood"]],
		"creatures": [creatures["hellhound"],
			creatures["ghoul"], creatures["clockwork"]]
	},
	{	"terrain": terrain["tomb"],
		"name": "Catacomb",
		"cellsize": (3, 3),
		"items": [items["torch"], items["torch"], weapons["pickaxe"],
			weapons["bullet"], weapons["spear"],
			armor["splintmail"], shields["bronze"]],
		"creatures": [creatures["hellhound"], creatures["nightmare"],
			creatures["ghoul"], creatures["clockwork"]]
	},
]

scrheight = -1
scrwidth = -1

world = None
worldrng = None
log = None

title_screen = None
character_screen = None
inventory_screen = None
game_screen = None
active_screen = None

finished = False

def run_in_curses(stdscr):
	global scrheight, scrwidth, world, worldrng, log, active_screen
	global title_screen, game_screen, character_screen, inventory_screen
	
	scrheight, scrwidth = stdscr.getmaxyx()

	if (scrheight < 24 or scrwidth < 80):
		raise RuntimeError("80x24 or larger terminal required.")

	curses.mousemask(
		curses.BUTTON1_CLICKED | curses.BUTTON1_DOUBLE_CLICKED)
	stdscr.leaveok(0)
	if curses.has_colors():
		curses.init_pair(
			RED, curses.COLOR_RED, curses.COLOR_BLACK)
		curses.init_pair(
			GREEN, curses.COLOR_GREEN, curses.COLOR_BLACK)
		curses.init_pair(
			BLUE, curses.COLOR_BLUE, curses.COLOR_BLACK)
		curses.init_pair(
			YELLOW, curses.COLOR_YELLOW, curses.COLOR_BLACK)
	
	worldrng = random.Random()

	title_screen = TitleScreen(stdscr)
	character_screen = CharacterScreen(stdscr)
	inventory_screen = InventoryScreen(stdscr)
	game_screen = GameScreen(stdscr)
	active_screen = title_screen
	
	while not finished:
		if (scrheight < 24 or scrwidth < 80):
			stdscr.erase()
			stdscr.addstr(
				0, 0, "80x24 or larger terminal required.")
			stdscr.refresh()
		else:
			active_screen.render()
		key = stdscr.getch()
		if key == curses.KEY_RESIZE:
			scrheight, scrwidth = stdscr.getmaxyx()
		else:
			active_screen.handle_key(key)

def draw_dialog_bg(window, top, left, height, width):
	window.attron(curses.A_REVERSE)
	for y in range(height):
		window.addstr(top + y, left, " " * width)
	rectangle(window, top, left, top + height - 1, left + width - 1)
	window.attroff(curses.A_REVERSE)
	
def draw_help_dialog(window):
	draw_dialog_bg(window, 2, 15, 20, 52)
	window.addstr(3, 16, "How to play".center(50))
	for i in range(0, len(help_text)):
		window.addstr(5 + i, 16, help_text[i], curses.A_REVERSE)
	window.addstr(20, 16, "Press any key".center(50))

def draw_help_bar(window, message):
	window.addstr(scrheight - 1, 0,
		message.ljust(scrwidth - 1), curses.A_REVERSE)

def prompt(window, message):
	draw_dialog_bg(window, 10, 15, 4, 52)
	window.addstr(11, 16, message[0:50].center(50), curses.A_REVERSE)
	window.addstr(12, 16, " " * 50)
	curses.echo()
	answer = window.getstr(12, 16, 50)
	curses.noecho()
	return answer

def menu(window, message, message2, options):
	draw_dialog_bg(window, 2, 15, 20, 52)
	window.addstr(3, 16, message.center(50), curses.A_REVERSE)
	window.addstr(4, 16, message2.center(50), curses.A_REVERSE)
	draw_help_bar(window,
		"Arrows or jk to select, space or Enter to confirm, "
		"Esc or q to cancel.")
	
	selected = 0
	
	while True:
		for i in range(len(options)):
			if i == selected:
				window.addstr(i + 6, 16,
					options[i].center(50))
			else:
				window.addstr(i + 6, 16,
					options[i].center(50),
					curses.A_REVERSE)
		key = window.getch()
		if key == curses.KEY_DOWN or key == ord('j'):
			selected += 1
			if selected > len(options) - 1:
				selected = 0
		elif key == curses.KEY_UP or key == ord('k'):
			selected -= 1
			if selected < 0:
				selected = len(options) - 1
		elif key == 10 or key == ord(' ') or key == curses.KEY_ENTER:
			if len(options) > 0:
				return options[selected]
			else:
				return None
		elif key == 27 or key == ord('q'):
			return None
		else:
			curses.flash()

def next_coords(x, y, direction):
	if direction == 'n':
		return x, y - 1
	elif direction == 's':
		return x, y + 1
	elif direction == 'e':
		return x + 1, y
	elif direction ==  'w':
		return x - 1, y
	else:
		raise ValueError("Invalid compass direction " + str(direction))

def roll_dice(count, sides):
	roll = 0
	for i in range(count):
		roll += random.randint(1, sides)
	return roll

def count_items(items):
	group = {}
	for i in items:
		if i.name in group:
			group[i.name] += 1
		else:
			group[i.name] = 1
	return group

def sum_item_weights(items):
	group = {}
	for i in items:
		if i.name in stack:
			group[i.name] += i.weight
		else:
			group[i.name] = i.weight
	return group

class TitleScreen:
	def __init__(self, stdscr):
		self.stdscr = stdscr
	
	def render(self):
		self.stdscr.clear()

		self.stdscr.addstr(0, 0,
			"Tomb of the Snake".ljust(scrwidth), curses.A_REVERSE)

		for i in range(4):
			self.stdscr.addstr(
				2 + i * 2, 0, blurb[i].center(scrwidth))
		
		if curses.has_colors():
			attr = curses.color_pair(RED) | curses.A_BOLD
		else:
			attr = 0
		for i in range(4):
			self.stdscr.addstr(10 + i, 0,
				title_banner[i].center(scrwidth), attr)
		self.stdscr.addstr(17, 0,
			"No Time To Play, 2015".center(scrwidth))
		if curses.has_colors():
			attr = curses.color_pair(BLUE)
		else:
			attr = 0
		self.stdscr.addstr(19, 0,
			"http://notimetoplay.org/".center(scrwidth), attr)

		draw_help_bar(self.stdscr,
			"[N]ew game [C]ontinue game [H]ow to play [Q]uit")
		
		self.stdscr.refresh()
			
	def handle_key(self, key):
		global finished, world, log, active_screen
		
		if key == ord('q') or key == 27:
			finished = True
		elif key == ord('n'):
			log = GameLog()
			world = GameWorld()
			world.player.log = log
			
			name = prompt(self.stdscr, "What's your name, hero?")
			world.player.name = name[0:50].decode()

			active_screen = game_screen
		elif key == ord('c'):
			if world == None:
				world = GameWorld()
				log = GameLog()
				world.player.log = log
			
				name = prompt(
					self.stdscr, "What's your name, hero?")
				world.player.name = name[0:50]
			active_screen = game_screen
		elif key == ord('h'):
			draw_help_dialog(self.stdscr)
			self.stdscr.getch()
		else:
			curses.flash()

class CharacterScreen:
	def __init__(self, stdscr):
		self.stdscr = stdscr

	def render(self):
		self.stdscr.clear()

		self.stdscr.addstr(0, 0,
			"Character sheet".ljust(scrwidth), curses.A_REVERSE)

		p = world.player
		self.stdscr.addstr(2, 2, p.name)
		self.stdscr.hline(3, 2, curses.ACS_HLINE, len(p.name))
		self.stdscr.addstr(5, 2,  "Muscle:  %2d" % (p.muscle,))
		self.stdscr.addstr(7, 2,  "Stamina: %2d" % (p.stamina,))
		self.stdscr.addstr(9, 2,  "Agility: %2d" % (p.agility,))
		self.stdscr.addstr(11, 2, "Speed:   %2d" % (p.speed,))
		self.stdscr.addstr(13, 2, "Senses:  %2d" % (p.senses,))
		
		self.stdscr.vline(5, 39, curses.ACS_VLINE, 9)

		self.stdscr.addstr(5, 41,
			"Dice size: %d" % (p.dice_size,))
		self.stdscr.addstr(7, 41,
			"Life: %d of %d" % (p.life(), p.stamina * p.dice_size))
		ap = p.speed * p.dice_size
		self.stdscr.addstr(9, 41,
			"Action points: %d of %d" % (p.action_points, ap))
		self.stdscr.addstr(11, 41,
			"Experience: %d" % (p.experience,))
		effects = " / ".join(
			[fxdescs[i] for i in p.effects.keys()])		
		self.stdscr.addstr(13, 41, effects)
			
		self.stdscr.hline(15, 2, curses.ACS_HLINE, 76)
		
		self.stdscr.addstr(17, 2, "Weapon: " + str(p.weapon))
		self.stdscr.addstr(19, 2, "Ammo: " + str(p.ammo))
		self.stdscr.addstr(17, 41, "Shield: " + str(p.shield))
		self.stdscr.addstr(19, 41, "Armor: " + str(p.armor))

		draw_help_bar(self.stdscr, "[I]nventory [B]ack to game")
		
		self.stdscr.refresh()
			
	def handle_key(self, key):
		global active_screen
		
		if key == ord('b') or key == 27:
			active_screen = game_screen
		if key == ord('i'):
			active_screen = inventory_screen
		else:
			curses.flash()

class InventoryScreen:
	def __init__(self, stdscr):
		self.stdscr = stdscr

	def render(self):
		self.stdscr.clear()

		self.stdscr.addstr(0, 0,
			"Inventory".ljust(scrwidth), curses.A_REVERSE)

		group = count_items(world.player.content)
		
		row = 2
		for i in group.keys():
			self.stdscr.addstr(
				row, 1, "%2dx %-40s" % (group[i], i))
			row += 1

		draw_help_bar(self.stdscr, "[C]haracter sheet [B]ack to game")
			
	def handle_key(self, key):
		global active_screen
		
		if key == ord('b') or key == 27:
			active_screen = game_screen
		if key == ord('c'):
			active_screen = character_screen
		else:
			curses.flash()

class GameScreen:
	def __init__(self, stdscr):
		self.stdscr = stdscr
		self.target_mode = False
		self.look_mode = False
		self.target_squares = []
	
	def render(self):
		self.render_status(world.player)
		self.render_map(world.player.level)
		if world.player.is_dead():
			for i in range(5):
				self.stdscr.addstr(9 + i, 0,
					death_banner[i].center(80))
		self.render_log()
		if world.player.is_dead():
			draw_help_bar(self.stdscr, "? @ [I]nventory [M]enu")
		else:
			draw_help_bar(self.stdscr,
				"? @ [I]nventory [G]et [D]rop [E]at "
				"[W]ield [F]ire e[X]amine [T]unnel [M]enu")
		
		self.stdscr.refresh()
		
	def render_status(self, player):
		l = player.level
		status = "Level: %d Life:%3d AP:%3d" % (
			l.depth, player.life(), player.action_points)
		status = status.rjust(scrwidth)
		self.stdscr.addstr(0, 0, status, curses.A_REVERSE)
		self.stdscr.addstr(0, 0, l.name, curses.A_REVERSE)
		
	def render_map(self, level):
		lmap = level.level_map
		self.terrain = world.player.level.terrain
		
		x1, y1, x2, y2 = self.update_seen()
		
		self.stdscr.attron(curses.A_DIM)
		for y in range(level.height):
			for x in range(level.width):
				if level.seen[y][x]:
					self.render_tile(x, y + 1, lmap[y][x])
				else:
					self.stdscr.addch(y + 1, x, " ")
		self.stdscr.attroff(curses.A_DIM)
		
		for y in range(y1, y2 + 1):
			for x in range(x1, x2 + 1):
				self.render_tile(x, y + 1, lmap[y][x])
		
		self.target_squares = []
		self.render_things(level, Item)
		self.render_things(level, Creature)
	
	def render_tile(self, x, y, char):
		if curses.has_colors():
			color = curses.color_pair(self.terrain[char]["color"])
		else:
			color = 0
		self.stdscr.addch(y, x, char, color)
	
	def render_things(self, level, thing_class):
		for i in level.content:
			if not isinstance(i, thing_class):
				continue
			elif not world.player.can_see(i.x, i.y):
				continue
			
			char = i.char
			if i != world.player:
				square = (i.x, i.y)
				if square not in self.target_squares:
					self.target_squares.append(square)
				target_num = self.target_squares.index(square)
				if self.target_mode or self.look_mode:
					if target_num < 10:
						char = str(target_num)
				
			attr = curses.A_BOLD
			if curses.has_colors():
				attr = curses.color_pair(i.color) | attr
			self.stdscr.addch(i.y + 1, i.x, char, attr)
	
	def update_seen(self):
		p = world.player
		sight_radius = p.sight_radius()
		x1 = max(0, p.x - sight_radius)
		y1 = max(0, p.y - sight_radius)
		x2 = min(p.level.width - 1, p.x + sight_radius)
		y2 = min(p.level.height - 1, p.y + sight_radius)
		
		for y in range(y1, y2 + 1):
			for x in range(x1, x2 + 1):
				p.level.seen[y][x] = True
		
		return x1, y1, x2, y2
			
	def render_log(self):
		num_msg = scrheight - 22
		tail = log.messages[-num_msg:]
		for i in range(len(tail)):
			self.stdscr.addstr(21 + i, 0, tail[i].ljust(scrwidth))
		
	def play_ending(self):
		self.stdscr.timeout(2400)
		for i in range(len(ending_text)):
			self.stdscr.addstr(
				3 + i * 2, 4, ending_text[i], curses.A_BOLD)
			self.stdscr.getch()
		draw_help_bar(self.stdscr, "Press any key")
		self.stdscr.timeout(-1)
		self.stdscr.getch()

	def handle_key(self, key):
		global active_screen
		
		if key == ord('m') or key == 27:
			self.look_mode = False
			self.target_mode = False
			active_screen = title_screen
		elif key == ord('@'):
			self.look_mode = False
			self.target_mode = False
			active_screen = character_screen
		elif key == ord('i'):
			self.look_mode = False
			self.target_mode = False
			active_screen = inventory_screen
		elif key == ord('?'):
			self.look_mode = False
			self.target_mode = False
			draw_help_dialog(self.stdscr)
			self.stdscr.getch()
		elif world.player.is_dead():
			curses.flash()
			return
		
		if world.player.action_points <= 0:
			world.update()
		
		if key in dirkeys:
			self.look_mode = False
			self.target_mode = False
			if world.player.walk(dirkeys[key]):
				world.update()
		elif key == ord('>'):
			self.look_mode = False
			self.target_mode = False
			p = world.player
			xp = p.experience
			p.descend()
			if p.experience > xp:
				# PC just leveled up.
				self.render()
				trait = menu(self.stdscr, "Ding! New level!",
					"Select trait to upgrade:",
					["muscle", "stamina", "agility",
						"speed", "senses"])
				if trait != None:
					p.__dict__[trait] += 1
					p.log("You feel %s." % (
						traitadjs[trait],))
				else:
					p.wounds = 0
					p.log("Your wounds heal.")
		elif key == ord('<'):
			self.look_mode = False
			self.target_mode = False
			p = world.player
			p.ascend()
			if p.level == world.level0:
				if world.mcguffin in p.content:
					self.render()
					self.play_ending()
					p.level.level_map[p.y][p.x] = ord('=')
		elif key == ord('g') or key == ord(','):
			self.look_mode = False
			self.target_mode = False
			world.player.get_item_here()
			world.update()
		elif key == ord('d'):
			self.look_mode = False
			self.target_mode = False
			itlist = count_items(world.player.content).keys()
			it = menu(self.stdscr, "Drop what?", "", itlist)
			if it != None:
				world.player.drop(it)
				world.update()
			else:
				world.player.log("Canceled.")
			world.update()
		elif key == ord('e'):
			self.look_mode = False
			self.target_mode = False
			foods = [i for i in world.player.content if i.food > 0]
			itlist = list(count_items(foods).keys())
			it = menu(self.stdscr, "Eat what?", "", itlist)
			if it != None:
				world.player.eat(it)
				world.update()
			else:
				world.player.log("Canceled.")
			world.update()
		elif key == ord('w'):
			self.look_mode = False
			self.target_mode = False
			if self.wield_or_wear():
				world.update()
		elif key == ord('f'):
			self.look_mode = False
			self.target_mode = not self.target_mode
		elif key == ord('x'):
			self.target_mode = False
			self.look_mode = not self.look_mode
		elif ord('0') <= key <= ord('9'):
			tnum = key - ord('0')
			if not self.target_mode and not self.look_mode:
				world.player.log("But you're not aiming!")
			elif tnum >= len(self.target_squares):
				world.player.log("Not enough targets.")
			elif self.target_mode:
				x, y = self.target_squares[tnum]
				if world.player.fire_at(x, y):
					world.update()
				self.target_mode = False
			elif self.look_mode:
				x, y = self.target_squares[tnum]
				world.player.look(x, y)
				self.look_mode = False
		elif key == ord('t'):
			self.look_mode = False
			self.target_mode = False
			draw_help_bar(self.stdscr, "Tunnel which way?")
			direction = self.stdscr.getch()
			if direction in dirkeys:
				world.player.tunnel(dirkeys[direction])
				world.update()
			else:
				world.player.log("Canceled.")
		elif key == ord('.'):
			self.look_mode = False
			self.target_mode = False
			world.player.log("You stand still.")
			world.update()
		elif key == curses.KEY_MOUSE:
			self.look_mode = False
			self.target_mode = False
			device, x, y, z, button = curses.getmouse()
			if button == curses.BUTTON1_CLICKED:
				world.player.look(x, y - 1)
			elif button == curses.BUTTON1_DOUBLE_CLICKED:
				if world.player.fire_at(x, y - 1):
					world.update()
		else:
			curses.flash()
	
	def wield_or_wear(self):
		slot = menu(self.stdscr,
			"Wield/wear equipment", "Choose slot:",
			["weapon", "ammo", "shield", "armor"])
		if slot == None:
			world.player.log("Canceled.")
			return False
		elif slot == "weapon":
			attr = "attack"
		elif slot == "ammo":
			attr = "ammo"
		elif slot == "shield":
			attr = "defense"
		elif slot == "armor":
			attr = "armor"
		
		equipment = self.select_equipment(slot, attr)
		if equipment == None:
			world.player.log("Canceled.")
			return False
		elif equipment == "none":
			equipment = None
			
		world.player.equip(equipment, slot)
		return True
	
	def select_equipment(self, slot, attr):
		shortlist = [i for i in world.player.content
			if i.__dict__[attr] > 0]
		shortlist = ["none"] + list(count_items(shortlist).keys())
		return menu(self.stdscr, "Choose " + slot, "", shortlist)

class GameLog:
	def __init__(self):
		self.messages = []
	
	def say(self, message):
		message = message[0].capitalize() + message[1:]
		self.messages.append(message)
		while len(self.messages) > 100:
			del self.messages[0]

	def call_attack(self, attacker, defender, damage):
		name1 = attacker.the_name()
		name2 = defender.the_name()
		if damage <= 0:
			self.say("%s pokes %s harmlessly." % (name1, name2))
		elif damage > defender.life():
			msg = "%s strikes %s for %d damage, killing %s!"
			msg  = msg % (name1, name2, damage, defender.pronoun)
			self.say(msg)
		else:
			msg = "%s strikes %s for %d damage."
			msg  = msg % (name1, name2, damage)
			self.say(msg)

	def __call__(self, message):
		self.say(message)

class GameWorld:
	def __init__(self):
		self.animal_ai = AnimalAI()
		self.undead_ai = UndeadAI()

		self.mcguffin = Item(items["idol"])
		self.player = Creature(creatures["human"])
		self.player.pronoun = "them"
		self.player.proper_name = True
		self.level0 = DungeonLevel(0, levels[0])
		self.level0.populate()
		
		self.player.move_to(0, 10, self.level0)
	
	def update(self):
		stuff = self.player.level.content
		for i in stuff.copy():
			if not isinstance(i, Creature):
				continue
			self.update_effects(i)
			if i.is_dead():
				drop = random.choice(i.drops)
				if drop != None:
					drop = Item(drop)
					drop.move_to(i.x, i.y, i.level)
				i.move_to(-1, -1, None)
			elif i.action_points <= 0:
				i.action_points += i.speed * i.dice_size
			elif i.mind == "animal":
				self.animal_ai.take_turn(i)
			elif i.mind == "undead":
				self.undead_ai.take_turn(i)
		self.update_torch(self.player, "weapon")
		self.update_torch(self.player, "shield")
	
	def update_torch(self, player, slot):
		item = player.__dict__[slot]
		if item != None and item.light > 0:
			item.light -= 1
			if item.light == 0:
				player.__dict__[slot] = None
				player.log("Your torch burns out.")
	
	def update_effects(self, creature):
		for i in creature.effects.copy().keys():
			effect = creature.effects[i]
			if effect["turns"] < 1:
				del creature.effects[i]
			else:
				effect["turns"] -= 1
				creature.wounds += roll_dice(
					1, effect["damage"])

class DungeonLevel:
	def __init__(self, depth, template):
		self.depth = depth
		self.width = 80
		self.height = 20

		self.name = template["name"]
		self.terrain = template["terrain"]
		self.items = template["items"]
		self.creatures = template["creatures"]
		#self.light_level = 1

		self.level_map = [bytearray(self.width)
			for i in range(self.height)]
		self.seen = [[False] * self.width for i in range(self.height)]
		self.prev_level = None
		self.next_level = None
		
		self.content = set()
	
	def is_on_grid(self, x, y):
		return x >= 0 and y >= 0 and x < self.width and y < self.height
	
	def terrain_at(self, x, y):
		tile = self.level_map[y][x]
		if tile in self.terrain.keys():
			return self.terrain[tile]
		else:
			return None
	
	def items_at(self, x, y):
		return (i for i in self.content
			if isinstance(i, Item) and i.x == x and i.y == y)
	
	def creature_at(self, x, y):
		for i in self.content:
			if isinstance(i, Creature) and i.x == x and i.y == y:
				return i
		return None
	
	def dig_next(self):
		if self.next_level != None:
			return
		
		self.next_level = DungeonLevel(
			self.depth + 1, levels[self.depth + 1])
		self.next_level.prev_level = self
		self.next_level.populate()
	
	def populate(self):
		if self.terrain == terrain["village"]:
			gen = VillageLevelGenerator(worldrng)
		elif self.terrain == terrain["cave"]:
			gen = CaveLevelGenerator(worldrng)
		elif self.terrain == terrain["tomb"]:
			gen = TombLevelGenerator(worldrng)
		else:
			raise RuntimeError("Unknown terrain type")
		
		gen.populate(self)

class Thing:
	def __init__(self):
		self.level = None
		self.x = -1
		self.y = -1
		
		self.name = "thing"
		self.pronoun = "it"
		self.proper_name = False
		self.special = None
	
	def move_to(self, x, y, parent = None):
		l = self.level
		
		if hasattr(l, "content") and self in l.content:
			l.content.remove(self)
		if hasattr(parent, "content"):
			parent.content.add(self)
			self.level = parent
		
		if not isinstance(parent, DungeonLevel): return

		if self.level.is_on_grid(x, y):
			self.x = x
			self.y = y
		else:
			raise ValueError("Can't move outside the level map.")

	def the_name(self):
		if self.proper_name:
			return self.name
		else:
			return "the " + self.name
	
	def a_name(self):
		if self.name[0] in ('a', 'e', 'i', 'o', 'u'):
			return "an " + self.name
		else:
			return "a " + self.name

	def __str__(self):
		return self.a_name()

class Item(Thing):
	def __init__(self, template):
		Thing.__init__(self)
		self.char = "?"
		
		self.weight = 0
		self.food = 0
		self.attack = 0
		self.defense = 0
		self.damage = 0
		self.ammo = 0
		self.armor = 0
		self.light = 0
		
		for attr in template.keys():
			self.__dict__[attr] = template[attr]
		
class Creature(Thing):
	def __init__(self, template):
		Thing.__init__(self)
		self.log = None

		self.char = "@"
		
		self.dice_size = 8
		self.muscle = 3
		self.agility = 3
		self.stamina = 3
		self.speed = 3
		self.senses = 3
		
		self.can_swim = False
		self.can_fly = False
		self.mind = None
		
		self.weapon = None
		self.shield = None
		self.armor = None
		self.ammo = None
		self.special = None
		
		self.drops = [None]
		
		for attr in template.keys():
			self.__dict__[attr] = template[attr]
		self.template = template
		
		self.wounds = 0
		self.experience = 0
		self.action_points = self.dice_size * self.speed
		
		self.content = set()
		self.effects = {}
		
		self.last_heading = None # For the AI system.

	def can_see(self, x, y):
		radius = self.sight_radius()
		can_see_x = abs(self.x - x) <= radius
		can_see_y = abs(self.y - y) <= radius
		return can_see_x and can_see_y
		
	def can_enter(self, x, y):
		tile = chr(self.level.level_map[y][x])
		if tile in ('.', ',', '=', '>', '<'):
			return True
		elif tile == '~':
			return self.can_swim or self.can_fly
		else:
			return False

	def walk(self, direction):
		if self.level == None:
			raise ValueError("Creature is out of play.")
		new_x, new_y = next_coords(self.x, self.y, direction)

		if not self.level.is_on_grid(new_x, new_y):
			self.log("An invisible barrier stops you.")
			return False
		elif self.level.creature_at(new_x, new_y) != None:
			creature = self.level.creature_at(new_x, new_y)
			if self.is_enemy(creature):
				self.attack(creature)
			#else:
			#	self.say("You bump into " + creature.name)
			return True
		elif not self.can_enter(new_x, new_y):
			t = self.level.terrain_at(new_x, new_y)
			if t != None and t["name"] != None:
				self.log("The way is barred by " + t["name"])
			else:
				self.log("The way is barred.")
		else:
			self.x = new_x
			self.y = new_y
			self.action_points -= 5
			return True

	def tunnel(self, direction):
		if self.level == None:
			raise ValueError("Creature is out of play.")
		new_x, new_y = next_coords(self.x, self.y, direction)
	
		if not self.level.is_on_grid(new_x, new_y):
			self.log("There's nothing in that direction.")
			return False
		elif self.level.level_map[new_y][new_x] != ord('#'):
			self.log("There's no wall in that direction.")
			return False
		
		for i in self.content.copy():
			if i.name == "pickaxe":
				self.level.level_map[new_y][new_x] = ord('.')
				self.content.remove(i)
				self.log("You break down the wall. "
					"The pickaxe falls apart.")
				self.action_points -= 20
				return True
		
		if self.weapon != None and self.weapon.name == "pickaxe":
				self.level.level_map[new_y][new_x] = ord('.')
				self.weapon = None
				self.log("You break down the wall. "
					"The pickaxe falls apart.")
				self.action_points -= 20
				return True

		self.log("You need a pickaxe for that.")
		return False
				
	def is_enemy(self, creature):
		return self.template != creature.template
	
	def attack(self, creature):
		if self.distance_to(creature) > 1:
			self.log(creature.the_name() +
				" is too far away for melee.")
			return False
		
		attack = roll_dice(self.agility, self.dice_size)
		if self.weapon != None:
			attack += self.weapon.attack
			if self.weapon.special != None:
				creature.apply_effect(self.weapon.special)
		elif self.special != None:
			creature.apply_effect(self.special)
		defense = roll_dice(creature.speed, creature.dice_size)
		if creature.shield != None:
			defense += creature.shield.defense
		
		if attack > defense:
			dmg_bonus = (self.muscle - 3) * self.dice_size / 2
			damage = (attack - defense) // 2 + dmg_bonus
			if self.weapon != None:
				damage += self.weapon.damage
			damage = creature.apply_armor(damage)
			if damage > 0:
				creature.wounds += damage
			self.log.call_attack(self, creature, damage)
		else:
			self.log("%s misses %s." %
				(self.the_name(), creature.the_name()))

		if self.weapon != None:
			self.action_points -= 4 + self.weapon.weight
		else:
			self.action_points -= 5
			
		return True
	
	def fire_at(self, x, y):
		if not self.can_see(x, y):
			self.log("You can't shoot what you can't see.")
			return False
		creature = self.level.creature_at(x, y)
		if creature == None:
			self.log("Nobody there for you to shoot.")
			return False
		distance = self.distance_to(creature)
		if distance < 2:
			self.log("You're too close to use your sling.")
			return False
		if self.ammo == None:
			self.log("You need ammo for your sling.")
			return False
		
		self.action_points -= 4 + self.ammo.weight
		
		attack = roll_dice(self.agility, self.dice_size)
		attack += self.ammo.ammo + self.senses - distance
		defense = roll_dice(creature.speed, creature.dice_size)
		if creature.shield != None:
			defense += creature.shield.defense

		if attack > defense:
			dmg_bonus = (self.muscle - 3) * self.dice_size / 2
			damage = (attack - defense) // 2 + dmg_bonus
			damage += self.ammo.damage
			damage = creature.apply_armor(damage)
			if damage > 0:
				creature.wounds += damage
				self.log("%s shoots %s for %d damage!" %
					(self.the_name(), creature.the_name(), damage))
			else:
				self.log("%s hits %s harmlessly." %
					(self.the_name(), creature.the_name()))
		else:
			self.ammo.move_to(x, y, self.level)
			self.log("%s's shot misses %s." %
				(self.the_name(), creature.the_name()))
		
		for item in self.content.copy():
			if item.name == self.ammo.name:
				self.ammo = item
				self.content.remove(item)
				return True
				
		self.ammo = None
		return True
	
	def distance_to(self, thing):
		if self.level != thing.level:
			return +inf
		else:
			return abs(self.x - thing.x) + abs(self.y - thing.y)
	
	def apply_armor(self, damage):
		if self.armor == None:
			return damage
		else:
			damage -= self.armor.armor
			if damage <= 0:
				return damage
			half = damage // 2
			self.armor.weight -= half
			if self.armor.weight < 0:
				self.log("Your armor falls apart.")
				self.armor = None
			return damage - half # In case damage was odd.
	
	def apply_effect(self, effect):
		kind, duration, damage = effect
		turns = roll_dice(1, duration)
		if kind in self.effects:
			self.effects[kind]["turns"] = max(
				turns, self.effects[kind]["turns"])
			self.effects[kind]["damage"] = max(
				damage, self.effects[kind]["damage"])
		else:
			self.effects[kind] = {"turns": turns, "damage": damage}
		self.log("%s is %s!" % (self.the_name(), fxdescs[kind]))
	
	def is_dead(self):
		return self.wounds >= self.dice_size * self.stamina
	
	def life(self):
		return self.dice_size * self.stamina - self.wounds
	
	def sight_radius(self):
		w = self.weapon
		s = self.shield
		
		if self.level.depth == 0:
			modifier = 2
		else:
			modifier = 0
		if w != None and w.light > 0 and modifier < 2:
			modifier += 1
		if s != None and s.light > 0 and modifier < 2:
			modifier += 1
		radius = self.senses * modifier
		if radius < 1:
			radius = self.senses // 2
		return radius
	
	def descend(self):
		tile = chr(self.level.level_map[self.y][self.x])
		if tile == '>':
			if self.level.next_level == None:
				self.level.dig_next()
			self.move_to(self.x, self.y, self.level.next_level)
			if self.level.depth > self.experience:
				self.experience = self.level.depth
				if self.wounds > 0:
					self.wounds -= 1
			self.action_points -= 5
		else:
			self.log("There's no way down from here.")
		
	def ascend(self):
		tile = self.level.level_map[self.y][self.x]
		if tile == ord('<'):
			self.move_to(self.x, self.y, self.level.prev_level)
			self.action_points -= 5
		else:
			self.log("There's no way up from here.")
	
	def look(self, x, y):
		if not self.level.is_on_grid(x, y):
			return
		elif not self.can_see(x, y):
			self.log("You can't see that far right now.")
			return
		
		tile = self.level.level_map[y][x]
		msg = "You see: " + self.level.terrain[tile]["name"]
		for i in self.level.content:
			if i.x == x and i.y == y:
				if i == self:
					msg += ", yourself"
				else:
					msg += ", " + i.name
		self.log(msg)
	
	def get_item_here(self):
		item = next(self.level.items_at(self.x, self.y), None)
		if item == None:
			self.log("There's nothing portable here.")
			return
		
		item.move_to(-1, -1, self)
		self.log("You pick up the " + item.name)
		self.action_points -= 5
	
	def drop(self, name):
		for item in self.content.copy():
			if item.name == name:
				item.move_to(self.x, self.y, self.level)
				self.log("Dropped.")
				self.action_points -= 5
				return
		self.log("But you don't have a %s!" % (name,))
	
	def eat(self, name):
		for item in self.content.copy():
			if item.name == name:
				if item.food < 1:
					self.log("That's not edible.")
					return
				elif self.wounds < 1:
					self.log("But you're feeling full!")
					return
					
				self.content.remove(item)
				self.wounds -= item.food
				if self.wounds < 0:
					self.wounds = 0
				self.log("You eat the %s." % (item.name,))
				self.action_points -= 10
				return
		self.log("But you don't have a %s!" % (name,))
	
	def equip(self, name, slot):
		if name != None:
			for item in self.content.copy():
				if item.name == name:
					prev_gear = self.__dict__[slot]
					self.__dict__[slot] = item
					self.content.remove(item)
					if prev_gear != None:
						self.content.add(prev_gear)
					self.log(slot + " changed.")
					self.action_points -= 10
					return
			self.log("But you don't have a %s!" % (name,))
		else:
			if self.__dict__[slot] != None:
				self.content.add(self.__dict__[slot])
				self.__dict__[slot] = None
			self.action_points -= 5
	
	
class VillageLevelGenerator:
	road_coords = []
	
	def __init__(self, rng):
		self.rng = rng
	
	def populate(self, level):
		for y in range(level.height):
			for x in range(level.width):
				level.level_map[y][x] = ord('.')
				
		self.make_trees(level)
		self.make_road(level)
		self.make_river(level)
		self.place_buildings(level)

		for y in range(level.height):
			for x in range(level.width):
				self.maybe_place_item(level, x, y)

		for y in range(level.height):
			for x in range(level.width):
				self.maybe_place_creature(level, x, y)
				
	def make_trees(self, level):
		size = level.width * level.height
		
		for i in range(size // 5):
			position = self.rng.randint(0, size - 1)
			x = position % level.width
			y = position // level.width
			if (position % 2 == 0):
				level.level_map[y][x] = ord('|')
			else:
				level.level_map[y][x] = ord('^')
				
	def make_road(self, level):
		y = level.height // 2 - 1
		for x in range(level.width):
			level.level_map[y][x] = ord(',')
			level.level_map[y + 1][x] = ord(',')
			self.road_coords.append(y)
			if (y <= 3):
				y += self.rng.choice([0, 0, 0, 0, 0, 0, 1])
			elif (y >= level.height - 3):
				y += self.rng.choice([-1, 0, 0, 0, 0, 0, 0])
			else:
				y += self.rng.choice([-1, 0, 0, 0, 0, 0, 1])
				
	def make_river(self, level):
		x = int(level.width * 0.4)
		for y in range(level.height):
			if level.level_map[y][x] == ord(','):
				level.level_map[y][x] = ord('=')
			else:
				level.level_map[y][x] = ord('~')
			delta_x = self.rng.randint(0, 2)
			if delta_x == 2: delta_x = 1
			x += delta_x
			
	def place_buildings(self, level):
		w = level.width
		# West of the river.
		self.place_building_cluster(level, int(w * 0.1), int(w * 0.4))
		# East of the river.
		self.place_building_cluster(level, int(w * 0.6), int(w * 0.9))
		
		x, y = self.last_building
		level.level_map[y][x] = ord('>')
		level.exit_down = self.last_building
		
	def place_building_cluster(self, level, from_x, to_x):
		h = level.height
		x = from_x
		while x < to_x:
			radius = self.rng.randint(1, 2)
			x += radius
			road_y = self.road_coords[x]
			if road_y < h // 2:
				y = road_y + int(h * 0.4)
			else:
				y = road_y - int(h * 0.4)
			self.make_building(level, x, y, radius)
			x += radius + 4
	
	def make_building(self, level, x, y, radius):
		for i in range(x - radius, x + radius + 1):
			for j in range(y - radius, y + radius + 1):
				level.level_map[j][i] = ord('#')
		# Make a door and clear the space in front of it.
		if y < level.height // 2:
			level.level_map[y + radius][x] = ord('.')
			level.level_map[y + radius + 1][x] = ord('.')
			level.level_map[y + radius + 1][x - 1] = ord('.')
			level.level_map[y + radius + 1][x + 1] = ord('.')
		else:
			level.level_map[y - radius][x] = ord('.')
			level.level_map[y - radius - 1][x] = ord('.')
			level.level_map[y - radius - 1][x - 1] = ord('.')
			level.level_map[y - radius - 1][x + 1] = ord('.')
		
		self.last_building = (x, y)
		
		radius -= 1;
		for i in range(x - radius, x + radius + 1):
			for j in range(y - radius, y + radius + 1):
				level.level_map[j][i] = ord('=')
	
	def maybe_place_item(self, level, x, y):
		tile = chr(level.level_map[y][x])
		if tile != '.' and tile != '=':
			return
		if self.rng.random() > 0.01:
			return
		
		item = Item(random.choice(level.items))
		item.move_to(x, y, level)
	
	def maybe_place_creature(self, level, x, y):
		tile = chr(level.level_map[y][x])
		if tile != '.' and tile != '=':
			return
		if self.rng.random() > 0.01:
			return
		
		creature = Creature(random.choice(level.creatures))
		creature.log = log
		creature.move_to(x, y, level)


class CaveLevelGenerator:
	def __init__(self, rng):
		self.rng = rng
		
		self.entrances = []
	
	def populate(self, level):
		for x in range (level.width):
			for y in range(level.height):
				level.level_map[y][x] = ord('#')

		assert level.prev_level != None

		x, y = level.prev_level.exit_down
		self.digRoomFrom(x, y, level)
		level.level_map[y][x] = ord('<')
		if level.depth % 2 == 1:
			while self.far_cell >= (20, 10):
				x, y = self.far_cell
				self.digRoomFrom(x, y, level)
		else:
			while self.far_cell < (70, 10):
				x, y = self.far_cell
				self.digRoomFrom(x, y, level)
		x, y = self.far_cell
		level.level_map[y][x] = ord('>')
		level.exit_down = self.far_cell

		self.makeWater(level)

		for y in range(level.height):
			for x in range(level.width):
				self.maybe_place_item(level, x, y)

		for y in range(level.height):
			for x in range(level.width):
				self.maybe_place_creature(level, x, y)
	
	def digRoomFrom(self, x, y, level):
		halfw = level.width // 2
		halfh = level.height // 2
		
		if level.depth % 2 == 1:
			directions = [(-1, 0), (-1, 0), (-1, 0),
				(0, -1), (0, -1), (1, 0), (0, 1)]
		else:
			directions = [(-1, 0), (0, -1),
				(1, 0), (1, 0), (1, 0), (0, 1), (0, 1)]
		self.far_cell = (x, y)
		for i in range(halfh):
			new_x = x
			new_y = y
			for j in range(halfw):
				direction = self.rng.choice(directions)
				dx, dy = direction
				new_x += dx
				new_y += dy
				if not self.advanceCorridor(
					new_x, new_y, level):
						break
	
	def advanceCorridor(self, x, y, level):
		if not(0 < x < level.width - 1 and 0 < y < level.height - 1):
			return False
		if level.level_map[y][x] == ord('#'):
			level.level_map[y][x] = ord('.')
		if level.depth % 2 == 1:
			if (x, y) < self.far_cell:
				self.far_cell = (x, y)
		else:
			if (x, y) > self.far_cell:
				self.far_cell = (x, y)
		return True
	
	def makeWater(self, level):
		min_x = 1
		min_y = 1
		max_x = level.width - 2
		max_y = level.height - 2
		
		water_tiles = []
		for y in range(min_y, max_y + 1):
			for x in range(min_x, max_x + 1):
				if level.level_map[y][x] != ord('#'):
					continue
				cnt = self.countNeighborTiles(
					x, y, level, ord('#'))
				if (cnt < 5):
					water_tiles.append((x, y))
		for i in water_tiles:
			x, y = i
			level.level_map[y][x] = ord('~')
	
	def countNeighborTiles(self, x, y, level, kind):
		count = 0
		for i in range(y - 1, y + 2):
			for j in range(x - 1, x + 2):
				if level.level_map[i][j] == kind:
					count += 1
		return count
	
	def maybe_place_item(self, level, x, y):
		tile = chr(level.level_map[y][x])
		if tile != '.':
			return
		if self.rng.random() > 0.02:
			return
		
		item = Item(random.choice(level.items))
		item.move_to(x, y, level)
	
	def maybe_place_creature(self, level, x, y):
		tile = chr(level.level_map[y][x])
		if tile != '.':
			return
		if self.rng.random() > 0.02:
			return
		
		creature = Creature(random.choice(level.creatures))
		creature.log = log
		creature.move_to(x, y, level)

class TombLevelGenerator:
	def __init__(self, rng):
		self.rng = rng
	
	def populate(self, level):
		for x in range(level.width):
			for y in range(level.height):
				level.level_map[y][x] = ord('.')
		for x in range (level.width):
			level.level_map[0][x] = ord('#')
			level.level_map[level.height - 1][x] = ord('#')
		for y in range(level.height):
			level.level_map[y][0] = ord('#')
			level.level_map[y][level.width - 1] = ord('#')
		
		self.cellw, self.cellh = levels[level.depth]["cellsize"]
		self.level = level
		self.subdivideWide(1, 1, level.width - 2, level.height - 2)

		x, y = level.prev_level.exit_down
		level.level_map[y][x] = ord('<')
		if level.depth % 2 == 1:
			if level.depth < len(levels) - 1:
				level.level_map[1][1] = ord('>')
				level.exit_down = (1, 1)
			else:
				idol = Item(items["idol"])
				idol.move_to(1, 1, level)
		elif level.depth < len(levels) - 1:
			lh2 = level.height - 2
			lw2 = level.width - 2
			level.level_map[lh2][lw2] = ord('>')
			level.exit_down = (lw2, lh2)
		else:
			world.mcguffin.move_to(
				level.width - 2, level.height - 2, level)
			
	
	def subdivideWide(self, x1, y1, x2, y2):
		w = x2 - x1 + 1
		h = y2 - y1 + 1
		# You have to check both dimensions
		# or you'll get oddly skewed levels.
		if w < self.cellw or h < self.cellh or w == h:
			self.furnishRoom(x1, y1, x2, y2)
			return 0
		
		if w == 3:
			x = x1 + 1
		else:
			x = x1 + self.rng.randint(1, w - 2)
		for y in range(y1, y2 + 1):
			self.level.level_map[y][x] = ord('#')

		wall1 =	self.subdivideHigh(x1, y1, x - 1, y2)
		wall2 = self.subdivideHigh(x + 1, y1, x2, y2)
		
		doory = y1 + self.rng.randint(0, h - 1)
		while doory == wall1 or doory == wall2:
			doory = y1 + self.rng.randint(0, h - 1)

		self.level.level_map[doory][x] = ord('.')
		# Account for walls placed deeper into recursion.
		self.level.level_map[doory][x - 1] = ord('.')
		self.level.level_map[doory][x + 1] = ord('.')
			
		return x

	def subdivideHigh(self, x1, y1, x2, y2):
		w = x2 - x1 + 1
		h = y2 - y1 + 1
		# You have to check both dimensions
		# or you'll get oddly skewed levels.
		if w < self.cellw or h < self.cellh or w == h:
			self.furnishRoom(x1, y1, x2, y2)
			return 0
		
		if h == 3:
			y = y1 + 1
		else:
			y = y1 + self.rng.randint(1, h - 2)
		for x in range(x1, x2 + 1):
			self.level.level_map[y][x] = ord('#')

		wall1 = self.subdivideWide(x1, y1, x2, y - 1)
		wall2 = self.subdivideWide(x1, y + 1, x2, y2)
		
		doorx = x1 + self.rng.randint(0, w - 1)
		while doorx == wall1 or doorx == wall2:
			doorx = x1 + self.rng.randint(0, w - 1)

		self.level.level_map[y][doorx] = ord('.')
		# Account for walls placed deeper into recursion.
		self.level.level_map[y - 1][doorx] = ord('.')
		self.level.level_map[y + 1][doorx] = ord('.')
			
		return y

	def furnishRoom(self, x1, y1, x2, y2):
		w = x2 - x1 + 1
		h = y2 - y1 + 1
		lmap = self.level.level_map
		
		if w == 3 and h == 3:
			lmap[y1 + 1][x1 + 1] = ord('+')
		elif w == 3:
			for y in range(y1 + 1, y2, 2):
				lmap[y][x1 + 1] = ord('|')
			if h % 2 == 0:
				lmap[y2][x2 - 1] = ord('+')
		elif h == 3:
			for x in range(x1 + 1, x2, 2):
				lmap[y1 + 1][x] = ord('|')
			if w % 2 == 0:
				lmap[y2 - 1][x2] = ord('+')
		elif w == 5:
			for y in range(y1 + 1, y2, 2):
				lmap[y][x1 + 1] = ord('|')
				lmap[y][x2 - 1] = ord('|')
			if h % 2 == 0:
				lmap[y2][x1] = ord('+')
				lmap[y2][x2 - 2] = ord('+')
				lmap[y2][x2] = ord('+')
		elif h == 5:
			for x in range(x1 + 1, x2, 2):
				lmap[y1 + 1][x] = ord('|')
				lmap[y2 - 1][x] = ord('|')
			if w % 2 == 0:
				lmap[y1][x2] = ord('+')
				lmap[y2 - 2][x2] = ord('+')
				lmap[y2][x2] = ord('+')
		elif w == 7 and h == 7:
			for y in range(y1 + 1, y2, 2):
				for x in range(x1 + 1, x2, 2):
					lmap[y][x] = ord('|')
			lmap[y1 + 3][x1 + 3] = ord('+')
		elif w > 5 and h > 5 and (w % 2 == 1 or h % 2 == 1):
			if h % 2 == 1:
				for y in range(y1 + 1, y2, 2):
					lmap[y][x1 + 1] = ord('#')
					lmap[y][x2 - 1] = ord('#')
			if w % 2 == 1:
				for x in range(x1 + 1, x2, 2):
					lmap[y1 + 1][x] = ord('#')
					lmap[y2 - 1][x] = ord('#')
			self.furnishRoom(x1 + 2, y1 + 2, x2 - 2, y2 - 2)
		else:
			for y in range(y1, y2 + 1):
				for x in range(x1, x2 + 1):
					if self.rng.random() > 0.01:
						continue
					item = Item(
						random.choice(
							self.level.items))
					item.move_to(x, y, self.level)

			for y in range(y1, y2 + 1):
				for x in range(x1, x2 + 1):
					if self.rng.random() > 0.01:
						continue
					creature = Creature(
						random.choice(
							self.level.creatures))
					creature.log = log
					creature.move_to(x, y, self.level)

class AnimalAI:
	def take_turn(self, mob):
		p = world.player
		if mob.distance_to(p) == 1:
			mob.attack(p)
			return

		mob.last_heading = random.choice(['n', 's', 'e', 'w'])
		x, y = next_coords(mob.x, mob.y, mob.last_heading)
		if mob.level.is_on_grid(x, y) and mob.can_enter(x, y):
			mob.walk(mob.last_heading)

class UndeadAI:
	def take_turn(self, mob):
		p = world.player
		if mob.distance_to(p) == 1:
			mob.attack(p)
			mob.last_heading = None # To reset the chase mode.
			return
		elif mob.x == p.x:
			if mob.y < p.y:
				mob.last_heading = 's'
			elif mob.y > p.y:
				mob.last_heading = 'n'
		elif mob.y == p.y:
			if mob.x < p.x:
				mob.last_heading = 'e'
			elif mob.x > p.x:
				mob.last_heading = 'w'
		elif mob.last_heading == None:
			mob.last_heading = random.choice(
				['n', 's', 'e', 'w'])

		x, y = next_coords(mob.x, mob.y, mob.last_heading)
		if mob.level.is_on_grid(x, y) and mob.can_enter(x, y):
			mob.walk(mob.last_heading)
		else:
			mob.last_heading = None

if __name__ == "__main__":
	try:
		curses.wrapper(run_in_curses)
	except RuntimeError as e:
		print(e)
