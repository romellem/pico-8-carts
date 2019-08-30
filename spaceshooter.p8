pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--space shooter tutorial
--by romellem
--@see https://ztiromoritz.github.io/pico-8-shooter/

function _init()
	t=0

	ship = get_ship()
	bullets = {}

	enemies = {}
	explosions = {}
	
	stars = generate_stars()
	
	menu()
end

function menu()
	_update = update_menu
	_draw = draw_menu

	music(0)
end

function start()
	music(-1)
	_update = update_game
	_draw = draw_game
end

function game_over()
	_update = update_over
	_draw = draw_over
end

function update_menu()
	update_star_positions()
	if btn(🅾️) then
		start()
	end
end

function update_over()

end

function draw_over()
	cls()
	print("game over", 50, 50, 4)
end

function update_game()
	--global timer for ship animation frame and immortality flash
	t+=1
	
	update_ship_immortality()
	
	update_star_positions()
	
	update_explosions_timer()
	
	if #enemies <= 0 then
		respawn()
	end
	
	update_enemies_positions()
	update_bullets_positions()
	
	animate_ship()
	move_ship()
end

function draw_game()
	cls()
	print(ship.p,9)
	
	draw_stars()
	draw_ship()
	draw_explosions()
	draw_bullets()
	draw_enemies()
	draw_ship_health()
end
-->8
--utility functions

--returns position of box offset against its boundaries
function abs_box(s)
	local box = {}
	box.x1 = s.box.x1 + s.x
	box.y1 = s.box.y1 + s.y
	box.x2 = s.box.x2 + s.x
	box.y2 = s.box.y2 + s.y
	
	return box
end

function coll(a,b)
	local box_a = abs_box(a)
	local box_b = abs_box(b)
	
	if box_a.x1 > box_b.x2 or
	   box_a.y1 > box_b.y2 or
	   box_b.x1 > box_a.x2 or
	   box_b.y1 > box_a.y2 then
	   
	   return false
	end
	
	return true
end
-->8
--scene

function generate_stars(num)
	if not num then num = 60 end

	local l_stars = {}
	for i=1,num do
		add(l_stars, {
			x=rnd(128),
			y=rnd(128),
			s=rnd(2)+1
		})
	end
	
	return l_stars
end

function update_star_positions()
	for st in all(stars) do
		st.y += st.s
		
		--wrap stars back around
		if (st.y >= 128) then
			st.y = 0
			st.x = rnd(128)
		end
	end
end

function draw_stars(arg_stars)
 if not arg_stars then
 	arg_stars = stars
 end

	for st in all(arg_stars) do
		pset(st.x, st.y, 6)
	end
end

function draw_menu()
	cls()

	--stars
	draw_stars()

	--ship and bullet
	spr(12, 48,95, 4,4)
	spr(9,  60,76)
	--enemies
	spr(10, 36,46, 2,2)
	spr(42, 56,51, 2,2)
	spr(10, 76,46, 2,2)
	
	--logo
	
	--set red to be transparent (so black is drawn)
	palt(8, true)
	--draw a black box bg behind logo to remove stars
	rectfill(33,0, 33+60,0+40, 0)
	
	--starting at pixel 50,11 in the sprite sheet,
	--grab a 30x20 rectangle, and draw it
	--at 33,0 on the screen, and stretch it
	--to double the size at 60x40
	sspr(50,11, 30,20, 33,0, 60,40)
	
	--reset area behind "start" text
	rectfill(8,72, 42,89, 1)
	palt()
	print("press 🅾️", 10, 75, 5)
	print("press 🅾️", 10, 74, 7)
	print("to start", 10, 84, 5)
	print("to start", 10, 83, 7)
	
end
-->8
--enemies and explosions

function explode(x,y)
	add(explosions, {x=x,y=y,t=0})
	sfx(1)
end

function update_explosions_timer()
	for ex in all(explosions) do
		ex.t += 1
		if (ex.t >= 13) then
			del(explosions, ex)
		end
	end
end

function respawn()
	local n = flr(rnd(9))+2
	for i=1,n do
		local d = -1
		if rnd(1) < 0.5 then d = 1 end
		add(enemies, {
			sp=17,
			m_x=i*16,
			m_y=-20-i*8,
			d=d,
			x=-32,
			y=-32,
			r=12,
			box={x1=0, y1=0, x2=7, y2=7}
		})
	end
end

function draw_explosions()
	for ex in all(explosions) do
		circ(ex.x, ex.y, ex.t/3, 8+ex.t%3)
		
		--reset color after drawing
		--(so our printed score in the upper corner stays white)
		color(6)
	end
