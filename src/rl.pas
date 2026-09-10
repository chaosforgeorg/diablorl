{$INCLUDE rl.inc}
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
  {$IFDEF HEAPTRACE} heaptrc, {$ENDIF}
  rlapplication;

//{$IFDEF WINDOWS}{$R rl.rc}{$ENDIF}
{$IFDEF WINDOWS}
{$R *.res}
{$ENDIF}

var Application : TGameApplication;

begin
  Application := TGameApplication.Create;
  try
    Application.Title := 'DiabloRL';
    Application.Initialize;
    if not Application.Terminated then Application.Run;
  finally
    Application.Free;
  end;
end.
