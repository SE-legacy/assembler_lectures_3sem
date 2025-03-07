#import "conf.typ" : conf
#import "@preview/plotst:0.2.0"
#import "@preview/fletcher:0.4.5" as fletcher: diagram, node, edge

#show: conf.with(
  title: [Lection 11],
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


= Директива label

Директива label определяет метку и присваивает ей тип:

```
<метка> label <тип>
```

byte, word, dword, fword (6б), qword (8б) tbyte (10 б), near, far. При этом метка получает значение, равное адресу следующей команды или следующих данных, и указанный тип. В зависимости от типа метки команда.

```
mov <метка>, 0 --- заполнит в памяти байт, слово, двойное слово и тд, нулем, а команда
call <метка>
```
выполнит ближний ... дальний вызова продпрограммы

Если подряд описать две метки:

```asm
mb label byte
mw label word
```

то к одной и той же оласти памяти можно обращаться как к байтам, если как к словам используя метки mb, mw

*Ключевые слова NEAR и FAR* используются в программе для выбора типа вызова или перехода, необходимого для достижения определеной метки. Например, в программе:

```asm
.CODE ...

FarLabel LABEL FAR

mov ax, 1
.................................................................
jmp FarLabel
.................................................................
jmp NearLabel
```

Первая инструкция JMP представляет собй переход дальнего типа (загружается оба регистра CS и IP), так как это переход на метку типа FAR, а второй переход имеет ближний тип (загружается только регистр IP), так как это переход на метку типа NEAR. Обе метки FarLabel и NearLabel описывают один и тот же адрес (адрес команды MOV), позволяют переходить на него различными способами.

= Функции управления файловой системой. Простейщая программа шифрования файлов.

Начиная с MS DOS 2.0 файловая система имеет иерархическую структуру, т.е. директории могут содержать в себе как файлы, так и другие директории. Но функции поиска файлов действуют только в педелах текущей директории, а функции создания и удаления файлов не применимы к директориям, хотя на самом низком уровне директория, а функции создания и удаления файлов не применимы к директориям, хотя на самом низком уровне директория --- это файл, в атрибуте которого бит 4 установлен в 1 и который содержит список вложенных фалйов, их атрибутов и физических адресов на диске. Поэтому для работы с директориями существуют спкциальные функции ОС.

1. Создать директорию --- 39h

_При вызове_: AH = 39h; DS:DX --- адрес ASCIIZ --- строки, содержащей путь в котором все директории, кроме последней существуют.

_Возврат_: CF=0 --- директория создана, ошибок нет

CF = 1 и AX = 3, если путь не найден

CF = 1 и AX = 5, если доступ запрещен

2. Удалить директорию -3Ah 

_При вызове_: AH = 3Ah; DS:DX --- адрес ASCIIZ --- строки, содержащей путь, последняя директория в котором будет удалена (она должна быть пустой, не должна быть текущей)

_Возврат_: CF = 0 --- ошибок нет, директория удалена

CF = 1 и AX = 3 --- путь не найден, 5 --- доступ запрещен, 10h --- удаляемая директория является текущей.

3. Определить текущую директорию --- 47h

_При вызове_: AH = 47h; DL = номер диска (00h --- текущий, 01h --- A, 02 --- B и т.п.)

DS:DX = 64 байтный буфер для текущего пути (ASCIIZ --- строка без имени диска, без первого и последнего символа "\"

_Возврат_: CF = 0 и AX = 0100h --- нет ошибки, операция выполнена

CF = 1 и AX = 0Fh, если указан не существующий диска

4. Сменить текущую директорию --- 3Bh 

_При вызове_: AH = 3Bh; DS:DX = 64-байтный адрес ASCIIZ строки, содержащей путь, который станет текущей директорией 

_Возврат_: CF = 0  --- если операция выполнена

CF = 1 и AX = 3 если путь не найден

== Возможно пропущен слайд

== Продолжение

Для работы с директориями, имеющими данные имена, а это стало возможно начиная с DOS 7.0 (WINDOWS-95),

таблицы расширения не FAT, a VFAT, номер соответствующей функции загружается в AX, и отличается от номера функции для DOS с короткими именами на 7i приписанное слева, т.е.

_FAT  YFAT_

39h   7139h
3Ah   713Ah 
47h   7147h
3Bh   713Bh

Перед работой с любыми LFN функциями для длинных имен следует один раз вызывать информацию 71A0h, чтобы определить размеры буферов для имен файлов и путей.

== Пропущенно 2 слайда

== Продолжение

= Вариант программы

```asm

.Model Small
.Stack 100h 
.Data

CR = 0Dh    ; возврат каретки
LF = 0Ah    ; перевод строки

Mess1 DB CR, LF, 'File name:'   ; приглашение к вводу имени файла
LenMess1 = $- Mess1             ; длина строки Mess1

Mess2 DB CR, LF, 'Password:'    ; приглашение к вводу пароля
LenMess2 = $- Mess2             ; длина строки Mess2

Buf password DB 80 Dup('*')     ; буфер для храниения пароля
Buf DB 4096 Dup(?)              ; буфер для шифрования файла
filelen DW ?                    ; слово для хранения длины файла
Key_Password DB ?               ; байт для хранения ключа шифра
Filename DB 32 Dup (?)          ; буфер для хранения имени файла
Descrfile DW ?                  ; слово для хранения дускриптора

; сегмент кода

.Code 

Start: 
    mov AX, @data     ; инициализация
    mov DS, AX        ; сегментного регистра DS
; вывод строки с приглашение ввести имя файла
    mov AH, 40h       ; функция записи -> AH 
    mov BX, 1         ; дескриптор стандартного вывода (дисплей) -> BX
    mov CX, LenLabel  ; длина выводимой строки -> CX

    mov DX, offset Mess1  ; адрес строки -> DS:DX
    int 21h               ; вызов функции 40h
    ; ввод имени файла
    mov AH, 3fh           ; функция чтения
    xor BX, BX            ; декскриптор стандартного вывода 0 -> BX
    mov CX, 30            ; сколько байто читать
    mov DX, offset Mess1  ; адрес строки -> DS:DX
    int 21h               ; вызов функции 40h 
    ; вывод имени файла
    mov AH, 3fh           ; функция чтения
    xor BX, BX            ; дескриптор стандартного ввода 0->BX
    mov CX, 30            ; сколько байтов читать 
    ; формирование строки с именем файла в фаормате ASCIIZ
    mov BX, AX            ; реально прочит-е кол-во байтов -> BX
    sub BX, 2             ; дописываем 0 в конец введенной строки символов
    mov filename[BX], 0   ; bx-2 перевод строки и возврат каретки
```
