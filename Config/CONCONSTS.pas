unit CONCONSTS;

interface
Uses Windows,Messages;
Const
{������ ��� ����������� ������(by Pos function).}
{Do not remove unfilled places here!!!!!! SEE BELOW}

ALT=' ALT ';(*����� ���������� ��������� �������,*)
SHIFT=' SHIFT ';(* ����� ����� ����� ���� ���������� *)
CTRL=' CTRL ';  (*��� ������ POS ��������*)
PGDWN=' PGDWN ';
PGUP=' PGUP ';
{������ ��� ����������� ������(by Pos function).}
{Do not remove unfilled places here!!!!!!}
CHARS:array [1..26]of  STRING[3]= (*���  ������-�������(� ��������  ��� ����� ������[0..3]of byte, ��� ������ ������ ����� ������������ ��� ����������� ������������� ������� �� ���� ������������ ������ ��� ��������� ������,������� �������� ������, ��� ���-�� �������� :-)*)
                (       (*����� �����*)
' Q ',' W ',' E ',      (**)
' R ',' T ',' Y ',      (**)
' U ',' I ',' O ',      (**)
' P ',' M ',' N ',      
' A ',' S ',' D ',      (**)
' F ',' G ',' H ',      (**)
' J ',' K ',' L ',      (**)
' Z ',' X ',' C ',
' V ',' B '
                );      (*����� �� ����� ����*)
  {������� � �.�. ����� �� ��������, ������� ������������ chars}                                              
 VAR
 WasError:boolean;(*����� �������� ����������- ����� ����� �������� � "������"*)

// procedure showmessage_(const Message:PChar);       (*��� ���-��� �����*)
 procedure ErrorMessage(const Message,Tittle:PChar); (*� ��� ��� ����- ������ ��������*)
                                                     (*����� ���� ��������� WasError- ������ ��� � ������*)
implementation
 //procedure showmessage_(const Message:PChar);
 //begin
 //MessageBox(0,Message,'',0);
 //end;

 procedure ErrorMessage(const Message,Tittle:PChar);
 begin
 WasError:=true;
 MessageBox(0,Message,Tittle,mb_IconHand+mb_ApplModal);
 end;
 initialization
 waserror:=false;
 finalization
end.
