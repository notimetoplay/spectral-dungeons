' Spectral Dungeons -- a roguelike for the ZX Spectrum
' 2013-06-22 Felix Plesoianu <felix@plesoianu.ro>
'
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.

#include <print64.bas>

const MWIDTH as ubyte = 30
const MHEIGHT as ubyte = 20

const MAXLEVEL as ubyte = 10
const MAXMOBS as ubyte = (MAXLEVEL + 1) * MHEIGHT ' Remember the last level!

const APREFRESH as ubyte = 20 ' Action point refresh.

const BLANK as ubyte = 0
const DOT as ubyte = 1
const COMMA as ubyte = 2
const VBAR as ubyte = 3
const CARET as ubyte = 4
const TILDA as ubyte = 5
const EQUAL as ubyte = 6
const HASH as ubyte = 7
const GT as ubyte = 8
const LT as ubyte = 9

dim tileChar(0 to 9) as string
tileChar(BLANK) = " "
tileChar(DOT) = "."
tileChar(COMMA) = ","
tileChar(VBAR) = "|"
tileChar(CARET) = "^"
tileChar(TILDA) = "~"
tileChar(EQUAL) = "="
tileChar(HASH) = "#"
tileChar(GT) = ">"
tileChar(LT) = "<"
dim tileName(0 to 9) as string
tileName(BLANK) = "void"
tileName(DOT) = "ground"
tileName(COMMA) = "road"
tileName(VBAR) = "tree"
tileName(CARET) = "tree"
tileName(TILDA) = "river"
tileName(EQUAL) = "floor"
tileName(HASH) = "wall"
tileName(GT) = "stairs down"
tileName(LT) = "stairs up"

dim tileInk(0 to 9) as ubyte => {0, 7, 6, 2, 4, 5, 6, 2, 7, 7}
dim canWalk(0 to 9) as ubyte => {0, 1, 1, 0, 0, 0, 1, 0, 1, 1}


const ITEMTYPES as ubyte = 13

const NOTHING as ubyte = 0
const IDOL as ubyte = 1
const BERRIES as ubyte = 2
const SHROOMS as ubyte = 3
const CANDLE as ubyte = 4
const TORCH as ubyte = 5
const STICK as ubyte = 6
const KNIFE as ubyte = 7
const HATCHET as ubyte = 8
const CUTLASS as ubyte = 9
const CLOTH as ubyte = 10
const LEATHER as ubyte = 11
const MAIL as ubyte = 12
const SCALE as ubyte = 13

dim itemChar(1 to ITEMTYPES) as string
itemChar(IDOL) = "&"
itemChar(BERRIES) = "%"
itemChar(SHROOMS) = "%"
itemChar(CANDLE) = "\"
itemChar(TORCH) = "\"
itemChar(STICK) = "/"
itemChar(KNIFE) = "/"
itemChar(HATCHET) = "/"
itemChar(CUTLASS) = ")"
itemChar(CLOTH) = "]"
itemChar(LEATHER) = "]"
itemChar(MAIL) = "]"
itemChar(SCALE) = "]"
dim itemName(0 to ITEMTYPES) as string
itemName(NOTHING) = "nothing"
itemName(IDOL) = "golden idol"
itemName(BERRIES) = "berries"
itemName(SHROOMS) = "mushrooms"
itemName(CANDLE) = "candles"
itemName(TORCH) = "torches"
itemName(STICK) = "stick"
itemName(KNIFE) = "knife"
itemName(HATCHET) = "hatchet"
itemName(CUTLASS) = "cutlass"
itemName(CLOTH) = "cloth armor"
itemName(LEATHER) = "leather armor"
itemName(MAIL) = "chain mail"
itemName(SCALE) = "scale mail"
dim itemInk(1 to ITEMTYPES) as ubyte => _
	{6, 1, 7, 6, 2, 2, 7, 7, 7, 7, 2, 7, 6}
dim isStackable(1 to ITEMTYPES) as ubyte => _
	{0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0}
dim itemAttack(1 to ITEMTYPES) as ubyte => _
	{0, 0, 0, 0, 3, 2, 5, 8, 10, 0, 0, 0, 0}
dim itemDefense(1 to ITEMTYPES) as ubyte => _
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 5, 8, 10}


const MOBTYPES as ubyte = 12

const NOBODY as ubyte = 0
const HUMAN as ubyte = 1
const SNAKE as ubyte = 2
const SPIDER as ubyte = 3
const RAT as ubyte = 4
const BAT as ubyte = 5
const CENTIPEDE as ubyte = 6
const ZOMBIE as ubyte = 7
const MUMMY as ubyte = 8
const SKELETON as ubyte = 9
const GHOUL as ubyte = 10
const WORM as ubyte = 11
const SHOGGOTH as ubyte = 12

