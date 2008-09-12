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
  Убедительная просьба -прежде чем что-либо изменять,хотя бы комментарии почитать,
  чтобы я хотя бы не зря это писал :-)
 !!!!!!!!! те строки, которые помечены <Sanja> были исправлены, написаны или подсказаны
           автором сайта www.pascal.times.lv
           (Александр Грищенко( очень надеюсь я правильно напечатал фамилию) 
 *)
{******************************************************************************
 Советую: для компиляции используйте <make.bat>- он компилирует <dialog.rc> и саму прогу
 Можно использовать TRegistry  тогда будет легче, но размер проги сразу вырастает на 40 кб.
 Он исполюзует SYSUTILS:---> поэтому на 40.
 А вот если подключить runtime library- Sysutils, просто так, без Registry, то сразу лучше прогу
 выбросить,так ресурсов жалко( меня лично бесят(извините за жаргонизм) проги, которые написаны с
 VCL и :--> огромны :-) и висят на systray-e, жрут ресурсы таких маломощных компов как мой.)
 Хотя можно будет рассматривать Exceptions(жаль что в блоке try except end; не предусмотрен
 другои удобный вид рассмотра эрроров).
                                     
 ******************************************************************************}
program CDTool;
{$R Dialog.res} //dialog resource here
{$R *.Res}      //all another resources here
{$A+}

uses
  Windows, Messages,(* SAnja: убедил, что лучше всё же пользоваться константами:-) *)
  MMSystem ,  
  ShellApi ;

  {$I consts.inc}
  {$I same.inc}
  {$I about.inc}
  //ROOT_KEY = HKEY_CURRENT_USER;
var  ROOT_KEY :THandle= HKEY_LOCAL_MACHINE;
const
  {SANJA:этот ключ помог "сделать" Александр,до этого был только HKey_Current_User
  из-за моей ошибки с WinApi}
  str_MainDlg  = 'CDTool';  { String=Caption }

 str_Message  = 'MYCDTOOLREGMESS' ; {это строка для регистрации моего сообщения от иконки
                                     на systray. это делает " RegisterWindowMessage"  function
                                     и присваевается переменой (значение сообщения)WM_MYTrayIcon}
strReg:PChar = 'SoftWare\Microsoft\Windows\CurrentVersion\Run'; 
                                                   (*
                                                     тот ключ, в котором будет
                                                    сохранен путь к проге, для Автозагрузки
                                                    проги вместе с Windows 
                                                    *)


ErrorRegHotKey=Bool(0);

var
  MyTag: TMCI_Open_Parms;  {структра с инфо, которая нужна "mci_open" комманде, то есть для получения доступа к этому устройству}
  SetParms: TMCI_Set_Parms; {--"--(тоже самое)толбко для установки свойств устройства}
  FFlags:Cardinal;          {Флаги для установки состояния СиДи }
  Data:TNotifyIconData;     {рекорд, нужный для помещения иконки в systray}
  WM_MYTrayIcon:LongWord=0; {переменная для самого сообщения от иконки-щелчок ...}
  Menu:Hmenu;               {менюшка в Syse}
  once:boolean=true;        {боолеан, для тупого способа НЕ ПРОРИСОВКИ
                                   диалога в первый раз, т.к. вначале
                                   WM_INITDIALOG  а потом WM_PAINT  :-)}
 WMHOT1,WMHOT2,WMHOT3:Uint;
REG_CHAR1,REG_CHAR2,REG_CHAR3:UInt;
MenuStr:PChar;

 procedure ShowConfigDialog(Parent:THandle);stdcall;external 'Config.dll';(*ф-ия конфига*)
//Main procedure-opens CD-Rom:-|

procedure NotifyCdRom(Operation:Cardinal);near;
begin
 mciSendCommand(                   {*******ПОСЫЛАЕТ сообщение устройству****************}
                MyTag.wDeviceId,   {*******идентификатор устройства*********************}
                 mci_set,          {*******говорит что требуется устаовка свойств*******}
                 Operation ,       {*******посылает значение операции*******************}
                 Longint(@SetParms){******адрес записи для установки, но по типу Лонгинт}
                 );                {****************************************************}
