pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
pr_recipe=3
jump_to=nil

function _init()
	logs={}
 ents={} 
 t=0
 sfx(26)
 -- vars
 days=1
 gold=4
 items={}
 customers=0
 
 -- forest
 herb={}
 for x=0,15 do for y=0,15 do
  if mget(16+x,y)==69 then
   add(herb,{x=x*8,y=y*8})
  end
 end end 
 
 -- merchant
 merchant={}
 merchant_pool={}
 for i=0,7 do 
  add(merchant_pool,32+i) 
 end

 -- equipment
 shelves={{nil,1,nil,2,3}}
 stock={}
 --shelves={{1,2,3,4,5,6,7,8,9}}
 --stock={1,2}
 recipes = {0,1,2}
 
 forest={}
 
 -- parse data
 al={}
 rdat={}
 for i=0,32 do
  o={cost={},res={}}  
  a=o.cost
  x=48 
  for k=0,8 do
	  n=mget(x,i)	  
	  if n==0 then
	   break
	  elseif n==134 then
	   a=o.res
	  else
	   add(a,n)
	  end
	  x+=1
	 end
	 if #o.cost>0 then
	  add(rdat,o)
	  if i>0 then add(al,i) end
	 else
	  break
	 end
 end
 
 deck={}
 while #al>0 do
  k=al[1+rand(#al)]
		del(al,k) 
  add(deck,k)  
 end

 -- witch
 witch=mke(0,60,60)
 witch.dr=dr_witch
 walk=0
 wface=0
 witch.ldx=0
 witch.ldy=0
 witch.dy=0
 witch.dy=0
 wflp=false

 --
 --scn=1
 --reset_scene() 
 --seq_loc=loop(choose_wp)
 --loop(control)
 new_day()
 if jump_to then
  scn=jump_to
  reset_scene()
  loop(control)
 else
  init_intro()
 end 
 
 --scn=1
 
end


function nhv(n)
 local sum=0
 for k in all(items) do
  if n==k then sum+=1 end
 end 
 return sum
end

function hv(n)
 return nhv(n)>0 
end

function spawn_forest(id)
 
 sum=0
 for p in all(forest) do
  if p.id==id then sum+=1 end
 end 
 if sum>=6 then return end 
 p=steal(herb)
 p.id=id
 add(forest,p)
end

function rand(k)
 return flr(rnd(k))
end


function end_game()
 fading=loop(fade)
 
end

function control(e)
 if freeze then return end
 if ending then
  freeze=true
  sfx(24)
  wait(40,end_game)
  return
 end
 
 --log_pt(witch.x+4,witch.y+4)
 
 witch.dx=0
 witch.dy=0
 act=nil
 wcol()
 if btn(0) then wmove(-1,0) end
 if btn(1) then wmove(1,0) end
 if btn(2) then wmove(0,-1) end
 if btn(3) then wmove(0,1) end

 -- walk_cycle
 if is_moving() then
  if t%4==0 then
  	walk=(walk+1)%4  	
	 end
	 if t%8== 0 then	
	  bs=4
	  if pcol(witch.x+4,witch.y+4,3) then
	   bs+=2
	  end
	  sfx(bs+(t%4))
	 end
	else
	 walk=0
 end
 
 -- interact
 if btnp(4) then
  if act then 
  	act.act(act) 
  elseif hv(33) and scn==1 then
   freeze=true
   witch.net=0
   loop(net_catch)
  end
 end
 
 -- check leave
 ma=-8
 if witch.x<ma or witch.y<ma or witch.x>128-ma or witch.y>128-ma then
  kl(e)
  sfx(23)
  fading=loop(fade)  
 end
end

function net_catch(e)
 walk=1
 
 if e.t%4 == 0 then
  
  witch.dx,witch.dy=-witch.ldy,witch.ldx
 end
 
 witch.net=-e.t/20
 if e.t==20 then
  witch.net = nil
  unfreeze()
  kl(e)    
 end
end

function ending_screen(win)
 --pal()
 t=0
 tdy=0
 ens=function()
  rectfill(0,0,127,127,win and 3 or 8)
  if win then
   camera(-23,-40)
   talk("conratulations! you finaly achieved the dream of every alchemist, you are now famous accross the kingdom and many rich men come to your house so you can brew them some potions. but who need bourgeoisie's money ? you can get all the gold you want now. you should take a rest and think about what you want to do with your life now...",t,80,64)
   camera()
  else
   print("game over",46,60,7)
  end
  if t>40 and btnp(4) then
  -- reboot()
  end 
 end
 
 
end

function fade(e)
 if e.light then
  e.t-=1.5
 end
 k=e.t/4 
 for i=0,15 do
  pal(i,sget(16+i,24+k+i/16))
 end
 if k>5 and not e.light then
  e.light=true
  days+=1
  if ending then
   ending_screen(true)
  elseif days==13 then
   ending_screen(false)
  else  
   new_day()
  end
  
 end 
 if k<=0 then
  init_intro()
  fading=nil
  pal()
  kl(e)
 end
 
end


function new_day()
 
 --
 if customers<4 then
  customers+=1
 end
 
 --forest
 for i=1,6 do
  prob=1
  if i>2 then prob+=i-2 end
  if hv(32) and (i==3 or i==4) then
   prob=1
  end  
  if days%prob==0 then
	  for n=1,max(3-i,1) do
	   spawn_forest(i)
	  end
  end  
 end 
 
 -- first butterfly
 if days==1 then spawn_forest(6) end
 
 --merchant
 while #merchant<2 and #merchant_pool>0 do
  add(merchant,steal(merchant_pool)) 
 end
 
 -- reset
 scn=0
 reset_scene()
 witch.x=60
 witch.y=60 
 walk=0
 wface=0
 witch.dx=0
 witch.dy=0 
 
 
 --


end

function init_intro()
 if days>1 then sfx(27) end
 tdy=0
 loop(nil,dr_intro)
end

function dr_intro(e)

 y=128-min(e.t/10,1)*48
 
 rectfill(0,y-1,127,y+30,7)
 rectfill(0,y,127,y+29,8)
 rectfill(0,y+31,127,y+31,1)
 
	print("day "..days,54,y+2,14)		
	
		
	by=y+9
	if not e.skip then
		camera(-1,-by)
		clip(0,by,128,y+56)	
		t=-1
		talk(quotes[days],e.t,126,13)
		clip()
		camera()
	end
	if e.skip then
	 e.t-=2
	 if e.t<0 then
	  kl(e)
	  seq_loc=loop(choose_wp)
	 end
	elseif btnp(4) then
	 sfx(28)
	 e.skip=true
	 e.t=10
	end
	
end


function get_act()
 for e in all(ents) do
  if e.act then
   local x=e.x
   local y=e.y
   if e.rx then
    x+=e.rx
    y+=e.ry
   end
   dx=x-witch.x-4
   dy=y-witch.y-4
   if sqrt(dx*dx+dy*dy)<4 then
    return e
   end
  end
 end 
 return nil
end

function is_moving()
 return witch.dx!=0 or witch.dy!=0
end 

function wmove(dx,dy)
 local spd=1.5
 if hv(35) then spd+=1 end
 
 witch.x+=dx*spd
 witch.y+=dy*spd
 
	while wcol() do
	 witch.x-=dx
	 witch.y-=dy
	end	
	witch.dx=dx
	witch.dy=dy
	

end

function wcol()  
 a={0,0,0,7,7,0,7,7} 
 for i=0,3 do
  local x=witch.x+a[1+i*2]
  local y=witch.y+a[2+i*2]
  if pcol(x,y,0) then return true end
 end
 
 
 for e in all(ents) do
  if e.rx then   
  	dx=(e.x+e.rx)-(witch.x+4)
 		dy=(e.y+e.ry)-(witch.y+2)
 		
 		--log_pt(e.x+e.rx,e.y+e.ry)
 		
 		function chk(lim)
 		 e.wn=abs(dx)+abs(dy)
 		 return abs(dx)< 4+e.rx+lim and abs(dy)< 4+e.ry+lim
 		end
 		if chk(6) and e.act then
 		 if not act or ( act.wn> e.wn ) then
 		  act=e
 		 end
 		end
 		if chk(0) then
 		 return true
 		end
  end 
 end

 return false
end

function pcol(x,y,n)
 --if n==0 and ( x<0 or y<0 or x>=128 or y>=128 ) then
 -- return true
 --end

 tl=mget(scn*16+x/8,y/8)
 return fget(tl,n) 
end

function inc_sum(a,inc)
 if not sum then
  sum={0,0,0,0,0,0,0,0,0,0,0}
 end
 for i=1,9 do
  if a[i] then
   sum[a[i]]+=inc
  end
 end 
 return sum
end

function reset_scene()
 ents={}
 add(ents,witch)
 if fading then
 add(ents,fading)
 end
 
 
 cauldrons={}
 herbo=nil 
 wagon=mke(0,0,0)
 wagon.brd=true
 wagon.dr=dr_wagon  
 wagon.rx=12+4*nhv(38)
 wagon.ry=12
 if scn==0 then
  for i=1,1+nhv(36) do
   e=mke(0,104,35+i*24)
   e.dr=dr_cauldron
   add(cauldrons,e)
   e.act=act_cauldron 
   e.rx=8 
   e.ry=5
  end   
  wagon.x=12
  wagon.y=96 
  wagon.act=act_wagon
  
  trash=mke(79,8,56)
  trash.act=init_load
  trash.rx=4
  trash.ry=4
 	trash.szy=1.25
 	trash.dr=function(e) 	 	
 	 y=0
 	 if trash==act  then
 	  if freeze then
 	   y=4
 	  else
 	   y =flr(2+cos(t/20)*2+.5)
 	  end
 	 end 	 
 	 sspr(120,42,8,6,8,55-y) 	
 	end
  
 elseif scn==1 then
  wagon.x=12
  wagon.y=28
   
  -- wood stuff  
  for p in all(forest) do   
   local e=mke(p.id,p.x,p.y)
   e.brd=true
   e.fp=p
     
   if e.fr==6 then
    e.fly=56
    local an=rnd()
    e.upd=function()
     spd=2
     e.vx=cos(an)*spd
     e.vy=sin(an)*spd
     an+=(rnd()-.5)/20  
     if is_out(e,-5) then
      an=atan2(64-e.x,64-e.y)
     end
    end
   else
	   e.float=true
	   e.rx=2
	   e.ry=2
	   e.act=grab_item	   
   end
   

   
  end  

 elseif scn==2 then
  wagon.x=86
  wagon.y=54
  
  herbo=mke(138,32,14)
  herbo.brd=true
  herbo.szy=2
  herbo.prt=174
  
  merc=mke(139,96,2)
  merc.brd=true
  merc.szy=2
  merc.lpy=15
  merc.prt=142
  
  -- merc
  for i=0,1 do
   local id=merchant[i+1]
   if id then
    e=mke(id,88+16*i,14)
    e.act=act_stuff
    e.rx=0
    e.ry=3
    e.brd=true
    e.price=mget(id-32,22) 
    e.desc=item_desc[id-31]   
   end
  end
  
  -- recipes
		for i=1,4 do
		 index=(i+days)%#deck
		 e=mke(22,i*16-8,27)
		 e.float=true
		 e.sell=deck[index+1]
		 e.act=act_stuff
		 e.rx=0
		 e.ry=3
		 e.brd=true
		 e.price=i
		 e.desc="this recipe will help you to create new ingredients."
		end
	 loop(nil,dr_hint)
	 
	 -- customers
	 for i=1,customers do
	  e=mke(12,i*16,99)
	  e.szy=2
	  e.brd=true
	  e.act=act_customer
	  e.rx=0
	  e.ry=3
	  e.intro=true
	 end
	 
 end 
  
 -- items / gold disp
 e=mke(0,0,0)
 e.depth=2
 e.brd=true
 e.dr=function(e)
  sspr(112,104,5,5,121,2)
  str=gold..""
  print(str,119-#str*4,2,7)
  
  x=2
  for n in all(items) do
   if not fget(n,0) then
    spr(n,x,2)
    x+=9
   end
  end
   
 end 
 
end

function is_out(e,ma)
 return e.x<ma or e.y<ma or e.x>128-ma or e.y>128-ma 
end

function act_trash(e)
 freeze=true
end


function ask_price(n)
 msg("the price is "..n.." coins",seller.prt)
 price=n
 choice=0
end

function act_merc(e)
 function f()
  ask_price(e.price)
 end
 msg(e.desc,142,f)
end

function act_stuff(e)
 seller=merc
 if e.fr==22 then seller=herbo end
 
 function f()
  ask_price(e.price)
 end
 msg(e.desc,seller.prt,f)
end


function grab_item(e)
 freeze=true
 if e.fr==2 and hv(34) then
  local a,b=seek_ing(nil)
  if a then
   del(forest,e.fp)
   sfx(6)
   shelves[a+1][b+1]=e.fr
   function f()
    sfx(22)
    unfreeze()
    e.life=20
    e.cblk=20
    e.float=false
   end
   moveto(e,e.x,e.y-24,24,f)
   return
  end
 end

 
 local i=get_stock_free_index()
 if i then
  sfx(15)
  del(forest,e.fp)
  e.act=nil
  e.rx=nil
  e.float=false
  local x,y =get_wagon_pos(i-1)
  function f()
   kl(e)
   stock[i]=e.fr
   unfreeze()
  end
  moveto(e,x,y,10,f)
  e.jump=20
 else
  sfx(3)
  wait(8,msg,"my wagon is full")
  --wait(10,unfreeze)
 end
 
end

function steal(a)
 local n=a[1+rand(#a)]
 del(a,n)
 return n
end

function act_customer(e)
 cst=e
 if e.intro then
  function f()
  	reset_pos()
   loop(nil,seek_wag)
   deliver=serve_food
  end
  msg("i'm really hungry today, what have you got in your wagon ?",172,f)
 end
end

function serve_food(index)
 local n=stock[1+index]
 
 if n then
  sfx(2)
  stock[1+index]=nil
  local e=mke(n,get_wagon_pos(index))
  e.jump=20
  e.depth=2
  
  function f()
   sfx(13)
   if fget(n,1) then
    wait(12,digest,e)
   else
    sfx(3)
    wait(12,cst_leave)
   end
  end
  moveto(e,cst.x,cst.y-5,20,f)
  
 else
  sfx(3)
  unfreeze()
 end
 
end

function digest(e)

 sfx(14)
 e.depth=0
 moveto(e,cst.x,cst.y+6,8)
 wait(16,pay_gold,e.fr,cst,cst_leave,true)
 wait(8,kl,e)
end

function cst_leave()
 customers-=1
 moveto(cst,cst.x,cst.y+32,24)
 cst.dr=function(e)
  spr(11,e.x,e.y)
  spr(27,e.x,e.y+14,1,1,t%8<4)
 end
 wait(24,kl,cst)
 wait(24,unfreeze)
end



function seek_wag(e)
 
 function lmov(dx,dy)
  sfx(9)
  xm=2+nhv(38)*2
  wx=(wx+dx)%xm
  wy=(wy+dy)%2
 end
 
 function cancel()
  sfx(3)
  kl(e)
  unfreeze()
 end
 
 if btnp(0) then lmov(-1,0) end
 if btnp(1) then lmov(1,0) end
 if btnp(2) then lmov(0,-1) end
 if btnp(3) then lmov(0,1) end
 if btnp(5) then cancel() end 
 
 index=wx*2+wy
 
 if btnp(4) and e.t>5 then
  kl(e)
  deliver(index)
 end

 local x,y=get_wagon_pos(index)
 rect(x-2,y-2,x+9,y+9,12+(t%4))
 
end



function act_scroll(e)
 freeze=true
 pay_gold(pr_recipe,herbo,buy_stuff)
end

function pay_gold(n,trg,f,earn)
 
 if n>gold and not earn then
  msg("i can't afford to buy this...")
  sfx(3)
  wait(8,unfreeze)
  witch.dy=1
  return
 end
 
 local ax=126
 local ay=2
 local bx=trg.x
 local by=trg.y
 
 if earn then
  ax,ay,bx,by=bx,by,ax,ay
 end
 
 function pop()
  sfx(0)
  local e=mke(54,ax,ay)
  if not earn then 
   gold-=1
  end
		function f()
		 sfx(1) 
		 kl(e) 
		 if earn then
		  gold+=1
		 else
		  trg.cbl=2
		 end
		end
  moveto(e,bx,by,10,f)
 end
 
 wt=0
 for i=1,n do
  wait(wt,pop)
  wt+=6
 end 
 wt+=10
 wait(wt,f)
 
end


function buy_stuff()

 if act.sell then
	 del(deck,act.sell)
	 add(recipes,act.sell)
 end

 local n=act
 function f() 
  sfx(8)
	 if n.fr>=32 then
	  del(merchant,n.fr)
	  add_item(n.fr)
	 end
  unfreeze()
  kl(n) 
 end
 act.float=nil
 moveto(act,act.x,act.y+8,8,f)
end

function add_item(n)
 if n==37 then
  add(shelves,{})
 end
 add(items,n)
end


function dr_hint(e)
 
 if freeze or not act or not act.sell then
  return
 end

 
 function f() draw_rec(act.sell,4,84) end
 border(f)

end

function border(f,a,b,c)
 apal(1)
 camera(0,1)
 f(a,b,c)
 camera(1,0)
 f(a,b,c)
 camera(0,-1)
 f(a,b,c)
 camera(-1,0)
 f(a,b,c)
 pal()
 camera()
 f(a,b,c)   
end


function dr_wagon(e)
 ext=nhv(38)
 function wh(y)
  sspr(112,110,16,18,e.x+4+ext*4,e.y+y)
 end
 wh(-4)
 
 map(12,16,e.x-8,e.y-4,4+ext,5 )
 for i=0,7 do
  n=stock[i+1]
  if n then  
   spr(n,get_wagon_pos(i))
  end
 end
 wh(12) 
end

function unfreeze()
 freeze=false
end

function act_wagon(e)
 
 n=get_stock()
 a,b=seek_ing(nil)
 if n and a then
 	freeze=true
  give(stock[n+1],get_wagon_pos(n))
  stock[n+1]=nil
  wait(21,unfreeze)
  
 elseif get_stock_free_index() then
		init_load()
	else
	 sfx(3)
 end
end

function init_load()
  freeze=true 
 	reset_pos() 
 	loop(load_wagon,dr_load)
end

function reset_pos()
 wx=0
 wy=0
 ws=0  
end

function load_wagon(e)

 function cancel()
		kl(e)
		if act.rec then
		 if upgs then upgs=nil end
		 act.rec=nil
		end
  unfreeze() 
  sfx(16)
 end

 function lmov(dx,dy)
  sfx(19)
  wx+=dx
  wy=(wy+dy)%3
  if wx<0 then
   ws=(ws-1)%#shelves
   wx=2
  elseif wx>2 then
   ws=(ws+1)%#shelves
   wx=0
  end
 end
 
 if btnp(0) then lmov(-1,0) end
 if btnp(1) then lmov(1,0) end
 if btnp(2) then lmov(0,-1) end
 if btnp(3) then lmov(0,1) end
 if btnp(5) then cancel() end
 if btnp(4) and e.t>1 then 
  si=wx+wy*3  
  a=get_stock_free_index()
  b=shelves[1+ws][si+1]  
  if not b then
   cancel()
   return   
  end
  
  trs=act==trash
  if trs or a or upgs then
   sfx(17) 
   e.upd=nil
   si=wx+wy*3
   x,y=get_shelf_pos(ws,si)   
   shelves[1+ws][si+1]=nil
   local en=mke(b,x,y)
      
   if trs or upgs then
    tx,ty=act.x,act.y 
   else
    tx,ty=get_wagon_pos(a-1)   
   end   
   en.depth=2
   en.jump=40
   function f() 
    sfx(4) 
    kl(en)   
    stock[a]=b
    if get_stock_free_index() then
     e.upd=load_wagon
    else
     cancel() 
    end   
   end 
   if trs then
	   function f()
	    sfx(18) 
	    kl(en) 
	    e.upd=load_wagon    
	   end
	  elseif upgs then
	   upgs-=1
	   if upgs==0 then upgs=nil end
	   function f()
	    sfx(20)
	    caul.recipe=true
	    caul.spoiled=true
	    kl(en)
	    wait(40,give,b+1,caul.x,caul.y-8)
	    if upgs then
	     e.upd=load_wagon
	    else
	     kl(e)
	     wait(40,unfreeze)
	    end
	   end
   end  
   moveto(en,tx,ty,20,f)
  end
 end

end

function get_stock_free_index()
 local mx=4+nhv(38)*2
 for i=1,mx do
  if not stock[i] then return i end
 end
 return nil
end



function dr_load()
 local x,y=get_shelf_pos(ws,wx+wy*3)
 rect(x-1,y-1,x+8,y+8,7)
end

function get_stock()
 for i=1,8 do
  if stock[i] then 
   return i-1 
  end
 end 
 return nil
end

function get_wagon_pos(i)
 return wagon.x+3+flr(i/2)*9,wagon.y+(i%2)*8
end


function act_cauldron(e)

 caul=e
	if e.rec then	
	 if e.spoiled then
	  msg("rhis recipe can only be used once per day")
		elseif can_pay(caul.rec.cost) then
   freeze=true
   init_cook()
  else
   msg("i can't use this recipe anymore..")
  end
	else
	 
	 freeze=true
	 loop(upd_scroll,dr_scrolls)
	 slide=0
		index=0
		
	end
end

function upd_scroll(e)
	function inc(n)
	 sfx(0)
	 slide+=n
	 index=(index+n)%#recipes
	end
 if btnp(0) then inc(1) end
 if btnp(1) then inc(-1) end
 if btnp(4) and e.t>1 then
  caul.rec=rdat[1+recipes[1+index]]
  cost=caul.rec.cost
  if cost[1]==48 then
   e.upd=nil
   e.t=10
   e.nxt=init_load
   upgs=#cost
  elseif can_pay(cost) then
   e.upd=nil
   e.t=10
   e.nxt=init_cook
  else
   unfreeze()
   sfx(3)
   kl(e)
  end  
 end
 if btnp(5) or btnp(2) or btnp(3) then 
 	freeze=nil
  e.upd=nil
  e.t=10 	
 end
end

function dr_scrolls(e)
 slide*=0.85
 if not e.upd then
  e.t-=2
  if e.t<0 then
   kl(e)
  end
 end 
 for i=0,6 do
  ri = recipes[1+((index+i-3)%#recipes)]
		local px=44+(i+slide-3)*36
		local py=102+sin((px+20)/256)*16
		if e.t<10 then
		 c=1-e.t/10
		 py += c*c*80
		end
		draw_rec(ri,px,py)
 end
end

function init_cook()
 wt=0
 for n in all(caul.rec.cost) do
  wait(wt,pay,n)
  wt+=21
 end
 wt+=32
 for n in all(caul.rec.res) do
  wait(wt,give,n,caul.x,caul.y-8)
  wt+=21
 end 
	wait(wt,unfreeze)
end

function pay(n)
 x,y=get_shelf_pos(seek_ing(n,true))
 local e=mke(n,x,y) 
 function f() 
  sfx(20)
  kl(e) 
  caul.recipe=true
 end 
 moveto(e,caul.x,caul.y-8,20,f)
 e.jump=40
 e.depth=2 
end

function give(n,fx,fy)
 sfx(17)
 local a,b=seek_ing(nil)
 if not a then return end 
 x,y=get_shelf_pos(a,b)
 
 if n==10 then
  ending=true
 end
 
 local e=mke(n,fx,fy)
 e.jump=40
 e.depth=2
 function f()
  sfx(4)
  kl(e)
  shelves[a+1][b+1]=n
 end
 moveto(e,x,y,20,f)

end

function seek_ing(n,rmv)
 a=0
 for sh in all(shelves) do
  for b=0,8 do   
   if sh[b+1]==n then 
    if rmv then sh[b+1]=nil end
    return a,b
   end
  end
  a+=1
 end
 return nil,nil
end

function get_shelf_pos(a,b)
 	return a*40+16+(b%3)*8, 16+flr(b/3)*8
end

function wait(t,f,a,b,c,d)
 e=mke(-1,0,0) 
 e.life=t
 e.nxt=function() f(a,b,c,d) end 
end

--function clone_array(a)
-- local b={}
-- for n in all(a) do add(b,n) end
-- return b
--end

function can_pay(a)  
 sum=nil
 for sh in all(shelves) do
  inc_sum(sh,1)
 end
 inc_sum(a,-1) 
  
 local k=0
 for n in all(sum) do
  if n<0 then 
   return false 
  end
  k+=1
 end
 return true
end

function draw_rec(ri,x,y)

 map(7,16,x,y,5,5)
 local o=rdat[ri+1]

 function ings(a,by)
  local ki=0 
  local ec=10
  if #a>=4 then ec=6 end
	 for n in all(a) do
	  spr(n,x+17+ki*ec-#a*flr(ec/2),by)
	  ki+=1
	 end
 end
 
 if o.cost[1]!=48 then 
	 ings(o.cost,8+y)
	 spr(96,x+12,y+16)
	 ings(o.res,24+y) 
 else
  ings(o.cost,16+y)
 end
	
 

end

function any_but()
 for i=0,5 do 
  if btn(i) then return true end
 end
 return false
end

function msg(str,prt,nxt)

 port=prt or 140
 nxt=nxt or unfreeze
 freeze=true
 ms=mke(-1,0,0)
 tdy=0
 
 ms.upd=function(ms)
 
  if price then
   if btnp(0) or btnp(1) then
    choice=1-choice
    sfx(9)
   end
   if btnp(4) and ms.t>1 then
    kl(ms)
    if choice==0 then
     pay_gold(price,seller,buy_stuff)
	    sfx(15)
    else
     sfx(16)     
     unfreeze()
    end
    price=nil
   end
   
  elseif any_but() then
   if ms.t>= #str then
    kl(ms)
    nxt()
   else
    ms.t+=1
   end
  end
  
  
 end
 ms.dr=function(ms)
  rectfill(7,107,120,124,7)
  rectfill(8,108,119,123,13)
		spr(port,8,108,2,2)
		
		camera(-26,-110)
		clip(9,109,110,14)
		talk(str,ms.t,96,6)
		clip()
		camera()
		
		if price and ms.t>10 then
			for i=0,1 do
			 txt=i==0 and "yes" or "no"
			 bx=48+i*36
				print(txt,bx,117, 7)
				if choice==i then
				 spr(49,bx-8,117)
				end
			end
		end
		
 end
 ms.depth=2
 
end


function dr_cauldron(e)
 camera(-e.x,-e.y)
 sspr(88,24,16,8,0,10) 
 dx=0
 if e.recipe then dx=-16 end
 sspr(88+dx,16,16,8,0,2)
 camera()
end

function choose_wp(e)

 function inc(n)
  sfx(9)
  scn = (scn+n)%3
  reset_scene()
  add(ents,seq_loc)
 end
 if not sl then
 
	 if btnp(2) then inc(-1) end
	 if btnp(3) then inc(1) end
	 if btnp(4) then 
	  sfx(25)
	  sl=0
	 end
	
 else
  sl+=1
  if sl==16 then
   loop(control)
  end 
  if sl>48 then
   sl=nil
   kl(e)
   seq_loc=nil
  end
 end
end

function kl(e)
 del(ents,e)
 if e.nxt then e.nxt(e) end
end


function loop(f,dr)
 local e=mke(-1,0,0)
 e.upd=f
 e.dr=dr
 e.depth=2
 return e
end


function dr_witch(e)


 ddy=0

 if pcol(e.x+4,e.y+4,1) then
  ddy=-4
 end

	camera(-e.x,ddy-e.y)
	
	
	
	-- shade
	for x=0,10 do 
	 for y=5,11 do
	  n=pget(x,y)
	  pset(x,y,shd(n,0))
	 end
	end
	
 -- body 
 if is_moving() then
	 wface=0
	 wflp=witch.dx==-1
	 if witch.dy<0 then wface=1 end
	 if witch.dx!=0 then 
	 	wface=2 	
	 end
	 witch.ldx=witch.dx
	 witch.ldy=witch.dy
 end
 
 sspr(0+walk*12,64+wface*8,12,8,-2,0,12,8,wflp)
 local dy=walk%2
 
 -- net
 if witch.net then
  ddx=cos(witch.net)*4
  ddy=sin(witch.net)*4
 
  for e in all(ents) do
   if e.fly then
	   local dx=witch.x+ddx-e.x
	   local dy=witch.y+ddy-e.y
	   if sqrt(dx*dx+dy*dy)<16 then
	   
	    
	    catch_butterfly(e)
	   
	   end
   end
  end
 
 	function f(x,y)
	  sx=x+ddx
	  sy=y+ddy
	  tx=x+ddx*4
	  ty=y+ddy*4
	  line(sx,sy,tx,ty,4)
  end
  f(4,2)
  f(5,3)
  f(5,2)
  f(4,3)  
 end 
 
 -- head 
 if face==2 then wface+=walk end
 sspr(48,76+wface*3,8,3,0,-2-dy,8,3,wflp)
 

 
 -- hat
 sspr(48,64,12,12,-2,-14-dy)
 
 
 
 
 camera()

end

function catch_butterfly(e)
 --kl(e)
 sfx(21)
 grab_item(e)
 --wait(20,grab_item,e)
 
end

function mke(fr,x,y)
 e={fr=fr,x=x,y=y, depth=1, t=0,
  vx=0,vy=0,frict=0,szx=1,szy=1
 
 }
 add(ents,e)
 return e
end

function upe(e)
 e.x+=e.vx
 e.y+=e.vy

 e.t+=1
 if e.upd then e.upd(e) end
 if e.life then
  e.life-=1
  if e.life<=0 then kl(e) end
 end
 
 --flame
 if e.recipe and t%4==0 then
  mke(16,e.x+2+rand(8),e.y+12)
  if t%8==0 then
	  p=mk_anim(60,64,4,4)
	  p.spoiled=e.spoiled
	  p.x=e.x+2+rand(10)
	  p.y=e.y+6
	  p.vy=-.5-rnd(.5)
	  p.depth=2
  end
 end
 -- counters
 for v,n in pairs(e) do
  if sub(v,1,1)=="c" then
   n-=1
   e[v]= n>0 and n or nil
  end
 end 
  
 --tween
 if e.twc then
  local c=min(e.twc+1/e.tws,1)
  e.x=e.sx+(e.ex-e.sx)*c
  e.y=e.sy+(e.ey-e.sy)*c
  if e.jump then
   --local cc=sqrt(c)
   e.y+=sin(c/2)*e.jump
  end
  
  e.twc=c  
  if c==1 then
   e.twc=nil
   e.jump=nil
   f=e.twf
   if f then
    e.twf=nil
    f()
   end
  end
 end
  
end

function moveto(e,tx,ty,n,f)
 e.sx=e.x
 e.sy=e.y
 e.ex=tx
 e.ey=ty
 e.twc=0
 e.tws=n
 e.twf=f
end

function dre(e)

 npal=false
	if e.depth!=depth then return end
 if e==act and t%6<=1 and not freeze then
  cl=7
  if e.price and e.price>gold then
   cl=8
  end
  apal(cl)
  npal=true
 end
 
 if e.cbl then
  apal(7)
  npal=true
 end

 if e.spoiled then
  pal(3,4)
  pal(11,9)
  npal=true
 end

 
 if e.fr> 0 and (not e.cblk or t%4<2 )then  
  -- auto_anim
  if fget(e.fr,3) and e.t%4==0 then
   e.fr+=1
   if fget(e.fr,0) then
    kl(e)
    return
   end
  end  
  local fr=e.fr
  local x=e.x
  local y=e.y 
  if e.float then
   y += flr(sin(t/20+x/7)+.5)
  end 
  if e.fly then
   fr=57+flr(cos(t/10)+.5)
  end
  
  spr(fr,x,y,e.szx,e.szy) 
 end
 
 if e.dr then e.dr(e) end 
 if npal then pal() end
 
end


function rspr(fr,x,y,rot)
	for gx=0,7 do for gy=0,7 do
  px=(fr%16)*8
  py=flr(fr/16)*8	 
  p=sget(px+gx,py+gy)
  if p>0 then
   dx=gx
   dy=gy	 
   for i=1,rot do
    dx,dy=7-dy,dx
   end
   pset(x+dx,y+dy,p)
  end
 end end 
end

function dr_shelves()

 -- slots 
 n=0
 for sh in all(shelves) do
 	map(0,16,n*40,8,5,5) 	
 	for i=0,8 do 
 	 id=sh[i+1]	 
 	 if id then
 	  x,y=get_shelf_pos(n,i)
 	  clip(x,y,x+8,y+8)
 	  spr(id,x,y-2) 	   
 	  clip()	 
 	 end
 	end
 	n+=1
 end 
 
 --sides
 n=0
 for sh in all(shelves) do
  bx=n*40+14
  for i=0,1 do
   x=bx+i*25
 	 rectfill(x,8,x+2,47,2)
		end
		rectfill(bx,8,bx+27,14,4)
		n+=1
 end 
 
end


function _update()
 logp={}
 t=t+1
 ysort(ents)
 foreach(ents,upe)
end

function _draw()
 cls()
 
 if ens then
  ens()
  return
 end
 
 map(scn*16,0) 
 if scn==0 then
  dr_shelves()
 end
 
 -- ents
 dr_ents(0)
 dr_ents(1)
 dr_ents(2)
 
 --
 if sdr then sdr() end
   
 -- choose loc
 if seq_loc then
	  dr_choose_loc()
 end
 

 -- logs
 color(7)
 cursor(0,0) 
 for str in all(logs) do
  print(str)
 end
 for p in all(logp) do
  pset(p.x,p.y,t%15)
 end
 
end


function dr_choose_loc()
 a,b,c,d = 16,80,112,120
 if sl and sl>16 then
  b+=(sl-16)*2
  d+=(sl-16)*2
 end	 
 for x=a,c do
  for y=b,d do
   if (x+y)%2==0 then
    n=pget(x,y) 
    pset(x,y,shd(n,0))
   end
  end
 end
 rect(a,b,c,d,7)	 
 places={"shelter","forest","market"}
 function dr() 
	 print( "choose a working place ",a+5, b+3 )
	 for i=1,3 do  
	  print( "go to "..places[i], a+20, b+6+i*8, 7)
	 end
	 if not sl or ( sl<16 and sl%4<2 ) then
	  sspr(8,24,4,5,a+12,b+14+scn*8)
	 end
 end
 drop_shadow(dr)

end

function dr_ents(dp)	

 depth=dp
 for e in all(ents) do
 
  if e.lpy then
   clip(e.x-1,e.y-1,e.x+10,e.lpy)
  end
 
  if e.brd and not fading then
   --dre(e)
   border(dre,e)
  else
   dre(e)
  end  
  
  clip()
 end


end

function log(n)
 add(logs,n)
 if #logs>16 then
  del(logs,logs[1])
 end
end

function log_pt(x,y)
 add(logp,{x=x,y=y})
end

function drop_shadow(dr)
 apal(1)
 camera(-1,-1)
 dr()
 camera()
 pal()
 dr()	 
end

function apal(n)
 for i=0,15 do pal(i,n) end
end

function shd(n,k)
 local x = (n%4)+(k%2)*4
 local y = n/4+flr(k/2)*4
 return sget(x,y)
end

function ysort(a)
 for i=1,#a do
  local j = i
  while j > 1 and a[j-1].y > a[j].y do
   a[j],a[j-1] = a[j-1],a[j]
   j = j - 1
  end
 end
end


function talk(text,cur,xmax,lim)

 local x=0
 local y=-tdy
 
 if cur<#text and t%4==0 then
  bs=9
  if port==172 then bs=11 end
  sfx(bs+rand(2))
 end
 
 for i=1,cur do
  ch=sub(text,i,i)
  if ch==" " then
   vx=x
   for k=i+1,#text do
    vx+=4
    if sub(text,k,k)==" " then
     break
    end 
   end
   if vx>xmax then
    x=0
    y+=6
   else
    print(ch,x,y,7)
    x+=4 
   end
  else
   print(ch,x,y,7)
   x+=4   
  end
 end
 if y>lim then
  tdy+=1
 end
end

function mk_anim(sx,sy,sz,le)
 local e=mke(0,x,y)
 local fr=0
 e.dr=function(e)
  fr=flr(e.t/4)
  if fr==le then
   kl(e)
  else
   sspr(sx,sy+fr*sz,sz,sz,e.x-sz/2,e.y-sz/2)
  end
 end
 return e 
end

-- ch ry so po ei a

item_desc={
 "mushroom and apple spawn everyday in the forest",
 "try to catch some butterlfy in the forest. they're amazing. please dont cook them all.",
 "when you grab logs in the forest, it directly goes to your shelf.",
 "you will run faster with this boots",
 "an extra cauldron will let you brew one more recipe each day.",
 "you will be able to stock more ingredients with this solid oak furniture.", 
 "i can improve the size of your wagon if you pay me.", 
 "this fine salt will increase by one the number of customer that come each days.", 
}

quotes={
 "in alchemy, the term chrysopoeia means transmutation into gold.",
 "sulphur, the fiery spirit that vivifies everything is the substance of the great work.",
 "true alchemy never regard earth, air, water, and fire as corporeal or chemical substances.",
 "lead represents the impurities of metals and humans",
 "within the first group are the illuminations and emblems found within the alchemical texts themselves",
 "mercury is the sole fire, used in its chemical form, quicksilver.",
 "the ourobouros will show you the way for the final transmutation.",
 "salt is the 'prima materia' for the stone of the philosophers.",
 "chrysopoeia indicates the creation of the philosopher's stone and the completion of the great work.",
 "calcination, sublimation and dissolution will be the three final steps",
 "the secrets of alchemy exist to transform mortals from a state of suffering and ignorance to a state of enlightenment and bliss.",
 "and, when you want something, all the universe conspires in helping you to achieve it.",

}
__gfx__
0011000000bb33bb04400000024442200000b000000000000000000000000770005555000000000000777a000444555000000000000000000000000055555555
21d600000bb3bbb04444400024444422000b00000bbbb000005050000000077f05555650077ddef00aa777a0444455550044550000ff00000000000051155555
24930000bb3bbbb02444444044444422088b22207b7bbb00aa0509900000fff4055561117777ffdeaaaa77aa444455550444455000fff0000000000015555655
d1d90000b3bbbb0022444ff4244442228e888222bbbbbbb0aa954990000ff40051561551edd2f22eaa97a77a221221220444455000ffff000000000055555655
000000003bbbb0000224f99f022222208e888222ffffbbb3aa95499000ff4000551115510eddf2e0999aa9992e5ee5e2e544555e00fff0000000000055557555
000000003bbb00000022f99f00d6dd008888822d9999bbbb0a9549007ff400005551111100edfe009aa999905effeee5e555555e00ff00000000000056675555
00000000200000000002f99f00776d00088822d00344b33ba7954a90fff0000005511110000ef0000999440005f45e5005555550000000000000000055555555
000000004000000000002ff0000770000022dd00334b34bbaa0509900f40000000111100000000000044400000ffee0005e55e50000000000000000055555555
0000000000000800008000000200000000000000000000000ffffff000000000000f0000000f0000000f00000cccddd007cfed60555555554444422244444111
000000000088880008800080000000000000000000000000f4ffffff000000000074700000747000007470000cccddd067c76d6d555542454444411144444111
000000000888880000000000000000000000000000000000f944440000000000007c7000007c7000007c70000ccc0dd067c76d6d5555224144444ddd44444111
000900000889980000000000000000000000000000002000f99999000000000007c0060007c0060007c006000ccd0550e7c76d625554444122222ddd22222000
000990000899980000800000000000000000080000000000ffffff00000000007aabb3c0777aa9c07ee882c00cc00440ecccddd2554411114444411144444555
009a90000899980000000000000009000000000000000000ffffff00000000007aabb3c0777aa9c07ee882c0099000000cccddd0544115554444411144444111
00aaa000008980000000a000000000000000000000000000fff99999000000006bb333c06aa999c0688222c0044000000ccdddd0441155554444411144444111
000a000000000000000000000000000000000000000000000f4444400000000006cccc0006cccc0006cccc000440000000dddd00511555552222211122222111
00fff9006767676000000040000000001dddddd1444444440000000000000000000000000000dddddd6600000000dddddd660000555555555555555555555555
0f90099006767dd60006642000422000d111111d4111111400000000002820000000000000dd11111111d60000dd11111111d600555111111111155555555555
f90000990067ddd700064207042240001dddddd1422222240044444400888000000000000d111111111111600d11111111111160551111111111115555555555
f99999990006dd700004266704492222d11111114244442442449994007cc0000000000061113333333311166111111111111116511010101010101511111111
f9444499000467000042066704444442d66ddd11411111140049242907cccc000000000061333333333333166111111111111116510101010101001566666666
ff999999009400000420777004444444dddddd1142222224000945497c777cc0000000006733bbbbbbbb33dd67111111111111dd550000000000005555555555
ffffff990940000042000000099999901dddd1114244442400092429c77777d0000000001677bbbbbbbbddd1167711111111ddd1555000000000055555555555
0fffff909400000020000000000000000111111040000004000099900cdddd000000000011d67776ddddd11111d67776ddddd111555555555555555555555555
0009000077000000001121d62493d1d95551111111111555000000000000000009900aa000000000000000001dddddddd1111111555555552222222244444111
00999000777000000000101d1241101455166666666665550077a000000000000990aaaa0900000000d000001dd676dddd11111155555555dddddddd44444111
09909900777700000000000101200002516555555555555507999a0000000000099aaaaa0d900000099aaa001dd777ddddd11111555555556666666644444111
99000990777000000000000000100001165555555555555507999a00000000000d9aaaa000aaa000099aaaa01dd676ddddd11111555555556666666622222111
9009009077000000000000000000000055555555555555610a999a000000000000daaa00000aaa00999aaaa00dddddddddd11110555555555555555544441115
00999000000000000000000000000000555555555555561500aaa00000000000000d00000000da00990aaa0000dddddddd111110555555555555555544441115
09909900000000000000000000000000555666666666615500000000000000000000d00000000000000aaa00000dddddd1111100555555555555555544441115
99000990000000000000000000000000555511111111155500000000000000000000000000000000000a00000000011111111000555555555555555522221115
fffffffe00000000000000004444444442444444bbbbbbbbbbbbbbbbffffffffbb777fbb3fffffffbbbbbbb33bbbbbbbfffffff3000000000000000000666600
fefeffee00000000000000004444444442444444bbbbbbbbbbbbbbbbffffffffb74444fbb3ffffffbbbbbb3ff3bbbbbbffffff3b000000000000000006111160
feeefeee00000000000000004444444442444444bbbb3bbbbbbbbbbbffffffffb3777f3bbb3fffffbbbbb3ffff3bbbbbfffff3bb000000000000000071111116
ffefeeee00000000000000002222222222222222bbbb3bbbbbbbbbbbffffffffb7777ffbbbb3ffffbbbb3ffffff3bbbbffff3bbb00000000000000006711116d
fffeeeee00000000000000004424444444444444b3bb3bb3bbbbbbbbffffffff77777fffbbb3ffffbbb3ffffffff3bbbffff3bbb0000000000000000667666dd
ffeee2e200000000000000004424444444444444bb3b3b3bbbbbbbbbffffffff77777fffbb3fffffbb3ffffffffff3bbfffff3bb00000000000000006666dddd
feeee22200000000000000004424444444444444bbbbbbbbbbbbbbbbffffffff3777fff3b3ffffffb3ffffffffffff3bffffff3b00000000000000006666dddd
eeeeee2e00000000000000002222222222222222bbbbbbbbbbbbbbbbffffffffb3ffff3b3fffffff3ffffffffffffff3fffffff300000000000000006666dddd
eeeeeeee1111111100000000444444444444244499999999ffffffff3bbbbbb3ffffffff97777779333333333333b3333bb33bbbbb3bbbb3000000000666ddd0
e2e2eeee1111111100000000444444444444244499999999fffffffff3bbbb3fffffffff77666677bb33b333333333bb3bb33bbbbbbbb3b3000000000066dd00
e222eeee1111111100000000444444444444244499999999ffffffffff3bb3ffffffffff76777767b3b33333333333bb333bbbb3bbb33b330000000000666600
ee2eeeee1111111100000000222222222222222244444444fffffffffff33fffffffffff76777767bb3333333b33bb33b33b33bb33b333330000000006676660
eeeeeeee4444444400000000444442444444444499999999fffffffffffffffffff33fff77666677bb33b33b33333b33333333bb33bb33b300000000667dd667
eeeee2e24444444400000000444442444444444499999999ffffffffffffffffff3bb3ff477777743bbbb33333b33bbb33333b3bbb33333300000000d666667d
eeeee2224444444400000000444442444444444499999999fffffffffffffffff3bbbb3f94444449bbb33bb33b3bbbbb333b33bbbb333333000000000d6667d0
eeeeee2e2222222200000000222222222222222299999999ffffffffffffffff3bbbbbb399999999bbb33bb33bbbb3bb33333333333b33330000000000dddd00
0000000024444444000000000000000000000000444444444444444444444444b99999bb99999999333333331111111111111111bbb77bbbbbbbbbbb00000000
00eeee00242222220000000000000000000000004444444444444444444444449999999b99999999333333331111111111111111bbb77bbbbb6666bb00000000
00eeee00242a29220000000000000000000000004411111111111111111111449999999b99999999333333331111111111111111b776677bb6667ddb00000000
00eeee00242aa9120000000000000000000000004411111111111111111111444999994b99999999333333331111113111111111b776677b6677dddb00000000
eeeeeeee242211120000000000000000000000003333333333333333333333334444444399999999333333331131133111111111bbb77bbb677dddd300000000
0eeeeee02222222200000000000000000000000033b3b33333333b33333333334411144399999999333333331133131111111111bbb77bbb666ddd3300000000
00eeee0011111111000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbb4413344399999999333333331113111111111111bbb3bbbbbb33333300000000
000ee00011111111000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbb33bb33399999999333333331111111111111111bbb3bbbbbbbb333300000000
ffffffff222222222122222288828802888088020882088088800880888288828888800013333331311111111111311113311333331333310000000000000000
fefeffff222222222122222288828802888288028882880288028802880008808800800091333319331131111111113313311333333331310000000000000000
feeeffff222222222122222288008802880288028800880288028802880008808800800099133199313111111111113311133331333113110000000000000000
ffefffff111111111111111188008802880288028880880288028802880008808800800099911999331111111311331131131133113111110000000000000000
ffffffff221222222222222288008882888008800882880288808802888008808888800099999999331131131111131111111133113311310000000000000000
fffffefe441444444444444488008802880208800082880288008802880008808800800099999999133331111131133311111313331111110000000000000000
fffffeee442444444444444488828802880208808882880288008802880008808800800099999999333113311313333311131133331111110000000000000000
ffffffef222222222222222288828802880208808880088088000880888288828800800099999999333113311333313311111111111311110000000000000000
011ffffff11011cdffff1000011ffffff110001dffffd111000000cd0000000000000000000000000000000005555110cfffccdddedccccccc55155511155111
01cdffff1d101ffcceedd00001cdffff1d1000dcceeccff1000000cd000007b000000000000000000000000055555111ccfcccddeefcccc1c577555511111111
0cdcceedd1d01ffcccdddd000ddcceedccc000dcccccdff100000ccd00000bb000000000000000000eedeed07555111dcccccccccfcccd115775555111dd6111
0ffcccddddd011dccfccdd000eccccdddff000dccfcddd1100000ccd000000000000000000000000eeeeeedd177766d1fccccfcccccdde11555151111dd66611
0ffccfcdddd001dcccccdd000ecccfcddff000ccccdddd110000cfcd00000aa00000000000000000eeeeeddd51114141ccccfffcd1111e1155511111224466d1
00dcccdddd0000dddfcccd0000ccccddd00000cccfcddd110000cccd0000a00b0000000000000000dddddddd551495911d11dddee11771115551111224441ddd
00dccfcccd00000dddcffd0000cccfcdd00000cffcdddd00000ccccdd000a00b0000000000000000d9d99d9d044999901ef11effff117e11551111211119144d
000ddddeec000000dddeed0000ceecdd000000ceedddd000000cfccde0000bb00000000000000000dfdffdfd0599995011f11effff117f115111124116191444
0011111111000011111111100111111111101111111111000ccccccdddd0f00f0000000000000000dcffffcd06d44dd012eeefffffffff111111249999999449
00111111111000e111111111011111111110111111111e00ccfcccccdded00000000000000000000dcc99ccd46ddddd422eeefffffffff1111124a999999949c
0011111111100ffd111111110111111111c011111111def0cccccfcccddd00000000000000000000dccffccd99dddd99221eeeeffffff111c1144999999999cc
0ed1111111100ffc11111111011111111de01111111dddf00cccccccccc0f00f00000000000000000fcccc90995dd5992211ef222ffff111c511444994994466
0ed1111111d000dcccd111100d1111111de011111dcddd001d1dd1d1000000000000000000000000cdfccfdc0554455022111fe2efffe111c5114224499444dd
00d111111d0000dddcccdd1000d111111d000dddcccddd001e1ee1e10000000000000000000000007cdccdc706d44dd021111dfffffe1111ccc11499994444d5
00dcdddddc00000dddcffc0000ccdddddd0000cffcdddd001ffffff10000000000000000000000000766667006d00dd02111ccddeeee1111ccc5449994444d55
000ddddeec000000dddeed0000ceecddd00000ceedddd000111111110000000000000000000000000080080006d00dd0211ccdddeeee1111cc5555544444d555
011111ffff00111ddccffd00011111ffff000111111fff00111111110000000000000000000000000000000000000000cc9944444444555c2deeeedeeeefdddd
1111ddcffe0011ffccccec0011111dcffe00011111dcc000111111110000000000000000000000000000000000000000c994445445444555ddeeedeeeefdfddd
111ddccce00001ffccccfc001111dcccc000011111cccff011111d1d0000000000000000000000000000000000000000c945555555554555ddddddeeefdfddd5
111ddccccf0000dddccccc00111ddccccc0001111dcccff01111de1e0000000000000000000000000000000000000000995eeeeeeee55555dddddddeeefdddd5
011dffcccc0000ddccccfc00011ddcffcc0000dddddddc001111ffff0000000000000000000000000000000000000000945555ee555e5555dd5ff9ddddddddd5
00ddffcccf000dddccccccf000ddddffcc000feddccccc001111d1dd0000000000000000000000000000000000000000955eeeeeeee5e555d59fff9dddd5d5d5
00ddddcccc0000dddcccdfe000dddddccc0000fedcccc000111de1ee0000000000000000000000000000000000000000c55555ee555ee555d59fffff9dd5d5d5
000dcccccf0000000000000000deecccc000000000000000111fffff0000000000000000000000000000000000000000c5e75efee5f5e55e2dddfff99999d555
011ffffff11011cdffff1000011ffffff110001dffffd11111111d1d0000000000000000000000000000000000000000c5efffeeeeeee55e2d7dfffdddf9d555
01cdffff1d101ffcceedd00001cdffff1d1000dcceeccff11111de1e0000000000000000000000000000000000000000b5effeeeeeee55ee2d7dfffdd7d9d555
0cdcceedd1d01ffcccdddd000ddcceedccc000dcccccdff11111ffff0000000000000000000000000000000000000000bbbf4ee55eeeee552dfffffdd7dfd555
0ffcccddddd011dccfccdd000eccccdddff000dccfcddd11111111d10000000000000000000000000000000000000000bbb9445555eeee552df7ffffffffd555
0ffccfcdddd001dcccccdd000ecccfcddff000ccccdddd1111111de10000000000000000000000000000000000000000bbb9ffee55eee5332dfffffffffd5555
00dcccdddd0000dddfcccd0000ccccddd00000cccfcddd1111111eff0000000000000000000000000000000000000000bb33ffeeeee6ddd32ddf9ffffffd5555
00dccfcccd00000dddcffd0000cccfcdd00000cffcdddd000000000000000000000000000000000000000000000000003337eeeeee6cc666ddddfffff99d5555
000ddddeec000000dddeed0000ceecdd000000ceedddd000000000000000000000000000000000000000000000000000337ceeeee7cc6666ddccdd99999d5555
00fffffffffffffffff90000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f94fffffffffffffffff000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f9994ffffffffffffffff900ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f9994fffffffffffffffff00ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f99944444444444400000000ffffffff0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff0000000000000000
f99999999999999900000000ffffffff0000000000000000000000000000000000000000000000000000000000000000f2444444444444440000000000000000
f99fffffffffffff00000000ffffffff0000000000000000000000000000000000000000000000000000000000000000f2244444444444440000000000000000
f9ffffffffffffff00000000ffffffff0000000000000000000000000000000000000000000000000000000000000000f2224444444444440000000000000000
9fffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000f9999fffffffffff077a000000000000
9fffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000f9999fffffffffff7999a00000000000
9fffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000f4444999999999997999a00000000000
9fffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000f9999fffffffffffa999a00000000000
9ffff9999999999999999900000000000000000000000000000000000000000000000000000000000000000000000000f9999fffffffffff0aaa000000000000
9ffff9999999999999999900000000000000000000000000000000000000000000000000000000000000000000000000f4444999999999990000000000000000
09ff94444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000f9999fffffffffff0000099999900000
009944444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000f9999fffffffffff0009999999999000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f4444999999999990099944444499900
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f9999fffffffffff0994444444444990
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f9999fffffffffff0944400220044490
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f4444999999999999444000220004449
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffff9440000440000449
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444444400000440000044
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444444444999449999444
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444444422444444444244
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222999999994422444444444244
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222999999994490000440000944
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222220444444444499000440009944
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222200000022000449900440099440
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400444999449994440
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000440044499999944400
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040004444444444000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444400000
__label__
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffef1f1fffe111fff
feeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffe17171ff177a1ff
ffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffff17171f17999a1f
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff17771f17999a1f
fffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefff1171e1a999a1e
fffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeeffff171ef1aaa1ee
ffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffeffffff1efff111fef
ffffffffffffff4444444444444444444444444444ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fefefffffefeff4444444444444444444444444444fefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefeffff
feeefffffeeefe4444444444444444444444444444eefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeeffff
ffefffffffefee4444444444444444444444444444efffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffff
fffffffffffeee4444444444444444444444444444ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffefeffeee24444444444444444444444444444fffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefe
fffffeeefeeee24444444444444444444444444444fffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeee
ffffffefeeeeee2222222222222222222222222222ffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffef
fffffffeeeeeee2221111111bb3bbbb11111111222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fefeffeee2e2ee2221111111b3bbbb111111111222fefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefeffff
feeefeeee222ee22211111113bbbb1111111111222eefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeeffff
ffefeeeeee2eee22211111113bbb11111111111222efffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffff
fffeeeeeeeeeee2224444444244444444444444222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffeee2e2eeeee22224444444444444444444444222fffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefe
feeee222eeeee22224444444444444444444444222fffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeee
eeeeee2eeeeeee2222222222222222222222222222ffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffef
eeeeeeeeeeeeee2224444441444444221111111222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e2e2eeeee2e2ee2222444ff4244442221111111222fefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefeffff
e222eeeee222ee222224f99f122222211111111222eefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeeffff
ee2eeeeeee2eee222122f99f11d6dd111111111222efffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffff
eeeeeeeeeeeeee222442f99f44776d444444444222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eeeee2e2eeeee22224442ff4444774444444444222fffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefe
eeeee222eeeee22224444444444444444444444222fffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeee
eeeeee2eeeeeee2222222222222222222222222222ffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffef
eeeeeeeeeeeeee2221111111111111111111111222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e2e2eeeee2e2ee2221111111111111111111111222fefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefeffff
e222eeeee222ee2221111111111111111111111222eefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeeffff
ee2eeeeeee2eee2221111111111111111111111222efffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffff
eeeeeeeeeeeeee2224444444444444444444444222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
eeeee2e2eeeee22224444444444444444444444222fffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefefffffefe
eeeee222eeeee22224444444444444444444444222fffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeeefffffeee
eeeeee2eeeeeee2222222222222222222222222222ffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffefffffffef
22222222212222222444444424444444244444422244444444444444424444444444444442444444444444444244444444444444424444444444444442444444
22222222212222222422222224222222242222222244444444444444424444444444444442444444444444444244444444444444424444444444444442444444
2222222221222222242a2922242a2922242a29222244444444444444424444444444444442444444444444444244444444444444424444444444444442444444
1111111111111122242aa912242aa912242aa9122222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22122222222222222422111224221112242211122244444444244444444444444424444444444444442444444444444444244444444444444424444444444444
44144444444444222222222222222222222222222244444444244444444444444424444444444444442444444444444444244444444444444424444444444444
44244444444444222111111111111111111111122244444444244444444444444424444444444444442444444444444444244444444444444424444444444444
22222222222222222111111111111111111111122222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
44444444444424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444444442444
44444444444424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444444442444
44444444444424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444444442444
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
44444244444444444444424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444
44444244444444444444424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444
44444244444444444444424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444
22222222226666222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
44444444466766644444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444444442444444
44444444667dd6674444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444444442444444
44444444d666667d4444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444444442444444
222222226d6667dd2222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
4424444466dddddd4424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444444444
442444446666dddd44244444444444444424444444444444442444444444444444244444444444444424444444444444442444444444dddddd66444444444444
442444446666dddd442444444444444444244444444444444424444444444444442444444444444444244444444444444424444444dd11111111d64444444444
222222226666dddd222222222222222222222222222222222222222222cd222222222222222222222222222222222222222222222d1111111111116222222222
444444444666ddd4444444444444244444444444444424444444444444cd24444444444444442444444444444444244444444222611111111111111622222222
444444444466dd4444444444444424444444444444442444444444444ccd244444444444444424444444444444442444444441116111111111111116dddddddd
444444444444244444444444444424444444444444442444444444444ccd24444444444444442444444444444444244444444ddd67111111111111dd66666666
22222222222222222222222222222222222222222222222222222222cfcd22222222222222222222222222222222222222222ddd167711111111ddd166666666
44444244444444444444424444444444444442444444444444444244cccd4444444442444444444444444244444444444444411111d67776ddddd11155555555
4444424444444444444442444444444444444244444444444444424ccccdd44444444244444444444444424444444444444441111dddddddd111111155555555
4444424444444444444442444444444444444244444444444444424cfccde44444444244444444444444424444444444444441111dd676dddd11111155555555
22222222222222222222222222222222222222222222222222222ccccccdddd222222222222222222222222222222222222221111dd777ddddd1111155555555
4444444442444444444444444244444444444444424444444444ccfcccccdded44444444424444444444444442444444444441111dd676ddddd1111155555555
4444444442444444444444444244444444444444424444444444cccccfcccddd44444444424444444444444442444444444441115dddddddddd1111555555555
44444444424444444444444442444444444444444244444444444cccccccccc4444444444244444444444444424444444444411155dddddddd11111555555555
2222222222222222222222222222222222222222222222222222221d1dd1d1222222222222222222222222222222222222222000511dddddd111111511111111
4424444444444444442444444444444444244444444444444424441e1ee1e1444424444444444444442444444444444444444555510101111111101566666666
4424444444444444442444444444444444244444444444444424411ffffff1144424444444444444442444444444444444444111550000000000005555555555
442444444444444444244444444444444424444444444444442441cdffff1d144424444444444444442444444444444444444111555000000000055555555555
22222222222222222222222222222222222222222222222222222cdcceedd1d22222222222222222222222222222222222222111555555555555555555555555
44444444444424444444444444442444444444444444244444444ffcccddddd44444444444442444444444444444244444444111555555555555555555555555
44444444444424444444444444442444444444444444244444444ffccfcdddd44444444444442444444444444444244444444111555555555555555555554245
444444444444244444444444444424444444444444442444444444dcccdddd222444444444442444444444444444244444444111555555555555555555552241
222222222222222222222222222222222222222222222222222222dccfcccd111222222222222222222222222222222222222111555555555555555555544441
4444424444444444444442444444444444444244444444444444422ddddeec222444424444444444444442444444444444441115555555555555555555441111
44444244444444444444424444444444444442444444444444444222222222222444424444444444444442444444444444441115555555555555555554411555
44444244444444444444424444444444444442444444444444444222222222222444424444444444444442444444444444441115555555555555555544115555
22222222222222222222222222222222222222222222222222222211111111111222222222222222222222222222222222221115555555555555555551155555
44444444424444444444444442444444444444444244444444444422212222222444444442444444444444444244444444444111555555555555555555555555
44444444424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444111555555555555555555555555
44444444424444444444444442444444444444444244444444444444424444444444444442444444444444444244444444444111555555555555555555555555
22222222222222222222211111122222222222222222222222222222222222222222222222222222222222222222222222222111555555555555555555555555
44244444444444444421199999911444442444444444444444244444444444444424444444444444442444444444444444441115555555555555555555555555
44244444444444444419999999999144442444444444444444244444444444444424444444444444442444444444444444441115555555555555555555555555
44244444444444444199944444499914442444444444444444244444444444444424444444444444442444444444444444441115555555555555555555555555
22222222222211111994444444444991111122222222222222222222222222222222222222222222222222222222222222221115555555555555555555555555
222222222221fffff777afffffffffffffff12222222222244444444444424444444444444442444444444444444244444444111555555555555555555555555
ddddddddddd1f244aa777a444444444444441ddddddddddd44444444444424444444444444442444444444444444244444444111555111111111155555555555
666666666661f22aaaa77aa444444444444416666666666644444444444424444444444444442444444444444444244444444111551111111111115555555555
666611111111f22aa97a77a444444444444416666666666622222222222222222222222222222222222222222222222222222000511010101010101511111111
555199999999f99999aa999fffffffffffff15555555555544444244444444444444424444444444444442444444444444444555510101010101001566666666
555199999999f999aa9999ffffffffffffff15555555555544444244444444444444424444444444444442444444444444444111550000000000005555555555
555144444444f4449994499999999999999915555555555544444244444444444444424444444444444442444444444444444111555000000000055555555555
555511112211f9999444ffffffffffffffff15555555555522222222222222222222222222222222222222222222222222222111555555555555555555555555
555555551441f9999fffffffffffffffffff15555555555544444444424444444444444442444444444444444244444444444111555555555555555555555555
555555555144f4444999999999999999999915555555555544444444424444444444444442444444444444444244444444444111555555555555555555555555
555555555514f9999fffffffffffffffffff15555555555544444444424444444444444442444444444444444244444444444111555555555555555555555555
555511111111f9999fffffffffffffffffff15555555555522222222222222222222222222222222222222222222222222222111555555555555555555555555
555199999999f4444999999999999999999915555555555544244444444444444424444444444444442444444444444444441115555555555555555555555555
555199999999f9999ff9999999999fffffff15555555555544244444444444444424444444444444442444444444444444441115555555555555555555555555
555144444444f9999f999444444999ffffff15555555555544244444444444444424444444444444442444444444444444441115555555555555555555555555
555511112211f4444994444444444999999915555555555522222222222222222222222222222222222222222222222222221115555555555555555555555555
555555551441fffff9444ff22ff4449fffff15555555555544444444444424444444444444442444444444444444244444444111555555555555555555555555
55555555514444449444444224444449444415555555555544444444444424444444444444442444444444444444244444444111555555555555555555555555
55555555551444449444444444444449444415555555555544444444444424444444444444442444444444444444244444444111555555555555555555555555
55555555555144444444444444444444444415555555555522222222222222222222222222222222222222222222222222222111555555555555555555555555
55555555555511114444999449999444111155555555555544444244444444444444424444444444444442444444444444441115555555555555555555555555
55555555555555514422444444444244155555555555555544444244444444444444424444444444444442444444444444441115555555555555555555555555
55555555555555514422444444444244155555555555555544444244444444444444424444444444444442444444444444441115555555555555555555555555
55555555555555514491112442111944155555555555555522222222222222222222222222222222222222222222222222221115555555555555555555555555
55555555555555514499151441519944155555555555555544444444424444444444444442444444444444444244444444444111555555555555555555555555
55555555555555551449911441199441555555555115555544444444424444444444444442444444444444444244444444444111555111111111155555555555
55555555555555551444999449994441555555551555565544444444424444444444444442444444444444444244444444444111551111111111115555555555
55555555555555555144499999944415555555555555565522222222222222222222222222222222222222222222222222222000511010101010101511111111
55555555555555555514444444444155555555555555755544244444444444444424444444444444442444444444444444444555510101010101001566666666
55555555555555555551144444411555555555555667555544244444444444444424444444444444442444444444444444444111550000000000005555555555
55555555555555555555511111155555555555555555555544244444444444444424444444444444442444444444444444444111555000000000055555555555
55555555555555555555555555555555555555555555555522222222222222222222222222222222222222222222222222222111555555555555555555555555

__gff__
0002000202020000000000000000000208080808080801000000000000020202000000000101010000000000000202020000000002020000000000000002020000000000000808000100000000000000000100000001000000010808080800000001000000000000000008080808010001000000000000000000080808080000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
707070707070707070707070707070706c7b6a5b454545454545455a6a7a6c6c454545464546464646464645464545453000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
707070707070707070707070707070707b6a5b454545454545466d45455a6a7a454545464646464545464646454546450286030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
707070707070707070707070707070706a5b456d454545454545454545456a6a454646464545454545465555555555450401860603000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
707070707070707070707070707070705b454646464546454645454545455a6a454646464646464648466566666667450586040403000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707057574b6a6a5c4545454545454645455a46595559555955594645454a574b45450403038609000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
434443444344434443444344434443445656567979794b464545454545454545486566666666666746464649564c45450686070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
535453545354535453545354535453545647566969694c45454645454545454557574b4a575757574b4a5756565657570202028608000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4344434443444344434443444344434458585858585858454646454546454545565656475656565656565656565647560501860708000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5354535453545354535453541e3e3e3e45454545454545464645454545456a5c565647475656565656564756696969690802860900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4344434443444344434443441f2d2e2f4545454645454546464545456d5d6a6a56565656565656565656565669696969090807860a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5354535453545354535453543f3d3d1d5c454545454545454545455d6a6a6a7d585858585858585858585858585858580101860500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4344434443444344434443443f3d3d3d6a456d45454546454545455a6a6a7d6c464646464646464646464646464646460201018606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3e3e3e3e3e3e5354535453541f2d2e2f7c5c45454545454545454545455a6a7a455559555955595559554646464546460305860701010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3d3d0f3d3d4344434443443f3d3d3d7b6a5c454545454545454545455d6a7d466566666666666666674646464646460701860605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3d3d3d3d3d5354535453543f3d3d3d7d7c6a6a5c454545454645455d6a7d6c464668466846684668454646466e46450403018608000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d3d3d3d3d0f4344434443441f2d2e2f6c6c7c6a6a5c45454545455d6a7d6c6c46464646464646464646466e464646460604038609000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70405151518c8dc0c1c1c1c200cccdcdcdcd0000000000000000000000000000000000000000000000000000000000000101860203040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40505151519c9d5656565600fddcdddddddd00010d020d030d040d050d060d070d080d090000000000000000000000000202040486090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505051515100005656565600fdecedededed0000000000000000000000000000000000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050515151000056565656000000fc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71726161610000d0d1d1d1d20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021222324252627000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0605040308060803000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010500003461400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800003054030520305100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002b0542b055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000745507435000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001f62500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001362500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001f61400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001361400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000184501f352241222d11500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001f05500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002105500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001155500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f3501f310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000376542b6341f6241361400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002d5552d515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c5550c515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f0422b5212b5150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000735507315000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002105500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f65407621070350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001335515442183250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001f3541f2251f1150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f055131151d055291151d315131151a0551a1121b0551a05518055181121d025110151a0251101518052180421803218022180121801218012180150000000000000000000000000000000000000000
012000001f3251f3451f3751f3551f3351f3251f31500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f3551b355183551d3351d3251d3150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018055180051f0550000524055000051332300005220551f005111151f0551d005111151d055000051b0551b0051b0551b0521b0550000513333000051d05500005111151805500005111151605500000
01100000115341d511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001d53411511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010900003705037030370100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