dim mobChar(1 to MOBTYPES) as string
mobChar(HUMAN) = "@"
mobChar(SNAKE) = "s"
mobChar(SPIDER) = "m"
mobChar(RAT) = "r"
mobChar(BAT) = "b"
mobChar(CENTIPEDE) = "j"
mobChar(ZOMBIE) = "Z"
mobChar(MUMMY) = "M"
mobChar(SKELETON) = "K"
mobChar(GHOUL) = "G"
mobChar(WORM) = "W"
mobChar(SHOGGOTH) = "S"
dim mobName(1 to MOBTYPES) as string
mobName(HUMAN) = "human"
mobName(SNAKE) = "snake"
mobName(SPIDER) = "spider"
mobName(RAT) = "sewer rat"
mobName(BAT) = "huge bat"
mobName(CENTIPEDE) = "centipede"
mobName(ZOMBIE) = "zombie"
mobName(MUMMY) = "mummy"
mobName(SKELETON) = "skeleton"
mobName(GHOUL) = "ghoul"
mobName(WORM) = "worm mass"
mobName(SHOGGOTH) = "shoggoth"
dim mobInk(1 to MOBTYPES) as ubyte => {3, 4, 2, 2, 2, 7, 4, 6, 7, 4, 7, 7}
dim mobDice(1 to MOBTYPES) as ubyte => _
	{8, 4, 4, 6, 6, 4, 10, 10, 8, 10, 12, 20}
dim mobHostility(1 to MOBTYPES) as ubyte => _
	{0, 1, 1, 1, 2, 1, 2, 2, 2, 2, 1, 1}
dim mobPoison(1 to MOBTYPES) as ubyte => _
	{0, 6, 4, 0, 0, 8, 0, 0, 0, 0, 0, 0}

dim levelViewDist(0 to MAXLEVEL) as ubyte => {5, 4, 3, 3, 3, 2, 2, 2, 1, 1, 1}
dim levelCellSize(1 to MAXLEVEL, 0 to 1) as ubyte => _
	{{7, 7}, {5, 7}, {5, 7}, {5, 7}, {5, 5}, _
	 {5, 5}, {5, 5}, {3, 3}, {3, 3}, {3, 3}}
dim levelMobs(0 to MAXLEVEL, 0 to 2) as ubyte => _
	{{SNAKE, SPIDER, RAT}, _
	 {RAT, BAT, CENTIPEDE}, _
	 {CENTIPEDE, SKELETON, NOBODY}, _
	 {CENTIPEDE, SKELETON, NOBODY}, _
	 {CENTIPEDE, SKELETON, MUMMY}, _
	 {MUMMY, ZOMBIE, NOBODY}, _
	 {MUMMY, ZOMBIE, NOBODY}, _
	 {MUMMY, SKELETON, GHOUL}, _
	 {GHOUL, WORM, NOBODY}, _
	 {NOBODY, WORM, SHOGGOTH}, _
	 {GHOUL, WORM, SHOGGOTH}}
dim levelItems(0 to MAXLEVEL, 0 to 4) as ubyte => _
	{{BERRIES, BERRIES, BERRIES, SHROOMS, STICK}, _
	 {SHROOMS, CLOTH, CANDLE, SHROOMS, NOTHING}, _
	 {CLOTH, CANDLE, CANDLE, NOTHING, KNIFE}, _
	 {LEATHER, CANDLE, CANDLE, NOTHING, KNIFE}, _
	 {LEATHER, CANDLE, CANDLE, NOTHING, KNIFE}, _
	 {MAIL, CANDLE, TORCH, NOTHING, HATCHET}, _
	 {MAIL, CANDLE, TORCH, NOTHING, HATCHET}, _
	 {MAIL, CANDLE, TORCH, NOTHING, HATCHET}, _
	 {SCALE, NOTHING, TORCH, NOTHING, CUTLASS}, _
	 {SCALE, NOTHING, TORCH, NOTHING, CUTLASS}, _
	 {SCALE, NOTHING, TORCH, NOTHING, CUTLASS}}

dim gameover as byte = 0


dim map(1 to MHEIGHT, 1 to MWIDTH) as ubyte
dim levelSeeds(0 to MAXLEVEL) as ulong

sub fillMap(tile as ubyte)
	dim x, y as ubyte
	for y = 1 to MHEIGHT
		for x = 1 to MWIDTH
			map(y, x) = tile
		next x
	next y
end sub

sub addTrees()
	dim x, y as ubyte
	dim r as float
	for y = 1 to MHEIGHT
		for x = 1 to MWIDTH
			r = rnd()
			if r < 0.1 then
				map(y, x) = VBAR
			elseif r < 0.2 then
				map(y, x) = CARET
			end if
		next x
	next y
end sub

dim roady(1 to MWIDTH) as ubyte
sub addRoad()
	dim x as ubyte
	dim y as ubyte = 10 ' Middle of the map
	dim r as float
	for x = 1 to MWIDTH
		map(y, x) = COMMA
		map(y + 1, x) = COMMA
		roady(x) = y
		
		r = rnd()
		if y <= 8 then
			if r < 0.15 then
				y = y + 1
			end if
		elseif y >= 12 then
			if r < 0.15 then
				y = y - 1
			end if
		else
			if r < 0.15 then
				y = y - 1
			elseif r < 0.3 then
				y = y + 1
			end if
		end if
	next x
end sub

sub addRiver()
	dim x as ubyte = 9
	dim y as ubyte
	for y = 1 to MHEIGHT
		if map(y, x) = COMMA
			map(y, x) = EQUAL
		else
			map(y, x) = TILDA
		end if
		
		if rnd() >= 0.5 then
			x = x + 1
		end if
	next y
end sub

