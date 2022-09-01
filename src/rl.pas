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

uses 
  {$ifdef HEAPTRACE} heaptrc, {$endif}
  SysUtils,
  vos, vdebug, vsystems, vutil, vlog, vparams,
  rlgame, rlconfig, rlglobal, rlpersistence;

//{$IFDEF WINDOWS}{$R rl.rc}{$ENDIF}
{$IFDEF WINDOWS}
{$R *.res}
{$ENDIF}

var RootPath : AnsiString = '';
    Config   : TDiabloConfig;

begin
  Randomize;

  {$IFDEF Darwin}
  {$IFDEF OSX_APP_BUNDLE}
  RootPath := GetResourcesPath();
  DataPath          := RootPath;
  ConfigurationPath := RootPath + 'config.lua';
  WritePath         := RootPath;
  SoundPath         := RootPath + 'sound/';
  {$ENDIF}
  {$ENDIF}

  {$IFDEF Windows}
  RootPath := ExtractFilePath( ParamStr(0) );
  DataPath          := RootPath;
  ConfigurationPath := RootPath + 'config.lua';
  WritePath         := RootPath;
  SoundPath         := RootPath + 'sound' + PathDelim;
  {$ENDIF}

  {$IFDEF HEAPTRACE}
  SetHeapTraceOutput( WritePath + 'heap.txt' );
  {$ENDIF}

  Logger.AddSink( TTextFileLogSink.Create( LOGDEBUG, WritePath+'log.txt', False ) );
  LogSystemInfo();
  Logger.Log( LOGINFO, 'Log path set to - '+WritePath );

  if ScorePath = '' then ScorePath := WritePath;
  ErrorLogFileName := WritePath + 'error.log';

  Config := TDiabloConfig.Create( ConfigurationPath );
  Game := Systems.Add( TGame.Create( Config ) ) as TGame;
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
