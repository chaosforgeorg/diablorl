{$INCLUDE rl.inc}
unit rlsettingsview;
interface

uses viotypes, vioevent, vbindings, vconfiguration, rlconfiguration;

type TGameSettingsApply = procedure of object;
     TGameSettingsState = ( GSS_GENERAL, GSS_DISPLAY, GSS_GAME, GSS_AUDIO, GSS_INPUT, GSS_UI,
       GSS_MOVEMENT, GSS_GAMEPLAY, GSS_PANELS, GSS_ITEMS );

     TGameSettingsView = class( TIOLayer )
       constructor Create( aConfiguration : TGameConfiguration;
         aOnApply : TGameSettingsApply );
       destructor Destroy; override;
       procedure Update( aDTime : Integer; aActive : Boolean ); override;
       function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
       function IsModal : Boolean; override;
       function HandleCaptureEvent( const aEvent : TIOEvent ) : Boolean;
       // Called by IO after the frame has finished; never from a resize callback.
       procedure ApplyPending;
       procedure ReportError( const aError : AnsiString );
     private
       FConfiguration  : TGameConfiguration;
       FResolutions : array of TIOPoint;
       FOriginalValues : TConfigurationValueMap;
       FEditEntry      : TConfigurationEntry;
       FEditError      : AnsiString;
       FApplyRequested : Boolean;
       FEnumOpen       : Boolean;
       FStringBuffer   : array[0..31] of Char;
       FOnApply        : TGameSettingsApply;
       FState          : TGameSettingsState;
       FCapture        : Boolean;
       FAcceptEdit, FCancelEdit : Boolean;
       FCaptureAction  : TBindingAction;
       FCaptureMessage : AnsiString;
       FError          : AnsiString;
       procedure UpdateDisplayChoices;
       procedure SetState( aState : TGameSettingsState );
       function BindingCatalog : TBindingCatalog;
       procedure ResetPage;
       procedure ApplySettings;
     end;

implementation

uses SysUtils, vutil, vtig, vtigio, vglconsole, rlbindings, rlui;

const CStates : array[ TGameSettingsState ] of record
        Title, Group : AnsiString;
        Parent : TGameSettingsState;
      end = (
        ( Title: 'Settings'; Group: ''; Parent: GSS_GENERAL ),
        ( Title: 'Settings (Display)'; Group: GAME_CONFIGURATION_GROUP_DISPLAY; Parent: GSS_GENERAL ),
        ( Title: 'Settings (Gameplay)'; Group: GAME_CONFIGURATION_GROUP_GAMEPLAY; Parent: GSS_GENERAL ),
        ( Title: 'Settings (Audio)'; Group: GAME_CONFIGURATION_GROUP_AUDIO; Parent: GSS_GENERAL ),
        ( Title: 'Settings (Input)'; Group: ''; Parent: GSS_GENERAL ),
        ( Title: 'Settings (Input - UI)'; Group: UI_KEY_BINDING_GROUP; Parent: GSS_INPUT ),
        ( Title: 'Settings (Input - Movement)'; Group: GAME_BINDING_GROUP_MOVEMENT; Parent: GSS_INPUT ),
        ( Title: 'Settings (Input - Gameplay)'; Group: GAME_BINDING_GROUP_ACTIONS; Parent: GSS_INPUT ),
        ( Title: 'Settings (Input - Panels)'; Group: GAME_BINDING_GROUP_PANELS; Parent: GSS_INPUT ),
        ( Title: 'Settings (Input - Items)'; Group: GAME_BINDING_GROUP_ITEMS; Parent: GSS_INPUT )
      );
      CSub : array[0..8] of record
        State : TGameSettingsState;
        Name, Description : AnsiString;
      end = (
        ( State: GSS_DISPLAY;  Name: 'Display'; Description: 'Resolution, fullscreen, font multiplier and native terminal settings.' ),
        ( State: GSS_GAME;     Name: 'Gameplay'; Description: 'Name, run delay and town reveal.' ),
        ( State: GSS_AUDIO;    Name: 'Audio'; Description: 'Walking sound and sound/music volume.' ),
        ( State: GSS_INPUT;    Name: 'Input'; Description: 'Configure keyboard input.' ),
        ( State: GSS_UI;       Name: 'UI'; Description: 'Menu and dialog keys. Only unmodified keys are supported.' ),
        ( State: GSS_MOVEMENT; Name: 'Movement'; Description: 'Direction keys, waiting, Run and attack-in-place modifiers.' ),
        ( State: GSS_GAMEPLAY; Name: 'Gameplay'; Description: 'Gameplay actions.' ),
        ( State: GSS_PANELS;  Name: 'Panels'; Description: 'Inventory, spellbook, character, journal and closing panels.' ),
        ( State: GSS_ITEMS;   Name: 'Items'; Description: 'Quick item slots.' )
      );

