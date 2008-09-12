{*****************************************************************************
                  OpenMind&Soft tool to open-close CdRom
                           28-October-2001
               Copyright (C) 2001 by OpenMind&Soft, Inc.
               contact e-mail:   leonidms@inbox.lv
               //*************************************//
                           29-January-2002     
                //*****//Some changes made :-))
               Copyright (C) 2002 by OpenMind&Soft, Inc.
 *******************************************************************( ldh )***/}
(*
  ������������ ������� -������ ��� ���-���� ��������,���� �� ����������� ��������,
  ����� � ���� �� �� ��� ��� ����� :-)
 !!!!!!!!! �� ������, ������� �������� <Sanja> ���� ����������, �������� ��� ����������
           ������� ����� www.pascal.times.lv
           (��������� ��������( ����� ������� � ��������� ��������� �������) 
 *)
{******************************************************************************
 �������: ��� ���������� ����������� <make.bat>- �� ����������� <dialog.rc> � ���� �����
 ����� ������������ TRegistry  ����� ����� �����, �� ������ ����� ����� ��������� �� 40 ��.
 �� ���������� SYSUTILS:---> ������� �� 40.
 � ��� ���� ���������� runtime library- Sysutils, ������ ���, ��� Registry, �� ����� ����� �����
 ���������,��� �������� �����( ���� ����� �����(�������� �� ���������) �����, ������� �������� �
 VCL � :--> ������� :-) � ����� �� systray-e, ���� ������� ����� ���������� ������ ��� ���.)
 ���� ����� ����� ������������� Exceptions(���� ��� � ����� try except end; �� ������������
 ������ ������� ��� ��������� �������).
                                     
 ******************************************************************************}
program CDTool;
{$R Dialog.res} //dialog resource here
{$R *.Res}      //all another resources here
{$A+}

uses
  Windows, Messages,(* SAnja: ������, ��� ����� �� �� ������������ �����������:-) *)
  MMSystem ,  
  ShellApi ;

  {$I consts.inc}
  {$I same.inc}
  {$I about.inc}
  //ROOT_KEY = HKEY_CURRENT_USER;
var  ROOT_KEY :THandle= HKEY_LOCAL_MACHINE;
const
  {SANJA:���� ���� ����� "�������" ���������,�� ����� ��� ������ HKey_Current_User
  ��-�� ���� ������ � WinApi}
  str_MainDlg  = 'CDTool';  { String=Caption }

 str_Message  = 'MYCDTOOLREGMESS' ; {��� ������ ��� ����������� ����� ��������� �� ������
                                     �� systray. ��� ������ " RegisterWindowMessage"  function
                                     � ������������� ��������� (�������� ���������)WM_MYTrayIcon}
strReg:PChar = 'SoftWare\Microsoft\Windows\CurrentVersion\Run'; 
                                                   (*
                                                     ��� ����, � ������� �����
                                                    �������� ���� � �����, ��� ������������
                                                    ����� ������ � Windows 
                                                    *)


ErrorRegHotKey=Bool(0);

var
  MyTag: TMCI_Open_Parms;  {�������� � ����, ������� ����� "mci_open" ��������, �� ���� ��� ��������� ������� � ����� ����������}
  SetParms: TMCI_Set_Parms; {--"--(���� �����)������ ��� ��������� ������� ����������}
  FFlags:Cardinal;          {����� ��� ��������� ��������� ���� }
  Data:TNotifyIconData;     {������, ������ ��� ��������� ������ � systray}
  WM_MYTrayIcon:LongWord=0; {���������� ��� ������ ��������� �� ������-������ ...}
  Menu:Hmenu;               {������� � Syse}
  once:boolean=true;        {�������, ��� ������ ������� �� ����������
                                   ������� � ������ ���, �.�. �������
                                   WM_INITDIALOG  � ����� WM_PAINT  :-)}
 WMHOT1,WMHOT2,WMHOT3:Uint;
REG_CHAR1,REG_CHAR2,REG_CHAR3:UInt;
MenuStr:PChar;

 procedure ShowConfigDialog(Parent:THandle);stdcall;external 'Config.dll';(*�-�� �������*)
//Main procedure-opens CD-Rom:-|