sub addHouse(cx as ubyte, cy as ubyte, radius as ubyte)
	dim x, y as ubyte
	dim radius2, radius3 as ubyte
	radius2 = radius - 1
	radius3 = radius + 1
	' Clear the grounds.
	for y = cy - radius3 to cy + radius3
		for x = cx - radius3 to cx + radius3
			map(y, x) = DOT
		next x
	next y
	' Make the walls.
	for y = cy - radius to cy + radius
		for x = cx - radius to cx + radius
			map(y, x) = HASH
		next x
	next y
	' Make the floor.
	for y = cy - radius2 to cy + radius2
		for x = cx - radius2 to cx + radius2
			map(y, x) = EQUAL
		next x
	next y
	' Make the door.
	if y > 10 then
		map(cy - radius, cx) = EQUAL
	else
		map(cy + radius, cx) = EQUAL
	end if
end sub

sub generateVillage()
	fillMap(DOT)
	
	addTrees()
	addRoad()
	addRiver()
	
	addHouse(5, roady(5) - 4, 1)
	addHouse(7, roady(7) + 5, 2)
	addHouse(24, roady(24) - 4, 2)
	addHouse(19, roady(19) - 4, 1)
	addHouse(26, 16, 1)
	
	map(16, 26) = GT
end sub

dim cellwidth, cellheight as ubyte

function subdivideWide(x1 as ubyte, y1 as ubyte, x2 as ubyte, y2 as ubyte) _
as ubyte
	dim w, h, x, y, wall1, wall2, doory as ubyte
	w = x2 - x1 + 1
	h = y2 - y1 + 1
	' You have to check both dimensions
	' or you'll get oddly skewed levels.
	if w < cellwidth or h < cellheight then return 0: end if

	if w = 3 then
		x = x1 + 1
	else
		x = x1 + 1 + int(rnd() * (w - 2))
	end if
	
	for y = y1 to y2
		map(y, x) = HASH
	next y
		
	wall1 =	subdivideHigh(x1, y1, x - 1, y2)
	wall2 = subdivideHigh(x + 1, y1, x2, y2)
		
	' Make door.
	do
		doory = y1 + int(rnd() * h)
	loop while doory = wall1 or doory = wall2
	map(doory, x) = DOT
	' Not superfluous!
	map(doory, x - 1) = DOT
	map(doory, x + 1) = DOT
		
	return x
end function

function subdivideHigh(x1 as ubyte, y1 as ubyte, x2 as ubyte, y2 as ubyte) _
as ubyte
	dim w, h, x, y, wall1, wall2, doorx as ubyte
	w = x2 - x1 + 1
	h = y2 - y1 + 1
	' You have to check both dimensions
	' or you'll get oddly skewed levels.
	if w < cellwidth or h < cellheight then return 0: end if

	if h = 3 then
		y = y1 + 1
	else
		y = y1 + 1 + int(rnd() * (h - 2))
	end if
	
	for x = x1 to x2
		map(y, x) = HASH
	next x
		
	wall1 = subdivideWide(x1, y1, x2, y - 1)
	wall2 = subdivideWide(x1, y + 1, x2, y2)
		
	' Make door.
	do
		doorx = x1 + int(rnd() * w)
	loop while doorx = wall1 or doorx = wall2
	map(y, doorx) = DOT
	' Not superfluous!
	map(y - 1, doorx) = DOT
	map(y + 1, doorx) = DOT
		
	return y
end function

sub generateCatacomb(levelNum as ubyte)
	dim x, y as ubyte

	fillMap(DOT)

	for x = 1 to MWIDTH
		map(1, x) = HASH
		map(MHEIGHT, x) = HASH
	next x
	for y = 1 to MHEIGHT
		map(y, 1) = HASH
		map(y, MWIDTH) = HASH
	next y

	cellwidth = levelCellSize(levelNum, 0)
	cellheight = levelCellSize(levelNum, 1)
	subdivideWide(2, 2, MWIDTH - 1, MHEIGHT - 1)
	
	if levelNum mod 2 = 1 then
		if levelNum < MAXLEVEL then
			map(2, 2) = GT
		end if
		map(MHEIGHT - 1, MWIDTH - 1) = LT
	else
		map(2, 2) = LT
		if levelNum < MAXLEVEL then
			map(MHEIGHT - 1, MWIDTH - 1) = GT
		end if
	end if
end sub


' Coords are x, y, level for any mob from 0 to MAXMOBS
' Mob 0 (zero) is always the player.
dim mobCoords(0 to MAXMOBS, 0 to 1) as ubyte
dim mobs(0 to MAXMOBS) as ubyte
dim mobLife(0 to MAXMOBS) as byte ' It can get negative from a hit!
dim mobActions(0 to MAXMOBS) as byte

dim heroDepth as ubyte = 0
dim heroMaxDepth as ubyte = 0 ' Deepest level attained this game.
dim heroMaxLife as ubyte
heroMaxLife = 2 * mobDice(HUMAN) - 1
dim heroWeapon as ubyte = NOTHING
dim heroArmor as ubyte = NOTHING
dim poisonTimer as ubyte = 0
dim lightTimer as ubyte = 0

dim inventory(1 to ITEMTYPES) as ubyte

sub populateLevel(levelNum as ubyte)
	dim x, y, offset, mobNum as ubyte
	offset = levelNum * MHEIGHT
	for y = 2 to MHEIGHT - 1
		mobNum = offset + y - 1
		mobs(mobNum) = levelMobs(levelNum, int(rnd() * 3))
		mobLife(mobNum) = 2 * mobDice(mobs(mobNum))
		do
			x = int(rnd() * (MWIDTH - 2)) + 1
		loop until canWalk(map(y, x)) 'Assumes it's the current level!
		mobCoords(mobNum, 0) = x
		mobCoords(mobNum, 1) = y
		mobActions(mobNum) = APREFRESH
	next y