constructor TGameSettingsView.Create( aConfiguration : TGameConfiguration;
  aOnApply : TGameSettingsApply );
begin
  inherited Create;
  FConfiguration := aConfiguration;
  FOnApply := aOnApply;
  UpdateDisplayChoices;
  FOriginalValues := FConfiguration.SnapshotValues;
  SetState( GSS_GENERAL );
  VTIG_EventClear;
end;

procedure TGameSettingsView.UpdateDisplayChoices;
var iNames : TStringArray;
    i, iCount, iSelected, iMaximum : Integer;
    iSize : TIOPoint;
begin
  iCount := 0;
  if UI.Driver.DisplayModes <> nil then iCount := UI.Driver.DisplayModes.Size;
  SetLength( FResolutions, iCount + 1 );
  SetLength( iNames, iCount + 1 );
  FResolutions[0] := Point( 0, 0 );
  iNames[0] := 'Native';
  iSize := Point( FConfiguration.GetInteger( 'screen_width' ),
    FConfiguration.GetInteger( 'screen_height' ) );
  iSelected := 0;
  for i := 1 to iCount do
  begin
    with UI.Driver.DisplayModes[i - 1] do FResolutions[i] := Point( Width, Height );
    iNames[i] := Format( '%dx%d', [FResolutions[i].X, FResolutions[i].Y] );
    if FResolutions[i] = iSize then iSelected := i;
  end;
  if (iSelected = 0) and (iSize.X > 0) and (iSize.Y > 0) then
  begin
    Inc( iCount );
    SetLength( FResolutions, iCount + 1 );
    SetLength( iNames, iCount + 1 );
    FResolutions[iCount] := iSize;
    iNames[iCount] := Format( '%dx%d (custom)', [iSize.X, iSize.Y] );
    iSelected := iCount;
  end;
  FConfiguration.CastInteger( 'display_mode' ).SetNames( iNames );
  FConfiguration.AccessInteger( 'display_mode' )^ := iSelected;
  iMaximum := 1;
  if UI.Console is TGLConsoleRenderer then
    iMaximum := TGLConsoleRenderer( UI.Console ).MaxScaleForDevice( Point( 80, 25 ) );
  if FConfiguration.GetInteger( 'font_multiplier' ) > iMaximum then
    iMaximum := FConfiguration.GetInteger( 'font_multiplier' );
  SetLength( iNames, iMaximum + 1 );
  iNames[0] := 'Automatic';
  for i := 1 to iMaximum do iNames[i] := 'x' + IntToStr( i );
  FConfiguration.CastInteger( 'font_multiplier' ).SetNames( iNames );
end;

destructor TGameSettingsView.Destroy;
begin
  if FEditEntry <> nil then UI.Driver.StopTextInput;
  if FOriginalValues <> nil then
  begin
    FConfiguration.RestoreValues( FOriginalValues );
    FOriginalValues.Free;
  end;
  inherited Destroy;
end;

procedure TGameSettingsView.SetState( aState : TGameSettingsState );
begin
  FState := aState;
  FEnumOpen := False;
  if aState = GSS_DISPLAY then UpdateDisplayChoices;
  VTIG_ResetSelect( 'settings' );
end;

function TGameSettingsView.BindingCatalog : TBindingCatalog;
begin
  case FState of
    GSS_UI : Result := FConfiguration.UIKeyBindings;
    GSS_MOVEMENT, GSS_GAMEPLAY, GSS_PANELS, GSS_ITEMS : Result := FConfiguration.GameKeyBindings;
    else Result := nil;
  end;
end;

