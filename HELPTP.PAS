unit HelpTp;
interface
  uses TpCrt,TpWindow,Strings,WndInit,ScrTp;
  type
    Wnd = array[1..17] of string[51];
    ShortStr = string[3];
    RoomInfo = record
      n:byte; { Screen number                  }
      l:byte; { Label y-coordinate             }
      b:byte; { Label beginning (x-coordinate) }
      s:byte  { Label length                   }
      end;
    RoomsInfo = array[1..21] of RoomInfo;
    Room = record  {Screen               }
      n:byte;      {Screen number        }
      w:Wnd;       {Screen buffer        }
      r:RoomsInfo; {Labels               }
      c:byte       {The number of labels }
      end;
    Labyr = array[0..1] of Room;


  var info : array[boolean] of ^Labyr;

  procedure WriteBright(s:string);
  procedure WriteInv(s:string);
  procedure TchHlp(nam:byte;hlp:boolean);

implementation

  procedure HelpProc; external;
  {$L HELP.OBJ}

  procedure GlsProc; external;
  {$L GLS.OBJ}

  procedure WriteBright(s:string);
    begin
      textattr:=Helphigh;
      write(s);
      textattr:=Helpattr
    end;
  procedure WriteInv(s:string);
    begin
      textattr:=Helpinv;
      write(s);
      textattr:=Helpattr;
    end;

  type
    MemPtr=^MemRoom;
    MemRoom=record
      n,l:byte;
      last,next:MemPtr
    end;
  var
    Stacks:array[boolean] of MemPtr;

  procedure InitStack(hlp:boolean);
    begin
      new(stacks[hlp]);
      stacks[hlp]^.n:=0;stacks[hlp]^.l:=0;
      stacks[hlp]^.last:=nil
    end;

  procedure Push(nam,i:byte;hlp:boolean);
    begin
      new(stacks[hlp]^.next);stacks[hlp]^.next^.last:=stacks[hlp];
      stacks[hlp]:=stacks[hlp]^.next;
      stacks[hlp]^.n:=nam;stacks[hlp]^.l:=i
    end;

  procedure Pull(var nam,i:byte;hlp:boolean);
    begin
      if stacks[hlp]^.last<>nil then begin
        nam:=stacks[hlp]^.n;i:=stacks[hlp]^.l;
        stacks[hlp]:=stacks[hlp]^.last;dispose(stacks[hlp]^.next)
      end
    end;

  procedure KillStack(hlp:boolean);
    begin
      while stacks[hlp]^.last<>nil do begin
        stacks[hlp]:=stacks[hlp]^.last;
        dispose(stacks[hlp]^.next)
      end
    end;

  procedure TchHlp(nam:byte;hlp:boolean);
    var
      first:boolean;
      rm:Room;
      i,j,oldnam:byte;
      k:keyboard;
    begin
      InitStack(hlp);textattr:=7;
      if hlp then begin
        Writemenu(menu[helpmode]);
        if not DisplayWindow(HelpWnd) then halt(1)
        end
      else begin Writemenu(menu[glsmode]);
        if not DisplayWindow(GlsWnd) then halt(1)
      end;
      hiddencursor;
      i:=1;
      repeat
        rm:=info[hlp]^[nam];
        clrscr;
        for j:=1 to 16 do writeln(rm.w[j]);write(rm.w[17]);
        for j:=1 to rm.c do begin
          gotoxy(rm.r[j].b,rm.r[j].l);
          WriteBright(copy(rm.w[rm.r[j].l],rm.r[j].b,rm.r[j].s))
        end;
        repeat
          gotoxy(rm.r[i].b,rm.r[i].l);
          WriteInv(copy(rm.w[rm.r[i].l],rm.r[i].b,rm.r[i].s));
          gotoxy(1,1);
          repeat k:=GetKey  until (k in [Enter..F2]) or (k=F4)
                                   or (k=Esc);
          gotoxy(rm.r[i].b,rm.r[i].l);
          if k<>Enter then WriteBright(copy(rm.w[rm.r[i].l],
                                       rm.r[i].b,rm.r[i].s));
          case k of
            Enter : begin Push(nam,i,hlp);nam:=rm.r[i].n;i:=1  end;
            Right : begin i:=i+1;if i>rm.c then i:=1   end;
            Left  : begin i:=i-1;if i=0 then i:=rm.c   end;
            Down  : begin
              first:=true;
              for j:=i+1 to rm.c do if first and (rm.r[j].b=rm.r[i].b)
                                      then begin
                                        i:=j;first:=false
                                      end;
              if first then
                begin Inc(i);if i>rm.c then i:=1  end;
              end;
            Up : begin
              first:=true;
              for j:=i-1 downto 1 do if first and (rm.r[j].b=rm.r[i].b)
                                       then begin
                                       i:=j;first:=false
                                     end;
              if first then
                begin Dec(i);if i=0 then i:=rm.c  end
              end;
            Homekey,PgUp : i:=1;
            Endkey,PgDn  : i:=rm.c;
	    F1 : if hlp then nam:=0
                   else begin
                     TchHlp(7,true);
                     Writemenu(menu[glsmode]);
                   end;
            F2 : begin oldnam:=nam;Pull(nam,i,hlp);
                   if nam=oldnam then k:=Another  end;
            F4 : if not hlp then nam:=0
          end
        until (k=Esc) or (k=Enter) or ((k=F1) and hlp) or (k=F2) or (k=F4)
      until k=Esc;
      KillStack(hlp);
      ErasedWnd:=EraseTopWindow
    end;

begin
  info[true]:=@HelpProc;
  info[false]:=@GlsProc;
end.