end sub

function getMobAt(x as ubyte, y as ubyte, z as ubyte) as integer
	dim i, offset, limit as ubyte
	if  mobCoords(0, 0) = x and mobCoords(0, 1) = y then
		return 0 ' Special case the player for now.
	end if
	offset = z * MHEIGHT
	limit = offset + MHEIGHT - 2
	for i = offset + 1 to limit
		if mobs(i) then
			if mobCoords(i, 0) = x then
				if mobCoords(i, 1) = y then
					return i
				end if
			end if
		end if
	next i
	return -1
end function

sub interactWith(mobNum as ubyte)
	print at 22, 0; ink 7; "Why, hello there."
end sub

function diceRoll(dice as ubyte, size as ubyte) as ubyte
	dim roll as ubyte = 0
	dim i as ubyte
	for i = 1 to dice
		roll = roll + int(rnd() * size) + 1
	next i
	return roll
end function

function damageBonus(mobNum as ubyte) as ubyte
	if mobNum = 0 then
		return heroMaxDepth
	else
		return 0
	end if
end function

function attackBonus(mobNum as ubyte) as ubyte
	if mobNum = 0 then
		return itemAttack(heroWeapon)
	else
		return heroDepth
	end if
end function

function defenseBonus(mobNum as ubyte) as ubyte
	if mobNum = 0 then
		return itemDefense(heroArmor)
	else
		return heroDepth
	end if
end function

sub handleAttackByOn(attacker as ubyte, defender as ubyte)
	dim att, def, attRoll, defRoll as ubyte
	dim margin as byte

	att = mobs(attacker)
	def = mobs(defender)
	attRoll = diceRoll(2, mobDice(att)) + attackBonus(attacker)
	defRoll = diceRoll(2, mobDice(def)) + defenseBonus(defender)
	margin = attRoll - defRoll

	if attacker = 0 or defender = 0 then
		blankLine(22): ink 7: print at 22, 0;
	end if
	if margin > 0 then
		margin = margin + damageBonus(attacker) - damageBonus(defender)
		if margin < 0 then margin = 0: end if
		mobLife(defender) = mobLife(defender) - margin
		if mobLife(defender) <= 0 then
			mobs(defender) = NOBODY
			if attacker = 0 then
				print "You kill the "; mobName(def); "!"
			elseif defender = 0 then
				print "The "; mobName(att); " kills you!!"
				printHeroStats()
				playDeath()
				gameover = 1
			end if
		else
			if attacker = 0 then
				print "You strike the "; mobName(def); "."
			elseif defender = 0 then
				if mobPoison(att) > 0 then
					poisonTimer = poisonTimer _
						+ int(rnd()*mobPoison(att))+1
				end if
				print "The "; mobName(att); " wounds you. Oof."
				printHeroStats()
			end if
		end if
	elseif margin = 0 then
		if attacker = 0 then
			print "You graze the "; mobName(def); "."
		elseif defender = 0 then
			if mobPoison(att) > 0 then
				poisonTimer = poisonTimer _
					+ int(rnd() * mobPoison(att)) + 1
				printHeroStats()
			end if
			print "The "; mobName(att); " grazes you. Whee."
		end if
	else
		if attacker = 0 then
			print "You miss the "; mobName(def); "."
		elseif defender = 0 then
			print "The "; mobName(att); " misses you. Ha."
		end if
	end if
	if attacker = 0 or defender = 0 then
		pause 10 ' Give player at least a chance to read the message.
	end if
end sub

sub moveMob(mobNum as ubyte, dx as byte, dy as byte)
	dim newx, newy as ubyte
	dim otherMob as integer

	newx = mobCoords(mobNum, 0) + dx
	newy = mobCoords(mobNum, 1) + dy

	if newx < 1 or newx > MWIDTH or newy < 1 or newy > MHEIGHT then
		return
	elseif not canWalk(map(newy, newx)) then
		return
	end if

	otherMob = getMobAt(newx, newy, heroDepth)
	if otherMob > -1 then
		if mobs(mobNum) <> mobs(otherMob) then ' Not the same species.
			handleAttackByOn(mobNum, otherMob)
		end if
	else
		mobCoords(mobNum, 0) = newx
		mobCoords(mobNum, 1) = newy
	end if
end sub

sub moveHero(dx as byte, dy as byte)
	dim newx, newy, hostility as ubyte
	dim otherMob as integer

	newx = mobCoords(0, 0) + dx
	newy = mobCoords(0, 1) + dy

	blankLine(22)
	if newx < 1 or newx > MWIDTH or newy < 1 or newy > MHEIGHT then
		print at 22, 0; ink 7; "You have nowhere else to go."
		return
	elseif not canWalk(map(newy, newx)) then
		ink 7
		print at 22, 0; "The way is barred by a ";
		print tileName(map(newy, newx)); "."
		return
	end if

	otherMob = getMobAt(newx, newy, heroDepth)
	if  otherMob > 0 then
		hostility = mobHostility(mobs(otherMob))
		if hostility > 0 then
			handleAttackByOn(0, otherMob)
		else
			interactWith(otherMob)
		end if
	else
		mobCoords(0, 0) = newx
		mobCoords(0, 1) = newy
	end if
end sub

