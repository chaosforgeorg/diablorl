{$include rl.inc}
program mpq;
uses Classes, SysUtils, vpkg, vdf;

var MPQFile   : TVDataCreator;

//{$R *.res}

begin
  MPQFile := TVDataCreator.Create('diablorl.mpq');
  try
    MPQFile.Add('const.inc',FILETYPE_LUA,[vdfCompressed]);
    MPQFile.Add('lua/*.lua',FILETYPE_LUA,[vdfCompressed]);
    MPQFile.Add('lua/cells/*.lua',FILETYPE_LUA,[vdfCompressed],'cells');
    MPQFile.Add('lua/items/*.lua',FILETYPE_LUA,[vdfCompressed],'items');
    MPQFile.Add('lua/npc/*.lua',FILETYPE_LUA,[vdfCompressed],'npc');
    MPQFile.Add('lua/levels/*.lua',FILETYPE_LUA,[vdfCompressed],'levels');
  except
    on e : Exception do
      Writeln( e.Message );
  end;
  FreeAndNil(MPQFile);
end.


