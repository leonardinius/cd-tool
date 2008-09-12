unit CONCONSTS;

interface
Uses Windows,Messages;
Const
{строки для определения хоткея(by Pos function).}
{Do not remove unfilled places here!!!!!! SEE BELOW}

ALT=' ALT ';(*здесь специально оставлены пробелы,*)
SHIFT=' SHIFT ';(* чтобы потом можно было определить *)
CTRL=' CTRL ';  (*эти строки POS функцией*)
PGDWN=' PGDWN ';
PGUP=' PGUP ';
{строки для определения хоткея(by Pos function).}
{Do not remove unfilled places here!!!!!!}
CHARS:array [1..26]of  STRING[3]= (*это  строки-массивы(в принципе  это равно массив[0..3]of byte, где первый символ вроде используется для внутреннего представления строкиБ то есть используется Дельфи при выделении памяти,ведения счётчика ссылок, или что-то подобное :-)*)
                (       (*здесь буквы*)
' Q ',' W ',' E ',      (**)
' R ',' T ',' Y ',      (**)
' U ',' I ',' O ',      (**)
' P ',' M ',' N ',      
' A ',' S ',' D ',      (**)
' F ',' G ',' H ',      (**)
' J ',' K ',' L ',      (**)
' Z ',' X ',' C ',
' V ',' B '
                );      (*почти всё кроме цифр*)
  {запятые и т.д. вроде не работают, советую исполюзовать chars}                                              
 VAR
 WasError:boolean;(*очень полезная переменная- когда ЭРРОР ставится в "правду"*)

// procedure showmessage_(const Message:PChar);       (*это так-для теста*)
 procedure ErrorMessage(const Message,Tittle:PChar); (*а это для дела- ЭРРОРЫ выдавать*)
                                                     (*ведет учет состояния WasError- ставит его в правда*)
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
