{$A-,B-,D-,F-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 65520,0,655360}
unit ServTp;
interface
  uses TpCrt,TpWindow,Strings,WndInit,ScrTp,FilesTp,HelpTp;
  type
    ExerRec=record
      lpi,items,cols:byte;{lpi-lines per item;cols-columns per line}
      curl,curc:byte;{current line and column}
      marked:set of byte;
      col:array[1..8] of byte;{columns beginnings}
      buf:array[1..255] of str;{str=^string}
      end;
  const
    add:array[Up..Right] of record l,c : shortint; end =
         ((l:-1;c:0) , (l:1;c:0) , (l:0;c:-1) , (l:0;c:1));
  type statistics=record  all,ans,rgh:word  end;
  var stat:record     { STATistics : ALL - the number of ALL exercises      }
        exe,que : statistics    {    ANS - the number of ANSwered exercises }
        end;                    {    RGH - the number of RiGHt answers      }

 {procedure Locate(var ex:ExerRec;l,c:byte);}
 {procedure WriteItem(var ex:ExerRec;l,c:byte);}
 {procedure Move(var ex:ExerRec;l,c:byte);}
 {procedure ReleaseEx(var ex:ExerRec);}
 {procedure Exer(var ex:ExerRec;var errexit:boolean;
                 mode:byte);}
  procedure Result;
  procedure Exercise(vars,mode:byte);
        {vars - the number of variants}
        {mode=0 - one answer of many proposed}
        {mode>0 - several answers}