procedure NotifyCdRom(Operation:Cardinal);near;
begin
 mciSendCommand(                   {*******�������� ��������� ����������****************}
                MyTag.wDeviceId,   {*******������������� ����������*********************}
                 mci_set,          {*******������� ��� ��������� �������� �������*******}
                 Operation ,       {*******�������� �������� ��������*******************}
                 Longint(@SetParms){******����� ������ ��� ���������, �� �� ���� �������}
                 );                {****************************************************}
(*
�������� ��� ���� ��� ������������ ���������������
����� �� ���� "���������" ���������� � �.�.
������ ����� �� ��������, �.�. �������� �� ��� �� ���:->
:-> mciSendString
���������������������������������������������������������
���� ���(� �������������� � � ���� ��������� ����
�� CDEvents- ��������� �����
*)
//******************************************************************//
//      mciSendString('set cdaudio door open',nil,0,0);             //
//      mciSendString('set cdaudio door closed',nil,0,0);           //
// ��������� �������� � ����� :-)                                   //
//******************************************************************//
end;

procedure GetShortCut(var MenuStr:PChar;const WmHot:Integer);
begin
 CASE WmHot of
 mod_Alt:MenuStr:='Alt+';
 mod_Control:MenuStr:='Ctrl+';
 mod_Shift:MenuStr:='Shift+';
 mod_Alt+mod_Control:MenuStr:='Alt+Ctrl+';
 mod_Alt+mod_Shift:MenuStr:='Alt+Shift+';
 mod_Control+mod_Shift:MenuStr:='Ctrl+Shift+';
 mod_Alt+mod_Control+mod_Shift:MenuStr:='Alt+Ctrl+Shift+';
 Else MenuStr:='' ;{������ ��������}
 end;
end;
function GetChar(const Char:Integer):PChar;
var CH_:String;
begin
Case Char of
vk_Prior:Result:='PgUp';
vk_Next:Result:='PgDwn';
Else begin
     ch_:=Chr(byte(Char));  //���� �� ������ Runtime Error :--->�� ������� ���
     Result:=PChar(ch_);    //
     end;
end;
end;

FUNCTION MainDialogProc {Callback Function-���� ������� ��������}
                        (DlgWin     : hWnd ; {����������}
                         DlgMessage : UINT;  {���������}
                         DlgWParam  : WPARAM ;{������. ����}
                         DlgLParam  : LPARAM)(*������. ����*)
                                                : BOOL;(*���������*)STDCALL;(*��� ��������� ������ � ��������,�������� � �������*)

 const temp:PChar='CdTool';(*��������� ��������*)
 var
    Len:Integer; (*����� �������� ����� � ��������*)
    str:string;  (*���� ��������*)
    PT:TPoint;   (*���������� ��� ����,����� ����� ��� ���������� ����*)
    KEY:hKeY;    (*������-Handle ��� �����, ��� �����������*)
    RegRes:Dword;(*����������� � ���������� ������, �� �������*)
    WasError:boolean;(*used in REINIT_MESS ��� ����������� ���� �� ������� �����*)

 begin
Result:=true;
    if dlgMessage =WM_MYTrayIcon then (*���� ��������� �� ������*)
    case DlgLParam of
       WM_RBUTTONDOWN:                (*��������,������ ����� �����*)
            begin
               GetCursorPos(pt);      (*���? ����������?*)

               if RegOpenKeyEx(                 (*��������� ����*)
                                       ROOT_KEY,(*HKey_Current_User*)
                                       strReg,  (*���� ������, ���� Software\...*)
                                       0,       (*���������������*)
                                       KEY_READ,(*��� ������*)
                                       key) = ERROR_SUCCESS
               then begin           (*���� ���������� ==>*)
                   RegRes:=REG_SZ;  (*������ ����� ������*)
                        RegQueryValueEx(
                                         KEY, (*����,������� ��� ������*)
                                        temp,(*PChar('CdTool')*)
                                        nil, (*���������������*)
                                        @RegRes,(*����� �� ��,��� ������ ����� ������*)
                                        nil,    (*���. ��� ������ ���� �����.��� nil=> �������� �����*)
                                         @Len);  (*������ ���� �� � � ��������*)
          (*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*)
       SetString(str,nil,len); //Sanja: ������� ����� ��� �����, ���� ������� ��������
          (*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*)
                   if  RegQueryValueEx(     (*������ *)
                                        KEY,(*����*)
                                        temp,(*'CdTool'*)
                                        nil,  (*reserved*)
                                         @RegRes,(*��� ������, ������� ������*)
                                         @Str[1], {Sanja:��� ������! -> PByte(str)}(*�:��-�� ����� ��� ����*)
                                         @Len)   (*�����,������� ������*)
                                              =Error_Success
                   then begin (*���� ������*)
                         SetLength(str,lStrLen(PChar(str)));(*�������� ����������� ������,��� ��������*)
                         //MessageBox(dlgWin,PChar(str),'',mb_ok);  //bilo dlja proverki
                         if str=ParamStr(0) then
                            begin                            (*���� ����� � ���� � �����(� ����� ������� ������ ����� �����)*)
                               EnableMenuItem(menu,ID_MAutoY,mf_Grayed);(*������ ����������� ������ � ����*)
                               EnableMenuItem(menu,ID_MAutoN,mf_Enabled);(*������ ����������� ������ � ����*)
                            end
                            else begin                       (*���� �� ����� � ���� � �����*)
                               EnableMenuItem(menu,ID_MAutoN,mf_Grayed);(*������ ����������� ������ � ����*)
                               EnableMenuItem(menu,ID_MAutoY,mf_Enabled);(*������ ����������� ������ � ����*)
                            end;
                         end
                   Else begin (*���� �������� �������� �������� ,�������� ��� ����:-)*)//<> Eroor_Success
                      EnableMenuItem(menu,ID_MAutoN,mf_Grayed); (*������ ����������� ������ � ����*)
                      EnableMenuItem(menu,ID_MAutoY,mf_Enabled);(*������ ����������� ������ � ����*)
                   end;
               end

               // --> ���� ���� ������� �� �������, ��:
               else begin
                  EnableMenuItem(menu,ID_MAutoN,mf_Grayed);(*������ ����������� ������ � ����*)
                  EnableMenuItem(menu,ID_MAutoY,mf_Enabled);(*������ ����������� ������ � ����*)
               end;

               TrackPopupMenuEx(    (*���������� ���� � �����-�� �����*)
                     GetSubmenu(Menu,0),(*�������� �������� ������� ��� ����*)
                     tpm_LeftAlign,     (*��-�� ������������ ����*)
                     pt.x,              (*���������� �*)
                     pt.y,              (*���������� �*)
                     dlgWin,            (*���������� �������*)
                     nil                //ne pomnju,nado v HELPE pogljadet
                            );
            end;

       WM_LBUTTONUP:
        (*������� �� �������:--> ������ ����� ����� ����*)
         //messagebox(0,'','',0);
            ShowWindow(dlgWin,sw_show); (*���������� ������*)
    end;(*�����-���� ��������� �� ����*)

   case  DLGMessage
   of
    WM_PAINT:
          begin
               if  once
               then
                   begin
                      ShowWindow(dlgWin,sw_hide); (*������ ������-������� �����:--->(<BLINKING>)*)
                      once :=false;(*� ����. ��� ����� ����������*)
                      result:=true;
                      exit;
                   end
               else
                   DefWindowProc(DlgWin, WM_PAINT,0,0);(*������������ ��������� ����*)
          end;

    wm_InitDialog: (*��� �������� �������*)
          begin
                 Menu:=LoadMenu(hInstance,'MYPOPUP'); (*����. �� �������� ����*)
                 SetWindowLong (          (*������,����� ����� ������ �� �������*)
                                dlgWin,  (*ID*)
                                GWL_ExSTYLE,(*������ ����� �����-�������� *)
                                WS_EX_TOOLWINDOW  and  not WS_EX_APPWINDOW or WS_EX_TOPMOST);(*����� ���������*)
                //  sendMessage(DlgWin,
                //  $0080{wm_SetIcon},
                //  1,
                //  LoadIcon  (hInstance,'MAINICON')
               //   );
                //  SetWindowPos(dlgWin,hwnd(-1),0,0,176,130,swp_nomove);
                //InsertMenu(
                   //   GetSystemMenu(dlgWin,false),
                   //   $FFFFFFFF,
                   //   mf_Byposition ,
                    //  ID_SystemMenu,
                    //  '&About'
                    //  );