sub moveHeroDown()
	if map(mobCoords(0, 1), mobCoords(0, 0)) = GT then
		heroDepth = heroDepth + 1
		blankViewport()
		print at 10, 8; ink 7; "Digging catacomb"
		randomize levelSeeds(heroDepth)
		generateCatacomb(heroDepth)
		if heroDepth > heroMaxDepth then
			heroMaxDepth = heroDepth
			heroMaxLife = heroMaxLife + 1
			populateLevel(heroDepth)
			createItems(heroDepth)
		end if
		randomize
		blankViewport()
		printLevelNum()
		printHeroStats()
		
		if heroDepth mod 2 = 1 then
			mobCoords(0, 0) = MWIDTH - 1
			mobCoords(0, 1) = MHEIGHT - 1
		else
			mobCoords(0, 0) = 2
			mobCoords(0, 1) = 2
		end if
		blankLine(22)
	else
		print at 22, 0; ink 7; "There's no way down from here."
	end if
end sub

sub moveHeroUp()
	if map(mobCoords(0, 1), mobCoords(0, 0)) = LT then
		blankViewport()
		print at 10, 2; ink 7; " You stumble in darkness..."
		heroDepth = heroDepth - 1
		randomize levelSeeds(heroDepth)
		if heroDepth > 0 then
			generateCatacomb(heroDepth)
		else
			generateVillage()
		end if
		randomize
		blankViewport()
		printLevelNum()
		
		if heroDepth = 0 then
			mobCoords(0, 0) = 26
			mobCoords(0, 1) = 16
			if inventory(IDOL) > 0 then
				drawViewport()
				playEnding()
				gameover = 1
			end if
		elseif heroDepth mod 2 = 0 then
			mobCoords(0, 0) = MWIDTH - 1
			mobCoords(0, 1) = MHEIGHT - 1
		else
			mobCoords(0, 0) = 2
			mobCoords(0, 1) = 2
		end if
		blankLine(22)
	else
		print at 22, 0; ink 7; "There's no way up from here."
	end if
end sub

sub mobWander(mobNum as ubyte)
	dim rndir as ubyte
	rndir = int(rnd() * 4)
	if rndir = 0 then
		moveMob(mobNum, 0, -1)
	elseif rndir = 1 then
		moveMob(mobNum, 0, 1)
	elseif rndir = 2 then
		moveMob(mobNum, 0, -1)
	elseif rndir = 3 then
		moveMob(mobNum, 0, 1)
	end if
end sub

sub mobHuntHero(mobNum as ubyte)
	dim myx, myy, herox, heroy as byte
	myx = mobCoords(mobNum, 0)
	myy = mobCoords(mobNum, 1)
	herox = mobCoords(0, 0)
	heroy = mobCoords(0, 1)
	if myx = herox then
		if myy > heroy then
			moveMob(mobNum, 0, -1)
		else
			moveMob(mobNum, 0, 1)
		end if
	elseif myy = heroy then
		if myx > herox then
			moveMob(mobNum, -1, 0)
		else
			moveMob(mobNum, 1, 0)
		end if
	else
		mobWander(mobNum)
	end if
end sub

sub mobRunFromHero(mobNum as ubyte)
	dim myx, myy, herox, heroy as byte
	myx = mobCoords(mobNum, 0)
	myy = mobCoords(mobNum, 1)
	herox = mobCoords(0, 0)
	heroy = mobCoords(0, 1)
	if myx = herox then
		if myy < heroy then
			moveMob(mobNum, 0, -1)
		else
			moveMob(mobNum, 0, 1)
		end if
	elseif myy = heroy then
		if myx < herox then
			moveMob(mobNum, -1, 0)
		else
			moveMob(mobNum, 1, 0)
		end if
	else
		mobWander(mobNum)
	end if
end sub

sub processShoggoth(mobNum as ubyte)
	if lightTimer > 0 then
		mobLife(mobNum) = mobLife(mobNum) - 2
		blankLine(22)
		ink 7: print at 22, 0;
		if mobLife(mobNum) < 1 then
			mobs(mobNum) = NOBODY
			print "Light has killed the shoggoth!"
		else
			print "The shoggoth melts a little."
		end if
	end if
end sub

sub processMobs()
	dim i, offset, limit as ubyte
	offset = heroDepth * MHEIGHT
	limit = offset + MHEIGHT - 2
	for i = offset + 1 to limit
		if mobs(i) then
			if mobActions(i) > 0 then
				mobActions(i) = _
					mobActions(i) - mobDice(mobs(i))
				if mobHostility(mobs(i)) < 2 then
					if lightTimer < 1 then
						mobWander(i)
					else
						mobRunFromHero(i)
					end if
				else
					if lightTimer < 1 then
						mobHuntHero(i)
					else
						mobWander(i)
					end if
				end if
			else
				mobActions(i) = mobActions(i) + APREFRESH
			end if
		end if
	next i
end sub

dim healingTimer as ubyte = 0
sub processHealing()
	healingTimer = healingTimer + 1
	if healingTimer >= heroMaxLife then
		if mobLife(0) < heroMaxLife then
			mobLife(0) = mobLife(0) + 1
			healingTimer = 0
			printHeroStats()
		else
			healingTimer = healingTimer - 1
		end if
	end if
end sub

sub processPoison()
	if poisonTimer > 0 then
		mobLife(0) = mobLife(0) - 1
		poisonTimer = poisonTimer - 1
		printHeroStats()
		if mobLife(0) < 1 then
			blankLine(22)
			print at 22, 0; "You succumb to the poison!!"
			playDeath()
			gameover = 1
		end if
	end if
