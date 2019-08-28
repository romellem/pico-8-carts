pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--space shooter tutorial
--by romellem

function _init()
	t=0

	ship = {
		sp=1,
		x=60,
		y=60,
		h=3,
		p=0,
		box={x1=0, y1=0, x2=7, y2=7}
	}
	bullets = {}

	enemies = {}
	for i=1,10 do
		add(enemies, {
			sp=17,
			m_x=i*16,
			m_y=60-i*8,
			x=-32,
			y=-32,
			r=12,
			box={x1=0, y1=0, x2=7, y2=7}
		})
	end
end

-- returns position of box offset against its boundaries
function abs_box(s)
	local box = {}
	box.x1 = s.box.x1 + s.x
	box.y1 = s.box.y1 + s.y
	box.x2 = s.box.x2 + s.x
	box.y2 = s.box.y2 + s.y
	
	return box
end

function coll(a,b)
	--@todo
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
end

function _update()
	--@todo this will eventually overflow at 32768
	t+=1
	
	for e in all(enemies) do
		e.x = e.r*sin(t/50) + e.m_x
		e.y = e.r*cos(t/50) + e.m_y
		
		if coll(ship,e) then
			--@todo
		end
	end
	
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
			end
		end
	end
	
	if (t%6 < 3) then
		ship.sp = 1
	else
		ship.sp = 2
	end
	
	if (btn(⬅️)) then ship.x-=1 end
	if (btn(➡️)) then ship.x+=1 end
	if (btn(⬆️)) then ship.y-=1 end
	if (btn(⬇️)) then ship.y+=1 end
	if (btnp(🅾️)) then fire() end
end

function _draw()
	cls()
	print(ship.p,9)
	spr(ship.sp, ship.x, ship.y)
	for b in all(bullets) do
		spr(b.sp, b.x, b.y)
	end
	
	for e in all(enemies) do
		spr(e.sp, e.x, e.y)
	end
	
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
