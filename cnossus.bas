' Escape from Cnossus -- a roguelike for the ZX Spectrum
' 2013-07-10 Felix Plesoianu <felix@plesoianu.ro>
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

const BLACK as ubyte = 0
const BLUE as ubyte = 1
const RED as ubyte = 2
const MAGENTA as ubyte = 3
const GREEN as ubyte = 4
const CYAN as ubyte = 5
const YELLOW as ubyte = 6
const WHITE as ubyte = 7

const MWIDTH as ubyte = 30
const MHEIGHT as ubyte = 20

const MAXLEVEL as ubyte = 20
const MAXMOBS as ubyte = MHEIGHT
const MAXITEMS as ubyte = MHEIGHT

const APREFRESH as ubyte = 20 ' Action point refresh.

const BLANK as ubyte = 0
const DOT as ubyte = 1
const COMMA as ubyte = 2
const VBAR as ubyte = 3
const STAR as ubyte = 4
const TILDA as ubyte = 5
const HASH as ubyte = 6
const GT as ubyte = 7
const ANDSIGN as ubyte = 8

dim tileChar(0 to 8) as string
tileChar(BLANK) = " "
tileChar(DOT) = "!"
tileChar(COMMA) = chr$(34)
tileChar(VBAR) = "#"
tileChar(STAR) = "$"
tileChar(TILDA) = "%"
tileChar(HASH) = "&"
tileChar(GT) = "'"
tileChar(ANDSIGN) = "("
dim tileName(0 to 8) as string
tileName(BLANK) = "void"
tileName(DOT) = "floor"
tileName(COMMA) = "mosaic"
tileName(VBAR) = "column"
tileName(STAR) = "basin"
tileName(TILDA) = "pool"
tileName(HASH) = "wall"
tileName(GT) = "stairs down"
tileName(ANDSIGN) = "statue"

dim tileInk(0 to 8) as ubyte => _
	{BLACK, WHITE, MAGENTA, RED, CYAN, CYAN, YELLOW, WHITE, MAGENTA}
dim canWalk(0 to 8) as ubyte => {0, 1, 1, 0, 0, 0, 0, 1, 0}


const ITEMTYPES as ubyte = 23

const NOTHING as ubyte = 0
const CANDLE as ubyte = 1
const TORCH as ubyte = 2
const KNIFE as ubyte = 3
const SICKLE as ubyte = 4
const ADZE as ubyte = 5
const AXE as ubyte = 6
const DOUBLEAXE as ubyte = 7
const SWORD as ubyte = 8
const SPEAR as ubyte = 9
const RAWMEAT as ubyte = 10
const DRIEDFRUIT as ubyte = 11
const CHEESE as ubyte = 12
const OILLAMP as ubyte = 13
const BAG as ubyte = 14
const JAR as ubyte = 15
const COFFER as ubyte = 16
const GREAVE as ubyte = 17
const ARMGUARD as ubyte = 18
const PAULDRON as ubyte = 19
const CLOTH as ubyte = 20
const LEATHER as ubyte = 21
const SCALE as ubyte = 22
const SHIELD as ubyte = 23

dim itemChar(1 to ITEMTYPES) as string
itemChar(CANDLE) = ")" '\'
itemChar(TORCH) = "*"
itemChar(KNIFE) = "+" '(
itemChar(SICKLE) = ","
itemChar(ADZE) = "-"
itemChar(AXE) = "." ')
itemChar(DOUBLEAXE) = "/"
itemChar(SWORD) = "0" '/
itemChar(SPEAR) = "1"
itemChar(RAWMEAT) = "2" '%
itemChar(DRIEDFRUIT) = "3"
itemChar(CHEESE) = "4"
itemChar(OILLAMP) = "5" '\'
itemChar(BAG) = "6" '?
itemChar(JAR) = "7" '!
itemChar(COFFER) = "8" '=
itemChar(GREAVE) = "9" '[
itemChar(ARMGUARD) = ":"
itemChar(PAULDRON) = ";"
itemChar(CLOTH) = "<" ']
itemChar(LEATHER) = "="
itemChar(SCALE) = ">"
itemChar(SHIELD) = "?"
dim itemName(0 to ITEMTYPES) as string
itemName(NOTHING) = "nothing"
itemName(CANDLE) = "candle"
itemName(TORCH) = "torch"
itemName(KNIFE) = "knife"
itemName(SICKLE) = "sickle"
itemName(ADZE) = "adze"
itemName(AXE) = "axe"
itemName(DOUBLEAXE) = "double axe"
itemName(SWORD) = "short sword"
itemName(SPEAR) = "spear"
itemName(RAWMEAT) = "raw meat"
itemName(DRIEDFRUIT) = "dried fruit"
itemName(CHEESE) = "cheese"
itemName(OILLAMP) = "oil lamp"
itemName(BAG) = "bag"
itemName(JAR) = "big jar"
itemName(COFFER) = "coffer"
itemName(GREAVE) = "greave"
itemName(ARMGUARD) = "armguard"
itemName(PAULDRON) = "pauldron"
itemName(CLOTH) = "linen tunic"
itemName(LEATHER) = "leather vest"
itemName(SCALE) = "scale mail"
itemName(SHIELD) = "shield"
dim itemInk(1 to ITEMTYPES) as ubyte => _
	{YELLOW, RED, _
	 YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, YELLOW, _
	 RED, BLUE, WHITE, WHITE, WHITE, _
	 WHITE, RED, _
	 YELLOW, RED, RED, WHITE, RED, YELLOW, YELLOW}
