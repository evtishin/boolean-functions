program Transfor(input,output);
uses TpCrt,ScrTp,{Screen,}HelpTp;

var
  f:text;
  lr:file of Room;
  rm:room;
  first:boolean;
  ns:word;
  nsg,t:byte;
  cl:byte;
  ch:byte;
  s,ifn,ofn:string;
  Tabl:array[byte] of ShortStr;
  k:Keyboard;

procedure ReadLine(var f:text;var s:string);
  var
    st,tab:string;
    i,l:byte;
begin
  tab:='    '+'    ';
  readln(f,st);
  s:='';
  for i:=1 to length(st) do
    if st[i]=^I then s:=s+tab
                else s:=s+st[i];
  l:=length(s);
  while s[l]=' ' do begin
    delete(s,l,1);
    Dec(l);
  end;
  if s[l]='$' then delete(s,l,1);
end;

procedure ClrRm(var rm:Room);
  var i:byte;
  begin
    for i:=1 to 17 do rm.w[i]:=''
  end;

function Findl(s:ShortStr):byte;
  var t:byte;
  begin
    t:=0;
    while (Tabl[t]<>s) and (t<255) do Inc(t);
    if t=255 then begin
      Write(' Label ',s,' hasn''t found');Halt(1) end;
    Findl:=t
  end;

begin
  writeln;
  writeln('Transformator of .TXT files to .GlS and .HLP files.');
  writeln('(C) 1995 by PA CAMAPCKOE, v 4.0');
  writeln('Press Esc to quit');
  k:=GetKey;if k=Esc then halt;
  Write('Type input file name:  ');Readln(ifn);
  Write('Type output file name:  ');Readln(ofn);
  Assign(f,ifn);Assign(lr,ofn);
  Reset(f);Rewrite(lr);ns:=0;t:=0;
  repeat
    Readline(f,s);
    if s[1]='#' then begin
      Tabl[t]:=copy(s,2,3);Inc(t)
    end;
  until eof(f);reset(f);
  repeat
    Readline(f,s);
    if s[1]='#' then begin
      if ns>0 then begin
	rm.c:=cl-1;Write(lr,rm)
	end;
      ClrRm(rm);
      rm.n:=Findl(Copy(s,2,3));ns:=ns+1;nsg:=0;cl:=1;
      Writeln(' Structure number',ns:3,' Name : ',Copy(s,2,3):4)
      end
    else begin
      nsg:=nsg+1;ch:=1;first:=false;
      while ch<=length(s) do begin
	if s[ch]='\' then begin
	  first:=not first;
	  if first then begin
	    rm.r[cl].l:=nsg;rm.r[cl].b:=ch;
	    rm.r[cl].n:=Findl(Copy(s,ch+1,3));delete(s,ch,5)
	    end
	  else begin
	    rm.r[cl].s:=ch-rm.r[cl].b;cl:=cl+1;delete(s,ch,1)
	    end
	end;
      ch:=ch+1
      end;
    if length(s)<50 then rm.w[nsg]:=s
		    else begin write('Too long string');halt(1) end
    end
  until eof(f);
  Close(lr)
  end.
