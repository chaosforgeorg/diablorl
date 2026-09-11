{$INCLUDE rl.inc}
unit rlbindings;
interface

uses vbindings, vioevent, vtigio, rlconfig;

const GAME_BINDING_GROUP_MOVEMENT = 'keybindings_movement';
      GAME_BINDING_GROUP_ACTIONS = 'keybindings_actions';
      GAME_BINDING_GROUP_PANELS = 'keybindings_panels';
      GAME_BINDING_GROUP_ITEMS = 'keybindings_items';
      UI_KEY_BINDING_GROUP = 'ui_bindings_keyboard';

const GameKeyBindingInfo : array[0..32] of TBindingInfo = (
  ( Action: COMMAND_WALKNORTH;  ID: 'input_walk_north';     Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_UP;     Name: 'Walk north';           Description: 'Walk north.' ),
  ( Action: COMMAND_WALKSOUTH;  ID: 'input_walk_south';     Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_DOWN;   Name: 'Walk south';           Description: 'Walk south.' ),
  ( Action: COMMAND_WALKEAST;   ID: 'input_walk_east';      Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_RIGHT;  Name: 'Walk east';            Description: 'Walk east.' ),
  ( Action: COMMAND_WALKWEST;   ID: 'input_walk_west';      Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_LEFT;   Name: 'Walk west';            Description: 'Walk west.' ),
  ( Action: COMMAND_WALKNE;     ID: 'input_walk_northeast'; Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_PGUP;   Name: 'Walk northeast';       Description: 'Walk northeast.' ),
  ( Action: COMMAND_WALKSE;     ID: 'input_walk_southeast'; Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_PGDOWN; Name: 'Walk southeast';       Description: 'Walk southeast.' ),
  ( Action: COMMAND_WALKNW;     ID: 'input_walk_northwest'; Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_HOME;   Name: 'Walk northwest';       Description: 'Walk northwest.' ),
  ( Action: COMMAND_WALKSW;     ID: 'input_walk_southwest'; Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_END;    Name: 'Walk southwest';       Description: 'Walk southwest.' ),
  ( Action: COMMAND_WAIT;       ID: 'input_wait';           Group: GAME_BINDING_GROUP_MOVEMENT; Default: VKEY_PERIOD; Name: 'Wait';                 Description: 'Wait.' ),
  ( Action: COMMAND_ESCAPE;     ID: 'input_escape';         Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_ESCAPE; Name: 'Game menu / cancel';   Description: 'Game menu / cancel.' ),
  ( Action: COMMAND_SWITCHMODE; ID: 'input_switch_mode';    Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_TAB;    Name: 'Travel / next target'; Description: 'Travel / next target.' ),
  ( Action: COMMAND_MESSAGES;   ID: 'input_messages';       Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_M;      Name: 'Message history';      Description: 'Message history.' ),
  ( Action: COMMAND_PICKUP;     ID: 'input_pickup';         Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_G;      Name: 'Pick up';              Description: 'Pick up.' ),
  ( Action: COMMAND_ACT;        ID: 'input_action';         Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_SPACE;  Name: 'Interact';             Description: 'Interact.' ),
  ( Action: COMMAND_LOOK;       ID: 'input_look';           Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_L;      Name: 'Look';                 Description: 'Look.' ),
  ( Action: COMMAND_FIRE;       ID: 'input_fire';           Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_F;      Name: 'Fire';                 Description: 'Fire.' ),
  ( Action: COMMAND_CAST;       ID: 'input_cast';           Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_Z;      Name: 'Cast';                 Description: 'Cast.' ),
  ( Action: COMMAND_OK;         ID: 'input_confirm';        Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_ENTER;  Name: 'Confirm';              Description: 'Confirm.' ),
  ( Action: COMMAND_QUICKSLOT;  ID: 'input_quick_items';    Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_Q;      Name: 'Quick items';          Description: 'Quick items.' ),
  ( Action: COMMAND_QUICKSKILL; ID: 'input_quick_spells';   Group: GAME_BINDING_GROUP_ACTIONS;  Default: VKEY_S;      Name: 'Quick spells';         Description: 'Quick spells.' ),
  ( Action: COMMAND_INVENTORY;  ID: 'input_inventory';      Group: GAME_BINDING_GROUP_PANELS;  Default: VKEY_I;      Name: 'Inventory';            Description: 'Inventory.' ),
  ( Action: COMMAND_SPELLBOOK;  ID: 'input_spellbook';      Group: GAME_BINDING_GROUP_PANELS;  Default: VKEY_B;      Name: 'Spellbook';            Description: 'Spellbook.' ),
  ( Action: COMMAND_PLAYERINFO; ID: 'input_character';      Group: GAME_BINDING_GROUP_PANELS;  Default: VKEY_C;      Name: 'Character';            Description: 'Character.' ),
  ( Action: COMMAND_JOURNAL;    ID: 'input_journal';        Group: GAME_BINDING_GROUP_PANELS;  Default: VKEY_J;      Name: 'Journal';              Description: 'Journal.' ),
  ( Action: COMMAND_CWIN;       ID: 'input_close_panels';   Group: GAME_BINDING_GROUP_PANELS;  Default: VKEY_BACK;   Name: 'Close panels';         Description: 'Close panels.' ),
  ( Action: COMMAND_QUICKSLOT1; ID: 'input_item_1';         Group: GAME_BINDING_GROUP_ITEMS;    Default: VKEY_1;      Name: 'Quick item 1';         Description: 'Quick item 1.' ),
  ( Action: COMMAND_QUICKSLOT2; ID: 'input_item_2';         Group: GAME_BINDING_GROUP_ITEMS;    Default: VKEY_2;      Name: 'Quick item 2';         Description: 'Quick item 2.' ),
  ( Action: COMMAND_QUICKSLOT3; ID: 'input_item_3';         Group: GAME_BINDING_GROUP_ITEMS;    Default: VKEY_3;      Name: 'Quick item 3';         Description: 'Quick item 3.' ),
  ( Action: COMMAND_QUICKSLOT4; ID: 'input_item_4';         Group: GAME_BINDING_GROUP_ITEMS;    Default: VKEY_4;      Name: 'Quick item 4';         Description: 'Quick item 4.' ),
  ( Action: COMMAND_QUICKSLOT5; ID: 'input_item_5';         Group: GAME_BINDING_GROUP_ITEMS;    Default: VKEY_5;      Name: 'Quick item 5';         Description: 'Quick item 5.' ),
  ( Action: COMMAND_QUICKSLOT6; ID: 'input_item_6';         Group: GAME_BINDING_GROUP_ITEMS;    Default: VKEY_6;      Name: 'Quick item 6';         Description: 'Quick item 6.' ),
  ( Action: COMMAND_QUICKSLOT7; ID: 'input_item_7';         Group: GAME_BINDING_GROUP_ITEMS;    Default: VKEY_7;      Name: 'Quick item 7';         Description: 'Quick item 7.' ),
  ( Action: COMMAND_QUICKSLOT8; ID: 'input_item_8';         Group: GAME_BINDING_GROUP_ITEMS;    Default: VKEY_8;      Name: 'Quick item 8';         Description: 'Quick item 8.' )
);

