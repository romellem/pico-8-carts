pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
t=0

function _init()
	ship = {sp=1,x=60,y=60,h=3}
	bullets = {}

	enemies = {}
	for i=1,10 do
		add(enemies, {
			sp=17,
			m_x=i*16,
			m_y=60-i*8,
			x=-32,
			y=-32,
			r=12
		})
	end
end

function fire()
	local b = {
		sp=3,
		x=ship.x,
		y=ship.y,
		dx=0,
		dy=-3
	}
	add(bullets,b)
end

function _update()
	--@todo this will eventually overflow at 32768
	t+=1
	
	for e in all(enemies) do
		e.x = e.r*sin(t/50) + e.m_x
		e.y = e.r*cos(t/50) + e.m_y
	end
	
	for b in all(bullets) do
		b.x+=b.dx
		b.y+=b.dy
		
		if (b.x < 0 or b.x > 128 or b.y < 0 or b.y > 128) then
			del(bullets,b)
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
	print(#bullets,9)
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
