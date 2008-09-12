Unit Main;
 Interface
uses
  Messages,   
  Windows,
  CONCONSTS ;

{$R config1.res}// our resurces here 
 {$I conconsts.inc}// constants
 {$I same.inc}     // values,what need be similar with values in CdTool application.
 procedure CreateConfigDialog(Parent:THandle);
Implementation
 VAR Owner:THandle;// Our dialog handle- where to send our Apply Messages
 (*!!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! *)
 FUNCTION MainDialogProc {Callback Function-���� ������� ��������}
                        (DlgWin     : hWnd ; {����������}
                         DlgMessage : UINT;  {���������}
                         DlgWParam  : WPARAM ;{������. ����}
                         DlgLParam  : LPARAM)(*������. ����*)
                                                : BOOL;(*���������*)STDCALL;Far;(*��� ��������� ������ � ��������,�������� � �������*)


TYPE
_str_=string[8];//���- ������[8] 
 VAR
  KEY:hKeY;    (*�����-Handle ��� �����, ��� �����������*)
 RegRes:Dword;(*����������� � ���������� ������, �� �������*)
 Root_Key:THandle;(*��� ���� ����� �������- ��� ������ ����������� ��� ��� ������ � �����*)

   buf:array[0..254]of char; (*������*)
   Byte_:Integer;            (*��������-255, �� �� ���� �������-��� ���������� � �������� � ���� ������*)
   buf_:String;              (*�� buf==> ��������� � buf_*)
Handle:Integer;              (*handle ��� ������ �������.
                               ���� ����� �������� �
                               SendDlgItemMessage*)

  i:BYTE;(* ���������� ��� ���� ����� �����  ������ � ������� �� �����[3]*)
 WMHOT1,WMHOT2,WMHOT3:integer;(*��� ��� ���� ����� ������� ������ ����� � ������*)
 HOTSTR1,HOTSTR2,HOTSTR3:string[8];(*������ ��� �����������, ����� ���������� ������, � 7,�.�.<PGDWN>=7��������+1 ������������ ����(?)-����� ������ �� ���)*)
 Place1,Place2:byte;(*��� ��� ���� ����� ����� ����� ��������� ������� � ������ ��� ����������� �� ����������� ����������*)
 begin
 result:=true;
