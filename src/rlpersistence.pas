{$include rl.inc}
// @abstract(Persistence class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
unit rlpersistence;
interface
uses DOM, vxml, viotypes, vxmldata;

const MAX_SCORE_ENTRIES = 500;
const SCORE_FILE_NAME   = 'score.mpq';

type

{ TPersistence }

TPersistence = class
  constructor Create( const aScorePath : AnsiString );
  procedure Add( aScore : LongInt; const aName : AnsiString; aLevel : DWord; const aGrave, aKlass, aResult : AnsiString );
  function ScoreList : TIOStringArray;
  destructor Destroy; override;
private
  FScoreFile : TScoreFile;
end;

implementation
uses SysUtils, Classes, vutil;

{ TPersistence }

constructor TPersistence.Create( const aScorePath : AnsiString );
begin
  FScoreFile := TScoreFile.Create( aScorePath + SCORE_FILE_NAME, MAX_SCORE_ENTRIES );
  FScoreFile.Lock;
  try
    FScoreFile.Load;
  finally
    FScoreFile.Unlock;
  end;
end;

procedure TPersistence.Add(aScore: LongInt; const aName: AnsiString; aLevel : DWord; const aGrave, aKlass, aResult: AnsiString);
var iEntry   : TScoreEntry;
begin
  FScoreFile.Lock;
  try
    FScoreFile.Load;
    iEntry := FScoreFile.Add( aScore );
    if iEntry <> nil then 
    begin
      iEntry.SetAttribute('level', IntToStr(aLevel) );
      iEntry.SetAttribute('name', aName );
      iEntry.SetAttribute('klass', aKlass );
      iEntry.SetAttribute('grave', aGrave );
      iEntry.SetAttribute('result', aResult );
      FScoreFile.Save;
    end;
  finally
    FScoreFile.Unlock;
  end;
end;

function TPersistence.ScoreList: TIOStringArray;
var iCount : DWord;
    iEntry : TScoreEntry;
    iColor : string[2];
begin
  Result := TIOStringArray.Create;
  if FScoreFile.Entries = 0 then Exit;
  for iCount := 1 to FScoreFile.Entries do
  begin
    iEntry := FScoreFile[ iCount ];

    if iCount = FScoreFile.LastEntry
      then iColor := '{y'
      else iColor := '{l';

    Result.Push( ' '+iColor + Padded( iEntry.GetAttribute('score') ,6)
                             + Padded( iEntry.GetAttribute('name')  ,14)
                             + Padded( iEntry.GetAttribute('klass') + '} L'+iEntry.GetAttribute('level') ,12)
                             + Padded( iEntry.GetAttribute('grave') ,19)
                             +         iEntry.GetAttribute('result') );
  end;

end;

destructor TPersistence.Destroy;
begin
  FreeAndNil( FScoreFile );
end;

end.