procedure TGameSettingsView.ResetPage;
var iState : TGameSettingsState;
begin
  if FState = GSS_GENERAL then
    FConfiguration.ResetValues
  else if CStates[ FState ].Group <> '' then
    FConfiguration.ResetGroup( CStates[ FState ].Group )
  else
    for iState := GSS_UI to GSS_ITEMS do
      FConfiguration.ResetGroup( CStates[ iState ].Group );
end;

procedure TGameSettingsView.ApplySettings;
begin
  if not FConfiguration.ValuesValid then
  begin
    ReportError( 'Invalid settings. Run and attack must use different modifiers unless disabled.' );
    Exit;
  end;
  FOnApply;
  UI.SaveWindowGeometry;
  FreeAndNil( FOriginalValues );
  FOriginalValues := FConfiguration.SnapshotValues;
  if not FConfiguration.WriteSettings then
  begin
    FError := 'Could not save settings. Your changes remain active for this process. File: ' + FConfiguration.SettingsPath;
    VTIG_EventClear;
    Exit;
  end;
  if FState = GSS_GENERAL
    then FFinished := True
    else SetState( CStates[ FState ].Parent );
end;

procedure TGameSettingsView.ApplyPending;
begin
  if not FApplyRequested then Exit;
  FApplyRequested := False;
  try
    ApplySettings;
  except
    on E : Exception do ReportError( 'Could not apply settings. ' + E.Message );
  end;
end;

procedure TGameSettingsView.ReportError( const aError : AnsiString );
begin
  FError := aError;
  FFinished := False;
  VTIG_EventClear;
end;

procedure TGameSettingsView.Update( aDTime : Integer; aActive : Boolean );
var iGroup : TConfigurationGroup;
    iEntry, iHover : TConfigurationEntry;
    iCatalog : TBindingCatalog;
    iIndex, iSub, iCount, iSelected, iEdited : Integer;
    iKey : TIOKeyCode;
    iValue, iDescription, iBackLabel : AnsiString;
    iNext : TGameSettingsState;
    iHasNext, iReset, iApply, iBack, iWasOpen : Boolean;
    procedure BeginWindow( const aTitle, aID : AnsiString );
    begin
      VTIG_PushStyle( @TIGFramedWindowStyle );
      VTIG_BeginWindow( aTitle, aID, Point( 76, 22 ) );
      VTIG_PopStyle;
    end;