(*
смотрите код ниже как альтернативу вышенаписанному
Тогда не надо "открывать" устройство и т.д.
Только вроде он медленее, т.к. вызывает всё тот же код:->
:-> mciSendString
ЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁЁ
Этот код(с мциСендКомманд и с этим открытием взят
из CDEvents- компонкнт такой
*)
//******************************************************************//
//      mciSendString('set cdaudio door open',nil,0,0);             //
//      mciSendString('set cdaudio door closed',nil,0,0);           //
// Пояснения смотрите в Хэлпе :-)                                   //
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
 Else MenuStr:='' ;{всякий запасной}
 end;
end;
function GetChar(const Char:Integer):PChar;
var CH_:String;
begin
Case Char of
vk_Prior:Result:='PgUp';
vk_Next:Result:='PgDwn';
Else begin
     ch_:=Chr(byte(Char));  //если не хотите Runtime Error :--->не меняйте это
     Result:=PChar(ch_);    //
     end;
end;
end;

FUNCTION MainDialogProc {Callback Function-сама Виндовс вызывает}
                        (DlgWin     : hWnd ; {дескриптор}
                         DlgMessage : UINT;  {сообщение}
                         DlgWParam  : WPARAM ;{дополн. инфо}
                         DlgLParam  : LPARAM)(*дополн. инфо*)
                                                : BOOL;(*результат*)STDCALL;(*вид помещения данных в регистре,принятый в Виндовс*)

 const temp:PChar='CdTool';(*временное значение*)
 var
    Len:Integer; (*длина значения ключа в регистре*)
    str:string;  (*само значение*)
    PT:TPoint;   (*переменная для того,чтобы знать где показывать меню*)
    KEY:hKeY;    (*перемю-Handle для ключа, где Атозагрузка*)
    RegRes:Dword;(*использован в нескольких местах, по разному*)
    WasError:boolean;(*used in REINIT_MESS для определения надо ли Дефаулт Валуе*)

 begin
Result:=true;
    if dlgMessage =WM_MYTrayIcon then (*если сообщения от иконки*)
    case DlgLParam of
       WM_RBUTTONDOWN:                (*например,правая клава мышки*)
            begin
               GetCursorPos(pt);      (*где? координаты?*)

               if RegOpenKeyEx(                 (*открываем ключ*)
                                       ROOT_KEY,(*HKey_Current_User*)
                                       strReg,  (*путь дальше, типа Software\...*)
                                       0,       (*зарезервировано*)
                                       KEY_READ,(*для чтения*)
                                       key) = ERROR_SUCCESS
               then begin           (*если получилось ==>*)
                   RegRes:=REG_SZ;  (*читать будем строку*)
                        RegQueryValueEx(
                                         KEY, (*ключ,который уже открыт*)
                                        temp,(*PChar('CdTool')*)
                                        nil, (*зарезервировано*)
                                        @RegRes,(*адрес на то,что читать будем сторку*)
                                        nil,    (*адр. где должен быть ответ.Раз nil=> получаем длину*)
                                         @Len);  (*именно сюда мы её и получаем*)
          (*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*)
       SetString(str,nil,len); //Sanja: Выделим место под буфер, куда положим значение
          (*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*)
                   if  RegQueryValueEx(     (*читаем *)
                                        KEY,(*ключ*)
                                        temp,(*'CdTool'*)
                                        nil,  (*reserved*)
                                         @RegRes,(*тип данных, которые читаем*)
                                         @Str[1], {Sanja:ВОТ ОШИБКА! -> PByte(str)}(*Я:из-за этого был глюк*)
                                         @Len)   (*длина,сколько читаем*)
                                              =Error_Success
                   then begin (*если удачно*)
                         SetLength(str,lStrLen(PChar(str)));(*получаем полноценную строку,для проверки*)
                         //MessageBox(dlgWin,PChar(str),'',mb_ok);  //bilo dlja proverki
                         if str=ParamStr(0) then
                            begin                            (*если равно к пути к проге(а насре волнуют другие копии проги)*)
                               EnableMenuItem(menu,ID_MAutoY,mf_Grayed);(*меняет доступность пункта в меню*)
                               EnableMenuItem(menu,ID_MAutoN,mf_Enabled);(*меняет доступность пункта в меню*)
                            end
                            else begin                       (*если не равно к пути к проге*)
                               EnableMenuItem(menu,ID_MAutoN,mf_Grayed);(*меняет доступность пункта в меню*)
                               EnableMenuItem(menu,ID_MAutoY,mf_Enabled);(*меняет доступность пункта в меню*)
                            end;
                         end
                   Else begin (*если неудачно получили значение ,например его нету:-)*)//<> Eroor_Success
                      EnableMenuItem(menu,ID_MAutoN,mf_Grayed); (*меняет доступность пункта в меню*)
                      EnableMenuItem(menu,ID_MAutoY,mf_Enabled);(*меняет доступность пункта в меню*)
                   end;
               end

               // --> Если ключ открыть не удалось, то:
               else begin
                  EnableMenuItem(menu,ID_MAutoN,mf_Grayed);(*меняет доступность пункта в меню*)
                  EnableMenuItem(menu,ID_MAutoY,mf_Enabled);(*меняет доступность пункта в меню*)
               end;

               TrackPopupMenuEx(    (*показывает меню в какой-то точке*)
                     GetSubmenu(Menu,0),(*получает смещение нужного мне меню*)
                     tpm_LeftAlign,     (*св-ва расположения меню*)
                     pt.x,              (*координата Х*)
                     pt.y,              (*координата У*)
                     dlgWin,            (*дескриптор диалога*)
                     nil                //ne pomnju,nado v HELPE pogljadet
                            );
            end;

       WM_LBUTTONUP:
        (*реакция на событие:--> щелчок левой клавы мыши*)
         //messagebox(0,'','',0);
            ShowWindow(dlgWin,sw_show); (*показываем диалог*)
    end;(*конец-если сообщение от мыши*)

   case  DLGMessage
   of
    WM_PAINT:
          begin
               if  once
               then
                   begin
                      ShowWindow(dlgWin,sw_hide); (*прячет диалог-фиговый метод:--->(<BLINKING>)*)
                      once :=false;(*в след. раз будет прорисовка*)
                      result:=true;
                      exit;
                   end
               else
                   DefWindowProc(DlgWin, WM_PAINT,0,0);(*Умалчиваемая процедура окна*)
          end;

    wm_InitDialog: (*при загрузке диалога*)
          begin
                 Menu:=LoadMenu(hInstance,'MYPOPUP'); (*загр. из ресурсов меню*)
                 SetWindowLong (          (*делаем,чтобы снизу ничего не маячило*)
                                dlgWin,  (*ID*)
                                GWL_ExSTYLE,(*ставим новые флаги-свойства *)
                                WS_EX_TOOLWINDOW  and  not WS_EX_APPWINDOW or WS_EX_TOPMOST);(*какие конкретно*)
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
этот код сверху нужен, если на диалоге есть кнопы(систем.)
*)
  with Data do begin
                      cbSize:=Sizeof(data);(*размер самой записи*)
                      szTip:='This is a tool to open-close CdRom';(*Всплыв. подсказка*)
                      uFlags:=Nif_Message or Nif_Icon or nif_Tip ;(*Флаги для вставки иконки*)
                      uId:=ID_SYSICON; (*ID иконки*)        
                      wnd:=dlgWin;//HWND
                      uCallBackMessage:=WM_MYTrayIcon;(*Сообщение в окно*)
                      hIcon:=LoadIcon(hInstance,'MAINICON');(*иконка*)
                          Shell_NOtifyIcon(nim_Add,@data);(*сама ф-ия *)                                                                               
                 end;
               SendMessage(DlgWin,ReINIT_Mess(*моё,родное,сам объявил*),0,0); (*сообщение-в ответ на это считывает значения из регистра, потом посылает сообщениеБ в ответ на кот.-регистрация ХотКеев*) 
             end;
