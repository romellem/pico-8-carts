pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--space shooter tutorial
--by romellem

function _init()
	t=0

	ship = get_ship()
	bullets = {}

	enemies = {}
	explosions = {}
	
	stars = {}
	create_stars()
	
	start()
end

function start()
	_update = update_game
	_draw = draw_game
end

function game_over()
	_update = update_over
	_draw = draw_over
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

function create_stars()
	for i=1,60 do
		add(stars, {
			x=rnd(128),
			y=rnd(128),
			s=rnd(2)+1
		})
	end
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

function draw_stars()
	for st in all(stars) do
		pset(st.x, st.y, 6)
	end
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
		e.m_y += 1.3
		e.x = e.r*sin(e.d*t/50) + e.m_x
		e.y = e.m_y --e.r*cos(t/50) + e.m_y
		
		if coll(ship,e) and not ship.imm then
			ship.imm = true
			ship.h -= 1
			
			--@todo should game_over call be somewhere else?
			if ship.h <= 0 then
				game_over()
			end
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
				explode(e.x,e.y)
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
		y=60,
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

function move_ship()
	if (btn(⬅️)) then ship.x-=1 end
	if (btn(➡️)) then ship.x+=1 end
	if (btn(⬆️)) then ship.y-=1 end
	if (btn(⬇️)) then ship.y+=1 end
	if (btnp(🅾️)) then fire() end
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
00000000008008000080080000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008008000080080000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700008888000088880000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000088118800881188000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000088cc880088cc88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700080880800808808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a00000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bb70b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bb77b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bb77b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b0bbb0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b00b000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080800000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888880006666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088800000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010800001353300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
010800000022200212106200f6200e6110d6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