begin
  if not aActive then Exit;
  if FError <> '' then
  begin
    BeginWindow( 'Settings Error', 'settings_error' );
      VTIG_Text( FError );
    VTIG_End( 'Enter/Escape: return to Settings' );
    Exit;
  end;
  if FEditEntry <> nil then
  begin
    BeginWindow( FEditEntry.Name, 'settings_string' );
      VTIG_Text( FEditEntry.Description );
      VTIG_Text( FEditError );
      VTIG_Input( @FStringBuffer[0], SizeOf( FStringBuffer ) );
      if FAcceptEdit then
      begin
        FAcceptEdit := False;
        FEditError := '';
        if FEditEntry is TStringConfigurationEntry then
          TStringConfigurationEntry( FEditEntry ).Value := StrPas( @FStringBuffer[0] )
        else with TIntegerConfigurationEntry( FEditEntry ) do
          if TryStrToInt( StrPas( @FStringBuffer[0] ), iEdited ) and
             ( iEdited >= Min ) and ( iEdited <= Max ) then Value := iEdited
          else FEditError := Format( 'Enter an integer from %d to %d.', [ Min, Max ] );
        if FEditError = '' then
        begin
          UI.Driver.StopTextInput;
          FEditEntry := nil;
        end;
        VTIG_EventClear;
      end;
    VTIG_End( 'Enter: accept   Escape: cancel' );
    if FCancelEdit then
    begin
      FCancelEdit := False;
      UI.Driver.StopTextInput;
      FEditEntry := nil;
      VTIG_EventClear;
    end;
    Exit;
  end;
  if FCapture then
  begin
    BeginWindow( 'Rebind Key', 'settings_capture' );
      if FState = GSS_UI
        then VTIG_Text( 'Press an unmodified key to bind.' )
        else VTIG_Text( 'Press a key or chord to bind.' );
      VTIG_Text( 'Backspace/Delete: unbind. Escape: cancel.' );
      VTIG_Text( FCaptureMessage );
    VTIG_End;
    Exit;
  end;

  iApply := False;
  iBack := False;
  iGroup := nil;
  if CStates[ FState ].Group <> '' then
    iGroup := FConfiguration.Group[ CStates[ FState ].Group ];
  iCatalog := BindingCatalog;
  iHover := nil;
  iCount := 0;
  iHasNext := False;
  BeginWindow( CStates[ FState ].Title, 'settings' );
    VTIG_BeginGroup( 15, True );
      VTIG_BeginGroup( 42 );
        if iGroup = nil then
        begin
          for iSub := 0 to High( CSub ) do
            if CStates[ CSub[ iSub ].State ].Parent = FState then
            begin
              if VTIG_Selectable( CSub[ iSub ].Name ) then
              begin
                iNext := CSub[ iSub ].State;
                iHasNext := True;
              end;
              Inc( iCount );
            end;
        end
        else
          for iEntry in iGroup.Entries do
          begin
            if iEntry.Name = '' then Continue;
            iCatalog := FConfiguration.CatalogForEntry( iEntry.ID );
            if VTIG_Selectable( iEntry.Name ) then
            begin
              if iCatalog <> nil then
              begin
                FCaptureAction := iCatalog.ActionForID( iEntry.ID );
                FCaptureMessage := '';
                FCapture := True;
                VTIG_EventClear;
              end
              else if ( iEntry is TStringConfigurationEntry ) or
                ( ( iEntry is TIntegerConfigurationEntry ) and
                  ( Length( TIntegerConfigurationEntry( iEntry ).Names ) = 0 ) ) then
              begin
                FEditEntry := iEntry;
                FEditError := '';
                if iEntry is TStringConfigurationEntry then
                  iValue := TStringConfigurationEntry( iEntry ).Value
                else iValue := IntToStr( TIntegerConfigurationEntry( iEntry ).Value );
                StrPLCopy( FStringBuffer, iValue, High( FStringBuffer ) );
                UI.Driver.StartTextInput;
                VTIG_EventClear;
              end;
            end;
            Inc( iCount );
          end;
        iReset := VTIG_Selectable( 'Reset to defaults' );
        iApply := VTIG_Selectable( 'Apply settings' ) or iApply;
        if FState = GSS_GENERAL
          then iBack := VTIG_Selectable( 'Discard changes' ) or iBack
          else iBack := VTIG_Selectable( 'Back' ) or iBack;
        iSelected := VTIG_Selected( 'settings' );
      VTIG_EndGroup;
      VTIG_BeginGroup;
        iIndex := 0;
        if iGroup <> nil then
          for iEntry in iGroup.Entries do
          begin
            if iEntry.Name = '' then Continue;
            iCatalog := FConfiguration.CatalogForEntry( iEntry.ID );
            if iCatalog <> nil then
            begin
              iKey := TIOKeyCode( iCatalog.ConfigurationValue( iCatalog.ActionForID( iEntry.ID ) ) );
              if iKey = 0 then iValue := 'Unbound' else iValue := IOKeyCodeToStringShort( iKey );
              VTIG_InputField( iValue );
            end
            else if iEntry is TToggleConfigurationEntry then
              VTIG_EnabledInput( TToggleConfigurationEntry( iEntry ).Access, iIndex = iSelected )
            else if iEntry is TIntegerConfigurationEntry then
              with TIntegerConfigurationEntry( iEntry ) do
                if Length( Names ) > 0 then
                begin
                  iWasOpen := FEnumOpen;
                  if VTIG_EnumInput( Access, iIndex = iSelected, @FEnumOpen, Names ) then
                    if iEntry.ID = 'display_mode' then
                    begin
                      FConfiguration.AccessInteger( 'screen_width' )^ := FResolutions[Value].X;
                      FConfiguration.AccessInteger( 'screen_height' )^ := FResolutions[Value].Y;
                    end;
                  if iWasOpen and not FEnumOpen then VTIG_EventClear;
                end
                else VTIG_IntInput( Access, iIndex = iSelected, Min, Max, Step )
            else if iEntry is TStringConfigurationEntry then
              VTIG_InputField( TStringConfigurationEntry( iEntry ).Value );
            if iIndex = iSelected then iHover := iEntry;
            Inc( iIndex );
          end;
      VTIG_EndGroup;
    VTIG_EndGroup( True );
    iDescription := '';
    if iGroup = nil then
    begin
      iIndex := 0;
      for iSub := 0 to High( CSub ) do
        if CStates[ CSub[ iSub ].State ].Parent = FState then
        begin
          if iIndex = iSelected then iDescription := CSub[ iSub ].Description;
          Inc( iIndex );
        end;
    end
    else if iHover <> nil then iDescription := iHover.Description;
    if iSelected = iCount then
      if FState = GSS_GENERAL then iDescription := 'Reset all settings to defaults.'
      else if FState = GSS_INPUT then iDescription := 'Reset all input bindings to defaults.'
      else if iCatalog <> nil then iDescription := 'Reset this page. Conflicting bindings on other pages are unbound.'
      else iDescription := 'Reset this page to defaults.';
    if iSelected = iCount + 1 then iDescription := 'Apply all pending settings, save them and return.';
    if iSelected = iCount + 2 then
      if FState = GSS_GENERAL
        then iDescription := 'Close Settings and discard changes since opening or the last Apply.'
        else iDescription := 'Return to the previous page. Edits remain pending until Apply or Discard.';
    VTIG_Text( iDescription );
    if FState = GSS_DISPLAY then
      VTIG_Text( 'Only native terminal settings require restart. Launch flags override saved values.' )
    else VTIG_Text( 'Edits take effect on Apply settings.' );
  if FState = GSS_GENERAL then iBackLabel := 'discard' else iBackLabel := 'back';
  VTIG_End( UI.UIKey( VTIG_IE_UP ) + '/' + UI.UIKey( VTIG_IE_DOWN ) +
    ': select   ' + UI.UIKey( VTIG_IE_CONFIRM ) + ': choose   ' +
    UI.UIKey( VTIG_IE_CANCEL ) + ': ' + iBackLabel );

  if iHasNext then begin SetState( iNext ); VTIG_EventClear; end;
  if iReset then ResetPage;
  if iApply then FApplyRequested := True
  else if iBack or VTIG_EventCancel then
    if FState = GSS_GENERAL then FFinished := True else SetState( CStates[ FState ].Parent );
