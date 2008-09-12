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
 FUNCTION MainDialogProc {Callback Function-сама Виндовс вызывает}
                        (DlgWin     : hWnd ; {дескриптор}
                         DlgMessage : UINT;  {сообщение}
                         DlgWParam  : WPARAM ;{дополн. инфо}
                         DlgLParam  : LPARAM)(*дополн. инфо*)
                                                : BOOL;(*результат*)STDCALL;Far;(*вид помещения данных в регистре,принятый в Виндовс*)


TYPE
_str_=string[8];//тип- строка[8] 
 VAR
  KEY:hKeY;    (*перем-Handle для ключа, где Атозагрузка*)
 RegRes:Dword;(*использован в нескольких местах, по разному*)
 Root_Key:THandle;(*для кого будет Рестарт- для одного пльзователя или для машины в целом*)

   buf:array[0..254]of char; (*буффер*)
   Byte_:Integer;            (*значений-255, но по типу Интегер-для сохранения в регистре и регю хоткея*)
   buf_:String;              (*из buf==> переведем в buf_*)
Handle:Integer;              (*handle для посыла сообщен.
                               хотя можно работать с
                               SendDlgItemMessage*)

  i:BYTE;(* переменные для того чтобы иметь  доступ к массиву из строк[3]*)
 WMHOT1,WMHOT2,WMHOT3:integer;(*это для того чтобы сТавить разные клавы в хоткее*)
 HOTSTR1,HOTSTR2,HOTSTR3:string[8];(*строки для определения, может одинаковые хоткеи, а 7,т.к.<PGDWN>=7символов+1 терминальный нуль(?)-иначе просто не идёт)*)
 Place1,Place2:byte;(*это для того чтобы найти место положения ПагеДВН и ПагеАП для становления им одинакового приоритета*)
 begin
 result:=true;
