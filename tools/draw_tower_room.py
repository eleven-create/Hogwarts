"""Original, reproducible pixel scenery. Pillow only; no network or image API.

640x360 logical pixels, displayed with nearest filtering at 2x.
Coordinate layout is mirrored by bedroom.tscn collision rectangles.
"""
from pathlib import Path
import math
import random
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "environments"
R = random.Random(29)
im = Image.new("RGB", (640, 360), "#10131e")
d = ImageDraw.Draw(im)

def box(x, y, w, h, c, edge=None):
    d.rectangle((int(x), int(y), int(x+w-1), int(y+h-1)), fill=c, outline=edge)

def line(points, color, width=1):
    d.line(points, fill=color, width=width)

def poly(points, color):
    d.polygon(points, fill=color)

def ellipse(x,y,w,h,c,edge=None):
    d.ellipse((x,y,x+w-1,y+h-1),fill=c,outline=edge)

def wood(x,y,w,h,light=False):
    box(x,y,w,h,"#754b36" if light else "#4d342d","#231e24")
    box(x+1,y+1,w-2,2,"#b48250" if light else "#896143")
    for yy in range(y+5,y+h-2,5):
        line([(x+2,yy),(x+w-3,yy)],"#56392f" if light else "#38292a")
    for _ in range(max(1,w*h//160) if w>5 and h>5 else 0):
        xx=R.randrange(x+2,x+w-3); yy=R.randrange(y+3,y+h-2)
        line([(xx,yy),(min(x+w-3,xx+R.randrange(3,12)),yy)],"#976744" if light else "#654633")

def candle(x,y):
    ellipse(x-5,y+7,12,4,"#201c24")
    box(x-4,y+5,10,2,"#bb8d50")
    box(x,y-9,3,15,"#d9c79a");box(x,y-9,1,13,"#fff0c5")
    box(x+1,y-15,1,2,"#ffdbaa");box(x,y-13,3,4,"#d9763e")
    box(x+1,y-12,1,3,"#fff2bf")

def book(x,y,w,h,c):
    box(x,y,w,h,"#241f25");box(x+1,y+1,w-2,h-2,c)
    box(x+2,y+2,1,h-4,"#d5a961")
    if w>10:
        box(x+4,y+3,w-6,1,"#b39062");box(x+4,y+h-4,w-6,1,"#b39062")

def trunk(x,y,w=43):
    box(x+3,y+20,w,5,"#252027")
    wood(x,y,w,23);box(x+1,y,w-2,6,"#775139")
    box(x+1,y+5,w-2,1,"#b38751")
    for xx in [x+6,x+w-9]:
        box(xx,y+1,3,21,"#25282b");box(xx,y+3,3,1,"#b19560")
        box(xx,y+18,3,1,"#b19560")
    box(x+w//2-3,y+9,7,6,"#ba934b");box(x+w//2,y+11,1,3,"#4c3328")
    for xx in [x+1,x+w-4]:
        box(xx,y+1,3,3,"#aa8047");box(xx,y+18,3,4,"#aa8047")

def arch(x,y,w,h):
    # Deep window reveal and concentric stepped masonry.
    box(x-5,y+24,w+10,h-20,"#262936")
    for inset,c in [(0,"#77726c"),(3,"#aaa08a"),(6,"#393b48"),(9,"#171f34")]:
        xx=x+inset; yy=y+inset; ww=w-2*inset
        d.rounded_rectangle((xx,yy,xx+ww,y+h),radius=ww//2,fill=c)
    box(x+9,y+w//2,w-18,h-w//2,"#17283e")
    # Night air, distant mountains, tower silhouettes, moon.
    poly([(x+10,y+h-28),(x+24,y+h-42),(x+40,y+h-25),(x+w-10,y+h-44),(x+w-10,y+h),(x+10,y+h)],"#233b50")
    for xx,hh in [(x+14,24),(x+w-26,36)]:
        box(xx,y+h-hh,9,hh,"#101d30")
        poly([(xx-2,y+h-hh),(xx+4,y+h-hh-11),(xx+11,y+h-hh)],"#101d30")
        box(xx+3,y+h-hh+8,2,4,"#9c947a")
    ellipse(x+21,y+23,13,13,"#d6ddd0");ellipse(x+25,y+20,13,13,"#17283e")
    for sx,sy in [(18,45),(38,16),(48,32),(31,54)]:
        box(x+sx,y+sy,1,1,"#abc7cc")
    box(x+w//2-2,y+12,4,h-10,"#8e887b")
    box(x+8,y+62,w-16,3,"#8e887b")
    for xx in range(x+13,x+w-10,12):
        line([(xx,y+29),(min(xx+24,x+w-9),y+62)],"#506676")
        line([(xx,y+64),(min(xx+24,x+w-9),y+97)],"#506676")
    box(x-5,y+h,w+10,6,"#95836c");box(x-7,y+h+6,w+14,3,"#4d4543")

def banner(x,y):
    box(x-4,y-3,40,3,"#a58b58")
    poly([(x,y),(x+31,y),(x+31,y+55),(x+15,y+67),(x,y+55)],"#5e2430")
    poly([(x+3,y+2),(x+28,y+2),(x+28,y+53),(x+15,y+62),(x+3,y+53)],"#a34c43")
    box(x+5,y+2,2,49,"#c59553");box(x+24,y+2,2,49,"#c59553")
    # Original heraldic sun, not an extracted franchise crest.
    ellipse(x+9,y+17,14,14,"#d4ae64")
    ellipse(x+12,y+20,8,8,"#8c4539")
    for dx,dy in [(15,10),(15,33),(5,23),(25,23)]:
        box(x+dx,y+dy,2,3,"#dfb968")
    box(x+13,y+43,6,2,"#d4ae64")

def bed(x,y,variant):
    # Rear canopy, mattress, embroidered duvet, tied curtains, carved posts.
    ellipse(x-3,y+64,85,45,"#2b2429")
    wood(x+7,y+24,63,75)
    box(x+13,y+28,51,59,"#b59670","#4a3430")
    box(x+15,y+28,47,18,"#e5cda1")
    box(x+18,y+30,41,12,"#f4deb6")
    line([(x+20,y+40),(x+56,y+40),(x+58,y+37)],"#b49b7b")
    box(x+13,y+48,51,43,"#6e2838");box(x+15,y+47,47,5,"#be6e55")
    for dx in [17,27,45,57]:
        box(x+dx,y+53,2,32,"#863747")
    for yy in [57,82]:
        box(x+16,y+yy,45,1,"#c29a59")
    for dx in range(20,60,8):
        poly([(x+dx,y+69),(x+dx+2,y+66),(x+dx+4,y+69),(x+dx+2,y+72)],"#b38851")
    wood(x+9,y+91,60,10)
    # Drapery with highlights, dark inner folds and tassels.
    for left in [True,False]:
        a=x+4 if left else x+61
        poly([(a,y+6),(a+14,y+6),(a+11,y+37),(a+5,y+53),(a+12,y+79),(a,y+84)],"#6b2739")
        line([(a+4,y+9),(a+6,y+34),(a+2,y+49),(a+5,y+78)],"#b45b53",2)
        line([(a+11,y+9),(a+9,y+35),(a+5,y+49)],"#391e30",2)
        box(a+1,y+49,9,3,"#c5a363");box(a+7,y+52,1,9,"#e4bc6b")
    wood(x,y,78,12)
    box(x+3,y+3,72,2,"#ce9b58");box(x+5,y+9,68,4,"#813542")
    for dx in range(9,72,8):
        box(x+dx,y+10,3,6,"#a8504b")
    for dx in [0,73]:
        wood(x+dx,y-3,5,108)
        box(x+dx+1,y+2,1,98,"#be9058")
        ellipse(x+dx-1,y-8,7,8,"#ae8853");box(x+dx+1,y-9,2,2,"#e3c581")
    trunk(x+17,y+112,44)
    book(x+20,y+108,13,5,["#3e5860","#776244"][variant%2])

def fireplace():
    x,y=281,70
    box(x-10,y+66,96,27,"#252228")
    # Tall stone chimney.
    for row in range(8):
        for col in range(4):
            xx=x+col*19+(9 if row%2 else 0)
            if xx+17>x+77: continue
            c=R.choice(["#70645b","#7c6e60","#675f5a"])
            box(xx,y+row*10,18,9,c)
            box(xx,y+row*10,18,1,"#958573")
    box(x+14,y+40,49,45,"#251b22")
    d.rounded_rectangle((x+12,y+31,x+65,y+86),radius=23,fill="#b49b76")
    d.rounded_rectangle((x+19,y+39,x+58,y+85),radius=17,fill="#211a22")
    box(x+19,y+59,40,25,"#211a22")
    box(x-7,y+29,92,6,"#b69971");box(x-9,y+26,96,3,"#dec092")
    box(x-7,y+85,93,5,"#b09977");box(x-12,y+90,102,6,"#726355")
    for xx in [x+22,x+43]:
        line([(xx,y+79),(xx+12,y+74)],"#896044",4)
    for i in range(8):
        xx=x+23+i*4; h=R.randrange(10,30)
        poly([(xx-3,y+78),(xx,y+78-h),(xx+5,y+76-h//2),(xx+6,y+80)],"#d66d3b")
        poly([(xx,y+78),(xx+2,y+65),(xx+4,y+79)],"#ffe0a0")
    for xx in range(x+18,x+64,8):
        box(xx,y+75,2,10,"#30242a")
    box(x+15,y+76,54,2,"#594335")
    candle(x+2,y+20);candle(x+69,y+20)
    # Small framed star chart over the hearth.
    box(x+19,y-10,41,31,"#b28b54","#2a252b");box(x+23,y-6,33,23,"#23323c")
    ellipse(x+31,y-2,15,15,None,"#b4a077")
    line([(x+25,y+11),(x+50,y-2)],"#6e8b88")
    for a,b in [(28,3),(48,10),(39,5)]:
        box(x+a,y+b,2,2,"#e4c989")

def desk(x,y):
    ellipse(x-7,y+25,99,24,"#26242a")
    for dx in [4,76]: wood(x+dx,y+16,5,24)
    wood(x,y,86,27,True)
    book(x+6,y+4,14,18,"#485954");book(x+20,y+6,11,15,"#813b40")
    # Open parchment notebook and quill.
    poly([(x+35,y+5),(x+49,y+7),(x+63,y+4),(x+66,y+19),(x+50,y+22),(x+36,y+20)],"#dfcaa0")
    line([(x+49,y+8),(x+50,y+20)],"#8c7458")
    for yy in [10,13,16]:
        line([(x+38,y+yy),(x+46,y+yy+1)],"#b29a76")
        line([(x+53,y+yy),(x+61,y+yy-1)],"#b29a76")
    box(x+70,y+12,6,6,"#25323b")
    line([(x+73,y+13),(x+80,y-1)],"#d9d2b4")
    poly([(x+75,y+10),(x+75,y+1),(x+83,y-6),(x+81,y+3)],"#e9dec0")
    candle(x+4,y+1)
    wood(x+33,y+39,27,8);wood(x+35,y+47,4,7);wood(x+53,y+47,4,7)
    box(x+35,y+28,23,14,"#713442","#af784b")

def shelves(x,y):
    box(x-3,y-3,72,71,"#281f25")
    wood(x,y,66,66)
    for yy in [y+3,y+23,y+44]:
        box(x+5,yy,56,16,"#251e25")
        xx=x+6
        while xx<x+56:
            w=R.randrange(4,9);hh=R.randrange(10,16)
            book(xx,yy+16-hh,w,hh,R.choice(["#4c6764","#81464a","#a07a4d","#696174"]))
            xx+=w+1
        box(x+3,yy+16,60,3,"#a0764c")

# Cutaway octagonal tower, silhouette first.
outer=[(84,42),(548,42),(608,93),(608,309),(559,339),(82,339),(33,306),(33,95)]
poly(outer,"#0b101b")
poly([(85,48),(546,48),(600,96),(600,303),(554,332),(86,332),(41,301),(41,98)],"#38333b")
# Upper dressed stone wall.
poly([(86,52),(546,52),(592,99),(592,152),(48,152),(48,100)],"#48444c")
for row in range(10):
    yy=54+row*10
    xmin= max(49,85-(yy-54)) if yy<90 else 49
    xmax= min(591,548+(yy-54)) if yy<100 else 591
    for xx in range(40-(14 if row%2 else 0),600,29):
        a=max(xmin,xx); b=min(xmax,xx+27)
        if b-a<2: continue
        c=R.choice(["#55515a","#5b5660","#4b4954","#605a60","#514e59"])
        box(a,yy,b-a,9,c);box(a,yy,b-a,1,"#777077")
        if R.random()<.24: line([(a+2,yy+6),(min(b-1,a+8),yy+6)],"#3e3d47")
# Floor in warm, staggered timber planks.
box(49,151,543,155,"#48372f")
for row in range(16):
    yy=151+row*10
    for xx in range(49-(24 if row%2 else 0),594,49):
        x=max(xx,49); w=min(xx+48,592)-x
        if w<1: continue
        c=R.choice(["#68503c","#70523d","#73563f","#624935","#78583e"])
        box(x,yy,w,9,c);box(x,yy,w,1,"#90704d")
        for _ in range(3):
            a=R.randrange(x,max(x+1,x+w-2))
            line([(a,yy+R.choice([3,6])),(min(x+w-1,a+R.randrange(3,14)),yy+6)],"#574232")
poly([(49,306),(592,306),(551,327),(89,327)],"#47352e")
for yy in range(309,326,6): line([(60+(yy-309),yy),(581-(yy-309),yy)],"#77573d")
# Wall trims, corner columns, shadow beneath wall.
box(48,145,544,7,"#a08c73");box(48,152,544,5,"#302d32")
for x in [52,578]:
    wood(x,149,10,155);box(x+2,151,2,149,"#927554")
for x in [65,252,377,561]:
    box(x,62,11,86,"#3a3943");box(x+2,63,6,82,"#8b8178")
    for yy in [67,94,122,144]:box(x-2,yy,15,3,"#a39682")
arch(111,61,66,78);arch(465,61,66,78)
banner(208,69);banner(403,69)
fireplace()
# Moonlight ribbons on floor.
overlay=Image.new("RGBA",im.size); od=ImageDraw.Draw(overlay)
for x in [120,474]:
    od.polygon([(x,151),(x+40,151),(x+75,242),(x+20,242)],fill=(125,163,183,20))
im=Image.alpha_composite(im.convert("RGBA"),overlay).convert("RGB");d=ImageDraw.Draw(im)
# Woven central rug, gold geometric borders.
box(247,185,149,125,"#2d242b")
box(250,187,143,120,"#8e413f")
box(253,190,137,114,"#c19a60");box(256,193,131,108,"#672d37")
box(262,199,119,96,"#a95749");box(264,201,115,92,"#70323c")
for yy in range(190,306,4):
    line([(249,yy),(246,yy+1)],"#b38b54");line([(394,yy),(397,yy+1)],"#b38b54")
for yy in range(207,292,14):
    for xx in [258,381]:
        poly([(xx,yy),(xx+3,yy+4),(xx,yy+8),(xx-3,yy+4)],"#c5a267")
for xx in range(268,379,14):
    for yy in [196,297]:box(xx,yy,6,2,"#dbb06a")
cx,cy=322,246
poly([(cx,216),(cx+34,cy),(cx,277),(cx-34,cy)],"#b17c4e")
poly([(cx,222),(cx+27,cy),(cx,270),(cx-27,cy)],"#622c38")
ellipse(cx-13,cy-13,27,27,"#bd9559")
ellipse(cx-10,cy-10,21,21,"#7f3b3d")
for i in range(8):
    a=i*math.pi/4
    line([(cx+int(math.cos(a)*15),cy+int(math.sin(a)*15)),(cx+int(math.cos(a)*20),cy+int(math.sin(a)*20))],"#e2b972")
# Beds leave generous central and front circulation.
for i,x in enumerate([76,164,401,489]):bed(x,158,i)
desk(84,276)
shelves(484,265)
# Apothecary bottles on bookshelf top.
for x,c in [(489,"#589e90"),(505,"#9b77a5"),(529,"#c39051")]:
    ellipse(x,258,8,7,c);box(x+2,253,4,7,c);box(x+2,252,4,2,"#b59e70")
    box(x+2,258,2,3,"#c0c9ae")
# Owl on a brass perch and its cage.
ellipse(204,297,28,8,"#24222a")
box(216,271,3,27,"#a4814c");box(207,294,22,3,"#bfa26a")
ellipse(207,262,22,22,"#94836b");ellipse(210,258,16,17,"#c3b698")
ellipse(211,262,6,7,"#ede0b9");ellipse(219,262,6,7,"#ede0b9")
box(213,264,2,3,"#242936");box(220,264,2,3,"#242936")
poly([(217,267),(220,267),(218,270)],"#b88448")
for yy in [276,280]:line([(212,yy),(222,yy)],"#67584e")
# Exit threshold with brass floor inlay.
poly([(291,323),(349,323),(357,337),(283,337)],"#211d28")
box(292,323,56,3,"#aa895d")
for yy in [329,334]:line([(287,yy),(353,yy)],"#856343")
poly([(317,327),(323,327),(323,330),(327,330),(320,335),(313,330),(317,330)],"#e0b97a")
# Warm light pools, low opacity, pixel-based compositing.
glow=Image.new("RGBA",im.size); gd=ImageDraw.Draw(glow)
for cx,cy,r in [(320,159,93),(87,280,40),(285,88,27),(351,88,27)]:
    for rr in range(r,2,-4):
        gd.ellipse((cx-rr,cy-rr*.55,cx+rr,cy+rr*.55),fill=(255,158,65,int(3+(1-rr/r)*17)))
im=Image.alpha_composite(im.convert("RGBA"),glow).convert("RGB")
# Fine deterministic pixel grain and edge vignette.
pix=im.load()
for y in range(360):
    for x in range(640):
        r,g,b=pix[x,y]
        dist=((x-320)/350)**2+((y-185)/250)**2
        factor=1-max(0,dist-.35)*.17
        n=R.choice([-2,-1,0,0,0,1,2])
        pix[x,y]=tuple(max(0,min(255,int(v*factor)+n)) for v in (r,g,b))
# Upscale once with hard edges, then paint a second detail pass at 1280x720.
# This creates one-pixel stitching and material marks that the earlier 640px pass
# could not represent, while preserving the deliberately pixel-built silhouettes.
im = im.resize((1280, 720), Image.Resampling.NEAREST)
d = ImageDraw.Draw(im)
R = random.Random(113)

# Fine stone pitting and hairline cracks on the tower wall.
for _ in range(245):
    x = R.randrange(95, 1185); y = R.randrange(105, 303)
    if 535 < x < 745 and 105 < y < 302:
        continue
    shade = R.choice(["#302f38", "#777078", "#45434d"])
    length = R.randrange(2, 10)
    d.line((x, y, x + length, y + R.choice([-1, 0, 0, 1])), fill=shade)
    if R.random() < .16:
        d.line((x + length, y, x + length + R.randrange(2, 5), y + R.randrange(2, 7)), fill=shade)

# Wood grain knots, nail heads and scratches.
for _ in range(210):
    x = R.randrange(100, 1175); y = R.randrange(310, 652)
    if 485 < x < 795 and 360 < y < 625:
        continue
    c = R.choice(["#322724", "#9b7049", "#50372d"])
    d.line((x, y, min(1175, x + R.randrange(3, 20)), y + R.choice([-1, 0, 1])), fill=c)
for x in range(116, 1170, 98):
    for y in range(318, 625, 20):
        d.rectangle((x, y, x + 2, y + 2), fill="#2a2424")
        d.point((x, y), fill="#aa8256")

# Curtain weave, embroidered dots and blanket fringe.
for bx in [152, 328, 802, 978]:
    for y in range(330, 495, 6):
        d.line((bx + 10, y, bx + 145, y), fill="#7c2d3d")
    for x in range(bx + 17, bx + 143, 12):
        d.point((x, 415), fill="#f0c477")
        d.point((x + 2, 417), fill="#ad754b")
    for x in range(bx + 31, bx + 130, 8):
        d.line((x, 505, x - 2, 514), fill="#bd8252")

# Rug cross-stitch and slight wear; drawn sparingly so the crest stays readable.
for y in range(404, 594, 7):
    for x in range(534 + ((y // 7) % 2) * 4, 758, 8):
        if ((x + y) // 7) % 5:
            d.point((x, y), fill="#8d4545")
        else:
            d.point((x, y), fill="#d1a467")
for _ in range(55):
    x = R.randrange(530, 765); y = R.randrange(402, 598)
    d.line((x, y, x + R.randrange(2, 8), y), fill="#5e3039")

# Readable-looking ink marks on parchment, brass glints and colored bottle shine.
for y, width in [(574, 29), (579, 34), (584, 21), (589, 30)]:
    d.line((465, y, 465 + width, y), fill="#8c7157")
for x, y in [(310,270),(406,528),(810,526),(1000,520),(1080,520),(579,193),(702,193)]:
    d.rectangle((x, y, x + 2, y + 2), fill="#f7d990")
for x, y in [(982,516),(1014,516),(1062,516)]:
    d.line((x + 2, y, x + 2, y + 10), fill="#d7eee1")

# Dust specks caught by moon and fire light.
for _ in range(70):
    x = R.randrange(170, 1110); y = R.randrange(190, 575)
    if R.random() < .6 and not (500 < x < 790 and 360 < y < 610):
        d.point((x, y), fill=R.choice(["#b9ac91", "#777b82", "#c6a777"]))

OUT.mkdir(parents=True,exist_ok=True)
im.save(OUT/"tower_dormitory.png", optimize=True)
print(OUT/"tower_dormitory.png")