Case
DlgMessage of
   WM_INITDIALOG:BEGIN
                   Handle:=GetDlgItem(DlgWin,ID_MACHINE_RADIO); (*�������� �����*)
                   SendMessage(Handle,BM_SETCHECK,BST_CHECKED,0);(*������ LocalMachine � ��������� Checked*)
                 END;
   WM_COMMAND:{ALL COMMANDS HERE: like menu or buttons pushes}
              case LOWOrd(DlgWParam) of
              ID_APPLY_BUTTON:
                             Begin
                              WasError:=false; {����� ������� � �� ���� ������� :-) }
                             (*��� ���  �����-��� ����� ��� ������� ����-����*)
                             WmHot1:=0; //Inits
                             FillChar(buf,sizeof(buf),0); //Inits
                             Handle:=GetDlgItem(dlgWin,ID_OPEN_EDIT); // ����� ��������
                             byte_:=SendMessage(Handle,EM_LINELENGTH,-1,0)+1;//�������� �����(? ����� �� �����)
                             SendMessage(Handle,WM_GETTEXT,byte_,Integer(@buf));(*������ �������� � ������*)
                             buf[byte_+1]:=#0; (*� ��� ��� ������������ ����? :-) *)
                             //ShowMessage_(PChar(@buf[1])); {test string}
                             buf_:=' '+ShortString(buf)+' '; (*�������-��� POS �-��, + ���������� � ���� ������.������ *)
                             //showmessage_(PChar(buf_));{test string}
                                if pos(ALT,buf_)<> 0 (*���� ���� ����, �� ����� *)
                                        then wmHot1:=mod_ALt; (*��������� �������� ������������ �����*)
                                if pos(shift,buf_)<> 0  (*Shift?*)
                                        then wmHot1:=WmHot1+mod_Shift;
                                if pos(CTRL,buf_)<> 0   (*Ctrl? *)
                                        then wmHot1:=WmHot1+mod_Control;
                                        place1:=0;place2:=0;(*Inits-we need for it :-)*)

                                 FillChar(HotStr1,sizeof(HotStr1),0);//inits

                                Place1:= pos(PGUP,ShortString(buf_)); //���� ������� ���������� ���������
                                Place2:=pos(PGDWN,buf_); //������� �������� ����� � �������� � ������ ��� ������
                                if (Place1<>0)or (Place2<>0)(*���� ���� -�����������*)
                                        then    (*�����*)
                                            if ((Place1<Place2)and(Place2>0)and(Place1<>0))or((Place1>Place2)and(Place2=0))
                                              then   (*(���� �����1 ������ ��2 � ��1 ������ ����) ��� (��2-���, � ��1-����)*)
                                              HotStr1:=pgUp (*������ ���� ������*)
                                              else
                                              HotStr1:=PGDWN  (*����� ��������*)
                                        else (*if PGUP or PGDWN not found*)
                                        
                                        FOR  i:=1 to 26 (*��������� ���� ������*)
                                        do
                                        if pos(Chars[i],buf_)<>0 (*�����!!!!!!!*)
                                        then begin
                                             HOTStr1:=_Str_(Chars[i]);(*������ *)
                                             break;(*����� ������� ����� �������- ����� �� Loop*)
                                             end;
                                            //showmessage_(PChar(@hotstr1[1])); (*����*)
                              if HotStr1='' then ErrorMessage('The hotkey needs for pressing chars','The script "compile" error!');
                              if WmHot1=0 then   ErrorMessage(' Hotkey needs for pressed'#13' system buttons like-'+ALT,'The script compile error!');
                           (*���� ��������� ��������� ��������� *)
            (*
              ���� ���� ����� ��� �� ��� 2-�� �����
              ��������� �� ����- �������� ����
              � ��������-�Ѩ �� �� �����-
              � ��������� � ����� ������� :-)                                                           
              *)                                                      
                                                                  
                             (*��� ��� �������� ����-����*)
                                 Handle:=0;
                                    WmHot2:=0;
                             FillChar(buf,sizeof(buf),0);
                             Handle:=GetDlgItem(dlgWin,ID_CLOSE_EDIT);
                             byte_:=SendMessage(Handle,EM_LINELENGTH,-1,0)+1;
                             SendMessage(Handle,WM_GETTEXT,byte_,Integer(@buf));
                             buf[byte_+1]:=#0;
                             //ShowMessage_(PChar(@buf[1])); {test string}
                             buf_:=' '+ShortString(buf)+' ';
                             //showmessage_(PChar(buf_));{test string}
                                if pos(ALT,buf_)<> 0
                                        then wmHot2:=mod_ALt;
                                if pos(shift,buf_)<> 0
                                        then wmHot2:=WmHot2+mod_Shift;
                                if pos(CTRL,buf_)<> 0
                                        then wmHot2:=WmHot2+mod_Control;

                                 FillChar(HotStr2,sizeof(HotStr2),0);
                                 place1:=0;place2:=0;(*Inits-we need for it :-)*)


                                Place1:= pos(PGUP,ShortString(buf_)); //���� ������� ���������� ���������
                                Place2:=pos(PGDWN,ShortString(buf_));
                                if (Place1<>0)or (Place2<>0)
                                        then 
                                            if ((Place1<Place2)and (Place2<>0)and(Place1<>0))or((Place1>0)and(Place2=0))
                                              then
                                              HotStr2:=pgUp
                                              else
                                              HotStr2:=PGDWN
                                        else (*if PGUP or PGDWN not found*)
                                        
                                        FOR  i:=1 to 26
                                        do
                                        if pos(Chars[i],buf_)<>0
                                        then begin
                                             HOTStr2:=_Str_(Chars[i]);
                                             break;
                                             end;
                                            //showmessage_(PChar(@hotstr2[1]));
                              if HotStr2='' then ErrorMessage('The hotkey needs for pressing chars','The script "compile" error!');
                              if WmHot2=0 then   ErrorMessage(' Hotkey needs for pressed'#13' system buttons like-'+ALT,'The script compile error!');
            (*
              ���� ���� ����� ��� �� ��� 2-�� �����
              ��������� �� ����- �������� ����
              � ��������-�Ѩ �� �� �����-
              � ��������� � ����� ������� :-)                                                           
              *)         
                            (*��� ��� �������� �����:-)*)

                                 Handle:=0;
                                    WmHot3:=0;
                             FillChar(buf,sizeof(buf),0);
                             Handle:=GetDlgItem(dlgWin,ID_EXITAPP_EDIT);
                             byte_:=SendMessage(Handle,EM_LINELENGTH,-1,0)+1;
                             SendMessage(Handle,WM_GETTEXT,byte_,Integer(@buf));
                             buf[byte_+1]:=#0;
                             //ShowMessage_(PChar(@buf[1])); {test string}
                             buf_:=' '+ShortString(buf)+' ';
                             //showmessage_(PChar(buf_));{test string}
                                if pos(ALT,buf_)<> 0
                                        then wmHot3:=mod_ALt;
                                if pos(shift,buf_)<> 0
                                        then wmHot3:=WmHot3+mod_Shift;
                                if pos(CTRL,buf_)<> 0
                                        then wmHot3:=WmHot3+mod_Control;

                                 FillChar(HotStr3,sizeof(HotStr3),0);
                                 place1:=0;place2:=0;(*Inits-we need for it :-)*)


                                Place1:= pos(PGUP,ShortString(buf_)); //���� ������� ���������� ���������
                                Place2:=pos(PGDWN,ShortString(buf_));
                                if (Place1<>0)or (Place2<>0)
                                        then
                                            if ((Place1<Place2)and (Place2<>0)and(Place1<>0))or((Place1>0)and(Place2=0))
                                              then
                                              HotStr3:=pgUp
                                              else
                                              HotStr3:=PGDWN
                                        else (*if PGUP or PGDWN not found*)

                                        FOR  i:=1 to 26
                                        do
                                        if pos(Chars[i],buf_)<>0
                                        then begin
                                             HOTStr3:=_Str_(Chars[i]);
                                             break;
                                             end;
                                            //showmessage_(PChar(@hotstr3[1]));
                              if HotStr3='' then ErrorMessage('The hotkey needs for pressing chars','The script "compile" error!');
                              if WmHot3=0 then   ErrorMessage(' Hotkey needs for pressed'#13' system buttons like-'+ALT,'The script compile error!');
                   
                      (*���������� �������� :-) *)
                         if WasError then   (*�� Ũ� ������� ����� ��� ���� �����? 8-) *)
                                    ErrorMessage(^M^M'Some errors occured while application'^M'    tryed to compile the script!!!'^M+'Rewrite shortcuts you want to use!!!','"SCRIPT" ERROR!!!')
                    (*������ ���������������� ����. ������ ���� ������ �����, ��� ����� ���������*)
                                    else  //MessageBox(DlgWin,PChar(String('The following chars will be applayed!!'+^M+'    '+HotStr1+^M+'    '+HotStr2+^M+'    '+HotStr3)),'SEE THIS!!',mb_IconQuestion)
                                       ;
 (*�� �� ���������- � ���� �� �������� CAPSLOCK ��� ������� :-) *)