end sub

sub processLight()
	if lightTimer > 0 then
		lightTimer = lightTimer - 1
		if lightTimer < 1 then
			blankLine(22)
			print at 22, 0; ink 7; "Your light runs out."
		end if
	end if
end sub


dim itemCoords(0 to MAXLEVEL, 1 to MHEIGHT, 0 to 1) as ubyte
dim items(0 to MAXLEVEL, 1 to MHEIGHT) as ubyte

sub createItems(levelNum as ubyte)
	dim x, y as ubyte
	for y = 2 to MHEIGHT - 1
		items(levelNum, y) = levelItems(levelNum, int(rnd() * 5))
		do
			x = int(rnd() * (MWIDTH - 2)) + 1
		loop until canWalk(map(y, x)) 'Assumes it's the current level!
		itemCoords(levelNum, y, 0) = x
		itemCoords(levelNum, y, 1) = y
	next y
end sub

sub legend()
	dim i, mob as ubyte

	blankLine(22)
	print at 22, 0;
	
	for i = 0 to 2
		mob = levelMobs(heroDepth, i)
		print ink mobInk(mob); mobChar(mob); " ";
		print ink 7; mobName(mob); " ";
	next i
end sub

sub getItem(item as ubyte)
	ink 7: print at 22, 0;
	if isStackable(item) then
		inventory(item) = inventory(item) + 1
		print "You pick up some ";
		print itemName(item); "."
	elseif inventory(item) = 0 then
		inventory(item) = 1
		print "You pick up a ";
		print itemName(item); "."
	else
		print "Already got a ";
		print itemName(item); "."
	end if
	
	if itemAttack(item) > itemAttack(heroWeapon) then
		heroWeapon = item
	end if
	if itemDefense(item) > itemDefense(heroWeapon) then
		heroArmor = item
	end if
end sub

sub getItemAt(x as ubyte, y as ubyte)
	dim i, item as ubyte
	dim x1, y1 as byte

	blankLine(22)
	for i = 1 to MHEIGHT
		item = items(heroDepth, i)
		if item <> NOTHING then
			x1 = itemCoords(heroDepth, i, 0)
			y1 = itemCoords(heroDepth, i, 1)
			if x1 = x and y1 = y then
				getItem(item)
				items(heroDepth, i) = NOTHING
				return
			end if
		end if
	next i
	print at 22, 0; ink 7; "You grope at the empty floor."
end sub

sub eat()
	dim k as string
	
	ink 7
	blankLine(22)
	if inventory(BERRIES) + inventory(SHROOMS) > 0 then
		print at 22, 0; "Eat:";
		if inventory(BERRIES) > 0 then
			print " 1) berries";
		end if
		if inventory(SHROOMS) > 0 then
			print " 2) mushrooms";
		end if
		print " 0)-"
		
		pause 0
		k = inkey$()
		blankLine(22)

		if k = "1" then
			if inventory(BERRIES) > 0 then
				inventory(BERRIES) = inventory(BERRIES) - 1
				mobLife(0) = mobLife(0) + 3
				if mobLife(0) > heroMaxLife then
					mobLife(0) = heroMaxLife
				end if
				print at 22, 0; "You eat some berries. Mmm!"
				printHeroStats()
			else
				print at 22, 0; "But you don't have any."
			end if
		elseif k = "2" then
			if inventory(SHROOMS) > 0 then
				inventory(SHROOMS) = inventory(SHROOMS) - 1
				mobLife(0) = mobLife(0) + 5
				if mobLife(0) > heroMaxLife then
					mobLife(0) = heroMaxLife
				end if
				print at 22, 0; "You eat some mushrooms. Mmm!"
				printHeroStats()
			else
				print at 22, 0; "But you don't have any."
			end if
		end if
	else
		print at 22, 0; "You have nothing to eat."
	end if
end sub

sub alight()
	dim k as string

	ink 7
	blankLine(22)
	if inventory(CANDLE) + inventory(TORCH) > 0 then
		print at 22, 0; "Light a:";
		if inventory(CANDLE) > 0 then
			print " 1) candle";
		end if
		if inventory(TORCH) > 0 then
			print " 2) torch";
		end if
		print " 0)-"
		
		pause 0
		k = inkey$()
		blankLine(22)

		if k = "1" then
			if inventory(CANDLE) > 0 then
				inventory(CANDLE) = inventory(CANDLE) - 1
				if lightTimer < MHEIGHT / 2 then
					lightTimer = MHEIGHT / 2
				end if
				print at 22, 0; "You light a candle."
			else
				print at 22, 0; "But you don't have any."
			end if
		elseif k = "2" then
			if inventory(TORCH) > 0 then
				inventory(TORCH) = inventory(TORCH) - 1
				if lightTimer < MWIDTH / 2 then
					lightTimer = MWIDTH / 2
				end if
				print at 22, 0; "You light a torch."
			else
				print at 22, 0; "But you don't have any."
			end if
		end if
	else
		print at 22, 0; "You have no light source."
	end if
end sub

sub showInventory()
	dim reported as ubyte = 0
	dim i as ubyte
	ink 7
	blankLine(22)
	for i = 1 to ITEMTYPES
		if inventory(i) > 0 then
			print at 22, 0; "You have: ";
			if isStackable(i) then
				print inventory(i); " ";
			end if
			print itemName(i); " [more]"
			pause 0
			blankLine(22)
			reported = reported + 1
		end if
	next i
	if reported = 0 then
		print at 22, 0; ink 7; "You are empty-handed.";
	end if
