pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
	game_over=false
	make_cave()
	make_player()
end

function _update()
	update_cave()
	move_player()
end

function _draw()
	cls()
	draw_cave()
	draw_player()
end
-->8
function make_player()
	player={}
	player.x=24    --position
	player.y=60
	player.dy=0    --fall speed
	player.rise=1  --sprites
	player.fall=2
	player.dead=3
	player.speed=2 --fly speed
	player.score=0
end

function draw_player()
	if (game_over) then
		spr(player.dead, player.x, player.y)
	elseif (player.dy < 0) then
		spr(player.rise, player.x, player.y)
	else
		--falling
		spr(player.fall, player.x, player.y)
	end
end

function move_player()
	gravity=0.15 --increase this value to increase gravity
	player.dy += gravity
	
	--jump
	if (btnp(2)) then
		player.dy -= 5
	end
	
	--move to new position
	player.y += player.dy
end
-->8
function make_cave()
	cave={{["top"]=5, ["btm"]=119}}
	top=45  --how low can the ceiling go?
	btm=85  --how high can the floor get?
end

function update_cave()
	--remove the back of the cave
	if (#cave > player.speed) then
		for i=1,player.speed do
			del(cave, cave[1])
		end
	end
	
	--add more cave
	while (#cave < 128) do
		local col={}
		local up=flr(rnd(7)-3)
		local dwn=flr(rnd(7)-3)
		col.top = mid(3, cave[#cave].top+up, top)
		col.btm = mid(btm, cave[#cave].btm+dwn, 124)
		add(cave, col)
	end
end

function draw_cave()
	top_color=5 --adjust these values to get different colors!
	btm_color=6
	
	for i=1,#cave do
		line(i-1, 0, i-1, cave[i].top, top_color)
		line(i-1, 127, i-1, cave[i].btm, btm_color)
	end
end
__gfx__
0000000000aaaa0000aaaa0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00aaaaaa008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aa1aa1aaaaaaaaaa88988988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaaaa1aa1aa88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aa1111aaaaaaaaaa88899888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aaa11aaaaaa11aaa88988988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00aa11aa008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa0000aaaa0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