dim maxCarry(1 to ITEMTYPES) as byte => _
	{-1, -1, _
	 1, 1, 1, 1, 1, 1, 1, _
	 -1, -1, -1, -1, 1, _
	 0, 0, _
	 2, 2, 2, 1, 1, 1, 1}
dim itemAttack(1 to ITEMTYPES) as ubyte => _
	{0, 0, 2, 3, 5, 8, 10, 12, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
dim itemDefense(1 to ITEMTYPES) as ubyte => _
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 3, 5}


const MOBTYPES as ubyte = 16

const NOBODY as ubyte = 0
const TAUR as ubyte = 1
const SNAKE as ubyte = 2
const SPIDER as ubyte = 3
const RAT as ubyte = 4
const SCORPION as ubyte = 5
const CENTIPEDE as ubyte = 6
const CERBERUS as ubyte = 7
const HARPY as ubyte = 8
const CHIMERA as ubyte = 9
const MANTICORE as ubyte = 10
const CROC as ubyte = 11
const DRAKON as ubyte = 12
const BOAR as ubyte = 13
const GRIFFIN as ubyte = 14
const SPHINX as ubyte = 15
const BULL as ubyte = 16

dim mobChar(1 to MOBTYPES) as string
mobChar(TAUR) = "@"
mobChar(SNAKE) = "s"
mobChar(SPIDER) = "m"
mobChar(RAT) = "r"
mobChar(SCORPION) = "i"
mobChar(CENTIPEDE) = "j"
mobChar(CERBERUS) = "c"
mobChar(HARPY) = "h"
mobChar(CHIMERA) = "H"
mobChar(MANTICORE) = "M"
mobChar(CROC) = "C"
mobChar(DRAKON) = "D"
mobChar(BOAR) = "b"
mobChar(GRIFFIN) = "G"
mobChar(SPHINX) = "X"
mobChar(BULL) = "B"
dim mobName(1 to MOBTYPES) as string
mobName(TAUR) = "minotaur"
mobName(SNAKE) = "snake"
mobName(SPIDER) = "spider"
mobName(RAT) = "sewer rat"
mobName(SCORPION) = "scorpion"
mobName(CENTIPEDE) = "centipede"
mobName(CERBERUS) = "cerberus"
mobName(HARPY) = "harpy"
mobName(CHIMERA) = "chimera"
mobName(MANTICORE) = "manticore"
mobName(CROC) = "crocodile"
mobName(DRAKON) = "drakon"
mobName(BOAR) = "wild boar"
mobName(GRIFFIN) = "griffin"
mobName(SPHINX) = "sphinx"
mobName(BULL) = "bull"
dim mobInk(1 to MOBTYPES) as ubyte => _
	{WHITE, GREEN, RED, RED, RED, WHITE, _
	 BLUE, WHITE, YELLOW, YELLOW, GREEN, GREEN, _
	 RED, YELLOW, YELLOW, BLUE}
dim mobDice(1 to MOBTYPES) as ubyte => _
	{10, 8, 4, 6, 4, 6, 8, 8, 12, 12, 12, 20, 8, 12, 12, 12}
dim mobHostility(1 to MOBTYPES) as ubyte => _
	{0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1, 2}
dim mobPoison(1 to MOBTYPES) as ubyte => _
	{0, 6, 4, 0, 8, 8, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0}