Case
DlgMessage of
   WM_INITDIALOG:BEGIN
                   Handle:=GetDlgItem(DlgWin,ID_MACHINE_RADIO); (*получаем Хэндл*)
                   SendMessage(Handle,BM_SETCHECK,BST_CHECKED,0);(*ставим LocalMachine в состояние Checked*)
                 END;
   WM_COMMAND:{ALL COMMANDS HERE: like menu or buttons pushes}
              case LOWOrd(DlgWParam) of
              ID_APPLY_BUTTON:
                             Begin
                              WasError:=false; {вроде эрроров и не было никогда :-) }
                             (*это для  эдита-где ключи для окрытия СиДи-рома*)
                             WmHot1:=0; //Inits
                             FillChar(buf,sizeof(buf),0); //Inits
                             Handle:=GetDlgItem(dlgWin,ID_OPEN_EDIT); // Хэндл получаем
                             byte_:=SendMessage(Handle,EM_LINELENGTH,-1,0)+1;//получаем длину(? точно не помню)
                             SendMessage(Handle,WM_GETTEXT,byte_,Integer(@buf));(*читаем значение в буффер*)
                             buf[byte_+1]:=#0; (*а где наш терминальный нуль? :-) *)
                             //ShowMessage_(PChar(@buf[1])); {test string}
                             buf_:=' '+ShortString(buf)+' '; (*пробелы-для POS ф-ии, + приведение к типу коротк.строки *)
                             //showmessage_(PChar(buf_));{test string}
                                if pos(ALT,buf_)<> 0 (*если Альт есть, то тогда *)
                                        then wmHot1:=mod_ALt; (*добавляем значение виртуального ключа*)
                                if pos(shift,buf_)<> 0  (*Shift?*)
                                        then wmHot1:=WmHot1+mod_Shift;
                                if pos(CTRL,buf_)<> 0   (*Ctrl? *)
                                        then wmHot1:=WmHot1+mod_Control;
                                        place1:=0;place2:=0;(*Inits-we need for it :-)*)

                                 FillChar(HotStr1,sizeof(HotStr1),0);//inits

                                Place1:= pos(PGUP,ShortString(buf_)); //надо сделать одинаковый приоритет
                                Place2:=pos(PGDWN,buf_); //поэтому получаем место с которого в строке эти гадюки
                                if (Place1<>0)or (Place2<>0)(*если есть -встретились*)
                                        then    (*тогда*)
                                            if ((Place1<Place2)and(Place2>0)and(Place1<>0))or((Place1>Place2)and(Place2=0))
                                              then   (*(если Пласе1 раньше ПЛ2 и Пл1 вообще есть) или (Пл2-нет, а ПЛ1-есть)*)
                                              HotStr1:=pgUp (*значит есть ПагеАп*)
                                              else
                                              HotStr1:=PGDWN  (*иначе ПагеДоун*)
                                        else (*if PGUP or PGDWN not found*)
                                        
                                        FOR  i:=1 to 26 (*проверяем весь массив*)
                                        do
                                        if pos(Chars[i],buf_)<>0 (*нашли!!!!!!!*)
                                        then begin
                                             HOTStr1:=_Str_(Chars[i]);(*читаем *)
                                             break;(*зачем ресурсы компа тратить- выход из Loop*)
                                             end;
                                            //showmessage_(PChar(@hotstr1[1])); (*тэст*)
                              if HotStr1='' then ErrorMessage('The hotkey needs for pressing chars','The script "compile" error!');
                              if WmHot1=0 then   ErrorMessage(' Hotkey needs for pressed'#13' system buttons like-'+ALT,'The script compile error!');
                           (*выше обработка возможных недочётов *)
            (*
              НИЖЕ ТОЖЕ САМОЕ ДЛЯ НО ДЛЯ 2-ГО ЭДИТА
              ОПИСЫВАТЬ НЕ БУДУ- СМОТРИТЕ ВЫШЕ
              В ПРИНЦИПЕ-ВСЁ ТО ЖЕ САМОЕ-
              Я КОПИРОВАЛ И МЕНЯЛ ИНДЕКСЫ :-)                                                           
              *)                                                      
                                                                  
                             (*это для закрытия СиДи-Рома*)
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


                                Place1:= pos(PGUP,ShortString(buf_)); //надо сделать одинаковый приоритет
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
              НИЖЕ ТОЖЕ САМОЕ ДЛЯ НО ДЛЯ 2-ГО ЭДИТА
              ОПИСЫВАТЬ НЕ БУДУ- СМОТРИТЕ ВЫШЕ
              В ПРИНЦИПЕ-ВСЁ ТО ЖЕ САМОЕ-
              Я КОПИРОВАЛ И МЕНЯЛ ИНДЕКСЫ :-)                                                           
              *)         
                            (*это для закрытия проги:-)*)

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


                                Place1:= pos(PGUP,ShortString(buf_)); //надо сделать одинаковый приоритет
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
                   
                      (*ГЛОБАЛЬНАЯ ПРОВЕРКА :-) *)
                         if WasError then   (*ВЫ ЕЁЕ ПОМНИТЕ ЗАЧЕМ ЭТО БЫЛО НУЖНО? 8-) *)
                                    ErrorMessage(^M^M'Some errors occured while application'^M'    tryed to compile the script!!!'^M+'Rewrite shortcuts you want to use!!!','"SCRIPT" ERROR!!!')
                    (*МОЖЕТЕ РАЗКОМЕНТИРОВАТЬ СЛЕД. СТРОКУ ЕСЛИ ХОТИТЕ ЗНАТЬ, ЧТО БУДЕТ ПРИМЕНЕНО*)
                                    else  //MessageBox(DlgWin,PChar(String('The following chars will be applayed!!'+^M+'    '+HotStr1+^M+'    '+HotStr2+^M+'    '+HotStr3)),'SEE THIS!!',mb_IconQuestion)
                                       ;
 (*ВЫ НЕ ПОДУМАЙТЕ- У МЕНЯ НЕ СЛУЧАЙНО CAPSLOCK БЫЛ ВРУБЛЕН :-) *)