end;

function TGameSettingsView.HandleCaptureEvent( const aEvent : TIOEvent ) : Boolean;
var iKey : TIOKeyCode;
begin
  Result := False;
  if aEvent.EType = VEVENT_SYSTEM then Exit;
  if FError <> '' then
  begin
    if (aEvent.EType = VEVENT_KEYDOWN) and
       (aEvent.Key.Code in [VKEY_ENTER, VKEY_ESCAPE]) then FError := '';
    Exit( True );
  end;
  if not FCapture then Exit;
  if (aEvent.EType = VEVENT_KEYDOWN) and (aEvent.Key.Code <> 0) then
  begin
    if aEvent.Key.Code = VKEY_ESCAPE then FCapture := False
    else
    begin
      iKey := IOKeyEventToIOKeyCode( aEvent.Key );
      if aEvent.Key.Code in [VKEY_BACK, VKEY_DELETE] then iKey := 0;
      if (FState = GSS_UI) and (iKey and IOKeyCodeModMask <> 0) then
        FCaptureMessage := 'UI keys cannot use Shift, Ctrl or Alt. Press an unmodified key.'
      else
      begin
        BindingCatalog.SetKey( FCaptureAction, iKey );
        FCapture := False;
      end;
    end;
  end;
  Result := True;
end;

function TGameSettingsView.HandleEvent( const aEvent : TIOEvent ) : Boolean;
begin
  if not UI.IsTopLayer( Self ) then Exit( False );
  if (FEditEntry <> nil) and (aEvent.EType = VEVENT_KEYDOWN) then
  begin
    if aEvent.Key.Code = VKEY_ENTER then FAcceptEdit := True;
    if aEvent.Key.Code = VKEY_ESCAPE then FCancelEdit := True;
  end;
  Result := True;
end;

function TGameSettingsView.IsModal : Boolean;
begin
  Result := True;
end;

end.
