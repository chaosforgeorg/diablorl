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
    CmdLine  : TParams;

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

  CmdLine := TParams.Create;
  if CmdLine.isSet('god')    then GodMode := True;
  if CmdLine.isSet('config') then 
    ConfigurationPath := CmdLine.get('config');

  Config    := TDiabloConfig.Create( ConfigurationPath );
  DataPath  := Config.Configure( 'DataPath',  DataPath );
  WritePath := Config.Configure( 'WritePath', WritePath );
  ScorePath := Config.Configure( 'ScorePath', ScorePath );
  SoundPath := Config.Configure( 'SoundPath', SoundPath );
  
  if CmdLine.isSet('datapath')   then DataPath          := CmdLine.get('datapath');
  if CmdLine.isSet('writepath')  then WritePath         := CmdLine.get('writepath');
  if CmdLine.isSet('scorepath')  then ScorePath         := CmdLine.get('scorepath');
  if CmdLine.isSet('soundpath')  then SoundPath         := CmdLine.get('soundpath');

  FreeAndNil( CmdLine );

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
