#import "conf.typ" : conf
// #import "@preview/cetz:0.2.2"
#import "@preview/plotst:0.2.0"
#import "@preview/fletcher:0.4.5" as fletcher: diagram, node, edge

#show: conf.with(
  title: [Lection 4],
  type: "referat",
  info: (
      author: (
        name: [Смирнов],
        faculty: [КНиИТ],
        group: "251",
        sex: "male"
      ),
      inspector: (
        degree: "",
        name: ""
      )
  ),
  settings: (
    title_page: (
      enabled: true
    ),
    contents_page: (
      enabled: true
    )
  )
)

= Команда побитовой обработки данных

Команда:

*xor OP1, OP2 : 1 xor 1 = 0, 0 xor 0 = 0*, в остальном случае = 1 

Например:

(AL) = 1011 0011, маска = 0000 1111

* xor AL, OFh: = 1011 1100 *

Команда * not OP *: результат - инверсия значения операнда 

Если (AL) = 0000 0000, *not AL*: (AL) = 1111 1111 

Значения флагов не изменяются.

== Примеры:

1. ```asm
xor AX,AX; обнуляет регистр AX быстрее, чем mov и sub
```

2. ```asm
xor AX, BX; меняет местами значения AX и BX
xor BX, AX; быстрее чем команда
xor AX, BX; xchg AX, BX
```

3. Определить кол-во задолжников в группе из 20 студентов. Информация о студентах содержится в массиве байтов

X DB 20 DUB(?), причем 4 битах каждого байта содержатся оценки, т.е 1 --- сдал, 0 --- "хвост"

В DL сохраним кол-во задолжников.

------------------------------------------------------
```asm
mov DL, 0 
mov SI, 0 ; i = 0
mov CX, 20 ; кол-во повторений цикла
nz:
    mov AL, X[SI]
    and AL, 0Fh ; обнуляем старшую часть байта
    xor AL, 0Fh ;
    jz m ; ZF = 1, хвостов нет, передаем на повторение цикла
    inc DL ; увеличиваем кол-во задолжников
m:
    inc SI ; переходим к следующему студенту
    add DL, "0"
    mov AH, 6
    int 21h
```
------------------------------------------------------

== Команды сдвига

Формат команд арифметического и логического сдвига можно представить так: sXY OP1, OP2 ; \<комментарий> 

Здесь X --- h или a, Y --- I или r; OP1 --- r или m, OP2 --- d или CL

И для всех команд сдвига в CL используются только 5 младших разрядов, принимающих значения от 0 до 31. При сдвиге на один разряд 

*shl: CF \<- \<- \<- 0*

*shl: 0 -> -> -> CF ->*

*sal: CF \<- \<- \<- 0*

*sar: 0 -> -> -> CF ->*

Здесь знаковый бит распространяется на сдвигаемые разряды. Например (AL) = 1101 0101

sar AL, 1; (AL) = 1110 1010 и CF = 1

Сдвиги больше, чем на 1, эквивалентны соответствующим сдвигам на

1. выполненным последовательно.

*Сдвиги повышенной точности для i186 и выше:*

  *shrd OP1, OP2, OP3*  
  *shid OP1, OP2, OP3*  

Содержимое превого операнда (OP1) сдвигается на (OP3) разрядов также, как и в командах shr и shl но бит, вышедший за разрядную сетку, не обнуляется, а заполняется содержимым второго операнда, которым может быть только регистр.

*Циклические сдвиги:*

Надо бы сюда картинку вставить я манал стрелки рисовать
.

.

.

..

..


После выполнения коменды циклического сдвига CF всегда равен последнему биту, вышедшему за пределы приемника.

Циклические сдвиги с переносом содержимого Флажка CF:

опять каритнка
.


.

.

.

.

.

.

Для всех команд сдвига флаги ZF, SF, PF устанавливаются соответствии с результатом, AF --- не определен, OF --- не определен при сдвигах на несколько разраядов, при сдвиге на 1 разряд в зависимости от команды:

- Для циклических команд, повышенной точности и _sal_, _shl_ флаг OF = 1, если после сдвига старший бит изменится;

- после sar OF = 0; 

- после shr OF = значению старшего бита исходного числа

== Для самостоятельного изучения команды:

- BT\<приемник>, \<источник>
- BTS\<приемник>, \<источник>
- BTR\<приемник>, \<источник>
- BTC\<приемник>, \<источник>
- BTF\<приемник>, \<источник>
- BSR\<приемник>, \<источник>

== Структуры.

Структура состоит из полей-данных различного типа и длины, занимая последовательные байты памяти. Чтобы использовать переменные типа структука, необходима в начале описать тип структуры:

```
<имя типа> struc
    <описание поля>
    ---------------
    <описание поля>
<имя типа> ends
```

\<имя типа> --- то индентификатор типа структуры, struc и ends --- директивы, причем \<имя типа> в директиве ends также обязательно... Для описания полей используются директивы определения DB, DW, DD,... Имя, указанное в этих директивах, является именем поля, поля не могут быть структурами или могут быть структурами зависит от компилятора.

Например, 

```asm
TData struc ; TData --- идентификатор типа
    y DW 2000 ; y, m, d --- имена полей. Значения, указанные
    m DB ? ; в поле операндов директив DW и DB
    d DB 28 ; называются значениями полей, приятными
TData ends ; по умолчанию
```

? --- означает, что значения по умолчанию нет.

На основании описания типа в программу ничего не записывается и память не выделяется. Описание типа может располагаться в любом месте программы, но только до описания переменных данного типа. На основании описания переменных Ассемблером выделяется память в соответствии с описанием типа в последовательных ячейках, так что в нашем случае размещение полей можно представить так:

*фотка мини таблички*
.

.

.

.

.

.

.

.


Описание переменных типа сруктуры осуществляется с помощью директивы вида:

*имя переменной имя типа \<нач. значения>*

Здесь уголки не метасимволы, а реальные символы языка, внутри которых через запятую указываются начальные значения полей.

Нач-ым значением может быть: 

1. ?
2. вырпжение
3. строка
4. пусто

например:

```asm
dt1 TData <?, 6, 4>
dt2 TData <1999, ,>
dt3 TData < , ,>
```

*опять мини табличка*


.

.

.

.

.

Идентификатор типа TData используются как директива для описания переменных также, как используются стандартные директивы DB, DW и т.д. Если начальные значения не будут умещаться в отведенное ему при описании типа поле, то будет фиксироваться ошибка. Правила использования начальных значений и значений по умолчанию:

- Приоритетными являются начальные хначения полей, при описании переменных, т.е. если при описании переменной для поля указан ? или какое-либо значение, то значения этих плей по умолчанию игнорируются.

Отсутсвие начального значения отмечается запятой. Если отсутствуют значения первого поля или полей, расположенных в середине списка полей, то запятые опускать нельзя.

Например
```asm
dt4 TData <1980, ,> ; можно dt4 TData <1980>
dt5 TData < , ,5> ; нельзя заменить на  dt5 TData <5?
```

Если отчутствуют все начальные значения отпускаются все запятые, но угловые скобки сохраняются: *dt6 Tdata \< >* 

При описании перменных, каждая переменная описывается отдельно, но можно описать массив структур, для этого в директиве описания переменной указывется несколько операндов и (или) консткция повторения DUP.

Например:
```asm
dst TData <, 4, 1>, 25 DUP (< >)
```

описан массив из 26 элементов типа TData, и первый элемент