const UIKeyBindingInfo : array[0..10] of TBindingInfo = (
  ( Action: VTIG_IE_UP;      ID: 'ui_keyboard_up';        Group: UI_KEY_BINDING_GROUP; Default: VKEY_UP;     Name: 'Up';        Description: 'Move the UI selection or view up.' ),
  ( Action: VTIG_IE_DOWN;    ID: 'ui_keyboard_down';      Group: UI_KEY_BINDING_GROUP; Default: VKEY_DOWN;   Name: 'Down';      Description: 'Move the UI selection or view down.' ),
  ( Action: VTIG_IE_LEFT;    ID: 'ui_keyboard_left';      Group: UI_KEY_BINDING_GROUP; Default: VKEY_LEFT;   Name: 'Left';      Description: 'Move the UI selection or tab left.' ),
  ( Action: VTIG_IE_RIGHT;   ID: 'ui_keyboard_right';     Group: UI_KEY_BINDING_GROUP; Default: VKEY_RIGHT;  Name: 'Right';     Description: 'Move the UI selection or tab right.' ),
  ( Action: VTIG_IE_HOME;    ID: 'ui_keyboard_home';      Group: UI_KEY_BINDING_GROUP; Default: VKEY_HOME;   Name: 'Home';      Description: 'Move to the start of a UI list or view.' ),
  ( Action: VTIG_IE_END;     ID: 'ui_keyboard_end';       Group: UI_KEY_BINDING_GROUP; Default: VKEY_END;    Name: 'End';       Description: 'Move to the end of a UI list or view.' ),
  ( Action: VTIG_IE_PGUP;    ID: 'ui_keyboard_page_up';   Group: UI_KEY_BINDING_GROUP; Default: VKEY_PGUP;   Name: 'Page up';   Description: 'Move a UI view up by one page.' ),
  ( Action: VTIG_IE_PGDOWN;  ID: 'ui_keyboard_page_down'; Group: UI_KEY_BINDING_GROUP; Default: VKEY_PGDOWN; Name: 'Page down'; Description: 'Move a UI view down by one page.' ),
  ( Action: VTIG_IE_CANCEL;  ID: 'ui_keyboard_cancel';    Group: UI_KEY_BINDING_GROUP; Default: VKEY_ESCAPE; Name: 'Cancel';    Description: 'Cancel or leave the current UI.' ),
  ( Action: VTIG_IE_CONFIRM; ID: 'ui_keyboard_confirm';   Group: UI_KEY_BINDING_GROUP; Default: VKEY_ENTER;  Name: 'Confirm';   Description: 'Confirm the current UI selection.' ),
  ( Action: VTIG_IE_SELECT;  ID: 'ui_keyboard_select';    Group: UI_KEY_BINDING_GROUP; Default: VKEY_SPACE;  Name: 'Select';    Description: 'Select the current UI entry.' )
);

type TGameMovementModifier = ( GMM_NONE, GMM_SHIFT, GMM_ALT, GMM_CTRL );

type TGameBindingCatalog = class( TBindingCatalog )
  function ValuesValid( aMax : Integer = IOKeyCodeMax ) : Boolean;
end;

implementation

function TGameBindingCatalog.ValuesValid( aMax : Integer ) : Boolean;
var iIndex, iOther, iValue : Integer;
begin
  for iIndex := 0 to High( FInfo ) do
  begin
    iValue := ConfigurationValue( FInfo[ iIndex ].Action );
    if (iValue < 0) or (iValue > aMax) then Exit( False );
    if iValue <> 0 then
      for iOther := 0 to iIndex - 1 do
        if ConfigurationValue( FInfo[ iOther ].Action ) = iValue then Exit( False );
  end;
  Result := True;
end;

end.