dim mobDrops(1 to MOBTYPES, 0 to 2) as ubyte => _
	{{NOTHING, NOTHING, NOTHING}, _
	 {RAWMEAT, ARMGUARD, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {RAWMEAT, NOTHING, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {RAWMEAT, LEATHER, NOTHING}, _
	 {SHIELD, SHIELD, NOTHING}, _
	 {RAWMEAT, RAWMEAT, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {NOTHING, NOTHING, NOTHING}, _
	 {RAWMEAT, RAWMEAT, RAWMEAT}}

dim levelCellSize(0 to 4, 0 to 1) as ubyte => _
	{{7, 7}, {7, 5}, {5, 5}, {5, 3}, {3, 3}}
dim levelMobs(1 to MAXLEVEL, 0 to 4) as ubyte => _
	{{SNAKE, BOAR, CERBERUS, NOBODY, NOBODY}, _
	{CENTIPEDE, BOAR, HARPY, NOBODY, NOBODY}, _
	{SNAKE, CERBERUS, RAT, NOBODY, NOBODY}, _
	{CENTIPEDE, HARPY, RAT, NOBODY, NOBODY}, _
	{SNAKE, CERBERUS, BOAR, NOBODY, NOBODY}, _
	{CENTIPEDE, HARPY, BOAR, NOBODY, NOBODY}, _
	{SNAKE, NOBODY, CERBERUS, RAT, NOBODY}, _
	{SPIDER, RAT, NOBODY, HARPY, NOBODY}, _
	{SCORPION, BOAR, CROC, NOBODY, NOBODY}, _
	{SPIDER, BOAR, HARPY, NOBODY, NOBODY}, _
	{SCORPION, CROC, RAT, RAT, NOBODY}, _
	{SPIDER, RAT, CERBERUS, HARPY, NOBODY}, _
	{SCORPION, CROC, BOAR, NOBODY, NOBODY}, _
	{SPIDER, BOAR, RAT, HARPY, NOBODY}, _
	{MANTICORE, GRIFFIN, CROC, NOBODY, NOBODY}, _
	{GRIFFIN, BULL, SPIDER, NOBODY, NOBODY}, _
	{SPHINX, MANTICORE, BULL, NOBODY, NOBODY}, _
	{SPHINX, CHIMERA, BULL, NOBODY, NOBODY}, _
	{MANTICORE, CHIMERA, BULL, NOBODY, NOBODY}, _
	{DRAKON, GRIFFIN, BULL, NOBODY, NOBODY}}
dim levelItems(1 to MAXLEVEL, 0 to 4) as ubyte => _
	{{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, NOTHING, COFFER, NOTHING, TORCH}, _
	{JAR, DOUBLEAXE, COFFER, NOTHING, TORCH}, _
	{JAR, DOUBLEAXE, COFFER, NOTHING, TORCH}, _
	{JAR, DOUBLEAXE, COFFER, NOTHING, TORCH}, _
	{JAR, SPEAR, COFFER, SHIELD, TORCH}, _
	{JAR, SPEAR, COFFER, SHIELD, TORCH}, _
	{JAR, SPEAR, COFFER, SHIELD, TORCH}}
dim jarDrops(1 to MAXLEVEL, 0 to 4) as ubyte => _
	{{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, NOTHING, NOTHING, NOTHING}, _
	{NOTHING, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, NOTHING, NOTHING, NOTHING}, _
	{NOTHING, NOTHING, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, NOTHING, NOTHING, NOTHING}, _
	{NOTHING, NOTHING, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, NOTHING, NOTHING, NOTHING}, _
	{DRIEDFRUIT, NOTHING, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, NOTHING, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, NOTHING, CHEESE, NOTHING, NOTHING}, _
	{DRIEDFRUIT, CANDLE, CHEESE, NOTHING, NOTHING}}
dim cofferDrops(1 to MAXLEVEL, 0 to 4) as ubyte => _
	{{CLOTH, NOTHING, KNIFE, NOTHING, BAG}, _
	 {CLOTH, NOTHING, KNIFE, NOTHING, BAG}, _
	 {LEATHER, NOTHING, KNIFE, NOTHING, BAG}, _
	 {CLOTH, NOTHING, KNIFE, NOTHING, BAG}, _
	 {CLOTH, NOTHING, SICKLE, NOTHING, BAG}, _
	 {GREAVE, NOTHING, SICKLE, NOTHING, BAG}, _
	 {GREAVE, NOTHING, SICKLE, NOTHING, BAG}, _
	 {GREAVE, NOTHING, SICKLE, NOTHING, BAG}, _
	 {ARMGUARD, NOTHING, ADZE, NOTHING, BAG}, _
	 {ARMGUARD, NOTHING, ADZE, NOTHING, BAG}, _
	 {ARMGUARD, NOTHING, ADZE, NOTHING, OILLAMP}, _
	 {PAULDRON, NOTHING, ADZE, NOTHING, BAG}, _
	 {PAULDRON, NOTHING, AXE, NOTHING, OILLAMP}, _
	 {PAULDRON, NOTHING, AXE, NOTHING, BAG}, _
	 {LEATHER, NOTHING, AXE, NOTHING, OILLAMP}, _
	 {LEATHER, NOTHING, AXE, NOTHING, BAG}, _
	 {LEATHER, NOTHING, SWORD, NOTHING, OILLAMP}, _
	 {SCALE, NOTHING, SWORD, NOTHING, BAG}, _
	 {SCALE, NOTHING, SWORD, NOTHING, OILLAMP}, _
	 {SCALE, NOTHING, SWORD, NOTHING, BAG}}


dim gameover as byte = 0

dim map(1 to MHEIGHT, 1 to MWIDTH) as ubyte

sub fillMap(tile as ubyte)
	dim x, y as ubyte
	for y = 1 to MHEIGHT
		for x = 1 to MWIDTH
			map(y, x) = tile
		next x
	next y
end sub


sub furnishRoom(x1 as ubyte, y1 as ubyte, x2 as ubyte, y2 as ubyte)
	dim w, h, x, y as ubyte
	
	w = x2 - x1 + 1
	h = y2 - y1 + 1
	
	if w = 3 and h = 3 then
		if rnd() < 0.5 then
			map(y1 + 1, x1 + 1) = STAR
		else
			map(y1 + 1, x1 + 1) = ANDSIGN
		end if
	elseif w = 3 then
		for y = y1 + 1 to y2 - 1 step 2
			map(y, x1 + 1) = VBAR
		next y
		if h mod 2 = 0 then
			if rnd() < 0.5 then
				map(y2, x2 - 1) = STAR
			else
				map(y2, x2 - 1) = ANDSIGN
			end if
		end if
	elseif h = 3 then
		for x = x1 + 1 to x2 - 1 step 2
			map(y1 + 1, x) = VBAR
		next x
		if w mod 2 = 0 then
			if rnd() < 0.5 then
				map(y2 - 1, x2) = STAR
			else
				map(y2 - 1, x2) = ANDSIGN
			end if
		end if
	elseif w = 4 or h = 4 then
		for y = y1 + 1 to y2 - 1
			for x = x1 + 1 to x2 - 1
				map(y, x) = TILDA
			next x
		next y
	'elseif w = 5 and h = 5 then
	'	map(y1 + 1, x1 + 1) = VBAR
	'	map(y1 + 1, x2 - 1) = VBAR
	'	map(y2 - 1, x1 + 1) = VBAR
	'	map(y2 - 1, x2 - 1) = VBAR
	elseif w = 5 then
		for y = y1 + 1 to y2 - 1 step 2
			map(y, x1 + 1) = VBAR
			map(y, x2 - 1) = VBAR
		next y
		if h mod 2 = 0 then
			if rnd() < 0.5 then
				map(y2, x2 - 2) = STAR
			else
				map(y2, x2 - 2) = ANDSIGN
			end if
		end if
	elseif h = 5 then
		for x = x1 + 1 to x2 - 1 step 2
			map(y1 + 1, x) = VBAR
			map(y2 - 1, x) = VBAR
		next x
		if w mod 2 = 0 then
			if rnd() < 0.5 then
				map(y2 - 2, x2) = STAR
			else
				map(y2 - 2, x2) = ANDSIGN
			end if
		end if
	elseif w = 7 and h = 7 then
		for y = y1 + 1 to y2 - 1 step 2
			for x = x1 + 1 to x2 - 1 step 2
				map(y, x) = VBAR
			next x
		next y
		if rnd() < 0.5 then
			map(y1 + 3, x1 + 3) = STAR
		else
			map(y1 + 3, x1 + 3) = ANDSIGN
		end if
	elseif w > 2 and h > 2 then
		for y = y1 to y2
			map(y, x1) = COMMA
			map(y, x2) = COMMA
		next y
		for x = x1 to x2
			map(y1, x) = COMMA
			map(y2, x) = COMMA
		next x
		if w = 6 and h = 6 then
			furnishRoom(x1 + 1, y1 + 1, x2 - 1, y2 - 1)
		elseif w = 9 and h = 9 then
			furnishRoom(x1 + 1, y1 + 1, x2 - 1, y2 - 1)
		end if
	end if
end sub

dim cellwidth, cellheight as ubyte

function subdivideWide(x1 as ubyte, y1 as ubyte, x2 as ubyte, y2 as ubyte) _
as ubyte
	dim w, h, x, y, wall1, wall2, doory as ubyte
	w = x2 - x1 + 1
	h = y2 - y1 + 1
	' You have to check both dimensions
	' or you'll get oddly skewed levels.
	if w < cellwidth or h < cellheight or w = h then
		furnishRoom(x1, y1, x2, y2)
		return 0
	end if

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
	if w < cellwidth or h < cellheight or w = h then
		furnishRoom(x1, y1, x2, y2)
		return 0
	end if

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

sub generatePalaceFloor(levelNum as ubyte)
	dim x, y, r as ubyte

	fillMap(DOT)

	for x = 1 to MWIDTH
		map(1, x) = HASH
		map(MHEIGHT, x) = HASH
	next x
	for y = 1 to MHEIGHT
		map(y, 1) = HASH
		map(y, MWIDTH) = HASH
	next y

	r = int(rnd() * 5)
	cellwidth = levelCellSize(r, 0)
	cellheight = levelCellSize(r, 1)
	subdivideWide(2, 2, MWIDTH - 1, MHEIGHT - 1)
	
	if levelNum mod 2 = 1 then
		map(MHEIGHT - 1, MWIDTH - 1) = GT
	else
		map(MHEIGHT - 1, 2) = GT
	end if
end sub


' Coords are x, y for any mob from 0 to MAXMOBS
' Mob 0 (zero) is always the player.
dim mobCoords(0 to MAXMOBS, 0 to 1) as ubyte
dim mobs(0 to MAXMOBS) as ubyte
dim mobLife(0 to MAXMOBS) as byte ' It can get negative from a hit!
dim mobActions(0 to MAXMOBS) as byte

dim heroDepth as ubyte = 0
dim heroMaxLife as ubyte
dim heroMaxActions as ubyte = APREFRESH
dim heroDamageBonus as ubyte = 0
heroMaxLife = 2 * mobDice(TAUR)
dim heroWeapon as ubyte = NOTHING
dim heroArmor as ubyte = NOTHING
dim poisonTimer as ubyte = 0
dim lightTimer as ubyte = 0

dim inventory(1 to ITEMTYPES) as ubyte


sub populateLevel(levelNum as ubyte)
	dim x, y, mobNum as ubyte
	for y = 2 to MHEIGHT - 1
		mobNum = y
		mobs(mobNum) = levelMobs(levelNum, int(rnd() * 5))
		mobLife(mobNum) = 2 * mobDice(mobs(mobNum))
		do
			x = int(rnd() * (MWIDTH - 2)) + 1
		loop until canWalk(map(y, x))
		mobCoords(mobNum, 0) = x
		mobCoords(mobNum, 1) = y
		mobActions(mobNum) = APREFRESH
	next y
end sub

function getMobAt(x as ubyte, y as ubyte) as integer
	dim i as ubyte
	for i = 0 to MAXMOBS
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
		return heroDamageBonus
	else
		return 0
	end if
end function

function attackBonus(mobNum as ubyte) as ubyte
	if mobNum = 0 then
		return itemAttack(heroWeapon)
	else
		return int(heroDepth / 2)
	end if
end function

function defenseBonus(mobNum as ubyte) as ubyte
	if mobNum = 0 then
		return itemDefense(heroArmor)
	else
		return int(heroDepth / 2)
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
			handleMobDrop(defender)
			mobs(defender) = NOBODY
			if attacker = 0 then
				print "You kill the "; mobName(def); "!"
			elseif defender = 0 then
				print "The "; mobName(att); " kills you!!"
				'printHeroStats()
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
				'printHeroStats()
			end if
		end if
	elseif margin = 0 then
		if attacker = 0 then
			print "You graze the "; mobName(def); "."
		elseif defender = 0 then
			if mobPoison(att) > 0 then
				poisonTimer = poisonTimer _
					+ int(rnd() * mobPoison(att)) + 1
				'printHeroStats()
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

	otherMob = getMobAt(newx, newy)
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

	otherMob = getMobAt(newx, newy)
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
	blankLine(22)
	if map(mobCoords(0, 1), mobCoords(0, 0)) = GT then
		heroDepth = heroDepth + 1
		blankViewport()
		print at 10, 2; ink 7; "  You stumble in darkness,  "
		print at 11, 2; ink 7; "stairs crumbling behind you!"
		if heroDepth <= MAXLEVEL then
			generatePalaceFloor(heroDepth)
			mobLife(0) = mobLife(0) + 1
			populateLevel(heroDepth)
			createItems(heroDepth)
			'pause 25
			levelUp()
			blankViewport()
			clearSeen()
			printLevelNum()
			'printHeroStats()
		
			if heroDepth mod 2 = 1 then
				mobCoords(0, 0) = 2
			else
				mobCoords(0, 0) = MWIDTH - 1
			end if
			mobCoords(0, 1) = 2
		else
			blankViewport()
			playEnding()
			gameover = 1
		end if
	else
		print at 22, 0; ink 7; "There's no way down from here."
	end if
end sub

sub moveHeroUp()
	blankLine(22)
	print at 22, 0; ink 7; "There's no going back."
end sub

sub levelUp()
	dim k as string
	dim c as ubyte

	blankViewport()
	ink 7
	print at 5, 2; "You feel:"
	print at 8, 2; "1) stronger"
	print at 10, 2; "2) sturdier"
	print at 12, 2; "3) faster"
	print at 15, 2; "0) whatever"
	pause 0
	k = inkey$()
	if k = "1" then
		heroDamageBonus = heroDamageBonus + 1
	elseif k = "2" then
		heroMaxLife = heroMaxLife + 1
	elseif k = "3" then
		heroMaxActions = heroMaxActions + 1
	else
		c = int(rnd() * 3)
		if c = 1 then
			heroDamageBonus = heroDamageBonus + 1
		elseif c = 2 then
			heroMaxLife = heroMaxLife + 1
		elseif c = 3 then
			heroMaxActions = heroMaxActions + 1
		end if
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

sub processMobs()
	dim i as ubyte
	for i = 1 to MAXMOBS ' Skip the player!
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

sub processPoison()
	if poisonTimer > 0 then
		mobLife(0) = mobLife(0) - 1
		poisonTimer = poisonTimer - 1
		'printHeroStats()
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


dim itemCoords(1 to MAXITEMS, 0 to 1) as ubyte
dim items(1 to MAXITEMS) as ubyte
dim itemHere as ubyte = 0

sub createItems(levelNum as ubyte)
	dim x, y as ubyte
	items(1) = NOTHING
	for y = 2 to MHEIGHT - 1
		items(y) = levelItems(levelNum, int(rnd() * 5))
		if items(y) <> NOTHING then
			do
				x = int(rnd() * (MWIDTH - 2)) + 1
			loop until canWalk(map(y, x))
			itemCoords(y, 0) = x
			itemCoords(y, 1) = y
		end if
	next y
	items(MHEIGHT) = NOTHING
end sub

function getFreeItemSlot() as ubyte
	dim i as ubyte = 0
	for i = 1 to MHEIGHT
		if items(i) = 0
			return i
		end if
	next i
	return i
end function

sub handleMobDrop(mobNum)
	dim item as ubyte
	item = getFreeItemSlot()
	if item > 0 then
		items(item) = mobDrops(mobs(mobNum), int(rnd() * 3))
		itemCoords(item, 0) = mobCoords(mobNum, 0)
		itemCoords(item, 1) = mobCoords(mobNum, 1)
	end if
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

function openItem(item as ubyte) as ubyte
	dim found as ubyte
	blankLine(22)
	if item = JAR then
		found = jarDrops(heroDepth, int(rnd() * 5))
	elseif item = COFFER then
		found = cofferDrops(heroDepth, int(rnd() * 5))
	else
		print at 22, 0; ink 7; "That's not a thing you can open."
		return item
	end if
	if found = NOTHING then
		ink 7: print at 22, 0;
		print "The "; itemName(item); " crumbles to dust."
	elseif maxCarry(found) > -1 then
		print at 22, 0; ink 7; "You find: "; itemName(found); "."
	else
		print at 22, 0; ink 7; "You find: "; itemName(found); "."
	end if
	return found
end function

sub openItemHere()
	if itemHere > 0 then
		items(itemHere) = openItem(items(itemHere))
	else
		print at 22, 0; ink 7; "There's nothing here to open."
	end if
end sub

function getItem(item as ubyte) as ubyte
	blankLine(22)
	ink 7: print at 22, 0;
	if maxCarry(item) = -1 then
		if (inventory(BAG) > 0) or (inventory(item) < 1) then
			inventory(item) = inventory(item) + 1
			print "You pick up the ";
			print itemName(item); "."
			return 1
		else
			print "You need a bag to carry more."
			return 0
		end if
	elseif maxCarry(item) = 0 then
		print "That's hardly portable."
		return 0
	elseif inventory(item) < maxCarry(item)
		inventory(item) = inventory(item) + 1
		print "You pick up the ";
		print itemName(item); "."
		
		if itemAttack(item) > itemAttack(heroWeapon) then
			heroWeapon = item
		end if
		if itemDefense(item) > 0 then
			heroArmor = heroArmor + itemDefense(item)
		end if
		return 1
	else
		print "Already got enough of those."
		return 0
	end if
end function

sub getItemHere()
	if itemHere > 0 then
		if getItem(items(itemHere)) then
			items(itemHere) = NOTHING
		end if
	else
		print at 22, 0; ink 7; "You grope at the empty floor."
	end if
end sub

sub eat()
	dim k as string
	dim food, life as ubyte

	blankViewport()
	ink 7
	print at 5, 2; "Eat what?"
	if inventory(DRIEDFRUIT) > 0 then
		print at 8, 2; "1) dried fruit"
	end if
	if inventory(CHEESE) > 0 then
		print at 10, 2; "2) cheese"
	end if
	if inventory(RAWMEAT) > 0 then
		print at 12, 2; "3) raw meat"
	end if
	print at 15, 2; "0) nothing"
	pause 0
	k = inkey$()
	if k = "1" then
		food = DRIEDFRUIT
		life = 3
	elseif k = "2" then
		food = CHEESE
		life = 5
	elseif k = "3" then
		food = RAWMEAT
		life = 8
	else
		restoreSeen()
		return
	end if
	if inventory(food) > 0 then
		inventory(food) = inventory(food) - 1
		if mobLife(0) < heroMaxLife then
			mobLife(0) = mobLife(0) + life
		end if
		print at 22, 0; "You eat some "; itemName(food); ". Mmm!"
	else
		print at 22, 0; "But you don't have any."
	end if
	restoreSeen()
end sub

sub alight()
	dim k as string
	dim light, timeout as ubyte

	blankViewport()
	ink 7
	print at 5, 2; "Light what?"
	if inventory(TORCH) > 0 then
		print at 8, 2; "1) a torch"
	end if
	if inventory(CANDLE) > 0 then
		print at 10, 2; "2) a candle"
	end if
	if inventory(OILLAMP) > 0 then
		print at 12, 2; "3) an oil lamp"
	end if
	print at 15, 2; "0) nothing"
	pause 0
	k = inkey$()
	if k = "1" then
		light = TORCH
		timeout = MHEIGHT / 2
	elseif k = "2" then
		light = CANDLE
		timeout = MWIDTH / 2
	elseif k = "3" then
		light = OILLAMP
		timeout = (MHEIGHT + MWIDTH) / 2
	else
		restoreSeen()
		return
	end if
	if inventory(light) > 0 then
		inventory(light) = inventory(light) - 1
		if lightTimer < timeout then
			lightTimer = timeout
		end if
		print at 22, 0; "You light the "; itemName(light); "."
	else
		print at 22, 0; "But you don't have any."
	end if
	restoreSeen()
end sub

sub showInventory()
	dim i, offset as ubyte

	blankViewport()
	ink 7: bright 1
	
	print at 2, 2; "You are carrying:"
	
	print at 4, 2; inventory(DRIEDFRUIT); "x dried fruit"
	print at 6, 2; inventory(CHEESE); "x cheese"
	print at 8, 2; inventory(RAWMEAT); "x raw meat"

	print at 10, 2; inventory(TORCH); "x torch"
	print at 12, 2; inventory(CANDLE); "x candle"
	print at 14, 2; inventory(OILLAMP); "x oil lamp"
	
	offset = 0
	for i = GREAVE to SHIELD
		print at 3 + offset, 15; inventory(i); "x "; itemName(i)
		offset = offset + 2
	next i
	
	print at 17, 8; "Weapon: "; itemName(heroWeapon)
	print at 19, 2; "Press any key"
	pause 0
	restoreSeen()
	blankLine(22)
end sub


dim seenMap(1 to MHEIGHT, 1 to MWIDTH) as ubyte

sub clearSeen()
	dim x, y as ubyte
	for y = 1 to MHEIGHT
		for x = 1 to MWIDTH
			seenMap(y, x) = 0
		next x
	next y
end sub

sub restoreSeen()
	dim x, y, tile as ubyte
	bright 0
	loadGraphics(1)
	for y = 1 to MHEIGHT
		print at y, 1;
		for x = 1 to MWIDTH
			tile = seenMap(y, x)
			if tile <> BLANK then
				print ink tileInk(tile); tileChar(tile);
			else
				print " ";
			end if
		next x
	next y
	loadGraphics(0)
end sub

sub drawMap(x1 as ubyte, y1 as ubyte, x2 as ubyte, y2 as ubyte)
	dim x, y, tile as ubyte
	for y = y1 to y2
		print at y, x1;
		for x = x1 to x2
			tile = map(y, x)
			print ink tileInk(tile); tileChar(tile);
			seenMap(y, x) = tile
		next x
	next y
end sub

sub drawVisibleMap()
	dim x1, x2, y1, y2, dist as byte
	if lightTimer > 0 then
		dist = 5
	else
		dist = 2
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
		dist = 2
	end if

	itemHere = 0
	for i = 1 to MAXITEMS
		item = items(i)
		if item <> NOTHING then
			x1 = itemCoords(i, 0)
			y1 = itemCoords(i, 1)
			if abs(x1 - x2) + abs(y1 - y2) <= dist then
				ink itemInk(item)
				print at y1, x1; itemChar(item)
				if x1 = x2 and y1 = y2 then
					itemHere = i
				end if
			end if
		end if
	next i
end sub

sub drawVisibleMobs()
	dim i, mob, dist as ubyte
	dim x, y, x1, y1, x2, y2 as byte
	
	x2 = mobCoords(0, 0)
	y2 = mobCoords(0, 1)
	if lightTimer > 0 then
		dist = 5
	else
		dist = 2
	end if

	for i = 1 to MAXMOBS
		mob = mobs(i)
		if mob <> NOBODY then
			x1 = mobCoords(i, 0)
			y1 = mobCoords(i, 1)
			if abs(x1 - x2) + abs(y1 - y2) <= dist then
				ink mobInk(mob)
				print at y1, x1; mobChar(mob)
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
	print at 0, 9; ink 7; "Palace Level "; heroDepth
end sub

sub printHeroStats()
	ink 7: bright 1: print at 21, 7;
	print "Life: "; mobLife(0); "/"; heroMaxLife;
	if poisonTimer > 0 then
		print " Poisoned!"
	elseif lightTimer > 0 then
		print " Light: "; lightTimer; "\''"
	else
		print " AP: "; mobActions(0); "\''\''\''\''\''"
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
	loadGraphics(1)
	drawVisibleMap()
	bright 1
	drawVisibleItems()
	loadGraphics(0)
	drawVisibleMobs()
end sub

sub drawTitlePage()
	ink 7: bright 1
	print at 2, 2; "They call you the Minotaur."
	print at 4, 2; "For decades, they fed you..."
	print at 6, 2; "...with sacrifices."
	print at 8, 2; "But now, they have stopped."
	print at 10, 2; "It is time for you to..."
	print at 13, 2; ink 2; bold 1; "    Escape from Cnossus"
	print at 16, 2; "       No Time To Play, 2013"
	print at 18, 2; "    http://notimetoplay.org/"
end sub

sub drawHelpPage()
	ink 7: bright 1
	print at 2, 2; bold 1; "        How to play"
	printat64(4, 4)
	print64("Descend the 20 floors of the palace")
	printat64(7, 4)
	print64("and take the last stairs. You can never go back.")
	printat64(10, 4)
	print64("A few monsters are edible or have usable hides.")
	printat64(13, 4)
	print64("The best weapon is chosen for you. Armor adds up.")
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
		print64("[H]elp [D]own [L]egend [O]pen [G]et [E]at [A]light [I]nventory")
	else
		print64("Cursor keys/5,6,7,8: move; [.]: wait; Shift-Q: quit           ")
	end if
end sub

sub playEnding()
	ink 7
	bright 1
	printat64(2, 2)
	print64("At the bottom of the staircase, a short tunnel opens up onto")
	pause 120
	printat64(4, 2)
	print64("... blue sky! A road descends among wind-swept trees towards")
	pause 120
	printat64(6, 2)
	print64("a stream and a group of strange buildings. As you look, the")
	pause 120
	printat64(8, 2)
	print64("whirring of a giant insect in the sky makes you turn around.")
	pause 120

	printat64(11, 2)
	print64("Then you see the palace, rising majestically along the back")
	pause 120
	printat64(13, 2)
	print64("of a hill behind you. And it's a ruin. It must have been one")
	pause 120
	printat64(15, 2)
	print64("for many centuries. All of a sudden, you feel weak...")
	pause 120

	printat64(18, 2)
	print64("You have won?")
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

sub loadGraphics(yes as ubyte)
	if yes then
		POKE UINTEGER 23606, @tileGraphics - 256
	else
		POKE UINTEGER 23606, 15360
	end if
	return
tileGraphics:
	asm
		defb $00, $00, $00, $00, $00, $00, $00, $00 ;   -- blank
		defb $10, $00, $54, $00, $45, $00, $54, $00 ; ! -- floor
		defb $11, $aa, $44, $aa, $11, $aa, $44, $aa ; " -- mosaic
		defb $7e, $3c, $00, $18, $18, $18, $00, $3c ; # -- column
		defb $66, $99, $00, $24, $42, $7e, $3c, $00 ; $ -- basin
		defb $00, $06, $99, $60, $06, $99, $60, $00 ; % -- water
		defb $fd, $00, $df, $df, $df, $00, $fd, $fd ; & -- wall
		defb $00, $24, $3c, $24, $3c, $a5, $81, $7e ; ' -- stairs down
		defb $19, $99, $a5, $da, $98, $a4, $24, $7e ; ( -- statue
		defb $02, $06, $04, $10, $18, $18, $5a, $3c ; ) -- candle
		defb $08, $18, $10, $00, $3c, $18, $18, $10 ; * -- torch
		defb $00, $00, $04, $1f, $7f, $04, $00, $00 ; + -- knife
		defb $00, $00, $30, $48, $87, $87, $80, $00 ; , -- sickle
		defb $00, $00, $70, $9c, $87, $80, $00, $00 ; - -- adze
		defb $00, $60, $ff, $ff, $60, $f0, $60, $00 ; . -- axe
		defb $60, $f0, $60, $ff, $ff, $60, $f0, $60 ; / -- doubleaxe
		defb $c0, $a0, $50, $2a, $14, $0e, $17, $02 ; 0 -- sword
		defb $f0, $e0, $b0, $18, $0c, $06, $03, $01 ; 1 -- spear
		defb $00, $3c, $42, $5a, $52, $44, $48, $30 ; 2 -- raw meat
		defb $00, $00, $30, $4c, $52, $ff, $7e, $00 ; 3 -- dried fruit
		defb $00, $00, $3c, $24, $24, $ff, $7e, $00 ; 4 -- cheese
		defb $00, $00, $02, $43, $a1, $80, $7e, $3c ; 5 -- oil lamp
		defb $00, $12, $0c, $1e, $61, $81, $81, $7e ; 6 -- bag
		defb $7e, $3c, $18, $db, $bd, $7e, $3c, $18 ; 7 -- jar
		defb $00, $7e, $e7, $e7, $bd, $81, $ff, $00 ; 8 -- coffer
		defb $00, $1c, $12, $12, $14, $14, $38, $78 ; 9 -- greave
		defb $00, $00, $00, $fe, $a1, $d9, $06, $00 ; : -- armguard
		defb $00, $00, $3e, $41, $42, $4c, $30, $00 ; ; -- pauldron
		defb $42, $a5, $99, $81, $e7, $24, $42, $7e ; < -- cloth tunic
		defb $24, $5a, $4a, $52, $89, $91, $99, $e7 ; = -- leather
		defb $00, $66, $99, $a5, $42, $5a, $24, $00 ; > -- scale mail
		defb $18, $24, $42, $5a, $5a, $42, $24, $18 ; ? -- shield
	end asm
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
	elseif k = "o" or k = "O"
		openItemHere()
	elseif k = "g" or k = "G"
		getItemHere()
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
	mobs(0) = TAUR
	mobCoords(0, 0) = 2
	mobCoords(0, 1) = 2
	mobLife(0) = 2 * mobDice(TAUR)
	mobActions(0) = APREFRESH
	for i = 1 to ITEMTYPES
		inventory(i) = 0
	next i
	heroDepth = 1
	heroMaxLife = mobLife(0)
	heroMaxActions = APREFRESH
	heroDamageBonus = 0
	heroWeapon = NOTHING
	heroArmor = NOTHING
	poisonTimer = 0
	
	helpPage = 0
	gameover = 0 ' ESSENTIAL!

	blankViewport()
	print at 10, 2; ink 7; "  You wake up in darkness.  "
	generatePalaceFloor(1)
	populateLevel(1)
	createItems(1)
	'pause 25
	levelUp()
	blankViewport()
	clearSeen()
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
				mobActions(0) = mobActions(0) - mobDice(TAUR)
			else
				mobActions(0) = mobActions(0) + heroMaxActions
				processMobs()
				processPoison() ' Every turn is too often.
			end if
			processMobs()
			processLight()
			printHeroStats()
		end if
	loop until gameover <> 0
end sub


border 0
paper 0
'loadGraphics()

dim k as string
do
	ink 7
	bright 1
	cls
	drawBorder()
	printat64(23, 0)
	print64("[N]ew game [H]ow to play [C]redits")
	
	randomize

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