end

--enemies

function update_enemies_positions()
	for e in all(enemies) do
		e.m_y += 1 + rnd(1)
		e.x = e.r*sin(e.d*t/50) + e.m_x
		e.y = e.m_y --e.r*cos(t/50) + e.m_y
		
		if coll(ship,e) and not ship.imm then
			ship_hit(e)
		end
		
		if e.y >= 150 then
			del(enemies,e)
		end
	end
end

function draw_enemies()
	for e in all(enemies) do
		spr(e.sp, e.x, e.y)
	end
end
-->8
--ship and bullets

--bullets

function fire()
	local b = {
		sp=3,
		x=ship.x,
		y=ship.y,
		dx=0,
		dy=-3,
		box={x1=2, y1=0, x2=5, y2=4}
	}
	add(bullets,b)
	sfx(0)
end

function update_bullets_positions()
	for b in all(bullets) do
		b.x+=b.dx
		b.y+=b.dy
		
		if (b.x < 0 or b.x > 128 or b.y < 0 or b.y > 128) then
			del(bullets,b)
		end
		
		for e in all(enemies) do
			if (coll(b,e)) then
				del(enemies,e)
				ship.p += 1

				--enemy is 7x7, so center explosion at 3x3
				explode(e.x+3,e.y+4)
			end
		end
	end
end

function draw_bullets()
	for b in all(bullets) do
		spr(b.sp, b.x, b.y)
	end
end

--ship

function get_ship()
	return {
		sp=1,
		x=60,
		y=80,
		h=4,
		p=0,
		t=0,
		imm=false,
		box={x1=0, y1=0, x2=7, y2=7}
	}
end

function animate_ship()
	if (t%6 < 3) then
		ship.sp = 1
	else
		ship.sp = 2
	end
	
	--6 is timer for ship animation,
	--8 is timer for hit flash
	if t >= (6*8) then t=0 end
end

function update_ship_immortality()
	if ship.imm then
		ship.t += 1
		if ship.t > 30 then
			ship.imm = false
			ship.t = 0
		end
	end
end

function ship_hit(e)
	ship.imm = true
	ship.h -= 1
	sfx(2)
	
	if e then
		explode(e.x+3, e.y+4)
		del(enemies,e)
	end
	
	if ship.h <= 0 then
		game_over()
	end
end

function move_ship()
	if (btn(⬅️)) then ship.x-=1 end
	if (btn(➡️)) then ship.x+=1 end
	if (btn(⬆️)) then ship.y-=1 end
	if (btn(⬇️)) then ship.y+=1 end
	if (btnp(🅾️)) then fire() end
	
	--prevent ship from leaving bounding box
	ship.x=mid(0,ship.x,121)
	ship.y=mid(60,ship.y,120)
end

function draw_ship()
	--when hit, ship "flashes" based on global `t` timer
	if not ship.imm or t%8 < 4 then
		spr(ship.sp, ship.x, ship.y)
	end
end

function draw_ship_health()
	for i=1,4 do
		if i<=ship.h then
			spr(33, 80+6*i, 3)
		else
			spr(34, 80+6*i, 3)
		end
	end
