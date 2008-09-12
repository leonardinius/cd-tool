library Config;


uses
  Windows,Main;

{.$R *.RES}
(*Ну здесь всё понятно :-) *) 
 procedure CreateConfigBox(const Parent:THandle);export;far;stdcall;
 begin
  CreateConfigDialog(Parent);(*ф-ия из Main.pas*)
 end;
 Exports CreateConfigBox name 'ShowConfigDialog'; (*назовём её как нам захочется*)
begin
(*DllEntry point here:-)*)
end.
 