REG_MESS: begin      (*Дело в том, что как только в блоке ИФ выполняется условиеб, то следует выход из блока*)
                      (*:=====> вставил WasError*)  
                  WasError:=false;
                   //messageBox(0,PChar(IntToStr(wmhot1)+^M+IntToStr(wmhot2)+^M+IntToStr(wmhot3)+^M+IntToStr(reg_char1)+^M+IntToStr(reg_char2)+^M+IntToStr(reg_char3)+^M),'',0);
                 if RegisterHotKey(dlgWin,ID_HotKey1,{mod_Alt,33}wmHot1,Reg_Char1)=ErrorRegHotKey then WasError:=true;(*если кто-то уже заразервировал эти клавы*)
                 if RegisterHotKey(dlgWin,ID_HotKey2,{mod_Alt,34}wmHot2,Reg_Char2)=ErrorRegHotKey then WasError:=true;(*то покажем фигу,они пока работать не будут у него*) 
                 if RegisterHotKey(dlgWin,Id_HotKey3,{mod_alt,88}wmHot3,Reg_Char3)=ErrorRegHotKey then WasError:=true;
                  (*wmHot1..3 and Reg_Char1..3 are read from registry*)
                  if WasError (*был ЭРРОР , Г А Д Ы , шутка, вы этого не видели :-) *)
                 then MessageBox( (*даем увидеть это *)                                      
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
                    
    wm_HotKey:       (*Клавы , "горячие" жали?*)
          case dlgWParam of (*а какую?*)
             ID_HotKey2:  //opens CD
                 NotifyCdRom(mci_set_door_Closed);
             ID_HotKey1: //Closes CD
                 NotifyCdRom(mci_set_door_open);
             ID_HotKey3:
                  SendMessage(DlgWin, WM_SYSCOMMAND, SC_CLOSE, 0);(*Александр: посоветовал всё же использовать сообщения*)
         end;//  WM_HOTKEY

   WM_COMMAND:
        CASE LOWOrd(DlgWParam) OF
         (*реакция на менюшки и на кнопы на диалоге*)
            Id_CDOpen  :  NotifyCdRom(mci_set_door_open);(*диалог-кнопа открыть*)
            Id_CdClose :  NotifyCdRom(mci_set_door_closed);(* то же,но закр.*)
            Id_Close   :  ShowWindow(dlgWin,sw_Hide);     (*то же,но свернуть*)
            Id_MAbout  :  AboutProc(DlgWin); (*ф-ия in SAME.INC*)(*да эта BMP-шка весит до .....*)  //menu in systray about
            Id_MExit   :  SendMessage(DlgWin, WM_SYSCOMMAND, SC_CLOSE, 0);(*Александр*)
            ID_MOpen:   NotifyCdRom(mci_set_door_open);
            Id_MClose:  NotifyCdRom(mci_set_door_closed);
            Id_MAutoY:
            begin (*"Делает" рестарт с Виндосой---менюшка*)
                 (*Sanja: выкинул лишнюю дребедень+ флага*)
                 if RegCreateKeyEx(ROOT_KEY,(*посмотрите или в Хэлпе или Config.dll*)
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
                    (*посмотрите или в Хэлпе или Config.dll*)
                   RegSetValueEx(key,PChar('CdTool'),0,REG_SZ, PChar(ParamStr(0)),
                      //Александр: --> ОШИБКА {sizeof(PChar(ParamStr(0)))});
                      Length(ParamStr(0)));
                   RegCloseKey(key);
                    end
               else
                (*Да надоели эти ЭРРОРЫ , даже открыть не удалось , даём знать об таком оскорблении*)
                 MessageBox(0,
                            'The apllication was not able to create autorun key '+#13+
                            'for you, so it will not be able to restart with Windows.'+#13+
                            'Try to restart application or retry the last operation!' ,
                              'Application Error',
                             MB_OK+ MB_APPLMODAL
                             );
            end;

           Id_MAutoN: (*"Анти Делает" рестарт с Виндосой---менюшка*)
            begin      (*Александр: оптимизация *)
            (*пояснения -выше *)
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

      wm_SysCommand:  (*системные комманды*)
           case DlgWParam of
            SC_CLOSE: (*закрываемся*)
            begin
                 Shell_NOtifyIcon(nim_delete,@data);(*удаляемся в syse*)
                 SendMessage(DlgWin,UnReg_MEss,0,0); (*посылаем объявл. нами сообщение- надо закругляться с этими ХотКеями*)
                 EndDialog(DlgWin, LOWORD(DlgWParam));(*точно закрываемся*)
                 result:=true;(*а может и не надо *)
                 exit;
            end;
                //  ID_SystemMenu:AboutProc(dlgWin);//eto esli knopi na caption estja
             // SC_SIZE:  exit;
           end;
     ExitMess:begin(*same.inc, как и другие, его посылает диалог из <config.dll> *)
                  SendMessage(DlgWin,wm_COMMAND,Id_MAutoN,0);{LoWord(WPARAM)-ID но так как ID_MAutoN- настолько малбчто это и будет LoWord(WParam)}
                  SendMessage(DlgWin,UnReg_Mess,0,0);(*ХотКеям-каюк-UnRegister*)
                  SendMessage(DlgWin,REINIT_MESS,0,0);(*читаем значен. из регистра :-) *)
                  SendMessage(DlgWin,wm_COMMAND,Id_MAutoY,0);(*!!!!!!регистрирует незав. от предыдущего :-), лень было обрабатывать *)
                  //*********************************\\
              end;
     UnReg_MEss:begin(*пресловутое сообщ. -каюк ХотКеям*)
                 UnregisterHotKey(dlgWin,ID_HotKey1);(*И так ясно*)
                 UnregisterHotKey(dlgWin,ID_HotKey2);(*И так ясно*)
                 UnregisterHotKey(dlgWin,ID_HotKey3);(*И так ясно*)
                 end;
     Reinit_Mess:begin
     (*что где посмотрите в CONFIG.DLL*)
                  WasError:=false;

                     if RegOpenKeyEx(                 (*открываем ключ*)
                                       HKEY_LOCAL_MACHINE, (*будут одинаковые значения для всех*)
                                       strConfig,  (*путь дальше, типа Software\...*)
                                       0,       (*зарезервировано*)
                                       KEY_READ,(*для чтения*)
                                       key) =ERROR_SUCCESS
               then begin           (*если получилось ==>*)
                    RegRes:=Reg_DWord;Len:=sizeOf(UINT);
                    if  RegQueryValueEx(     (*читаем *)
                                        KEY,(*ключ*)
                                        H_Key,(*для кого рестарт?*)
                                        nil,  (*reserved*)
                                         @RegRes,(*тип данных, которые читаем*)
                                         @Root_Key,
                                         @Len)<> ERROR_SUCCESS  (*длина,сколько читаем*)
                             then WasError:=true 
                             else case Root_Key of
                             0:Root_Key:=HKey_Current_User; (*и так ясно *)
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
                    if  RegQueryValueEx(     (*читаем *)
                                        KEY,(*ключ*)
                                        OpenShortCut,
                                        nil,  (*reserved*)
                                         @RegRes,(*тип данных, которые читаем*)
                                         @WMHOT1,
                                         @Len)<> ERROR_SUCCESS  (*длина,сколько читаем*)
                              then WasError:=true;
                    if  RegQueryValueEx(     (*читаем *)
                                        KEY,(*ключ*)
                                        CloseShortCut,
                                        nil,  (*reserved*)
                                         @RegRes,(*тип данных, которые читаем*)
                                         @WmHot2,
                                         @Len)<> ERROR_SUCCESS  (*длина,сколько читаем*)
                              then WasError:=true;
                    if  RegQueryValueEx(     (*читаем *)
                                        KEY,(*ключ*)
                                        ExitShortCut,
                                        nil,  (*reserved*)
                                         @RegRes,(*тип данных, которые читаем*)
                                         @WMHot3,
                                         @Len)<> ERROR_SUCCESS  (*длина,сколько читаем*)
                             then WasError:=true;
                     if  RegQueryValueEx(     (*читаем *)
                                        KEY,(*ключ*)
                                        OpenChar,
                                        nil,  (*reserved*)
                                         @RegRes,(*тип данных, которые читаем*)
                                         @Reg_Char1,
                                         @Len)<> ERROR_SUCCESS  (*длина,сколько читаем*)
                             then WasError:=true;
                     if  RegQueryValueEx(     (*читаем *)
                                        KEY,(*ключ*)
                                        CloseChar,
                                        nil,  (*reserved*)
                                         @RegRes,(*тип данных, которые читаем*)
                                         @Reg_Char2,
                                         @Len)<> ERROR_SUCCESS  (*длина,сколько читаем*)
                            then WasError:=true;
                           // MessageBox(dlgWin,PChar(IntToStr(reg_char2)),'',0);
                           // MessageBox(dlgWin,PChar(Chr(reg_char2)),'',0);
                     if  RegQueryValueEx(     (*читаем *)
                                        KEY,(*ключ*)
                                        ExitChar,
                                        nil,  (*reserved*)
                                         @RegRes,(*тип данных, которые читаем*)
                                         @Reg_Char3,
                                         @Len)<> ERROR_SUCCESS  (*длина,сколько читаем*)
                              then WasError:=true;
                              
                         RegCloseKey(key);

                     end
                     else //if открытие рег.ключа<>ERROR_SUCCESS
                          begin
                           (*будем думать-это первый запуск проги, или инфо было удалено злоумышлениками*)
                          (*будет надеяться это не какой-то вид Эррора*)
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
                  SendMessage(DlgWin,Reg_Mess,0,0); (*моё сообщ.- регистрация ХотКеев*)
                  
                 GetShortCut(MenuStr,wmHot1);
                   ModifyMenu(Menu,ID_MOpen,MF_STRING,ID_MOpen,PChar('&Open CdRom'#9+'('+MenuStr+GetChar(Reg_Char1)+')'));
                 GetShortCut(MenuStr,wmHot2);
                   ModifyMenu(Menu,ID_MClose,MF_STRING,ID_MClose,PChar('&Close CdRom'#9+'('+MenuStr+GetChar(Reg_Char2)+')'));
                 GetShortCut(MenuStr,wmHot3);
                   ModifyMenu(Menu,ID_MExit,MF_STRING,ID_MExit,PChar('&Exit CdTool'#9+'('+MenuStr+GetChar(Reg_Char3)+')'));
                 end;
                
    end;
    Result:=false;(*если мы хотим , чтобы был виден диалог 8-) *)

 end;



var ErrCode: MCIERROR;                  (*Added by Sanja*)
    ErrStr: Array[0..128 +40] of Char;  (*Added by Sanja*)

begin
(*Sanja:добавлена эта проверка:->Регистрируем новое сообщение. Кстати, надо обрабатывать ошибочную ситуацию!*)
  WM_MYTrayIcon:=RegisterWindowMessage(str_Message);
        if WM_MYTrayIcon = 0 then (*если неудачно *)
        begin
          MessageBox(0, 'Cannot register Windows message.','CDTool - system error', MB_APPLMODAL + MB_OK);
          Exit;
        end;

  MyTag.dwCallBack:=0; (*на всякий...*)
  MyTag.lpstrDeviceType:='CDAudio'; (*тип устройства: список в регистре или же system.ini*)
  FFlags:=//mci_notify or{вроде нам не надо(в этой версии) }
          mci_open_type or mci_open_shareable;(*как мы его "открываем" *)

        //Sanja: Надо обработать ошибки
  ErrCode := mciSendCommand(
                0, (*не используется*)
                mci_Open,(*делаем доступным для програмного вмешательства :-)*)
                FFlags,(*флаги*)
                Cardinal(@MyTag)(*адрес ,но по типу Кардинал*)
                );

       if ErrCode = 0 then  (*<---:Sanja*)
        // Ошибок нет, продолжаем работу
        begin
           SetParms.dwCallback :=0;(*Мало ли чего..*)
       //Creates the Dialogbox
       DialogBox(
                    hInstance,(*наша Инстанце*)
                     STR_MAINDLG, (*Как мы его назовём , так и звать будем*)
                      0,          (*нам не надо,родителей у нас нету*)
                       @MainDialogProc (*адрес CallBack-a *)
                       );
        end
        else
        begin
        //Sanja:---> Была ошибка, выведем сообщение и завершим работу
           mciGetErrorString(ErrCode, ErrStr, SizeOf(ErrStr));(*получаем строку ошибки*)
           lstrcat(ErrStr, ^M^M'Application will be closed.'); (*копируем*)
           MessageBox(0, ErrStr, 'CDTool - MCI Error', MB_APPLMODAL + MB_OK)(*Люди!!!!!Эррррр-рррр-оррр!*)
        end;

end.