end sub


sub drawMap(x1 as ubyte, y1 as ubyte, x2 as ubyte, y2 as ubyte)
	dim x, y, tile as ubyte
	for y = y1 to y2
		print at y, x1;
		for x = x1 to x2
			tile = map(y, x)
			print ink tileInk(tile); tileChar(tile);
		next x
	next y
end sub

sub drawVisibleMap()
	dim x1, x2, y1, y2, dist as byte
	if lightTimer > 0 then
		dist = 5
	else
		dist = levelViewDist(heroDepth)
	end if
	x1 = mobCoords(0, 0) - dist
	y1 = mobCoords(0, 1) - dist
	x2 = mobCoords(0, 0) + dist
	y2 = mobCoords(0, 1) + dist
	if x1 < 1 then x1 = 1: end if
	if y1 < 1 then y1 = 1: end if
	if x2 > MWIDTH then x2 = MWIDTH: end if
	if y2 > MHEIGHT then y2 = MHEIGHT: end if
	drawMap(x1, y1, x2, y2)
end sub

sub drawVisibleItems()
	dim i, item, dist as ubyte
	dim x1, y1, x2, y2 as byte

	x2 = mobCoords(0, 0)
	y2 = mobCoords(0, 1)
	if lightTimer > 0 then
		dist = 5
	else
		dist = levelViewDist(heroDepth)
	end if

	for i = 1 to MHEIGHT
		item = items(heroDepth, i)
		if item <> NOTHING then
			x1 = itemCoords(heroDepth, i, 0)
			y1 = itemCoords(heroDepth, i, 1)
			if abs(x1 - x2) + abs(y1 - y2) <= dist then
				ink itemInk(item)
				print at y1, x1; itemChar(item)
			end if
		end if
	next i
end sub

sub drawVisibleMobs()
	dim i, offset, limit, mob, dist as ubyte
	dim x, y, x1, y1, x2, y2 as byte
	
	x2 = mobCoords(0, 0)
	y2 = mobCoords(0, 1)
	if lightTimer > 0 then
		dist = 5
	else
		dist = levelViewDist(heroDepth)
	end if

	offset = heroDepth * MHEIGHT
	limit = offset + MHEIGHT - 2
	for i = offset + 1 to limit
		mob = mobs(i)
		if mob <> NOBODY then
			x1 = mobCoords(i, 0)
			y1 = mobCoords(i, 1)
			if abs(x1 - x2) + abs(y1 - y2) <= dist then
				ink mobInk(mob)
				print at y1, x1; mobChar(mob)
				if mob = SHOGGOTH then
					processShoggoth(i)
				end if
			end if
		end if
	next i
	
	x = mobCoords(0, 0)
	y = mobCoords(0, 1)
	print at y, x; ink 7; "@"
end sub

sub drawBorder()
	dim i as ubyte
	print at 0, 0; "\ ."
	print at 0, MWIDTH + 1; "\. "
	for i = 1 to MWIDTH
		print at 0, i; "\.."
		print at MHEIGHT + 1, i; "\''"
	next i
	for i = 1 to MHEIGHT
		print at i, 0; "\ :"
		print at i, MWIDTH + 1; "\: "
	next i
	print at MHEIGHT + 1, 0; "\ '"
	print at MHEIGHT + 1, MWIDTH + 1; "\' "
end sub

sub printLevelNum()
	if heroDepth = 0 then
		print at 0, 7; ink 7; "Abandoned Village"
	else
		print at 0, 7; ink 7; "Catacomb Level "; heroDepth; "\.."
	end if
end sub

sub printHeroStats()
	ink 7: bright 1: print at 21, 7;
	print "Life: "; mobLife(0); "/"; heroMaxLife;
	if poisonTimer > 0 then
		print " Poisoned!"
	else
		print " XP: "; heroMaxDepth; "\''\''\''\''\''"
	end if
end sub

sub blankLine(n as ubyte)
	print at n, 0; "        "; "        "; "        "; "        "
end sub

sub blankViewport()
	dim y as ubyte
	for y = 1 to MHEIGHT
		print at y, 1; "          "; "          "; "          "
	next y
end sub

sub drawViewport()
	bright 0
	drawVisibleMap()
	bright 1
	drawVisibleItems()
	drawVisibleMobs()
end sub

sub drawTitlePage()
	ink 7: bright 1
	print at 3, 2; "You are lost in the woods."
	print at 5, 2; "Dark clouds hang in the sky."
	print at 7, 2; "The day has turned to night."
	print at 9, 2; "Now you will have to brave"
	print at 12, 2; ink 2; bold 1; "    The Spectral Dungeons"
	print at 15, 2; "       No Time To Play, 2013"
	print at 17, 2; "    http://notimetoplay.org/"
end sub

sub drawHelpPage()
	ink 7: bright 1
	print at 2, 2; bold 1; "        How to play"
	printat64(4, 4)
	print64("Dive to level 10 of the dungeon")
	printat64(7, 4)
	print64("and bring the golden idol back to the surface.")
	printat64(10, 4)
	print64("Fighting monsters doesn't benefit you.")
	printat64(13, 4)
	print64("The best weapon and armor is used automatically.")
	printat64(16, 4)
	print64("All the keys you need are shown during the game.")
	printat64(19, 4)
	print64("Remember, monsters hate light sources!")
end sub

