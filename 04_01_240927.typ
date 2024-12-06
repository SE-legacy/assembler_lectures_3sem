
Действительные с плавующей точкой в виде мантисы и порядка (34.751e + 02) имеет значение 3475.1)

== Символьные данные 

Это полчдеоватаельность символов заключенные в '' или ""

== Именнованные константы

также существуют именнованные константы, с помощью директиыв EQ

Переменные в ассмблере опред с помощью директив определения данных и памяти или с помощью  директивы равенства

Консатнты используются в основном как операнды в выражениях или в директивах определения данных в памяти 


== Выражения

выражения строятся из операндов, операторов и скобок. Операнды --- это констатнты и переменные операторы --- это знаки оперциий (арифмет = +, -, \*, /, mod; лог = NOT, AND, OR, XOR; отношений LT \< LE \<=, NE != GT > GE >=  сдвига SHL \<\<, SHR >>; Специальные OFFSET, PTR)

OFFSET \<name> --- ее значением является смещение операнда, а операндом может быть метка или переменная 

PTR определяет тип оперенда (BYTE, WORD, DWORD, FWORD, QWORD, TWORD)


= Директива определения 

Общий вид:

[\<name>] DX \<операнды> \<;комментарии>, где X это B, W, D, F, Q, T

В поле операндов может быть "?", одна или несколько констант, разделенных запятой. Имя если оно есть определяет адрес первого байта выделяемой обасти. Директивой выделяется указанное кол-во байтов ОП и указанные операнды пересылаются в эти поля памяти. Если опеанд --- это "?", то в соответсвующее поле ничего не заносится 

Пример:

*R1 DB 0, 0, 0*: выделено 3 поля, заполненных "0"

- Если операндом является символическое имя IM1, которое соответствует смещению в сегменте 03AC1h, то после выполнения 

M DD

-

-

- Определение двумерного массива: 
    1. *Arr DB 7, 94, 11, -5*
    2. *DB 5, 0, 1, 2*
    3. *Db -5, 0, 15, 24*

- CONST EQ 100 

*D DB Const DUP (?)* --- выделить 100 байт в памяти. В диретиве определения байта (слова) максимально допустимая константа --- 255 (65535)

С помощью директивы определения айта можно определить строковую константу длинной 255 символов, а спомощью определения слова можно определить строковую константу, которая может содержать не более двух символов

== комманда прерывания int 

прерывает работу процессора, передает управления опреационной систем или BIOS и после выполнения этой программы, управление передается комманде, следующей за командой INT 

Выполняемые действия будут зависеть от операнда, параметра INT и содержания некоторых регистров 

Например, чтобы выести на экран "!" необходимо:

MOV AH, 6 

MOV DL "!"

INT 21h

Стек определеяется с помощью регистров SS и SP (ESP) 

Системный регистр SS содержит адрес начала сегмента стека,

ОС сама выбирает этот адрес и пересылает его в регистр SS 

Регистр  SP указывает на вершину стека и при добавлении элемента стека содержимое этого стека уменьшается на длину операнда.

Добавить элемент в стек можно с помощью комманды 

*PUSH\<опернад>*

где операндом может быть как регистр так и переменная, 

Удалить элемент с вершины стека можно с помощью операции 

*POP\<операнд>*

*PUSHA/POPA* позволяет положить в стек удалить содержимое всех регистров общего назначения в последовательности AX, BX, CX, DX, SP, BP, SI, DI

*PUSHAD/POPAD* позволяют положить в стек содержиме всех регистров общего назначения в последовательности


К любому элементу стека можно обратиться следующим образом:

*MOV BP, SP* ; .....

.....

.....


```asm
TTITLE Prim.asm
PAGE, 120
;описание сегмента стека
SSEG Segment Pfrf stack "stack"

DB 100h DUP(?)
Sseg ends

;Описание сегмента данных 
DSEG Segment Para Public "Data"
DAN DB '1', '3', '5', '7'
REZ DB 4 DUP (?)
DSEG ends

;кодовый сегмент оформлен как одна внешняя процедура, к ней обращаются из отладчика 

CSEG Segment Para Public 'Code'
Assume SS:SSEG, DS:DSEG, CS:CSEG

Start Proc FAR
PUSH DS 
XOR AX, AX 
PUSH AX
MOV AX, DSEG;
MOV DS, AX;

;пересылка данных в опратной последовательности с выводом на экран

MOV AH, 6 
MOV DL, DAN + 3 
MOV REZ, DL
INT 21h ;вывели на экран 7 
MOV DL, DAN + 2 
MOV REZ + 1, DL
INT 21h ;вывели на экран 5 
MOV DL, DAN + 1 
MOV REZ + 2, DL
INT 21h ;вывели на экран 3 
MOV DL, DAN
MOV REZ + 3, DL
INT 21h ;вывели на экран 1 
MOV AH, 4CH
INT 21h 
Start endp
CSEG ends 
End Start
```

= Директива сегмент

Общий вид 
\<name> Segment \<ReadOnly> \<выражение> \<type> \<size> \<"класс">

Любой из операндов может отсутствовать 

- Если  есть ReadOnly, то будет выведено сообщение об ошибку при попытке записи в сегмент

- Операнд "выравнивание" определят адрес начала сегмента.

BYTE --- адрес начала может быть любым

WORD --- адрес начала сегмента кратен 2 

DWORD --- адрес начала сегмента кратен 4

Para --- адрес начала сегмента кратен 16 (по умолчанию)

PAGE --- адрес начала мегмента кратен 256 

- Тип определяет тип обхединения сегмнтов 

Значение stack указывается в сегменте стека для остальных сегмнотов public. Если такой параметр при сутствует, то все сегмнты с одним именем и различными классами объединяются в порядке их записи.

Значение Common говорит, что сегменты с одним именем объеденины, но не последовательно, а с одного и того же адреса так чт сегмент должен располагаться по абсолютному адресу, определенному операнду "выражение"

Значение Private означает, что это сегмент ни с каким другим объединяться не должен 

- \<разрядность> use 16 --- сегмент до 64 КБ 

Use 32 --- сегмент до 4 ГБ

- \<class> --- с одинаковым классом сегменты располагаются в исполняемом файле последовательностью друг за другом

= Точные директивы

Впрограмме на ассемблере могут использоваться упрощенные (точечные) директивы

*.MODEL* --- директива, определяющая модель выделяемой памяти 


```asm
.MODEL small

```

= .COM-файлы 

После обработки компилятором и редактором связей получаем exe=файл, который содержит блок начальной загруски, размером не менее 512 байт, но существует возможность создания другого вида исполняемого файла, который может быть получен на основе exe-файла с помощью системной обарбатывающей программы 
