if  WasError=false then (*� ��� ������� �� ����*)
begin
 Handle:=GetDlgItem(DlgWin,ID_USER_RADIO); (*�� �� �������, ����� ������� SendDlgItemMessage-��.����.*)
 IF SendMessage(Handle,BM_GETCHECK,0,0)=BST_CHECKED (*�� ��� �� �������?*)
  THEN ROOT_KEY:=0         (*�-�-�-�-�-�-!*)
  ELSE ROOT_KEY:=1; 
                         
                      if RegCreateKeyEx(HKEY_LOCAL_MACHINE,
                                   strConfig,(*��� �� ����� ������� ���� ��������*)
                                   0,
                                   nil,
                                   REG_OPTION_NON_VOLATILE,(**���-��� �� ��� �� ��� ����� �������� �������� - ����� �� ����� � ������ ���������, � ����� �� �������*)
                                   Key_Write,              (*������ �����, ��-��-��*)
                                    NIL,
                                    key,                  (*��� � ��� ���������� �����*)
                                    @RegRes              (*��� �� ����- � ��� ������� ���� �� ������� ��� �������*)
                                    ) = ERROR_SUCCESS
                then
                    begin(*���� ������ �� ���������*) 
                   RegSetValueEx(key,OpenShortCut,0,REG_DWORD,@WMHOT1,sizeof(Integer));(*��������� ����������� ����� ��� �������� ����*)
                   RegSetValueEx(key,CloseShortCut,0,REG_DWORD,@WMHOT2,sizeof(Integer));(*��������*)
                   RegSetValueEx(key,ExitShortCut,0,REG_DWORD,@WMHOT3,sizeof(Integer)); (*������ �� �����*)
                       if HotStr1=PGUP then byte_:=vk_Prior else(*��� ��� *)
                       if HotStr1=PGDWN then byte_:=vk_Next else
                       byte_ :=ord(HotStr1[2]);         (*��� char :-)*)
                   RegSetValueEx(key,OpenChar,0,REG_DWORD,@Byte_,sizeof(Integer));(*����� ��� �������� ����*)
                       if HotStr2=PGUP then byte_:=vk_Prior else                 (*� ��� �� ������� :-) , �������*)
                       if HotStr2=PGDWN then byte_:=vk_Next else                (*���� ���-��. ����*)
                       byte_ :=ord(HotStr2[2]);
                   RegSetValueEx(key,CloseChar,0,REG_DWORD,@Byte_,sizeof(Integer)); (*�������� ����*)
                       if HotStr3=PGUP then byte_:=vk_Prior else
                       if HotStr3=PGDWN then byte_:=vk_Next else
                       byte_ :=ord(HotStr3[2]);
                       
                   RegSetValueEx(key,ExitChar,0,REG_DWORD,@Byte_,sizeof(Integer));(*������ �� ����� *)
                   RegSetValueEx(key,H_KEY,0,REG_DWORD,@ROOT_KEY,sizeof(DWORD));

                      RegCloseKey(key);   (*��������� �����, ��� ��� ���������- ����� ERROR*)
                      SendMessage(Owner,ExitMess,0,0);(*�������� ��������� � �������-CdTool- ��� ��� ��� �������� ��� ���������� �������������� Owner-�, � �������� WM_PARENTNOTIFY, �� ���-�� �� ����� � ����*)
                      SendMessage(DlgWin,WM_SYSCOMMAND,SC_CLOSE,0);
                    end
               else (*��, �� ����� � ��� ��������, ��� ������*)
                    ErrorMessage('The application was unable to'^M+ 'save you� chosen settings.'^M+'Exit the application and'^M+' then retry that you did!','System registry ERROR!');

                        WasError:=false ; (*������ INIT*)

