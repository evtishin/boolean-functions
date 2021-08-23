{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 16384,0,655360}
unit Screen;
interface
  uses Crt,Strings;
  type
    str=^string;
    Wind=record
      y1,x1,y2,x2,ysize:byte;
      first,pos:byte;{pos - current line}
      scr:array[1..24] of str;
    end;
    Keyboard=(Space,Enter,Homekey,PgUp,
              Endkey,PgDn,Up,Down,Left,Right,
              F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,
	      Esc,Yes,No,Another);
  var
    MainWnd,ExerWnd,Current:Wind;
    color,highcolor:byte;
    CurrentMode:Workmode;

  procedure NormalMode;
 {procedure HighMode;}
 {procedure Inverse;}
  procedure ClrBuf(var w:Wind);
  procedure ClrScreen;
  procedure NewWnd(x1,y1,x2,y2:byte;var w:Wind);
  procedure WriteWnd;
  procedure ActivateWnd(var w:Wind);
  procedure WriteBuf(var s:string);
  procedure WriteLine(var s:string);
  procedure Change(y,x:byte;var s:string);
  function  GetKey:Keyboard;
  procedure WriteMenu(s:string);
  procedure WriteMenuBar;

implementation
  procedure NormalMode;
  begin
    lowvideo;
    textcolor(color);
    textbackground(black);
  end;

  procedure HighMode;
  begin
    highvideo;
    textcolor(highcolor);
    textbackground(black);
  end;

  procedure Inverse;
  begin
    lowvideo;
    textcolor(black);
    textbackground(color);
  end;

  procedure ClrBuf(var w:Wind);
    var i:byte;
  begin
    with w do begin
      for i:=1 to ysize do
	scr[i]^:='';
      pos:=1;first:=1;
    end;
  end;

  procedure ClrScreen;
  begin
    ClrBuf(Current);
    clrscr;
    WriteMenuBar;
    Current.pos:=1;
    gotoxy(1,1)
  end;

  procedure NewWnd(x1,y1,x2,y2:byte;var w:Wind);
    var i:byte;
  begin
    w.x1:=x1;w.y1:=y1;
    w.x2:=x2;w.y2:=y2;
    w.pos:=1;w.first:=1;
    w.ysize:=y2-y1+1;
    for i:=1 to w.ysize do begin
      new(w.scr[i]);
      w.scr[i]^:='';
    end;
  end;

  procedure WriteLine(var s:string);
    var l,x,  i,len:byte;
	ch:char;
  begin
    with Current do begin
      len:=length(s);x:=1;i:=1;
      WHILE (i<=len) and (x<x2-x1+1) do BEGIN
	Case s[i] of
          '\':begin
		Inc(i);
		case s[i] of
                  '\':begin
                        write('\');
                        Inc(x);
                      end;
		  ' ':TextAttr:=7;
		  'h':HighMode;
		  'i':Inverse;          {inversed text}
                  'b':Inc(TextAttr,$80);{blinking}
		end;
		Inc(i);
	      end;
	Else
	  begin
	    write(s[i]);
	    Inc(x);Inc(i);
	  end;
        End;{of Case}
      END;{of WHILE ... BEGIN}
      NormalMode;
      clreol;
      writeln;
    end;{of with}
  end;

  procedure WriteWnd;
    var l,y:byte;
  begin
    NormalMode;
    with Current do begin
      window(x1,y1,x2,y2);
      l:=(first-1)mod ysize+1;
      gotoxy(1,1);
      for y:=1 to ysize-1 do begin
	writeline(scr[l]^);
	l:=l mod ysize+1;
      end;
      gotoxy(1,pos);
    end;
  end;

  procedure ActivateWnd(var w:Wind);
    var i:byte;
  begin
    with w do
      window(x1,y1,x2,y2);
    Current:=w;
    WriteWnd;
  end;

  procedure WriteBuf(var s:string);
  begin
    with Current do begin
      scr[(pos+first-2)mod ysize+1]^:=s;
      if pos=y2 then first:=first mod ysize+1
		else inc(pos);
    end;
  end;

  procedure Change(y,x:byte;var s:string);
    var l:byte;st:string;
  begin
    with Current do begin
      y:=pos-y;
      l:=(y+first-2) mod ysize+1;
      st:=scr[l]^;
      if x>=length(st) then x:=length(st)-1;
      if x=0 then x:=1;
      delete(st,x,length(s));insert(s,st,x);
      gotoxy(1,y);writeline(st);
      scr[l]^:=st;
    end;
  end;

  function Getkey:Keyboard;
    var
      ch:char;c:byte;
      wminold,wmaxold:word;
      xold,yold:byte;
  begin
    wminold:=windmin;wmaxold:=windmax;
    xold:=wherex;yold:=wherey;
    window(1,25,2,25);
    gotoxy(1,1);
    ch:=readkey;
    if ch=#0 then begin
      c:=ord(readkey);
      case c of
	59..68:Getkey:=Keyboard(ord(F1)+c-59);
	71:Getkey:=Homekey;
	73:Getkey:=PgUp;
	79:Getkey:=Endkey;
	81:Getkey:=PgDn;
	72:Getkey:=Up;
	80:Getkey:=Down;
	75:Getkey:=Left;
	77:Getkey:=Right;
      else Getkey:=Another;
      end;
      end
    else
      case ch of
	'y','d','¤':Getkey:=Yes;
	'n','­':Getkey:=No;
	#32:Getkey:=Space;
	#13:Getkey:=Enter;
	#27:Getkey:=Esc;
      else Getkey:=Another;
      end;
    window(lo(wminold)+1,hi(wminold)+1,lo(wmaxold)+1,hi(wmaxold)+1);
    gotoxy(xold,yold);
  end;

  procedure WriteMenu(s:string);
    var
      i,len,color:byte;
  begin
    window(1,25,80,25);
    HighMode;
    color:=white;textcolor(color);
    len:=length(s);i:=1;
    while i<=len do begin
      if s[i]='\' then begin
        if color=magenta then begin
                        color:=white;highvideo;
                      end
		      else begin
                        color:=magenta;lowvideo;
                      end;
        Inc(i);
      end;
      write(s[i]);
      Inc(i);
    end;
    NormalMode;
    clreol;
    with Current do begin
      window(x1,y1,x2,y2);
      gotoxy(1,pos);
    end;
  end;

  procedure WriteMenuBar;
  begin
    WriteMenu(menu[CurrentMode]);
  end;


var k:Keyboard;
begin
  color:=lightgray;
  highcolor:=white;
  NewWnd(1,1,80,24,MainWnd);
  NewWnd(1,1,80,24,ExerWnd);
  clrscr;
  Current:=MainWnd;
end.