implementation
  var
    LastLine:byte;

  procedure Locate(var ex:ExerRec;l,c:byte);
    var col,ln:byte;
  begin
    if c>1 then col:=ex.col[c-1]+2
           else col:=1;
    ln:=LastLine+l;
    gotoxy(col,ln);
  end;

  procedure WriteItem(var ex:ExerRec;l,c:byte);
    var
      st:string;
      fstch{first char},len{gth},it,i:byte;
      li,line:byte;{li-line in item,if it has more than one}
  begin
    it:=l*ex.cols+c-ex.cols;
    if  it in ex.marked then
        textattr:=ExMarked
      else
        textattr:=ExNorm;{brown}
    for li:=1 to ex.lpi do begin
      if (li=ex.lpi) and (l=ex.curl) and (c=ex.curc) then
        if  it in ex.marked then
	  textattr:=ExMarkedCur
        else
          textattr:=ExCur;{brown}
      line:=l*ex.lpi-ex.lpi+li;
      locate(ex,line,c);
      if c>1 then fstch:=ex.col[c-1]+2
	     else fstch:=1;
      len:=ex.col[c]-fstch+1;
      st:=copy(ex.buf[line]^,fstch,len);
      for i:=1 to length(st) do write(st[i]);
    end;
  end;

  procedure Move(var ex:ExerRec;l,c:byte);
    var oldl,oldc:byte;
  begin
    oldl:=ex.curl;oldc:=ex.curc;
    ex.curl:=l;ex.curc:=c;
    WriteItem(ex,oldl,oldc);
    WriteItem(ex,l,c);
  end;

  procedure WriteExer(var ex:ExerRec);
    var i,l,c:byte;
  begin
    with ex do begin
      l:=1;c:=1;
      for i:=1 to items do begin
        WriteItem(ex,l,c);
        Inc(c);if c>cols then begin c:=1;Inc(l);writeln; end;
      end;
      if c>1 then writeln;
    end;
  end;

  procedure Exer(var ex:ExerRec;var errexit:boolean;
                 mode:byte);
    var
      i,l,c,oldl,oldc,it,lines:byte;
      key:Keyboard;
  begin
    with ex do begin
      curl:=1;curc:=1;marked:=[];
      lines:=(items-1)div cols+1;
      WriteExer(ex);
      repeat
        key:=Getkey;
        case key of
          Space :
            begin
              it:=curl*cols+curc-cols;
	      if mode=1 then
                if it in marked
                  then marked:=marked-[it]
		  else marked:=marked+[it];
              WriteItem(ex,curl,curc);
            end;
          Homekey,PgUp : Move(ex,1,1);
          Endkey,PgDn : Move(ex,lines,(items-1) mod cols+1);
          Up..Right :
            begin
              l:=curl+add[key].l;
              c:=curc+add[key].c;
              if c>cols then begin c:=1;Inc(l); end;
              if c=0 then begin c:=cols;Dec(l); end;
              if l>lines then begin l:=1;
                           if (add[key].c=0) and (cols>1) then
                             c:=c mod cols+1;
                         end;
              if l=0     then begin l:=lines;
                           if (add[key].c=0) and (cols>1) then
                             c:=(c+cols-2)mod cols+1;
                         end;
              Move(ex,l,c);
            end;
          F1 : begin
            if mode=1 then TchHlp(6,true)
                      else TchHlp(5,true);
            WriteMenuBar;
            end;
          F3 : begin
            SetVisiblePage(0);
	    WriteMenu('Нажмите любую клавишу');
	    key:=GetKey;key:=Another;
            SetVisiblePage(1);
            end;
          F4 : begin
            TchHlp(0,false);
            WriteMenuBar;
            end;
          Enter :
            begin
              WriteMenu('\Вы уверены?(д/н)');
	      repeat  key:=Getkey; until (key=Yes) or (key=No)
                                          or (key=Enter);
              if key=No then WriteMenuBar
                        else errexit:=false;
            end;
          Esc :
            begin
              WriteMenu('\Прервать?(д/н)');
              repeat  key:=Getkey; until (key=Yes) or (key=No)
                                          or (key=Enter);
              if key=No then WriteMenuBar
                        else errexit:=true;
            end;
        else key:=Another;
        end;
      until (key=Yes) or (key=Enter);
      if mode<>1 then marked:=[curl*cols+curc-cols];
    end;
  end;

  procedure ReadData(var ex:ExerRec;var right:byteset;
                     var form,rgh,ans:boolean);
    var
      s:string;
      c:Command;
      i:byte;
      cont:boolean;
  begin
    cont:=true;
    while cont do begin
      readline(s);
      IF s[1]='#' THEN BEGIN
        c:=Com(s);
        case c of
          Cright : begin
            GetSet(s,right);
            rgh:=true;
            end;
          Cformat : with ex do begin
            form:=true;
            items:=GetInt(s);
            lpi:=GetInt(s);
            col[1]:=GetInt(s);
            cols:=1;
            repeat
              Inc(cols);
              col[cols]:=GetInt(s);
            until (col[cols] < col[cols-1]+2) or (cols=8);
            if col[cols] < col[cols-1]+2 then Dec(cols);
            if col[1]>0 then form:=true;
            end;
          Cans : if form then begin
            i:=1;
            repeat
              readline(s);
              if s[1]<>'#' then begin
                new(ex.buf[i]);
                ex.buf[i]^:=s;
              end;
              Inc(i);
            until s[1]='#';
            while i < (ex.items-1) div ex.cols+1 do begin
              new(ex.buf[i]);
              ex.buf[i]^:='';
              Inc(i);
            end;
            ans:=true;
	  end;
	  NoCom:cont:=false;
        end; {of case}
      END { of IF ... THEN BEGIN }
      ELSE BEGIN
        WriteLine(s);
        Inc(LastLine)
      END;
    end;
  end;

  procedure ReleaseEx(var ex:ExerRec);
    var
      i,lines:byte;
  begin
    with ex do begin
      lines:=((items-1) div cols+1)*lpi;
      for i:=1 to lines do dispose(buf[i])
    end
  end;

  procedure Exercise(vars,mode:byte);
    label Start;
    var
      exbegin:longint;
      v{ariant}:byte;
      FirstTime,form,rght,ans,found,err:boolean;
      k:Keyboard;
      rightans:ByteSet;
      ex:ExerRec;
      st:statistics;
  begin
    exbegin:=location;
    LastLine:=0;
    FirstTime:=true;
    if mode>1 then mode:=0;
    if mode=1 then CurrentMode:=Exermode2
	      else CurrentMode:=Exermode1;
    if vars=1 then st:=stat.que  else st:=stat.exe;
    SetVisiblePage(1);
    textattr:=Normtext;
    hiddencursor;
    window(1,1,80,24);
  Start:
    clrscr;
    WriteMenuBar;
    if vars>1 then v:=random(vars)+1
	      else v:=1;
    form:=false;rght:=false;ans:=false;
    ReadData(ex,rightans,form,rght,ans);
    if vars>1 then begin
      found:=true;
      if v>1 then
        Find(NoCom,v,Cend,found);
      if found then ReadData(ex,rightans,form,rght,ans);
    end;
    if form and rght and ans then begin
      if FirstTime then Inc(st.all);
      Exer(ex,err,mode);
      if not err then begin
        if FirstTime then
          Inc(st.ans);
        if ex.marked=rightans then begin
          WriteMenu('\Правильно.Нажмите любую клавишу.');
          Inc(st.rgh);
          FirstTime:=true;
          k:=GetKey
          end
        else begin
          WriteMenu('Неправильно.');
          ex.marked:=rightans;
          ex.curl:=0;ex.curc:=0;
          WriteExer(ex);
          delay(1000);
          if FirstTime and (vars>2) then begin
            WriteMenu('\Это правильный ответ.'+
                    'Хотите попробовать еще раз(д/н)?');
            repeat k:=GetKey until (k=Yes) or (k=No);
            if k=Yes then begin
              FirstTime:=false;
              location:=exbegin;
            end;
            end
          else begin
            WriteMenu('\Это правильный ответ.Нажмите лыбую клавишу');
            k:=GetKey;FirstTime:=true
          end
        end
      end;
      ReleaseEx(ex);
      if not FirstTime then goto Start
    end;
    if vars=1 then stat.que:=st  else stat.exe:=st;
    Find(Cend,0,Cend,found);
    CurrentMode:=Mainmode;
    clrscr;
    SetVisiblePage(0);textattr:=Normtext;
    WriteMenuBar;
  end;

  function Flex(n:byte;fl:ShortStr):ShortStr;
    var
      digit:byte;
  begin
    digit:= n - (n div 10)*10;
    if fl='' then
      case digit of
        1 : flex:='';
        2..4 : flex:='а';
        0,5..9 : flex:='ов'
      end
    else if fl='ие' then
      case digit of
        1 : flex:='ие';
        2..4 : flex:='ия';
        0,5..9 : flex:='ий'
      end
  end;

  procedure Result;
    var k:keyboard;
  begin
    if not DisplayWindow(ResWnd) then halt(1);
    with stat do begin
      writeln('  Вам были предложены ',exe.all,' упражнен',
                 Flex(exe.all,'ие'));
      writeln('                    и ',que.all,' вопрос',
                 Flex(que.all,''),'.');
      writeln('  Вы ответили правильно на ',exe.rgh,' упражнен',
                 Flex(exe.rgh,'ие'));
      writeln('                         и ',que.rgh,' вопрос',
		 Flex(que.rgh,''),'.')
    end;
    WriteMenu('Нажмите любую клавишу');
    k:=GetKey;k:=Another;
    ResWnd:=EraseTopWindow;
    WriteMenuBar;
  end;

begin
  Randomize;  {initializing the random generator}
  stat.exe.all:=0;stat.exe.ans:=0;stat.exe.rgh:=0;
  stat.que.all:=0;stat.que.ans:=0;stat.que.rgh:=0;
end.