END;(*If was not error*)
   end;(*End of case of ID_APPLY_BUTTON*)

              ID_HOW_TO   :begin (*���������- ��� ������� :-)*)
                   MessageBox(
                                dlgWin,
                                   'You can use something similar to primitive SCRIPT :-)       '^M+
                                   'You Can receive different hotkeys using these keywords:     '^M+
                                   '    ==============================================              '^M+
                                   '    ALT    -needs for pressed Alt   button'^M+
                                   '    SHIFT-needs for pressed Shift button'^M+
                                   '    CTRL -needs for pressed Ctrl  button'^M+
                                   '       Anothers are simple chars(only chars)'^M+
                                   '    =======================PLUS==================='^M+
                                   '    PGUP- needs for pressed PageUp button'^M+
                                   '    PGDWN -needs for pressed PageDown button'^M+
                                   '    =============================================='^M+
                                   'All anothers words(chars) are ignored.'^M+
                                   '    =============================================='^M+
                                   '   I mean that only one char-the first met in edit will be your'^M+
                                   '    hotkey,all anothers will not affect on CdTool application!'^M+
                                   '     =============================================='^M+
                                   ' Like this- ALT SHIFT X C==> Alt will be applayed, SHIFT will'^M+
                                   '          too, X will too, but C will not be applayed!!!!!!!!!!'^M+
                                   '  PGUP and PGDWN are like chars,but they have more prioritate'^M+
                                   'SO: if you have written <char> before the PGUP - only PGUP'^M+
                                   'will aplly :like this'^M+
                                   '    <ALT X PGUP> will produce <ALT+PGUP> not <ALT+X>'^M+
                                   '    =============================================='^M+
                                   '                BE CAREFUL USING "SCRIPT"'^M+
                                   'I think i have described all you need,if you are not fool'^M+
                                   'You will understand it !! :-)                               ',

                                'HOW TO ...??? The "SCRIPT" is case sensitive!!!!!',
                                MB_ICONQUESTION
                              );
                           end;
              ID_CANCEL_BUTTON:SendMessage(DlgWin,WM_SYSCOMMAND,SC_CLOSE,0);
              ID_USER_RADIO:
                            begin
                            Handle:=getDlgItem(DlgWin,ID_USER_RADIO);  (*������ CHECKED � �����������, ���� ����*)
                            SendMessage(Handle,BM_SETCHECK,BST_CHECKED,0);
                            Handle:=getDlgItem(DlgWin,ID_MACHINE_RADIO);
                            SendMessage(Handle,BM_SETCHECK,BST_UNCHECKED,0);
                            end;
              ID_MACHINE_RADIO:
                            begin                                      (*������ CHECKED � �����������, ���� ����*)
                            Handle:=getDlgItem(DlgWin,ID_MACHINE_RADIO);
                            SendMessage(Handle,BM_SETCHECK,BST_CHECKED,0);
                            Handle:=getDlgItem(DlgWin,ID_USER_RADIO);
                            SendMessage(Handle,BM_SETCHECK,BST_UNCHECKED,0);
                            end;
              end;
   WM_SYSCOMMAND:{we handle system commands here}
               if DlgWParam=SC_CLOSE
               then(*�����������*)
            begin
                 EndDialog(DlgWin, LOWORD(DlgWParam));(*����� �����������*)
                 result:=true;
                 exit;
         
       end;
   end;
   result:=false; (*���� ������, ����� ������ �� ��� �����- ��� �� ��� ���� :-) *)
 end;

(*!!!!!!!!!!!!!!!!!!!!!!!APP ENTRY POINT HERE!!!!!!!!!!!!!!!!!!!!!!!!!!S*)
 procedure CreateConfigDialog(Parent:THandle); (*� � �� ����� �������� � ���.*)
begin
Owner:=Parent;  (*Handle- ��������- ��� ������� ���  ���������*)
DialogBox(
                    hInstance,(*���� ��������*)
                     PChar(CONFIQ), (*��� �� ��� ������ , ��� � ����� �����*)
                      Parent,          (*���  ����,��������� � ��� ����*)
                       @MainDialogProc (*����� CallBack-a *)
                       );
end;
end.
