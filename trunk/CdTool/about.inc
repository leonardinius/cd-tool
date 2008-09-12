{$I aboutcon.inc}
{$R about.res}   
FUNCTION AboutDialogProc {Callback Function-сама Виндовс вызывает}
                        (DlgWin     : hWnd ; {дескриптор}
                         DlgMessage : UINT;  {сообщение}
                         DlgWParam  : WPARAM ;{дополн. инфо}
                         DlgLParam  : LPARAM)(*дополн. инфо*)
                                                : BOOL;(*результат*)STDCALL;Far;(*вид помещения данных в регистре,принятый в Виндовс*)
 begin
 result:=true;
 case DlgMessage of
 wm_initDialog:begin
                 SendDlgItemMessage(DlgWin,ID_About_Bitmap,stm_setImage,IMAGE_ICON,LoadImage(hInstance,'MAINICON',IMAGE_ICON,82,90,LR_LOADMAP3DCOLORS));
               end;
 //wm_paint:// begin
            //DrawIcon(DlgWParam,0,0,LoadIcon(hInstance,PChar('MAINICON')));
             //Handle:=GetDlgItem(DlgWin,ID_ABOUT_BITMAP);
             //SendMessage(DlgWin,stm_SETImage,IMAGE_ICON,LoadIcon(hInstance,PChar(About_Icon)));//,0);//PChar(About_Icon)));

           //end;

 wm_SysCommand:  (*системные комманды*)
           if DlgWParam =  SC_CLOSE  then EndDialog(DlgWin, LOWORD(DlgWParam));
  WM_COMMAND:
        if LOWOrd(DlgWParam)=ID_ABOUT_OK then SendMessage(DlgWin,wm_syscommand,sc_close,0);
      end;
 result:=false;
 end;
procedure aboutProc(Owner:THandle);
begin
DialogBox(
                    hInstance,(*наша Инстанце*)
                     PChar(ID_ABOUTDIALOG), (*Как мы его назовём , так и звать будем*)
                     Owner,
                       @AboutDialogProc (*адрес CallBack-a *)
                       );
end;