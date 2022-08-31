{$include rl.inc}
program rl;
//*                                                                *//
//*                     Diablo, the Roguelike                      *//
//*                     by Kornel Kisielewicz                      *//
//*             Chris Johnson and Mel'nikova Anastasia             *//
//*                                                                *//
//*      Copyright 2005-2013 (c) Kornel Kisielewicz, ChaosForge    *//
//*                                                                *//
// @exclude

{
TODO:
-- item detail window
}

uses {heaptrc,}SysUtils, vos, vdebug, vsystems, rlgame, vutil, vlog, rlglobal, rlpersistence;

//{$IFDEF WINDOWS}{$R rl.rc}{$ENDIF}
{$IFDEF WINDOWS}
{$R *.res}
{$ENDIF}

var RootPath : AnsiString = '';


begin
  Randomize;

  {$IFDEF Darwin}
  {$IFDEF OSX_APP_BUNDLE}
  RootPath := GetResourcesPath();
  DataPath          := RootPath;
  ConfigurationPath := RootPath;
  SaveFilePath      := RootPath;
  SoundPath         := RootPath + 'sound/';
  {$ENDIF}
  {$ENDIF}

  {$IFDEF Windows}
  RootPath := ExtractFilePath( ParamStr(0) );
  DataPath          := RootPath;
  ConfigurationPath := RootPath;
  SaveFilePath      := RootPath;
  SoundPath         := RootPath + 'sound\';
  {$ENDIF}

  Logger.AddSink( TTextFileLogSink.Create( LOGDEBUG, RootPath+'log.txt', False ) );
  LogSystemInfo();
  Logger.Log( LOGINFO, 'Root path set to - '+RootPath );

//  {$IFDEF DEBUG}SetHeapTraceOutput('heap.txt');{$ENDIF}
  Game := Systems.Add(TGame.Create) as TGame;
  Game.Prepare;
  try
    Game.Run;
  except
    on e : Exception do
    begin
      if (not GameEnd) then Game.Save;
      raise;
    end;
  end;
end.