if  WasError=false then (*У НАС ЭРРОРОВ НЕ БЫЛО*)
begin
 Handle:=GetDlgItem(DlgWin,ID_USER_RADIO); (*та же история, проще послать SendDlgItemMessage-см.Хэлп.*)
 IF SendMessage(Handle,BM_GETCHECK,0,0)=BST_CHECKED (*ну что мы выбрали?*)
  THEN ROOT_KEY:=0         (*А-а-а-а-а-а-!*)
  ELSE ROOT_KEY:=1; 
                         
                      if RegCreateKeyEx(HKEY_LOCAL_MACHINE,
                                   strConfig,(*где мы будем хранить наши значения*)
                                   0,
                                   nil,
                                   REG_OPTION_NON_VOLATILE,(**это-что то про то как будут изменены значения - вроде не будут в памяти храниться, а сразу на жесткий*)
                                   Key_Write,              (*писать будем, Ха-Ха-Ха*)
                                    NIL,
                                    key,                  (*где у нас Дескриптор будет*)
                                    @RegRes              (*нам не надо- а так говорит было ли открыто или создано*)
                                    ) = ERROR_SUCCESS
                then
                    begin(*если удачно то продолжим*) 
                   RegSetValueEx(key,OpenShortCut,0,REG_DWORD,@WMHOT1,sizeof(Integer));(*сохраняем виртуальные клавы для открытия СиДи*)
                   RegSetValueEx(key,CloseShortCut,0,REG_DWORD,@WMHOT2,sizeof(Integer));(*закрытия*)
                   RegSetValueEx(key,ExitShortCut,0,REG_DWORD,@WMHOT3,sizeof(Integer)); (*выхода из проги*)
                       if HotStr1=PGUP then byte_:=vk_Prior else(*или ЭТИ *)
                       if HotStr1=PGDWN then byte_:=vk_Next else
                       byte_ :=ord(HotStr1[2]);         (*или char :-)*)
                   RegSetValueEx(key,OpenChar,0,REG_DWORD,@Byte_,sizeof(Integer));(*клава для открытия СиДи*)
                       if HotStr2=PGUP then byte_:=vk_Prior else                 (*и так всё понятно :-) , надеюсь*)
                       if HotStr2=PGDWN then byte_:=vk_Next else                (*если нет-см. выше*)
                       byte_ :=ord(HotStr2[2]);
                   RegSetValueEx(key,CloseChar,0,REG_DWORD,@Byte_,sizeof(Integer)); (*закрытия СиДи*)
                       if HotStr3=PGUP then byte_:=vk_Prior else
                       if HotStr3=PGDWN then byte_:=vk_Next else
                       byte_ :=ord(HotStr3[2]);
                       
                   RegSetValueEx(key,ExitChar,0,REG_DWORD,@Byte_,sizeof(Integer));(*выхода из проги *)
                   RegSetValueEx(key,H_KEY,0,REG_DWORD,@ROOT_KEY,sizeof(DWORD));

                      RegCloseKey(key);   (*закрываем здесь, так как открылось- иначе ERROR*)
                      SendMessage(Owner,ExitMess,0,0);(*посылаем сообщение в СиДиТул-CdTool- так как при создании его Дескриптор приравнивается Owner-у, я пробовал WM_PARENTNOTIFY, НО ЧТО-то не пошло у меня*)
                      SendMessage(DlgWin,WM_SYSCOMMAND,SC_CLOSE,0);
                    end
               else (*Ой, не люблю я эти проверки, эти ЭРРОРЫ*)
                    ErrorMessage('The application was unable to'^M+ 'save youк chosen settings.'^M+'Exit the application and'^M+' then retry that you did!','System registry ERROR!');

                        WasError:=false ; (*Занова INIT*)

END;(*If was not error*)
   end;(*End of case of ID_APPLY_BUTTON*)

              ID_HOW_TO   :begin (*почитайте- это полезно :-)*)
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
                            Handle:=getDlgItem(DlgWin,ID_USER_RADIO);  (*меняем CHECKED у радиобаттон, если щелк*)
                            SendMessage(Handle,BM_SETCHECK,BST_CHECKED,0);
                            Handle:=getDlgItem(DlgWin,ID_MACHINE_RADIO);
                            SendMessage(Handle,BM_SETCHECK,BST_UNCHECKED,0);
                            end;
              ID_MACHINE_RADIO:
                            begin                                      (*меняем CHECKED у радиобаттон, если щелк*)
                            Handle:=getDlgItem(DlgWin,ID_MACHINE_RADIO);
                            SendMessage(Handle,BM_SETCHECK,BST_CHECKED,0);
                            Handle:=getDlgItem(DlgWin,ID_USER_RADIO);
                            SendMessage(Handle,BM_SETCHECK,BST_UNCHECKED,0);
                            end;
              end;
   WM_SYSCOMMAND:{we handle system commands here}
               if DlgWParam=SC_CLOSE
               then(*закрываемся*)
            begin
                 EndDialog(DlgWin, LOWORD(DlgWParam));(*точно закрываемся*)
                 result:=true;
                 exit;
         
       end;
   end;
   result:=false; (*если хочешь, чтобы диалог не был виден- это не для тебя :-) *)
 end;

(*!!!!!!!!!!!!!!!!!!!!!!!APP ENTRY POINT HERE!!!!!!!!!!!!!!!!!!!!!!!!!!S*)
 procedure CreateConfigDialog(Parent:THandle); (*а её мы будем вызывать в ДЛЛ.*)
begin
Owner:=Parent;  (*Handle- родителя- для посылки ему  сообщений*)
DialogBox(
                    hInstance,(*наша Инстанце*)
                     PChar(CONFIQ), (*Как мы его назовём , так и звать будем*)
                      Parent,          (*нам  надо,родителей у нас есть*)
                       @MainDialogProc (*адрес CallBack-a *)
                       );
end;
end.
