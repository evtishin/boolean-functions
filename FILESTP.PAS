{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 16384,0,655360}
unit FilesTp;
interface
  uses TpCrt,Graph,Strings;
    procedure ReadLine(var s:string);
    procedure Find(fc:Command;arg:word;stopcom:Command;var found:boolean);
    procedure Loadfile;
  type
    ContentsType=array [1..2] of record {the list of chapters}
                                s:string[50];
                                loc:longint;
                              end;
  var
    location:longint; {current position in buffer}
    Contents:^ContentsType;
    Chaps:byte;       {The number of chapters}

implementation
  procedure TeachText; external;
  {$L TEXT.OBJ}

  procedure ContentsProc; external;
  {$L CHAP.OBJ}

  type
    datatype=array[1..2] of char;
  var
   {buffer:pointer;   'twas pointer for procedure GetMem}
    data:^datatype;   {buffer where the file is to be loaded}
  const tab : string[8] = '    '+'    ';

  procedure ReadLine(var s:string);
  { This procedure "reads" string S from BUFFER, ...}
  begin
    s:='';
    while data^[location] > #0 do begin
      if data^[location] = ^I {... replacing tab symbols with spaces ...}
        then begin s:=s+tab;Inc(location)  end
        else begin
          s:=s+data^[location];
          Inc(location);
        end
    end;
    Inc(location);
    while s[ord(s[0])]=' ' do Dec(s[0]);{... and cutting spaces }
    if s[ord(s[0])]='$' then Dec(s[0]); { from the right rim. }
  end;

  procedure Find(fc:Command;arg:word;stopcom:Command;var found:boolean);
  { This procedure  looks for the command FC with argument ARG.
      It comletes after finding or when it meets command STOPCOM
      or the end of file FMAIN. If ARG = 0 , it looks for FC with
      any ARGument.
    If command FC was found FOUND is set to true, otherwise to false.}
    var
      s:string;
      c:command;
      n:word;
  begin
    found:=false;
    c:=NoCom;
    repeat
      readline(s);
      if s[1]='#' then begin
        c:=Com(s);
        n:=GetInt(s);
        found:=(c=fc) and ((n=arg) or (arg=0));
      end;
    until found or (c = stopcom);
  end;

  procedure Loadfile;
  {This procedure looked through the text and makes the table of CONTENTS}
  {Now it does almost nothing.}
    var
     {n:byte;
      s:string;
      c:Command;
      found:boolean;}
      key:char;
  begin
    location:=1;
    data:=@TeachText;
    Contents:=@ContentsProc;
    Chaps:=5;
    repeat until keypressed;
    while keypressed do key:=readkey;
    restorecrtmode;
    textattr:=7;
    location:=1;
  end;

end.