sub drawCreditsPage()
	ink 7: bright 1
	print at 3, 2; "A game by No Time To Play."
	print at 6, 2; "Made with Boriel's ZXBasic."
	print at 9, 2; "Open source -- MIT License."
	print at 12, 2; "Don't claim you wrote it."
	print at 15, 2; "And there's NO WARRANTY."
end sub

dim helpPage as ubyte = 0
sub showGameHelp()
	ink 7: bright 1
	printat64(23, 0)
	helpPage = not helpPage
	if helpPage then
		print64("[H]elp [U]p [D]own [L]egend [G]et [E]at [A]light [I]nventory")
	else
		print64("Cursor keys/5,6,7,8: move; [.]: wait; Shift-Q: quit         ")
	end if
end sub

sub playEnding()
	ink 7
	bright 1
	printat64(2, 4)
	print64("As fresh surface air touches the idol,")
	pause 120
	printat64(4, 4)
	print64("its golden shine quickly becomes tarnished.")
	pause 120
	printat64(6, 4)
	print64("Vile gasses spew out of the idol. You drop it,")
	pause 120
	printat64(8, 4)
	print64("and it tumbles back down the stairs.")
	pause 120
	printat64(10, 4)
	print64("The entrance to the catacomb collapses, then...")
	pause 120
	printat64(12, 4)
	print64("...the clouds part and the sun comes out!")
	pause 120
	printat64(16, 14)
	print64("You have won!")
	pause 120
	blankLine(22)
	blankLine(23)
	print at 23, 0; "Press any key to continue"
	pause 0
end sub

sub playDeath()
	ink 7
	bright 1
	pause 120
	blankLine(23)
	print at 23, 0; "Press any key to continue"
	pause 0
end sub


sub handleGameKey(k as string)
	dim c as ubyte
	c = code(k)
	if c = 8 or k = "5" then
		moveHero(-1, 0)
	elseif c = 10 or k = "6" then
		moveHero(0, 1)
	elseif c = 11 or k = "7" then
		moveHero(0, -1)
	elseif c = 9 or k = "8" then
		moveHero(1, 0)
	elseif k = ">" or k = "d" or k = "D" then
		moveHeroDown()
	elseif k = "<" or k = "u" or k = "U" then
		moveHeroUp()
	elseif k = "." then
		blankLine(22)
		print at 22, 0; ink 7; "You wait. Time passes..."
	elseif k = "l" or k = "L" then
		legend()
	elseif k = "g" or k = "G"
		getItemAt(mobCoords(0, 0), mobCoords(0, 1))
	elseif k = "e" or k = "E"
		eat()
	elseif k = "a" or k = "A"
		alight()
	elseif k = "i" or k = "I"
		showInventory()
	elseif k = "?" or k = "h" or k = "H"
		showGameHelp()
	elseif k = "Q"
		gameover = 1
	end if
end sub

sub initGame()
	dim i as ubyte
	mobs(0) = HUMAN
	mobCoords(0, 0) = 1
	mobCoords(0, 1) = 10
	mobLife(0) = 2 * mobDice(HUMAN) - 1
	mobActions(0) = APREFRESH
	for i = 1 to ITEMTYPES
		inventory(i) = 0
	next i
	heroDepth = 0
	heroMaxDepth = 0
	heroMaxLife = mobLife(0)
	heroWeapon = NOTHING
	heroArmor = NOTHING
	poisonTimer = 0

	' Initialize idol, since we always know where it starts out.
	items(MAXLEVEL, MHEIGHT) = IDOL
	itemCoords(MAXLEVEL, MHEIGHT, 0) = MWIDTH - 1
	itemCoords(MAXLEVEL, MHEIGHT, 1) = MHEIGHT - 1
	
	helpPage = 0
	gameover = 0 ' ESSENTIAL!
	
	randomize
	for i = 0 to MAXLEVEL
		levelSeeds(i) = int(RND() * 2100000000) + 1
	next i

	blankViewport()
	print at 10, 8; "Building village"
	randomize levelSeeds(0)
	generateVillage()
	populateLevel(0)
	createItems(0)
	blankViewport()
	printLevelNum()
	printHeroStats()
	showGameHelp()
end sub

sub gameLoop()
	dim k as string
	do
		drawViewport()
		pause 0
		k = inkey$()
		'print at 21, 2
		if gameover = 0 then
			handleGameKey(k)
			if mobActions(0) > 0 then
				mobActions(0) = mobActions(0) - mobDice(HUMAN)
			else
				mobActions(0) = mobActions(0) _
					+ APREFRESH + heroMaxDepth
				processMobs()
			end if
			processMobs()
			processPoison()
			processHealing()
			processLight()
		end if
	loop until gameover <> 0
end sub


border 0
paper 0

dim k as string
do
	ink 7
	bright 1
	cls
	drawBorder()
	printat64(23, 0)
	print64("[N]ew game [H]ow to play [C]redits")

	blankViewport()
	drawTitlePage()
	pause 0
	k = inkey$()
	if k = "n" or k = "N" then
		initGame()
		gameLoop()
	elseif k = "h" or k = "H" then
		blankViewport()
		drawHelpPage()
		blankLine(23)
		printat64(23, 0)
		print64("Press any key")
		pause 0
	elseif k = "c" or k = "C" then
		blankViewport()
		drawCreditsPage()
		blankLine(23)
		printat64(23, 0)
		print64("Press any key")
		pause 0
	end if
loop until k = "Q"
