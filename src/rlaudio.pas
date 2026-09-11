{$INCLUDE rl.inc}
unit rlaudio;
interface

uses Classes, Contnrs, vsound, vrandom, vutil, vrltools, rlconfig;

// Owns the audio backend, its source streams and the original Diablo MPQ.
// Source streams outlive backend playback and close before the archive.
type TGameAudio = class
  private
    FSound      : TSound;
    FStreams    : TObjectList;
    FMPQHandle  : THandle;
    FSoundPath  : AnsiString;
    FLastMVolume : Byte;
    FLastMusic  : AnsiString;
    function ReadFromMPQ( const aFileName : AnsiString ) : TStream;
  public
    constructor Create( aConfig : TGameConfig; aVisualRNG : TRNG;
      const aSoundPath : AnsiString );
    destructor Destroy; override;
    procedure PlayMusic( const aID : AnsiString );
    procedure PlaySound( const aID : AnsiString; aSource, aListener : TCoord2D );
    procedure PlaySound( const aID : AnsiString );
    procedure HaltSound;
    procedure SetMusicVolume( aVolume : Byte );
    procedure SetSoundVolume( aVolume : Byte );
end;

implementation

uses SysUtils, vstormlibrary, vfmodsound, vsdlsound, vmath, vdebug;

constructor TGameAudio.Create( aConfig : TGameConfig; aVisualRNG : TRNG;
  const aSoundPath : AnsiString );
var iSound : AnsiString;
    iMPQ : AnsiString;
begin
  inherited Create;
  FSoundPath := aSoundPath;
  iSound := aConfig.Configure( 'sound', 'NONE' );
  if iSound = 'NONE' then Exit;
  FStreams := TObjectList.Create( True );
  Log( LOGINFO, 'Sound mode requested, loading StormLib...' );
  LoadStorm;
  iMPQ := aConfig.Configure( 'mpq', 'DIABDAT.MPQ' );
  if not SFileOpenArchive( PChar( iMPQ ), 0, STREAM_FLAG_READ_ONLY, @FMPQHandle ) then
    Log( 'Failed to open MPQ!' );
  if iSound = 'DEFAULT' then iSound := {$IFDEF WINDOWS}'FMOD'{$ELSE}'SDL'{$ENDIF};
  if iSound = 'FMOD' then
    FSound := TFMODSound.Create
  else
    FSound := TSDLSound.Create( aVisualRNG );
  vsound.Sound := FSound;
end;

destructor TGameAudio.Destroy;
begin
  vsound.Sound := nil;
  if FSound <> nil then
  begin
    FSound.StopSound;
    FSound.Silence;
  end;
  FreeAndNil( FSound );
  FreeAndNil( FStreams );
  if FMPQHandle <> 0 then SFileCloseArchive( FMPQHandle );
  inherited Destroy;
end;

procedure TGameAudio.PlayMusic( const aID : AnsiString );
var iStream : TStream;
begin
  if FSound = nil then Exit;
  if not FSound.MusicExists(aID) then
  if FileExists( FSoundPath + aID ) then
    FSound.RegisterMusic( FSoundPath + aID, aID )
  else
  begin
    iStream := ReadFromMPQ( aID );
    if iStream <> nil
      then FSound.RegisterMusic( iStream, iStream.Size, aID, '.wav' )
      else Exit;
  end;
  FLastMusic := aID;
  FSound.PlayMusic(aID);
end;

procedure TGameAudio.PlaySound( const aID : AnsiString; aSource, aListener : TCoord2D );
const MAXDISTANCE = 15;
var iStream   : TStream;
    iVolume   : Integer;
    iDelta    : Integer;
    iPan      : Integer;
begin
  if FSound = nil then Exit;
  if not FSound.SampleExists(aID) then
  if FileExists( FSoundPath + aID ) then
    FSound.RegisterSample( FSoundPath + aID, aID )
  else
  begin
    iStream := ReadFromMPQ( aID );
    if iStream <> nil
      then FSound.RegisterSample( iStream, iStream.Size, aID )
      else Exit;
  end;
  iVolume := 32 + Round((MAXDISTANCE - Min(Distance(aListener,aSource) - 1,MAXDISTANCE) * 96) / MAXDISTANCE);
  iDelta  := aSource.x - aListener.x;
  iPan    := Min( Abs( iDelta ) - 1, MAXDISTANCE) * Sgn( iDelta );
  iPan    := Round(((iPan + MAXDISTANCE) * 255) / ( 2 * MAXDISTANCE ) );
  FSound.PlaySample(aID,Clamp(iVolume,0,255),Clamp(iPan,-127,128));
end;

procedure TGameAudio.PlaySound( const aID : AnsiString );
var iStream : TStream;
begin
  if FSound = nil then Exit;
  if not FSound.SampleExists(aID) then
  if FileExists( FSoundPath + aID ) then
    FSound.RegisterSample( FSoundPath + aID, aID )
  else
  begin
    iStream := ReadFromMPQ( aID );
    if iStream <> nil
      then FSound.RegisterSample( iStream, iStream.Size, aID )
      else Exit;
  end;
  FSound.PlaySample(aID);
end;

procedure TGameAudio.HaltSound;
begin
  if FSound = nil then Exit;
  FSound.StopSound;
end;

procedure TGameAudio.SetMusicVolume( aVolume : Byte );
var iResume : Boolean;
begin
  if FSound = nil then Exit;
  iResume := ( FLastMVolume = 0 );
  FLastMVolume := aVolume;
  FSound.SetMusicVolume(aVolume);
  if iResume and (aVolume > 0) then FSound.PlayMusic( FLastMusic );
end;

procedure TGameAudio.SetSoundVolume( aVolume : Byte );
begin
  if FSound = nil then Exit;
  FSound.SetSoundVolume(aVolume);
end;

type

{ TMPQStream }

 TMPQStream = class( TStream )
private
  FHandle : THandle;
  FSize   : Int64;
protected
  function  GetSize: Int64; override;
public
  constructor Create( aHandle : THandle );
  function Read( var aBuffer; aCount : LongInt ) : LongInt; override;
  function Seek( const aOffset : Int64; aOrigin : TSeekOrigin ) : Int64; override;
  destructor Destroy; override;
end;

{ TMPQStream }

function TMPQStream.GetSize: Int64;
begin
  Result := FSize;
end;

constructor TMPQStream.Create( aHandle : THandle );
begin
  FHandle := aHandle;
  FSize   := SFileGetFileSize(AHandle,nil);
end;

function TMPQStream.Read( var aBuffer; aCount : LongInt ) : LongInt;
var iBytesRead : Cardinal;
begin
  SFileReadFile(FHandle, @aBuffer, aCount, @iBytesRead, nil);
  Result:=iBytesRead;
end;

function TMPQStream.Seek( const aOffset : Int64; aOrigin : TSeekOrigin ) : Int64;
begin
  raise EStreamError.CreateFmt('Seek not implemented',[ClassName]);
  Seek := 0;
end;

destructor TMPQStream.Destroy;
begin
  SFileCloseFile( FHandle );
  inherited Destroy;
end;

function TGameAudio.ReadFromMPQ( const aFileName : AnsiString ) : TStream;
var iHandle   : THandle;
begin
  if not SFileOpenFileEx( FMPQHandle, PChar(aFileName), 0, @iHandle ) then
  begin
    Log('Sound file "'+aFileName+'" not found!');
    Exit( nil );
  end;
  Result := TMPQStream.Create( iHandle );
  FStreams.Add( Result );
end;

end.
