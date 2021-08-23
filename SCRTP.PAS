{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 16384,0,655360}
unit ScrTp;
interface
  uses TpCrt,Strings,WndInit;
  type
    str=^string;
    Keyboard=(Space,Enter,Homekey,PgUp,
              Endkey,PgDn,Up,Down,Left,Right,
              F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,
	      Esc,Yes,No,Another);
  var
    CurrentMode:Workmode;

  procedure WriteLine(var s:string);
  function  GetKey:Keyboard;
  procedure WriteMenu(s:string);
  procedure WriteMenuBar;

implementation

  procedure WriteLine(var s:string);
    var l,x,  i,len:byte;
	ch:char;
  begin
    len:=length(s);x:=1;i:=1;
    WHILE (i<=len) and (x<80) do BEGIN
      If s[i]='\' then begin
        Inc(i);
	case s[i] of
          '\':begin
                write('\');
                Inc(x);
              end;
	  ' ':textattr:=Normtext;
	  'h':textattr:=Hightext;
	  'i':textattr:=Invtext;          {inversed text}
          'b':Inc(TextAttr,$80);{blinking}
	end;
	Inc(i);
      end
      Else begin
        write(s[i]);
	Inc(x);Inc(i);
      end;
    END;{of WHILE ... BEGIN}
    textattr:=Normtext;
    clreol;
    writeln;
  end; { Procedure WriteLine }

  function Getkey:Keyboard;
    var
      ch:char;c:byte;
  begin
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
  end;

  procedure WriteMenu(s:string);
    var
      i,len,color:byte;
      wminold,wmaxold:word;
      xold,yold,oldattr:byte;
  begin
    wminold:=windmin;wmaxold:=windmax;
    xold:=wherex;yold:=wherey;
    window(1,25,80,25);
    oldattr:=textattr;
    textattr:=MenuHigh;
    len:=length(s);i:=1;
    while i<=len do begin
      if s[i]='\' then begin
        if textattr=MenuHigh then textattr:=MenuNorm
		             else textattr:=MenuHigh;
        Inc(i);
      end;
      write(s[i]);
      Inc(i);
    end;
    clreol;
    textattr:=oldattr;
    window(lo(wminold)+1,hi(wminold)+1,lo(wmaxold)+1,hi(wmaxold)+1);
    gotoxy(xold,yold);
  end;

  procedure WriteMenuBar;
  begin
    WriteMenu(menu[CurrentMode]);
  end;

end.