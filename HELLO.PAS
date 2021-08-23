uses graph,crt;
var
  grd,grm:integer;
  c:char;
  var p:pointer;
  s:string;

procedure Goth; external;
{$L GOTH.OBJ}
procedure Trip; external;
{$L TRIP.OBJ}
procedure EGADriver; external;
{$L EGAVGA.OBJ}

begin
  if registerbgidriver(@EGAdriver)<0 then halt(1);
  if registerbgifont(@Goth)<0 then halt(1);
  if registerbgifont(@Trip)<0 then halt(1);
  grd:=Detect;
  initgraph(grd,grm,'');
  setgraphmode(1);
  { creating a picture ... }
  settextstyle(triplexfont,horizdir,0);
  setcolor(9);
  s:='V.Tishin''s';
  outtextxy((getmaxx-textwidth(s))div 2,50,s);
  settextstyle(gothicfont,horizdir,7);
  setusercharsize(26,10,4,1);
  setcolor(11);
  s:='Boolean functions';
  outtextxy((getmaxx-textwidth(s))div 2+15,(getmaxy-textheight('o'))div 2-30,s);
  settextstyle(defaultfont,horizdir,1);
  setcolor(13);
  outtextxy(10,getmaxy-3*textheight('C')-39,
            'Worked out by Tishin V.V.');
  outtextxy(10,getmaxy-2*textheight('C')-33,
	    'Programmed by Tishin E.,Poberyoskin E., Samara University');
  settextstyle(triplexfont,horizdir,2);
  setusercharsize(4,5,4,5);
  setcolor(white);
  outtextxy(10,getmaxy-textheight('C')-17,
            '(C) 1991 by Tishin V.');
  repeat until keypressed;
  while keypressed do c:=readkey;
  closegraph;
end.