end
__gfx__
00000000008008000080080000099000000000000000000000000000000000000000000000999000000000000000000000000000000000999000000000000000
00000000008008000080080000099000000000000000000000000000000000000000000009999900000003333000000000000000000009999900000000000000
0070070000888800008888000009900000000000000000000000000000000000000000009a9e9a900000bbbbb30000000000000000009a9e9a90000000000000
0007700008811880088118800000000000000000000000000000000000000000000000009a9e9a900000bb776b3000000000000000009a9e9a90000000000000
00077000088cc880088cc88000000000000000000000000000000000000000000000000009a9a900000bbb777bb0000000000000020009a9a9000e0000000000
007007000808808008088080000000000000000000000000000000000000000000000000009a9000000bbb077bb00000000000000200009a90000e0000000000
00000000000a00000000a00000000000000000000000000000000000000000000000000000090000000abb777b0000000000000008e0000900008e0000000000
000000000000a000000a0000000000000000000000000000000000000000000000000000000900000000abb7bb00000000000000088e000900088e0000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000b0abbb0b00000000000000888888888888e0000000000
0000000000bbb0000000000000000000000000000000000000000000000000000000000000000000000b00bb800b30000000000008888888888e8e0000000000
000000000bb70b00000000000000000000000000000000000000000000000000000000000000000000b300b87000b000000000000288888888e88e0000000000
000000000bb77b00000000000000000000000000000000000000000000000000000000000000000000b000b00800b30000000000082888888e888e0000000000
000000000bb77b0000000000000000000000000000000000000000000000000000000000000000000000000c00000b00000000000882811111888e0000000000
00000000b0bbb0b00000000000000000000000000000000000000000077707700777007707770000000000000000000000000000028881112188e80000000000
00000000b00b000b000000000000000000000000000000000000000077570757075707570755000000000c00000000000000000028288111218e88e000000000
00000000000000000000000000000000000000000000000000000000750507070707070507000000000000000c0000000000002888828ccc6ce88888e0000000
0000000008080000060600000000000000000000000000000000000077700775077707000770000000000000000000000000028882888ccc6c8888888e000000
0000000088888000666660000000000000000000000000000000000000770750070707000750000000000000000000000000088888288ccccc88e88888000000
0000000008880000066600000000000000000000000000000000007000770700700707070700000000000bbbb33000000000088e00028888888e000288000000
000000000080000000600000000000000000000000000000000000077775070750070775077700000000bbbbbbb30000000028800002888888e8000088e00000
000000000000000000000000000000000000000000000000000000005550050500050550055500000000bbbbbbbb3000000088e0000288888888000028800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000bb763bbbbb00000028e0000000a0009a00000028e0000
00000000000000000000000000000000000000000000000000000000000000000000000070000000000b77763bbbb00000028e00000000a09a000000028e0000
00000000000000000000000000000000000000000000000000000077707070070007000750770770000b77763bbbb00000028e00000000a90a000000028e0000
00000000000000000000000000000000000000000000000000000775707070757075707707550757000b0773bbbb000000028e000000a000900a0000028e0000
00000000000000000000000000000000000000000000000000000750507070707070705707000707000ab77bbbb0000000008000000000a90a00000000800000
000000000000000000000000000000000000000000000000000007770077707070707007077007700000abbbb0bb000000000000000000009000000000000000
000000000000000000000000000000000000000000000000000000077070707070707007075007570008070b0000b30000000000000000a90a00000000000000
000000000000000000000000000000000000000000000000000700077070707070707007070007070c00000b0000000000000000000a0000a000a00000000000
0000000000000000000000000000000000000000000000000000777757507007005750070777070700000000bb300000000000000000000a0000000000000000
00000000000000000000000000000000000000000000000000000555050050050005000505550505000c0000000000000000000000000900a090000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010800001353300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
010800000022200212106200f6200e6110d6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000314000140031300013003120001200311000115007000340000400034000040003400004000340000400034000040003400004000330000300033000030003200002000320000200031000010003100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000
011400001015410152101520010210152001021215412152121520010212152001020f1540f1520f152001000f152001020b1540b1520b152001000b142001000000000000000000000000000000000000000000
011400000d1540d1520d152001000d152001020f1540f1520f152000000f152000001c1541c1521c1521c1521c152000001c1541c1521c1521c1521c152000001910019100191001910019100000001910019100
011400001915419152191521915219152000001915419152191520000019152000001715417152171521715217152000001715417152171521715217152000000000000000000000000000000000000000000000
011400001415414152141520010214152001021715417152171520010217152001021515415152151520010215152001021715417152171520010217152001020010200102001020010200102001020010200102
001000001910019100191001910019100000001910019100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000100301003010030000000b022000000d0300d0300d030000001602200000120301203012030000000d022000000f0300f0300f0300000017022000000000000000000000000000000000000000000000
011400001003010030100300000012022000001203012030120300000016022000002003020030200300000023022000002003020030200300000023022000000000000000000000000000000000000000000000
011400001c0301c0301c030000001e02200000200302003020030000001e022000001b0301b0301b030000001c02200000170301703017030000001b022000000000000000000000000000000000000000000000
011400001703017030170300010219022001021b0301b0301b030001021e022001021c0301c0301c0300010219022001021e0301e0301e030001021b022001020010200102001020010200102001020010200102
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000455004550045500050004553005000355003550035500050003553005000655006550065500050006553005000655006550065500050006543005000000000000000000000000000000000000000000
011400000855008550085500050008553005000655006550065500000006550000000455000000045400000004533000000455000000045400000004533000000000000000000000000000000000000000000000
011400000a550000000a540000000a533000000a550000000a540000000a533000000655000000065400000006533000000655000000065400000006533000000000000000000000000000000000000000000000
011400000b5500b5500b550000000b543000000355003550035500000003543000000155001550015500000001543000000355003550035500000003543000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011500000453004531045310050104530005010153003530005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000000000000000000000000000000000
__music__
01 0f101a24
00 0f111b25
00 0f121c26
02 0f131d27

