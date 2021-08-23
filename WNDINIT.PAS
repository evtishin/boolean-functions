unit WndInit;
interface
  uses TpWindow;
  var
    ErasedWnd,
    HelpWnd,
    GlsWnd,
    ResWnd,
    ChapWnd  : WindowPtr;
  const
    ExNorm = $13;
    ExCur =  $31;
    ExMarked = $1E;
    ExMarkedCur = $3E;
    Normtext = $1E;
    Hightext = $1F;
    Invtext = $71;
    MenuHigh = $74;
    MenuNorm = $70;
    Helpattr = $30;
    Helphigh = $3E;
    Helpinv = $1E;
    HelpFrame = $3F;

implementation
begin
  explode:=true;
  soundflagw:=false;
  explodedelay:=15;
  shadow:=true;
  if not MakeWindow(HelpWnd,15,4,66,22,true,true,false,
                Helpattr,HelpFrame,HelpFrame,'Help') then halt(1);
  if not MakeWindow(GlsWnd,14,3,67,23,true,true,false,
                Helpattr,HelpFrame,HelpFrame,'Словарь') then halt(1);
  if not MakeWindow(ResWnd,15,4,66,22,true,true,false,
           Helpattr,HelpFrame,HelpFrame,'Результат') then halt(1);
  if not MakeWindow(ChapWnd,15,4,66,23,true,true,false,
           Helpattr,HelpFrame,HelpFrame,'Смена раздела') then halt(1);
end.
