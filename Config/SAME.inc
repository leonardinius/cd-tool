const
(*ћои сообщени€ без WM_  префикса, чтобы было €сно(мне)- не от системы они*)
EXITMESS            =        WM_USER+209; {посылает CdTool, чтобы та знала,что пора перезагрузить значени€ ’от еев}
REINIT_MESS         =        wm_User+300; { в CdTool- в ответ на это перечитывает значени€ в регистре}
UNREG_MESS          =        WM_USER+301; {убирает зарегестрированные ’ќ“ ≈»}
REG_MESS            =        WM_USER+302; {наоборот ставит(регистрирует их)}
strConfig         : PChar='SoftWare\OpenMindSoft\CdTool\Config'; (*где значени€ настроек сохран€ютс€*)
OpenShortCut       : PChar='OpenShortCut'; {сист. клав. -открытие —иƒи}
CloseShortCut      : PChar='CloseShortCut';{сист. клав. -закрытие —иƒи}
ExitShortCut       : PChar='ExitShortCut'; {сист. клав. -выход из проги}
OpenChar           : PChar='OpenChar';     {клава- открытие —иƒи}
CloseChar          : PChar='CloseChar';    {клава- закрытие —иƒи}
ExitChar           : PChar='ExitChar';     {клава- выход из проги}
H_KEY              : PChar='H_KEY';        {дл€ кого рестарт}
