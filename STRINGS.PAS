{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 16384,0,655360}
unit Strings;
interface
  const
    zero=ord('0');
    alpha=['a'..'z'];
    digit=['0'..'9'];

  type  Command=(NoCom,Chap,Cend,Cexer,
		 Cchange,Cls,Cwait,Cdelay,
                 Cright,Cvariant,Cformat,
                 Cans,Cunknown);
        ByteSet=set of byte;
        Workmode=(mainmode,exermode1,exermode2,
                  helpmode,glsmode,chchmode);

  procedure CutSpaces(var s:string);
  function GetWord(var s:string):string;
  function GetInt(var s:string):word;
  procedure GetSet(var s:string;var bs:byteset);
  function Com(var s:string):Command;
  procedure Error;

  const
    Comname : array[NoCom..Cunknown] of string[16] =
     ('','chap','end','exe','change','cls','wait',
      'delay','right','variants','format','ans','');
    menu : array[Workmode] of string =
     ('F1\-Help\  F2\-выбрать раздел\  F3\-результат\  F4\-словарь\  '+
            #17'─┘\-продолжать\  Esc\-выход',
      'F1\-Help\  F3\-текст\  F4\-словарь\  '+
            #17'─┘\-закончить\  Esc\-прервать',
      'F1\-Help\  F3\-текст\  F4\-словарь\  Пробел\-отметить\  '+
            #17'─┘\-закончить\  Esc\-прервать',
      'F1\-оглавление\  '#24#25#27#26'\-выбрать\  '+
            #17'─┘\-войти\  F2\-последний экран\  Esc\-выход',
      'F1\-Help\  F4\-оглавление\  '#24#25#27#26'\-выбрать\  '+
            #17'─┘\-войти\  F2\-последний экран\  Esc\-выход',
      'F1\-Help\  '#24#25'\-выбрать\  '#17'─┘\-войти  \Esc\-прервать');

implementation
  procedure CutSpaces(var s:string);
    var
      i,l:byte;
  begin
    l:=length(s);i:=0;
    while (i<l) and (s[i+1]=' ') do Inc(i);
    delete(s,1,i);
  end;

  function GetWord(var s:string):string;
    var
      i,l:byte;
      w:string;
  begin
    w:='';
    CutSpaces(s);
    l:=length(s);i:=1;
    while  (i<=l) and (s[i] in alpha) do begin
      w:=w+s[i];
      Inc(i);
    end;
    delete(s,1,i-1);
    GetWord:=w;
  end;

  function GetInt(var s:string):word;
    var
      i,l:byte;
      n:word;
  begin
    l:=length(s);
    i:=1;n:=0;
    while (i<=l) and (s[i] in digit) do begin
      n:=n*10+ord(s[i])-zero;
      Inc(i);
    end;
    delete(s,1,i-1);
    GetInt:=n;
    if s[1]=',' then delete(s,1,1);
  end;

  procedure GetSet(var s:string;var bs:byteset);
    var
      i,l,n1,n2:byte;
  begin
    bs:=[];
    while (length(s)>0) and (s[1] in digit) do begin
      n1:=GetInt(s);
      if (s[1]='.') and (s[2]='.') then begin
        delete(s,1,2);
        n2:=GetInt(s);
        bs:=bs+[n1..n2];
        end
      else
        bs:=bs+[n1];
    end;
  end;

  function Com(var s:string):Command;
    var
      w:string;
      i:byte;
      c:Command;
  begin
    delete(s,1,1);
    w:=GetWord(s);c:=NoCom;
    while (Comname[c]<>w) and (c<=Cans) do Inc(c);
    Cutspaces(s);
    Com:=c;
  end;

  procedure Error;
  begin
    writeln('Ошибка');
    halt;
  end;

end.