(*
���� ��� ������ �����, ���� �� ������� ���� �����(������.)
*)
  with Data do begin
                      cbSize:=Sizeof(data);(*������ ����� ������*)
                      szTip:='This is a tool to open-close CdRom';(*������. ���������*)
                      uFlags:=Nif_Message or Nif_Icon or nif_Tip ;(*����� ��� ������� ������*)
                      uId:=ID_SYSICON; (*ID ������*)        
                      wnd:=dlgWin;//HWND
                      uCallBackMessage:=WM_MYTrayIcon;(*��������� � ����*)
                      hIcon:=LoadIcon(hInstance,'MAINICON');(*������*)
                          Shell_NOtifyIcon(nim_Add,@data);(*���� �-�� *)                                                                               
                 end;
               SendMessage(DlgWin,ReINIT_Mess(*��,������,��� �������*),0,0); (*���������-� ����� �� ��� ��������� �������� �� ��������, ����� �������� ���������� � ����� �� ���.-����������� �������*) 
             end;
REG_MESS: begin      (*���� � ���, ��� ��� ������ � ����� �� ����������� ��������, �� ������� ����� �� �����*)
                      (*:=====> ������� WasError*)  
                  WasError:=false;
                   //messageBox(0,PChar(IntToStr(wmhot1)+^M+IntToStr(wmhot2)+^M+IntToStr(wmhot3)+^M+IntToStr(reg_char1)+^M+IntToStr(reg_char2)+^M+IntToStr(reg_char3)+^M),'',0);
                 if RegisterHotKey(dlgWin,ID_HotKey1,{mod_Alt,33}wmHot1,Reg_Char1)=ErrorRegHotKey then WasError:=true;(*���� ���-�� ��� �������������� ��� �����*)
                 if RegisterHotKey(dlgWin,ID_HotKey2,{mod_Alt,34}wmHot2,Reg_Char2)=ErrorRegHotKey then WasError:=true;(*�� ������� ����,��� ���� �������� �� ����� � ����*) 
                 if RegisterHotKey(dlgWin,Id_HotKey3,{mod_alt,88}wmHot3,Reg_Char3)=ErrorRegHotKey then WasError:=true;
                  (*wmHot1..3 and Reg_Char1..3 are read from registry*)
                  if WasError (*��� ����� , � � � � , �����, �� ����� �� ������ :-) *)
                 then MessageBox( (*���� ������� ��� *)                                      
                   dlgWin,
                   'The program tried to receive on of the hotkeys.'+#13+
                         'It has been receiving by another program!!!'+#13+
                         'That program will not be able to use this hotkey!'+#13+
                         'Change your SoftWare configuration:-) and try'+#13+
                         'to restart CdTool program.'+#13+
                         'OR:Your default hotkey operation will open your CD :-)',
                   'CdTool-Warning',
                   mb_iconHand + MB_ApplMOdal
                   ) ;

          end;
                    
    wm_HotKey:       (*����� , "�������" ����?*)
          case dlgWParam of (*� �����?*)
             ID_HotKey2:  //opens CD
                 NotifyCdRom(mci_set_door_Closed);
             ID_HotKey1: //Closes CD
                 NotifyCdRom(mci_set_door_open);
             ID_HotKey3:
                  SendMessage(DlgWin, WM_SYSCOMMAND, SC_CLOSE, 0);(*���������: ����������� �� �� ������������ ���������*)
         end;//  WM_HOTKEY

   WM_COMMAND:
        CASE LOWOrd(DlgWParam) OF
         (*������� �� ������� � �� ����� �� �������*)
            Id_CDOpen  :  NotifyCdRom(mci_set_door_open);(*������-����� �������*)
            Id_CdClose :  NotifyCdRom(mci_set_door_closed);(* �� ��,�� ����.*)
            Id_Close   :  ShowWindow(dlgWin,sw_Hide);     (*�� ��,�� ��������*)
            Id_MAbout  :  AboutProc(DlgWin); (*�-�� in SAME.INC*)(*�� ��� BMP-��� ����� �� .....*)  //menu in systray about
            Id_MExit   :  SendMessage(DlgWin, WM_SYSCOMMAND, SC_CLOSE, 0);(*���������*)
            ID_MOpen:   NotifyCdRom(mci_set_door_open);
            Id_MClose:  NotifyCdRom(mci_set_door_closed);
            Id_MAutoY:
            begin (*"������" ������� � ��������---�������*)
                 (*Sanja: ������� ������ ���������+ �����*)
                 if RegCreateKeyEx(ROOT_KEY,(*���������� ��� � ����� ��� Config.dll*)
                                   strReg,
                                   0,
                                   nil,
                                   REG_OPTION_NON_VOLATILE,
                                   Key_Write,
                                    NIL,
                                    key,
                                    @RegRes
                                    ) = ERROR_SUCCESS
                then
                    begin
                    (*���������� ��� � ����� ��� Config.dll*)
                   RegSetValueEx(key,PChar('CdTool'),0,REG_SZ, PChar(ParamStr(0)),
                      //���������: --> ������ {sizeof(PChar(ParamStr(0)))});
                      Length(ParamStr(0)));
                   RegCloseKey(key);
                    end
               else
                (*�� ������� ��� ������ , ���� ������� �� ������� , ��� ����� �� ����� �����������*)
                 MessageBox(0,
                            'The apllication was not able to create autorun key '+#13+
                            'for you, so it will not be able to restart with Windows.'+#13+
                            'Try to restart application or retry the last operation!' ,
                              'Application Error',
                             MB_OK+ MB_APPLMODAL
                             );
            end;

           Id_MAutoN: (*"���� ������" ������� � ��������---�������*)
            begin      (*���������: ����������� *)
            (*��������� -���� *)
                 if RegCreateKeyEx(ROOT_KEY,
                                   strReg,
                                   0,
                                   nil,
                                   REG_OPTION_NON_VOLATILE,
                                   Key_Write,
                                   NIL,
                                   key,
                                   @RegRes) = ERROR_SUCCESS
             then
                  begin
                   RegDeleteValue(key,PChar('CdTool'));
                   RegCloseKey(key);
                 end
                else
                 MessageBox(0,
                            'The apllication was not able to delete autorun key '+#13+
                            'for you, so it can be restarted by Windows.'+#13+
                            'Try to restart application or retry the last operation!' ,
                              'Application Error',
                             MB_OK+ MB_APPLMODAL
                             );
            end;
          id_MConfig:begin
                     
                     ShowConfigDialog(dlgWin);(*NEW: ConfogDialog :-) *)
                     end;
      end;

      wm_SysCommand:  (*��������� ��������*)
           case DlgWParam of
            SC_CLOSE: (*�����������*)
            begin
                 Shell_NOtifyIcon(nim_delete,@data);(*��������� � syse*)
                 SendMessage(DlgWin,UnReg_MEss,0,0); (*�������� ������. ���� ���������- ���� ������������ � ����� ��������*)
                 EndDialog(DlgWin, LOWORD(DlgWParam));(*����� �����������*)
                 result:=true;(*� ����� � �� ���� *)
                 exit;
            end;
                //  ID_SystemMenu:AboutProc(dlgWin);//eto esli knopi na caption estja
             // SC_SIZE:  exit;
           end;
     ExitMess:begin(*same.inc, ��� � ������, ��� �������� ������ �� <config.dll> *)
                  SendMessage(DlgWin,wm_COMMAND,Id_MAutoN,0);{LoWord(WPARAM)-ID �� ��� ��� ID_MAutoN- ��������� ������� ��� � ����� LoWord(WParam)}
                  SendMessage(DlgWin,UnReg_Mess,0,0);(*�������-����-UnRegister*)
                  SendMessage(DlgWin,REINIT_MESS,0,0);(*������ ������. �� �������� :-) *)
                  SendMessage(DlgWin,wm_COMMAND,Id_MAutoY,0);(*!!!!!!������������ �����. �� ����������� :-), ���� ���� ������������ *)
                  //*********************************\\
              end;
     UnReg_MEss:begin(*����������� �����. -���� �������*)
                 UnregisterHotKey(dlgWin,ID_HotKey1);(*� ��� ����*)
                 UnregisterHotKey(dlgWin,ID_HotKey2);(*� ��� ����*)
                 UnregisterHotKey(dlgWin,ID_HotKey3);(*� ��� ����*)
                 end;
     Reinit_Mess:begin
     (*��� ��� ���������� � CONFIG.DLL*)
                  WasError:=false;

                     if RegOpenKeyEx(                 (*��������� ����*)
                                       HKEY_LOCAL_MACHINE, (*����� ���������� �������� ��� ����*)
                                       strConfig,  (*���� ������, ���� Software\...*)
                                       0,       (*���������������*)
                                       KEY_READ,(*��� ������*)
                                       key) =ERROR_SUCCESS
               then begin           (*���� ���������� ==>*)
                    RegRes:=Reg_DWord;Len:=sizeOf(UINT);
                    if  RegQueryValueEx(     (*������ *)
                                        KEY,(*����*)
                                        H_Key,(*��� ���� �������?*)
                                        nil,  (*reserved*)
                                         @RegRes,(*��� ������, ������� ������*)
                                         @Root_Key,
                                         @Len)<> ERROR_SUCCESS  (*�����,������� ������*)
                             then WasError:=true 
                             else case Root_Key of
                             0:Root_Key:=HKey_Current_User; (*� ��� ���� *)
                             1:Root_Key:=HKey_Local_Machine;
                             else 
                                  MessageBox(
                                             0,
                                             ^M^M'The application was unable to'^M' read restart option.'^M'So CdTool will use'^M'     HKEY_LOCAL_MACHINE'^M' by default !!!',
                                             'Warning',
                                             mb_IconHand+mb_ApplModal   
                                             );
                             end;
                    // MessageBox(dlgwin,PChar(IntToStr(Root_key)),'',mb_ok);
                    if  RegQueryValueEx(     (*������ *)
                                        KEY,(*����*)
                                        OpenShortCut,
                                        nil,  (*reserved*)
                                         @RegRes,(*��� ������, ������� ������*)
                                         @WMHOT1,
                                         @Len)<> ERROR_SUCCESS  (*�����,������� ������*)
                              then WasError:=true;
                    if  RegQueryValueEx(     (*������ *)
                                        KEY,(*����*)
                                        CloseShortCut,
                                        nil,  (*reserved*)
                                         @RegRes,(*��� ������, ������� ������*)
                                         @WmHot2,
                                         @Len)<> ERROR_SUCCESS  (*�����,������� ������*)
                              then WasError:=true;
                    if  RegQueryValueEx(     (*������ *)
                                        KEY,(*����*)
                                        ExitShortCut,
                                        nil,  (*reserved*)
                                         @RegRes,(*��� ������, ������� ������*)
                                         @WMHot3,
                                         @Len)<> ERROR_SUCCESS  (*�����,������� ������*)
                             then WasError:=true;
                     if  RegQueryValueEx(     (*������ *)
                                        KEY,(*����*)
                                        OpenChar,
                                        nil,  (*reserved*)
                                         @RegRes,(*��� ������, ������� ������*)
                                         @Reg_Char1,
                                         @Len)<> ERROR_SUCCESS  (*�����,������� ������*)
                             then WasError:=true;
                     if  RegQueryValueEx(     (*������ *)
                                        KEY,(*����*)
                                        CloseChar,
                                        nil,  (*reserved*)
                                         @RegRes,(*��� ������, ������� ������*)
                                         @Reg_Char2,
                                         @Len)<> ERROR_SUCCESS  (*�����,������� ������*)
                            then WasError:=true;
                           // MessageBox(dlgWin,PChar(IntToStr(reg_char2)),'',0);
                           // MessageBox(dlgWin,PChar(Chr(reg_char2)),'',0);
                     if  RegQueryValueEx(     (*������ *)
                                        KEY,(*����*)
                                        ExitChar,
                                        nil,  (*reserved*)
                                         @RegRes,(*��� ������, ������� ������*)
                                         @Reg_Char3,
                                         @Len)<> ERROR_SUCCESS  (*�����,������� ������*)
                              then WasError:=true;
                              
                         RegCloseKey(key);

                     end
                     else //if �������� ���.�����<>ERROR_SUCCESS
                          begin
                           (*����� ������-��� ������ ������ �����, ��� ���� ���� ������� ���������������*)
                          (*����� ��������� ��� �� �����-�� ��� ������*)
                          ShowConfigDialog(DlgWin);
                          Exit;
                          end;
                          
                    if WasError then begin
                         MessageBox(DlgWin,'The application was unable'#13'to read config values'#13'SO it will use default values'#13'You can see them in the config dialog!','WARNING',mb_IconHand);
                         Root_key:=HKey_Local_Machine;
                         WmHot1:=mod_Alt;
                         WmHot2:=mod_Alt;
                         WmHot3:=mod_Alt+mod_Control;
                          Reg_Char1:=vk_Prior;
                          Reg_Char2:=vk_Next;
                          Reg_Char3:=ord('X');
                  end;
                  SendMessage(DlgWin,Reg_Mess,0,0); (*�� �����.- ����������� �������*)
                  
                 GetShortCut(MenuStr,wmHot1);
                   ModifyMenu(Menu,ID_MOpen,MF_STRING,ID_MOpen,PChar('&Open CdRom'#9+'('+MenuStr+GetChar(Reg_Char1)+')'));
                 GetShortCut(MenuStr,wmHot2);
                   ModifyMenu(Menu,ID_MClose,MF_STRING,ID_MClose,PChar('&Close CdRom'#9+'('+MenuStr+GetChar(Reg_Char2)+')'));
                 GetShortCut(MenuStr,wmHot3);
                   ModifyMenu(Menu,ID_MExit,MF_STRING,ID_MExit,PChar('&Exit CdTool'#9+'('+MenuStr+GetChar(Reg_Char3)+')'));
                 end;
                
    end;
    Result:=false;(*���� �� ����� , ����� ��� ����� ������ 8-) *)

 end;



var ErrCode: MCIERROR;                  (*Added by Sanja*)
    ErrStr: Array[0..128 +40] of Char;  (*Added by Sanja*)

begin
(*Sanja:��������� ��� ��������:->������������ ����� ���������. ������, ���� ������������ ��������� ��������!*)
  WM_MYTrayIcon:=RegisterWindowMessage(str_Message);
        if WM_MYTrayIcon = 0 then (*���� �������� *)
        begin
          MessageBox(0, 'Cannot register Windows message.','CDTool - system error', MB_APPLMODAL + MB_OK);
          Exit;
        end;

  MyTag.dwCallBack:=0; (*�� ������...*)
  MyTag.lpstrDeviceType:='CDAudio'; (*��� ����������: ������ � �������� ��� �� system.ini*)
  FFlags:=//mci_notify or{����� ��� �� ����(� ���� ������) }
          mci_open_type or mci_open_shareable;(*��� �� ��� "���������" *)

        //Sanja: ���� ���������� ������
  ErrCode := mciSendCommand(
                0, (*�� ������������*)
                mci_Open,(*������ ��������� ��� ����������� ������������� :-)*)
                FFlags,(*�����*)
                Cardinal(@MyTag)(*����� ,�� �� ���� ��������*)
                );

       if ErrCode = 0 then  (*<---:Sanja*)
        // ������ ���, ���������� ������
        begin
           SetParms.dwCallback :=0;(*���� �� ����..*)
       //Creates the Dialogbox
       DialogBox(
                    hInstance,(*���� ��������*)
                     STR_MAINDLG, (*��� �� ��� ������ , ��� � ����� �����*)
                      0,          (*��� �� ����,��������� � ��� ����*)
                       @MainDialogProc (*����� CallBack-a *)
                       );
        end
        else
        begin
        //Sanja:---> ���� ������, ������� ��������� � �������� ������
           mciGetErrorString(ErrCode, ErrStr, SizeOf(ErrStr));(*�������� ������ ������*)
           lstrcat(ErrStr, ^M^M'Application will be closed.'); (*��������*)
           MessageBox(0, ErrStr, 'CDTool - MCI Error', MB_APPLMODAL + MB_OK)(*����!!!!!������-����-����!*)
        end;

end.
