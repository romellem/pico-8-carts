pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

x=50
y=50
dx=0
dy=0
acc=0.2 --acceleration

function _update()
	if btn(⬆️) then
	  dy-=acc
	elseif btn(⬇️) then
	  dy+=acc
	end
	
	if btn(⬅️) then
	  dx-=acc
	elseif btn(➡️) then
	  dx+=acc
	end
	
	x+=dx
	y+=dy
end

function _draw()
  cls()
  spr(1, x, y)
end
__gfx__
00000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000744000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000005444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000094000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
