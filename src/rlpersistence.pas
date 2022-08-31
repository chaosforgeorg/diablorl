{$include rl.inc}
// @abstract(Persistence class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
unit rlpersistence;
interface
uses DOM, vxml, vuitypes, vxmldata;

const MAX_SCORE_ENTRIES = 500;
const SCORE_FILE_NAME   = 'score.mpq';

type

{ TPersistence }

TPersistence = class
  constructor Create;
  procedure Add( aScore : LongInt; const aName : AnsiString; aLevel : DWord; const aGrave, aKlass, aResult : AnsiString );
  function ScoreList : TUIStringArray;
  destructor Destroy; override;
private
  FScoreFile : TScoreFile;
end;

implementation
uses SysUtils, Classes, vutil, rlglobal;

{ TPersistence }

constructor TPersistence.Create;
begin
  FScoreFile := TScoreFile.Create( SaveFilePath+SCORE_FILE_NAME, MAX_SCORE_ENTRIES );
  FScoreFile.Load;
end;

procedure TPersistence.Add(aScore: LongInt; const aName: AnsiString; aLevel : DWord; const aGrave, aKlass, aResult: AnsiString);
var iEntry   : TScoreEntry;
begin
  iEntry := FScoreFile.Add( aScore );
  if iEntry = nil then Exit;
  iEntry.SetAttribute('level', IntToStr(aLevel) );
  iEntry.SetAttribute('name', aName );
  iEntry.SetAttribute('klass', aKlass );
  iEntry.SetAttribute('grave', aGrave );
  iEntry.SetAttribute('result', aResult );
end;

function TPersistence.ScoreList: TUIStringArray;
var iCount : DWord;
    iEntry : TScoreEntry;
    iColor : string[2];
begin
  Result := TUIStringArray.Create;
  if FScoreFile.Entries = 0 then Exit;
  for iCount := 1 to FScoreFile.Entries do
  begin
    iEntry := FScoreFile[ iCount ];

    if iCount = FScoreFile.LastEntry
      then iColor := '@y'
      else iColor := '@l';

    Result.Push( ' '+iColor + Padded( iEntry.GetAttribute('score') ,6)
                             + Padded( iEntry.GetAttribute('name')  ,14)
                             + Padded( iEntry.GetAttribute('klass') + ' L'+iEntry.GetAttribute('level') ,12)
                             + Padded( iEntry.GetAttribute('grave') ,19)
                             +         iEntry.GetAttribute('result') );
  end;

end;

destructor TPersistence.Destroy;
begin
  FreeAndNil( FScoreFile );
end;

end.

