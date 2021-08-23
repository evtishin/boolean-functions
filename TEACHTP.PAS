program TeachTp;
uses TpCrt,TpWindow,Strings,WndInit,FilesTp,ScrTp,ServTp,HelpTp,Graph;
var
  s:string;
  c:command;
  y,x,n,m:byte;
  t:word;
  count:byte; {Current chapter}

procedure Goth; external;
{$L GOTH.OBJ}

procedure Trip; external;
{$L TRIP.OBJ}

procedure CGAdriver; external;
{$L CGA.OBJ}

procedure EGADriver; external;
{$L EGAVGA.OBJ}

procedure Hello(Endwork:boolean);
var
  grd,grm:integer;
  c:char;
  var p:pointer;

procedure DrawPicture;
begin
  { creating a picture ... }
  settextstyle(gothicfont,horizdir,7);
  setusercharsize(23,10,2,1);
  s:='Boolean functions';
  outtextxy((getmaxx-textwidth(s))div 2,(getmaxy-textheight(s))div 2-20,s);
  settextstyle(defaultfont,horizdir,1);
  outtextxy(10,getmaxy-3*textheight('C')-22,
            'Worked out by Tishin E.');
  outtextxy(10,getmaxy-2*textheight('C')-17,
	    'Programmed by Tishin E.,Poberyoskin E., Samara University');
  settextstyle(triplexfont,horizdir,2);
  setusercharsize(9,10,1,2);
  outtextxy(10,getmaxy-textheight('C')-10,
            '(C) 1995 by Tishin Eugene');
end;

begin
  if Endwork then
    detectgraph(grd,grm)
  else begin
    if registerbgidriver(@CGAdriver)<0 then halt(1);
    if registerbgidriver(@EGAdriver)<0 then halt(1);
    if registerbgifont(@Goth)<0 then halt(1);
    if registerbgifont(@Trip)<0 then halt(1);
    grd:=Detect;
    initgraph(grd,grm,'')
  end;
  if grd=CGA then begin
    grm:=CGAHi;
    end
  else begin
    grm:=EGALo;
  end;
  setgraphmode(grm);
  DrawPicture;
  if Endwork then begin
    repeat until keypressed;
    while keypressed do c:=readkey;
    closegraph;
    halt
  end
end;

procedure Chapter(var changed:boolean);
  var
    oldi,i:byte;
    k:Keyboard;
    found:boolean;
begin
  textattr:=HelpAttr;
  WriteMenu(menu[ChChmode]);
  if not DisplayWindow(ChapWnd) then halt(1);
  hiddencursor;
  changed:=false;
  if Chaps>0 then begin
    writeln;
    for i:=1 to Chaps do
      writeln(i:2,'.',Contents^[i].s);
    oldi:=1;if Count>0 then i:=Count else i:=1;
    repeat
      gotoxy(1,oldi+1);
      write(oldi:2,'.',Contents^[oldi].s);
      clreol;writeln;
      textattr:=HelpInv;
      gotoxy(1,i+1);
      write(i:2,'.',Contents^[i].s);
      clreol;writeln;
      textattr:=HelpAttr;
      oldi:=i;
      repeat k:=GetKey; until (k in [Enter..F1]) or (k=Esc);
      case k of
        Up..Right : begin
          i:=i+add[k].c+add[k].l;
          if i=0 then i:=Chaps;
          if i>Chaps then i:=1;
          end;
        Homekey,PgUp : i:=1;
        Endkey,PgDn : i:=Chaps;
        Enter : begin
          location:=Contents^[i].loc;
          Count:=i-1;
          changed:=true;
          end;
        F1 : begin
          oldi:=i;
          TchHlp(8,true);
          WriteMenu(menu[ChChmode]);
          i:=oldi;
          end;
      end;
    until (k=Esc) or (k=Enter);
  end
  else begin writeln;writeln('В тексте нет глав'); end;
  ChapWnd:=EraseTopWindow;
  textattr:=NormText
end;

procedure Wait;
  var
    key:Keyboard;
    changed:boolean;
begin
  repeat
    key:=Getkey;
    case key of
      F1:
        begin
          TchHlp(3,true);
          WriteMenuBar;
        end;
      F2 :
        begin
          Chapter(changed);
          if changed then clrscr;
          WriteMenuBar;
        end;
      F3 : Result;
      F4 :
        begin
          TchHlp(0,false);
          WriteMenuBar;
        end;
      Esc:
	begin
	  WriteMenu('\Вы хотите закончить(д/н)?');
	  repeat key:=Getkey until (key=Yes) or (key=No);
	  if key=Yes then Hello(true)
                     else WriteMenuBar;
	end
    end;
  until (key=Enter) or ((key=F2) and changed);
end;

begin
  Hello(false);
  Loadfile;
  count:=0;
  SetVisiblePage(0);textattr:=Normtext;
  clrscr;hiddencursor;
  window(1,1,80,24);
  CurrentMode:=MainMode;
  WriteMenuBar;
  repeat
    Readline(s);
    if s[1]='#' then begin
      c:=Com(s);
      case c of
	Cwait : Wait;
	Chap  : begin clrscr;Inc(Count)  end;
	Cdelay : begin t:=GetInt(s);delay(t); end;
	Cls    : begin Wait;clrscr end;
	Cexer  : begin
                  n:=GetInt(s);
                  m:=GetInt(s);
                  Exercise(n,m);
                end;
      end;
      end
    else begin
      Writeline(s);
    end;
  until (c=Cend);
  Hello(true);
end.


