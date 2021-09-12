[const]
T = 44;
[var]
R: Integer;
S: string;
D: Byte;
[common]
procedure ShowGold(const G: Integer);
begin
  MsgBox('Gold: ' + IntToStr(G) + ', R=' + IntToStr(R));
end;
[0]
    //Комментарий не должен попадать в исходный код
R := Rand(8, 25);
D := 77;
{$I test2.pas}
HP := 11;
Gold := 123;
ShowGold(Gold);
MsgBox('Здраствуй, ' + Name + '! Что привело тебя ко мне?');
//text &link 2, Покажи, что у тебя есть на продажу&link close, До встречи
//Комментарий не должен попадать в исходный код
//...
[1]
MsgBox(IntToStr(D));
//...
