library Config;


uses
  Windows,Main;

{.$R *.RES}
(*�� ����� �� ������� :-) *) 
 procedure CreateConfigBox(const Parent:THandle);export;far;stdcall;
 begin
  CreateConfigDialog(Parent);(*�-�� �� Main.pas*)
 end;
 Exports CreateConfigBox name 'ShowConfigDialog'; (*������ � ��� ��� ���������*)
begin
(*DllEntry point here:-)*)
end.
 
