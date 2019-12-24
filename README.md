
# 摘要

本文为哈尔滨工业大学计算机类“计算机系统”课程大作业论文。使用计算机管理、开发中的常用程序，探究了hello程序是如何从代码编译成可执行文件，又如何从可执行文件创建进程，进程结束后又如何被回收，即hello程序的一生。

**关键词**：程序；计算机系统；编译；链接；

# 第1章 概述

## Hello 简介

首先，人类在编辑器中将hello的代码打出，保存在磁盘中。编译器、汇编器、链接器、将源代码文件预处理、编译、汇编、链接，生成可执行文件。壳层调用操作系统中的进程管理相关系统调用，如fork、execve、mmap，分配了时间片，加载到内存中。中央处理器进行取址、译码，通过流水线执行程序的代码。内存管理单元使用页表缓存、页表hello提供内存管理，缓存为hello读取内存加速。操作系统使用存储管理与信号处理，使得hello能够在显示器上显示，读取键盘的输入。进程结束后，操作系统与壳层进行回收。

## 环境与工具

- 基于x86处理器的冯诺依曼计算机

- Arch Linux

- Zsh

- Clang

- LD

- edb

- GNU Binutils

## 中间结果

- hello.s
- hello.i
- hello.o
- hello
- hello.asm
- hello_exec.asm

[在此查看](https://github.com/mahoshojoHCG/Hello-P2P-Files)

## 本章小结

通过对最简单的一个hello程序进行分析研究，是我们对操作系统研究的基础。

# 第2章 预处理

## 预处理的概念与作用

预处理在语法分析处理之前，根据用户定义的规则，进行简单的词法单元替换。实现宏替换，包含其他文件的文本，并且条件性地编译或者包含文件。

## 预处理过程

```shell
clang -E hello.c -o hello.i
```

![hello_1](https://s2.ax1x.com/2019/12/21/Qv3NJs.png)

## Hello的预处理结果解析 

预处理结果见附件hello.i。

解析：

- 头文件中所有内容被复制到#include的位置，并且也处理了头文件中的#include指令。
- 所有头文件中的条件编译指令都被处理。
- 所有宏都被展开。
- 源文件的文件名标注在第3008行。
- 所有注释被删除。
- 制表符被一个空格代替。

## 本章小结 

预处理是C语言中最基本的编译前的必备操作，实现了对头文件的展开以及条件编译，是C语言设计思想的体现。

# **第3章** 编译

## 编译的概念与作用 

编译器是一种计算机程序，它会将某种编程语言写成的源代码转换成另一种编程语言。在这里，编译期将预处理过的C代码编译成了汇编语言。

## 编译的命令

```shell
clang -S hello.i -masm=intel
```

![hello_2](https://s2.ax1x.com/2019/12/21/QvtDIS.png)

## Hello的编译结果解析

编译结果见附件`hello.s`。

### 全局变量

#### 声明时

hello.i：

```C
int sleepsecs=2.5;
```

hello.s：

``` asm
sleepsecs:
	.long	2                       # 0x2
	.size	sleepsecs, 4

	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
```

`.long 2`意为sleepsecs的指为2，由于int类型并不能表示2.5，因此向下取整取2。编译时出现的warning也来源于此。

`.size sleepsecs, 4`意为sleepsecs的大小为4字节，即int的大小为4字节。

`.section .rodata.str1.1,"aMS",@progbits,1`意为全局变量sleepsecs将储存在.rodata块。

#### 使用时

``` asm
mov	edi, dword ptr [rip + sleepsecs]
```

使用全局寻址寄存器进行对全局变量的访问。

### 局部变量

#### 声明时

局部变量分配的是栈空间，声明时从rsp寄存器减去需要的大小。

如hello.s中

```asm
sub	rsp, 32
```

除了hello.i中所声明的一个int空间外，还从栈中申请了额外的内存用于储存其他的内容。

``` c
int i;
```

#### 使用时

在hello.i中：

```c
for(i=0;i<10;i++)
    //...
```

在hello.s中：

``` asm
mov	dword ptr [rbp - 20], 0
```

``` asm
mov	eax, dword ptr [rbp - 20]
add	eax, 1
mov	dword ptr [rbp - 20], eax
```

赋值仅需使用mov指令进行内存写入；进行运算时先从内存中将值取到寄存器中，对寄存器进行运算，再写回到内存中。

### 字符串

原hello.i中有两处使用到了字符串：

``` c
printf("Usage: Hello 学号 姓名！\n");
```

``` c
printf("Hello %s %s\n",argv[1],argv[2]);
```

其中字符串内容分别为

``` c
"Usage: Hello 学号 姓名！\n"
```

``` c
"Hello %s %s\n"
```

编译成

``` asm
.L.str:
	.asciz	"Usage: Hello \345\255\246\345\217\267 \345\247\223\345\220\215\357\274\201\n"
	.size	.L.str, 31

	.type	.L.str.1,@object        # @.str.1
.L.str.1:
	.asciz	"Hello %s %s\n"
	.size	.L.str.1, 13
```

汉字以UTF-8的形式储存，变成了形如`\345\255\246`这样的内容。

访问时依然通过简介寻址方式访问，但传递的是指针。

如在hello.s中

``` asm
lea	rdi, [rip + .L.str]
```

``` asm
lea	rdi, [rip + .L.str.1]
```

### 函数调用

在hello.i中一共进行了5次函数调用，分别为：

```c
printf("Usage: Hello 学号 姓名！\n");
```

``` c
exit(1);
```

``` c
printf("Hello %s %s\n",argv[1],argv[2]);
```

``` c
sleep(sleepsecs);
```

``` c
getchar();
```

分别编译为：

#### 第一次 printf

``` asm
lea	rdi, [rip + .L.str]
mov	al, 0
call	printf@PLT
```

此处printf函数仅有一个参数，根据调用规范，将`.L.str`字符串常量的地址放入rdi寄存器，并且将浮点数参数的数量0放入`al`寄存器。

``` asm
mov	edi, 1
mov	dword ptr [rbp - 24], eax # 4-byte Spill
call	exit@PLT
```

#### exit

由于exit函数原型为

``` c
extern void exit (int __status) __attribute__ ((__nothrow__ )) __attribute__ ((__noreturn__));
```

参数`__status`类型为int，因此送入寄存器为edi。`mov dword ptr [rbp - 24], eax`的作用为保存上一次对`printf`调用的返回值，但是这个返回值后面并没有用到。

#### 第二次 printf

``` asm
mov	rax, qword ptr [rbp - 16]
mov	rsi, qword ptr [rax + 8]
mov	rax, qword ptr [rbp - 16]
mov	rdx, qword ptr [rax + 16]
lea	rdi, [rip + .L.str.1]
mov	al, 0
call	printf@PLT
```

根据调用规定，`argv[1]`应在`rsi`中，`argv[2]`应在`rdx`中。

在`main`函数开始时，已经将`main`函数的第二个参数存入栈中：

``` asm
mov	qword ptr [rbp - 16], rsi
```

由于内存中的数值无法直接进行计算，因此将其取出到`rax`寄存器中，再使用`mov`指令进行数组访问，将指针加上索引个字长，将结果存入`rsi`与`rdx`以进行调用。

#### sleep

``` asm
mov	edi, dword ptr [rip + sleepsecs]
mov	dword ptr [rbp - 28], eax # 4-byte Spill
call	sleep@PLT
```

与调用`exit`类似，`sleep`原型为

``` c
extern unsigned int sleep (unsigned int __seconds);
```

不再赘述。

#### getchar

``` asm
call	getchar@PLT
```

由于`getchar`函数并无参数，直接调用即可。

### 条件控制

在hello.i中

``` c
if(argc!=3)
{
    //...
}
```

编译为

``` asm
cmp	dword ptr [rbp - 8], 3
je	.LBB0_2
# %bb.1:
; ...
.LBB0_2:
```

先使用`cmp`指令对两个操作数进行比较，并且设置标签，不满足条件就跳转到标签`.LBB0_2`处，不执行满足条件应执行的代码。

### 循环

在hello.i中

``` c
for(i=0;i<10;i++)
{
    //...
}
```

编译为

``` asm
mov	dword ptr [rbp - 20], 0
.LBB0_3:                                # =>This Inner Loop Header: Depth=1
cmp	dword ptr [rbp - 20], 10
jge	.LBB0_6
# %bb.4:                                #   in Loop: Header=BB0_3 Depth=1
; ...
# %bb.5:                                #   in Loop: Header=BB0_3 Depth=1
mov	eax, dword ptr [rbp - 20]
add	eax, 1
mov	dword ptr [rbp - 20], eax
jmp	.LBB0_3
.LBB0_6:
```

首先在栈中的一块内存上初始化循环控制变量i,然后再进入循环。设置标签，如果不再满足循环条件，则跳出。循环体的末尾对循环变量进行更新，再跳到循环头进行条件检查。

### 函数返回

在返回前，根据调用规范，将返回值放入到eax寄存器，这里用异或进行了存0的优化。

``` asm
xor	ecx, ecx
mov	dword ptr [rbp - 32], eax # 4-byte Spill
mov	eax, ecx
```

并且恢复在函数开始时分配的栈空间。

``` asm
add	rsp, 32
pop	rbp
```

最后使用`ret`指令返回。

## 本章小结

编译是C语言程序运行的基础，有了编译，C语言才能转换成汇编语言，进而在机器上运行。

# 第4章 汇编

## 汇编的概念与作用

汇编是指汇编器将汇编语言翻译成机器语言指令，并将指令打包成可重定位目标程序的格式，并保存在文件中。

## 汇编的命令

``` shell
clang -c hello.s
```

![hello_3](https://s2.ax1x.com/2019/12/22/QzfGWQ.png)

## 可重定位目标elf格式

``` shell
readelf -a hello.o
```

输出得

``` elf
ELF 头：
  Magic：  7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  类别:                              ELF64
  数据:                              2 补码，小端序 (little endian)
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI 版本:                          0
  类型:                              REL (可重定位文件)
  系统架构:                          Advanced Micro Devices X86-64
  版本:                              0x1
  入口点地址：              0x0
  程序头起点：              0 (bytes into file)
  Start of section headers:          960 (bytes into file)
  标志：             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           0 (bytes)
  Number of program headers:         0
  Size of section headers:           64 (bytes)
  Number of section headers:         11
  Section header string table index: 1

节头：
  [号] 名称              类型             地址              偏移量
       大小              全体大小          旗标   链接   信息   对齐
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .strtab           STRTAB           0000000000000000  00000330
       000000000000008a  0000000000000000           0     0     1
  [ 2] .text             PROGBITS         0000000000000000  00000040
       0000000000000089  0000000000000000  AX       0     0     16
  [ 3] .rela.text        RELA             0000000000000000  00000258
       00000000000000c0  0000000000000018          10     2     8
  [ 4] .data             PROGBITS         0000000000000000  000000cc
       0000000000000004  0000000000000000  WA       0     0     4
  [ 5] .rodata.str1.1    PROGBITS         0000000000000000  000000d0
       000000000000002c  0000000000000001 AMS       0     0     1
  [ 6] .comment          PROGBITS         0000000000000000  000000fc
       000000000000002e  0000000000000001  MS       0     0     1
  [ 7] .note.GNU-stack   PROGBITS         0000000000000000  0000012a
       0000000000000000  0000000000000000           0     0     1
  [ 8] .eh_frame         X86_64_UNWIND    0000000000000000  00000130
       0000000000000038  0000000000000000   A       0     0     8
  [ 9] .rela.eh_frame    RELA             0000000000000000  00000318
       0000000000000018  0000000000000018          10     8     8
  [10] .symtab           SYMTAB           0000000000000000  00000168
       00000000000000f0  0000000000000018           1     4     8
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)

There are no section groups in this file.

本文件中没有程序头。

There is no dynamic section in this file.

重定位节 '.rela.text' at offset 0x258 contains 8 entries:
  偏移量          信息           类型           符号值        符号名称 + 加数
00000000001e  000300000001 R_X86_64_64       0000000000000000 .rodata.str1.1 + 0
000000000029  000700000004 R_X86_64_PLT32    0000000000000000 printf - 4
000000000033  000400000004 R_X86_64_PLT32    0000000000000000 exit - 4
000000000056  000300000001 R_X86_64_64       0000000000000000 .rodata.str1.1 + 1f
000000000061  000700000004 R_X86_64_PLT32    0000000000000000 printf - 4
000000000068  00090000000b R_X86_64_32S      0000000000000000 sleepsecs + 0
00000000006d  000800000004 R_X86_64_PLT32    0000000000000000 sleep - 4
00000000007d  000500000004 R_X86_64_PLT32    0000000000000000 getchar - 4

重定位节 '.rela.eh_frame' at offset 0x318 contains 1 entry:
  偏移量          信息           类型           符号值        符号名称 + 加数
000000000020  000200000002 R_X86_64_PC32     0000000000000000 .text + 0

The decoding of unwind sections for machine type Advanced Micro Devices X86-64 is not currently supported.

Symbol table '.symtab' contains 10 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS hello.c
     2: 0000000000000000     0 SECTION LOCAL  DEFAULT    2 
     3: 0000000000000000     0 SECTION LOCAL  DEFAULT    5 
     4: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND exit
     5: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND getchar
     6: 0000000000000000   137 FUNC    GLOBAL DEFAULT    2 main
     7: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND printf
     8: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND sleep
     9: 0000000000000000     4 OBJECT  GLOBAL DEFAULT    4 sleepsecs

No version information found in this file.
```

## hello.o的结果解析

使用以下指令进行反汇编

``` shell
objdump -d -r hello.o -M intel > hello.asm
```

输出见附件

机器语言是由操作符与操作数构成的二进制，与汇编语言具有一一对应的关系。在汇编时，`call`指令与`jmp`类指令后的行号与函数名被汇编为地址，全局变量的地址也被写入，便于计算机进行调用。这是汇编语言与机器语言的主要区别。

## 本章小结

汇编是将汇编语言的程序编译成elf格式的文件，是编程语言与机械码之间的桥梁。

# 第5章 链接

## 链接的概念与作用

链接是将编译器与汇编器生成的目标文件外加库文件生成可执行文件。

## 链接的命令

```shell
ld -o hello -dynamic-linker /lib/ld-linux-x86-64.so.2 /lib/crt1.o /lib/crti.o /lib/crtn.o hello.o /lib/libc.so
```

使用`-dynamic-linker`表示使用动态链接，并且附带`ld-linux-x86-64.so`、`crt1.so`、`crti.so`、`crtn.o`与`libc.so`，表示与库链接。

![hello_4](https://s2.ax1x.com/2019/12/23/lSHxgK.png)

## 可执行目标文件hello的格式

使用

``` shell
readelf -a hello.o
```

输出得

``` readelf
ELF 头：
  Magic：  7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  类别:                              ELF64
  数据:                              2 补码，小端序 (little endian)
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI 版本:                          0
  类型:                              EXEC (可执行文件)
  系统架构:                          Advanced Micro Devices X86-64
  版本:                              0x1
  入口点地址：              0x401070
  程序头起点：              64 (bytes into file)
  Start of section headers:          14160 (bytes into file)
  标志：             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         10
  Size of section headers:           64 (bytes)
  Number of section headers:         25
  Section header string table index: 24

节头：
  [号] 名称              类型             地址              偏移量
       大小              全体大小          旗标   链接   信息   对齐
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .interp           PROGBITS         0000000000400270  00000270
       000000000000001a  0000000000000000   A       0     0     1
  [ 2] .note.ABI-tag     NOTE             000000000040028c  0000028c
       0000000000000020  0000000000000000   A       0     0     4
  [ 3] .hash             HASH             00000000004002b0  000002b0
       0000000000000030  0000000000000004   A       5     0     8
  [ 4] .gnu.hash         GNU_HASH         00000000004002e0  000002e0
       000000000000001c  0000000000000000   A       5     0     8
  [ 5] .dynsym           DYNSYM           0000000000400300  00000300
       00000000000000a8  0000000000000018   A       6     1     8
  [ 6] .dynstr           STRTAB           00000000004003a8  000003a8
       0000000000000052  0000000000000000   A       0     0     1
  [ 7] .gnu.version      VERSYM           00000000004003fa  000003fa
       000000000000000e  0000000000000002   A       5     0     2
  [ 8] .gnu.version_r    VERNEED          0000000000400408  00000408
       0000000000000020  0000000000000000   A       6     1     8
  [ 9] .rela.dyn         RELA             0000000000400428  00000428
       0000000000000030  0000000000000018   A       5     0     8
  [10] .rela.plt         RELA             0000000000400458  00000458
       0000000000000060  0000000000000018  AI       5    19     8
  [11] .init             PROGBITS         0000000000401000  00001000
       000000000000001b  0000000000000000  AX       0     0     4
  [12] .plt              PROGBITS         0000000000401020  00001020
       0000000000000050  0000000000000010  AX       0     0     16
  [13] .text             PROGBITS         0000000000401070  00001070
       0000000000000145  0000000000000000  AX       0     0     16
  [14] .fini             PROGBITS         00000000004011b8  000011b8
       000000000000000d  0000000000000000  AX       0     0     4
  [15] .rodata           PROGBITS         0000000000402000  00002000
       0000000000000030  0000000000000000   A       0     0     4
  [16] .eh_frame         PROGBITS         0000000000402030  00002030
       00000000000000e4  0000000000000000   A       0     0     8
  [17] .dynamic          DYNAMIC          0000000000403e50  00002e50
       00000000000001a0  0000000000000010  WA       6     0     8
  [18] .got              PROGBITS         0000000000403ff0  00002ff0
       0000000000000010  0000000000000008  WA       0     0     8
  [19] .got.plt          PROGBITS         0000000000404000  00003000
       0000000000000038  0000000000000008  WA       0     0     8
  [20] .data             PROGBITS         0000000000404038  00003038
       0000000000000008  0000000000000000  WA       0     0     4
  [21] .comment          PROGBITS         0000000000000000  00003040
       000000000000003e  0000000000000001  MS       0     0     1
  [22] .symtab           SYMTAB           0000000000000000  00003080
       00000000000004b0  0000000000000018          23    30     8
  [23] .strtab           STRTAB           0000000000000000  00003530
       0000000000000154  0000000000000000           0     0     1
  [24] .shstrtab         STRTAB           0000000000000000  00003684
       00000000000000c5  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)

There are no section groups in this file.

程序头：
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  PHDR           0x0000000000000040 0x0000000000400040 0x0000000000400040
                 0x0000000000000230 0x0000000000000230  R      0x8
  INTERP         0x0000000000000270 0x0000000000400270 0x0000000000400270
                 0x000000000000001a 0x000000000000001a  R      0x1
      [Requesting program interpreter: /lib/ld-linux-x86-64.so.2]
  LOAD           0x0000000000000000 0x0000000000400000 0x0000000000400000
                 0x00000000000004b8 0x00000000000004b8  R      0x1000
  LOAD           0x0000000000001000 0x0000000000401000 0x0000000000401000
                 0x00000000000001c5 0x00000000000001c5  R E    0x1000
  LOAD           0x0000000000002000 0x0000000000402000 0x0000000000402000
                 0x0000000000000114 0x0000000000000114  R      0x1000
  LOAD           0x0000000000002e50 0x0000000000403e50 0x0000000000403e50
                 0x00000000000001f0 0x00000000000001f0  RW     0x1000
  DYNAMIC        0x0000000000002e50 0x0000000000403e50 0x0000000000403e50
                 0x00000000000001a0 0x00000000000001a0  RW     0x8
  NOTE           0x000000000000028c 0x000000000040028c 0x000000000040028c
                 0x0000000000000020 0x0000000000000020  R      0x4
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
  GNU_RELRO      0x0000000000002e50 0x0000000000403e50 0x0000000000403e50
                 0x00000000000001b0 0x00000000000001b0  R      0x1

 Section to Segment mapping:
  段节...
   00     
   01     .interp 
   02     .interp .note.ABI-tag .hash .gnu.hash .dynsym .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt 
   03     .init .plt .text .fini 
   04     .rodata .eh_frame 
   05     .dynamic .got .got.plt .data 
   06     .dynamic 
   07     .note.ABI-tag 
   08     
   09     .dynamic .got 

Dynamic section at offset 0x2e50 contains 21 entries:
  标记        类型                         名称/值
 0x0000000000000001 (NEEDED)             共享库：[libc.so.6]
 0x000000000000000c (INIT)               0x401000
 0x000000000000000d (FINI)               0x4011b8
 0x0000000000000004 (HASH)               0x4002b0
 0x000000006ffffef5 (GNU_HASH)           0x4002e0
 0x0000000000000005 (STRTAB)             0x4003a8
 0x0000000000000006 (SYMTAB)             0x400300
 0x000000000000000a (STRSZ)              82 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000015 (DEBUG)              0x0
 0x0000000000000003 (PLTGOT)             0x404000
 0x0000000000000002 (PLTRELSZ)           96 (bytes)
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000017 (JMPREL)             0x400458
 0x0000000000000007 (RELA)               0x400428
 0x0000000000000008 (RELASZ)             48 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000006ffffffe (VERNEED)            0x400408
 0x000000006fffffff (VERNEEDNUM)         1
 0x000000006ffffff0 (VERSYM)             0x4003fa
 0x0000000000000000 (NULL)               0x0

重定位节 '.rela.dyn' at offset 0x428 contains 2 entries:
  偏移量          信息           类型           符号值        符号名称 + 加数
000000403ff0  000200000006 R_X86_64_GLOB_DAT 0000000000000000 __libc_start_main@GLIBC_2.2.5 + 0
000000403ff8  000400000006 R_X86_64_GLOB_DAT 0000000000000000 __gmon_start__ + 0

重定位节 '.rela.plt' at offset 0x458 contains 4 entries:
  偏移量          信息           类型           符号值        符号名称 + 加数
000000404018  000100000007 R_X86_64_JUMP_SLO 0000000000000000 printf@GLIBC_2.2.5 + 0
000000404020  000300000007 R_X86_64_JUMP_SLO 0000000000000000 getchar@GLIBC_2.2.5 + 0
000000404028  000500000007 R_X86_64_JUMP_SLO 0000000000000000 exit@GLIBC_2.2.5 + 0
000000404030  000600000007 R_X86_64_JUMP_SLO 0000000000000000 sleep@GLIBC_2.2.5 + 0

The decoding of unwind sections for machine type Advanced Micro Devices X86-64 is not currently supported.

Symbol table '.dynsym' contains 7 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND printf@GLIBC_2.2.5 (2)
     2: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __libc_start_main@GLIBC_2.2.5 (2)
     3: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND getchar@GLIBC_2.2.5 (2)
     4: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
     5: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND exit@GLIBC_2.2.5 (2)
     6: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND sleep@GLIBC_2.2.5 (2)

Symbol table '.symtab' contains 50 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000400270     0 SECTION LOCAL  DEFAULT    1 
     2: 000000000040028c     0 SECTION LOCAL  DEFAULT    2 
     3: 00000000004002b0     0 SECTION LOCAL  DEFAULT    3 
     4: 00000000004002e0     0 SECTION LOCAL  DEFAULT    4 
     5: 0000000000400300     0 SECTION LOCAL  DEFAULT    5 
     6: 00000000004003a8     0 SECTION LOCAL  DEFAULT    6 
     7: 00000000004003fa     0 SECTION LOCAL  DEFAULT    7 
     8: 0000000000400408     0 SECTION LOCAL  DEFAULT    8 
     9: 0000000000400428     0 SECTION LOCAL  DEFAULT    9 
    10: 0000000000400458     0 SECTION LOCAL  DEFAULT   10 
    11: 0000000000401000     0 SECTION LOCAL  DEFAULT   11 
    12: 0000000000401020     0 SECTION LOCAL  DEFAULT   12 
    13: 0000000000401070     0 SECTION LOCAL  DEFAULT   13 
    14: 00000000004011b8     0 SECTION LOCAL  DEFAULT   14 
    15: 0000000000402000     0 SECTION LOCAL  DEFAULT   15 
    16: 0000000000402030     0 SECTION LOCAL  DEFAULT   16 
    17: 0000000000403e50     0 SECTION LOCAL  DEFAULT   17 
    18: 0000000000403ff0     0 SECTION LOCAL  DEFAULT   18 
    19: 0000000000404000     0 SECTION LOCAL  DEFAULT   19 
    20: 0000000000404038     0 SECTION LOCAL  DEFAULT   20 
    21: 0000000000000000     0 SECTION LOCAL  DEFAULT   21 
    22: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS init.c
    23: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS static-reloc.c
    24: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS hello.c
    25: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS 
    26: 0000000000403e50     0 NOTYPE  LOCAL  DEFAULT   17 __init_array_end
    27: 0000000000403e50     0 OBJECT  LOCAL  DEFAULT   17 _DYNAMIC
    28: 0000000000403e50     0 NOTYPE  LOCAL  DEFAULT   17 __init_array_start
    29: 0000000000404000     0 OBJECT  LOCAL  DEFAULT   19 _GLOBAL_OFFSET_TABLE_
    30: 00000000004011b0     5 FUNC    GLOBAL DEFAULT   13 __libc_csu_fini
    31: 0000000000404038     0 NOTYPE  WEAK   DEFAULT   20 data_start
    32: 000000000040403c     4 OBJECT  GLOBAL DEFAULT   20 sleepsecs
    33: 0000000000404040     0 NOTYPE  GLOBAL DEFAULT   20 _edata
    34: 00000000004011b8     0 FUNC    GLOBAL HIDDEN    14 _fini
    35: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND printf@@GLIBC_2.2.5
    36: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __libc_start_main@@GLIBC_
    37: 0000000000404038     0 NOTYPE  GLOBAL DEFAULT   20 __data_start
    38: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND getchar@@GLIBC_2.2.5
    39: 0000000000000000     0 NOTYPE  WEAK   DEFAULT  UND __gmon_start__
    40: 0000000000402000     4 OBJECT  GLOBAL DEFAULT   15 _IO_stdin_used
    41: 0000000000401140   101 FUNC    GLOBAL DEFAULT   13 __libc_csu_init
    42: 0000000000404040     0 NOTYPE  GLOBAL DEFAULT   20 _end
    43: 00000000004010a0     5 FUNC    GLOBAL HIDDEN    13 _dl_relocate_static_pie
    44: 0000000000401070    47 FUNC    GLOBAL DEFAULT   13 _start
    45: 0000000000404040     0 NOTYPE  GLOBAL DEFAULT   20 __bss_start
    46: 00000000004010b0   137 FUNC    GLOBAL DEFAULT   13 main
    47: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND exit@@GLIBC_2.2.5
    48: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND sleep@@GLIBC_2.2.5
    49: 0000000000401000     0 FUNC    GLOBAL HIDDEN    11 _init

Histogram for bucket list length (total of 3 buckets):
 Length  Number     % of total  Coverage
      0  0          (  0.0%)
      1  0          (  0.0%)      0.0%
      2  3          (100.0%)    100.0%

Version symbols section '.gnu.version' contains 7 entries:
 地址：0x00000000004003fa  Offset: 0x0003fa  Link: 5 (.dynsym)
  000:   0 (*本地*)       2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)
  004:   0 (*本地*)       2 (GLIBC_2.2.5)   2 (GLIBC_2.2.5)

Version needs section '.gnu.version_r' contains 1 entry:
 地址：0x0000000000400408  Offset: 0x000408  Link: 6 (.dynstr)
  000000: Version: 1  文件：libc.so.6  计数：1
  0x0010:   Name: GLIBC_2.2.5  标志：无  版本：2

Displaying notes found in: .note.ABI-tag
  所有者            Data size   Description
  GNU                  0x00000010       NT_GNU_ABI_TAG (ABI version tag)
    OS: Linux, ABI: 3.2.0
```

## hello的虚拟地址空间

使用edb加载hello。

![edb_data_dump](https://s2.ax1x.com/2019/12/23/lSjl9A.png)

左下角的Data Dump区域即是ELF文件加载到虚拟地址中的内容显示。

考虑到上一部分中读取的节头信息

``` readflf
节头：
  [号] 名称              类型             地址              偏移量
       大小              全体大小          旗标   链接   信息   对齐
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .interp           PROGBITS         0000000000400270  00000270
       000000000000001a  0000000000000000   A       0     0     1
  [ 2] .note.ABI-tag     NOTE             000000000040028c  0000028c
       0000000000000020  0000000000000000   A       0     0     4
  [ 3] .hash             HASH             00000000004002b0  000002b0
       0000000000000030  0000000000000004   A       5     0     8
  [ 4] .gnu.hash         GNU_HASH         00000000004002e0  000002e0
       000000000000001c  0000000000000000   A       5     0     8
  [ 5] .dynsym           DYNSYM           0000000000400300  00000300
       00000000000000a8  0000000000000018   A       6     1     8
  [ 6] .dynstr           STRTAB           00000000004003a8  000003a8
       0000000000000052  0000000000000000   A       0     0     1
  [ 7] .gnu.version      VERSYM           00000000004003fa  000003fa
       000000000000000e  0000000000000002   A       5     0     2
  [ 8] .gnu.version_r    VERNEED          0000000000400408  00000408
       0000000000000020  0000000000000000   A       6     1     8
  [ 9] .rela.dyn         RELA             0000000000400428  00000428
       0000000000000030  0000000000000018   A       5     0     8
  [10] .rela.plt         RELA             0000000000400458  00000458
       0000000000000060  0000000000000018  AI       5    19     8
  [11] .init             PROGBITS         0000000000401000  00001000
       000000000000001b  0000000000000000  AX       0     0     4
  [12] .plt              PROGBITS         0000000000401020  00001020
       0000000000000050  0000000000000010  AX       0     0     16
  [13] .text             PROGBITS         0000000000401070  00001070
       0000000000000145  0000000000000000  AX       0     0     16
  [14] .fini             PROGBITS         00000000004011b8  000011b8
       000000000000000d  0000000000000000  AX       0     0     4
  [15] .rodata           PROGBITS         0000000000402000  00002000
       0000000000000030  0000000000000000   A       0     0     4
  [16] .eh_frame         PROGBITS         0000000000402030  00002030
       00000000000000e4  0000000000000000   A       0     0     8
  [17] .dynamic          DYNAMIC          0000000000403e50  00002e50
       00000000000001a0  0000000000000010  WA       6     0     8
  [18] .got              PROGBITS         0000000000403ff0  00002ff0
       0000000000000010  0000000000000008  WA       0     0     8
  [19] .got.plt          PROGBITS         0000000000404000  00003000
       0000000000000038  0000000000000008  WA       0     0     8
  [20] .data             PROGBITS         0000000000404038  00003038
       0000000000000008  0000000000000000  WA       0     0     4
  [21] .comment          PROGBITS         0000000000000000  00003040
       000000000000003e  0000000000000001  MS       0     0     1
  [22] .symtab           SYMTAB           0000000000000000  00003080
       00000000000004b0  0000000000000018          23    30     8
  [23] .strtab           STRTAB           0000000000000000  00003530
       0000000000000154  0000000000000000           0     0     1
  [24] .shstrtab         STRTAB           0000000000000000  00003684
       00000000000000c5  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)
```

初始的虚拟地址`0x400000`加上偏移量即是该段的起始虚拟地址。如`.interp`就在`0x400270`，在edb中查看如下：

![edb_data_dump_interp](https://s2.ax1x.com/2019/12/23/lSzzvR.png)

后续的段以此类推，不再赘述。

## 链接的重定位过程分析

使用以下指令进行反汇编

``` shell
objdump -d -r hello -M intel > hello_exec.asm
```

输出见附件

在对`.o`文件进行反汇编的时候，有且仅有`.text`段。在可执行程序的`main`函数部分，调用函数的与全局变量的地址与可重定向文件中的不同，这部分在链接的过程中被重定向了。此外，代码的地址也进行了重定向，与原来的地址不同。

重定向后含有代码的段还有`.init`、`.plt`、`.fini`，其中`.init`与`.fini`包含了主函数开始执行前与结束执行后所执行的代码，`.plt`段则包含了对调用库函数的包装。

在链接的时候，根据`call`的相对地址查找库中具有的函数，再将这些函数的地址放入`.plt`段，就实现了重定向。

## hello的执行流程

使用edb加载hello。

![edb_hello_start](https://s2.ax1x.com/2019/12/23/lpC8PO.png)

第一个执行的是`_dl_start`，继续进行单步调试。

由于函数调用函数过多，因此以下调用截图略去，函数的调用顺序如下：

| 函数名              |
| ------------------- |
| _dl_start           |
| _dl_init            |
| __libc_start_main   |
| __cxa_atexit        |
| __libc_csu_init     |
| _init               |
| _setjmp             |
| main                |
| printf@plt（10次）  |
| sleep@plt（10次）   |
| getchar@plt         |
| exit                |
| __run_exit_handlers |
| _dl_fini            |

## Hello的动态链接分析

根据前面的段信息可知`.got`的地址为`0x404000`，在edb中查看调用`_dl_init`前的。

![before](https://s2.ax1x.com/2019/12/23/lp1FC4.png)

再查看调用后的![after](https://s2.ax1x.com/2019/12/23/lp1k8J.png)

发现`.got`被写入。

在调用`_dl_init`之后，动态库中被调用的函数地址被确定，写入到`.got`段中，完成动态库的加载。

## 本章小结

链接能够使我们的程序能够调用库函数，而不需要知道库函数的源代码。这使得代码的复用更为方便。

# 第7章 hello进程管理

## 进程的概念与作用

进程是一个执行中成库的实例。

## 简述壳层的作用与处理流程

作用：分析用户的输入，并执行相应的指令。

处理流程：先使用行编辑器从标准输入中读取用户的输入，同时对命令进行分析。先检查命令是否为别名，如果是，则进行展开。然后检查指令是否为用户定义函数或者壳层内置指令，如果是，执行该指令。若不是，则检查系统path里是否含有该程序，如果没有，则检查该路径是否为绝对路径。如果找到了要执行的程序则执行程序，否则，告知用户指令未找到。

## Hello的fork进程创建过程

当在壳层中输入`./hello`的时候，根据上述流程，找到了在`./`目录下的`hello`文件，该文件具有`-rwxr-xr-x`的可执行权限。此时壳层调用`fork`的系统调用，内核会创建壳层进程在内存中除了真实外完全相同地址的一个副本，然后将创建的子进程的PID返回给主进程，0返回给子进程。

## Hello的execve过程

在壳层使用`fork`的系统调用创建子进程后，主进程继续执行原有代码，子进程进行`execve`系统调用来执行`hello`程序，并传递环境变量与参数。内核会覆盖子进程原有的内存空间，加载`hello`的地址空间进行覆盖，然后执行`hello`的ELF头中指定首地址的代码。此时，hello程序就得以执行。

## Hello的进程执行

进程向程序提供了一中独占处理器的假象，因此需要对多个同时运行的进程进行时间分片。由于在hello运行的时候系统中仍有在运行的其他进程，因此在hello的控制流运行一段时间片后，会保存hello的上下文，去执行其他程序的控制流，然后其他程序的时间过后，又继续执行hello，直到hello终止。

处理器中的一个寄存器的一个模式位提供了用户模式与内核模式的功能。在执行hello的时候，模式位没有设置，这样hello就处于用户模式，无法执行特权指令。当hello出现系统调用等异常的时候，控制传递到异常处理程序，模式变为内核模式，返回到应用程序代码是，又变回用户模式。这样就实现了用户模式与内核模式之间的切换。

## hello的异常与信号处理

在hello运行的时候，可能会出现异常。比如进行收到中断、系统调用、被操作系统挂起或者是出现硬件故障。也会收到信号，信号可以是键盘产生的，也可以是别的进程通过`kill`的系统调用产生的。例如在按`Ctrl+Z`会产生`SIGSTP`，按`Ctrl+C`会产生`SIGINT`。

比如在运行时

* 随便按键盘

![脸滚键盘](https://s2.ax1x.com/2019/12/23/lpIKje.png)

在最后按回车前，程序都没有停止运行，因为程序最后调用`getchar`，输入的字符都储存在缓冲区，按下回车后才能被程序读取。

* 按`Ctrl+C`

![SIGINT](https://s2.ax1x.com/2019/12/23/lpIRvF.png)

按`Ctrl+C`后，程序被`SIGINT`信号终止，并没有运行完所有代码，程序的返回值也并不是成功结束是的0。

* 按`Ctrl+Z`

![SIGSTP](https://s2.ax1x.com/2019/12/23/lpTZQO.png)

按`Ctrl+C`后，程序被`SIGINT`信号挂起，壳层显示程序被挂起，程序并没有运行完所有代码，但是也没有终止，程序的返回值也并不是成功结束是的0。

在这种情况下，继续探究：

​	1.运行`ps`

![ps](https://s2.ax1x.com/2019/12/23/lp7p1f.png)

​	表明hello的进程确实没有结束。

​	2.运行`jobs`

![jobs](https://s2.ax1x.com/2019/12/23/lp7n3V.png)

​	壳层的任务列表中仍有刚才挂起的进程，为我们稍后恢复进程提供可能。

​	3.运行`pstree`

![pstree](https://s2.ax1x.com/2019/12/23/lpHain.png)

​	在`pstree`的输出中可以清楚地看到`zsh`的子进程`hello`并没有停止。

​	4.运行`fg`

​	输入

``` shell
fg %./hello
```

![fg](https://s2.ax1x.com/2019/12/23/lpbPoj.png)

​	壳层告知进程恢复，然后继续运行，然后按回车使程序结束，一切照常。

​	5.运行kill

​	先再运行一次hello,然后与刚才同时挂起。然后输入（26462为hello的PID）

``` shell
kill 26462
fg %./hello
```

![kill](https://s2.ax1x.com/2019/12/23/lpbqnU.png)

  尝试恢复也无果，hello已经提前被结束。

## 本章小结

异常与控制使我们的程序能够处理动态的环境，知悉硬件变化，进行系统调用，是计算机系统中必不可少的部分。

# 第8章 hello的存储管理

## hello的存储器地址空间

**物理地址**是计算机主存的唯一地址，CPU在访存的时候，将物理地址通过内存总线传给主存，主存将取到的内容返回给CPU。hello在内存中也具有唯一的物理地址，CPU就通过这个地址访问hello的内存内容。

**虚拟地址**并不是真正的内存地址，CPU使用虚拟地址访问主存内容前需要使用内存管理单元将虚拟地址转换成物理地址才能使用。操作系统给每个进程都提供了一个独立的虚拟地址空间，hello也有一个独立的从`0x400000`开始的虚拟空间。

**逻辑地址**是程序角度看到的内存地址，即hello程序中的指针都是逻辑地址。

**线性地址**与**虚拟地址**是同义词。

## Intel逻辑地址到线性地址的变换-段式管理

逻辑地址由段标识符与段偏移量组成，先通过段标识符找到基址，然后将基址与段偏移相加，就得到了线性地址。但是在Linux中，所有的段基址总为0,因此Linux中的线性地址与逻辑地址是完全相同的。

## Hello的线性地址到物理地址的变换-页式管理

![Address](https://s2.ax1x.com/2019/12/23/lpzDQs.png)

从虚拟地址到物理地址的转换依靠内存管理单元，上图即是内存管理单元的大致工作流程。

## TLB与四级页表支持下的VA到PA的变换

TLB是页表的缓存，在CPU产生一个虚拟地址的时候，内存管理地址就会查询页表。如果在页表缓存中具有该虚拟地址，则可以直接使用。如果缓存不命中，则会从页表中取出地址，放入缓存中。

![PTE](https://s2.ax1x.com/2019/12/23/l9pBbq.png)

如图所示，在四级页表的支持下，虚拟地址被分成了4个VPN与1个VPO，第i个VPN对应的是第i个页表。在进行地址翻译的时候，先从1级页表找起，直至找到4级页表，加上VPO得到物理地址。

## 三级Cache支持下的物理内存访问

![Cache](https://s2.ax1x.com/2019/12/23/l9CktK.png)

如图所示，在翻译得到物理地址之后，根据地址提供组索引和块偏移在一级缓存中寻找内容，如果存在，则命中，直接取值返回，如果不命中，则继续查询下一级缓存，直取到值或者都不命中访问内存，并且在缓存中存入数据。

## hello进程fork时的内存映射

当`fork`的函数被调用的时候，内核会为新创建的进程创建各种需要的数据结构，并且为其分配一个心的PID。在为新进程创建虚拟内存的时候，表示进程内存信息的`mm_struct`、区域结构与页表的副本被创建。并且两个进程中的每个页面都被标记为只读，两每个区域结构都标记为私有的写时复制。

因此在`fork`返回时，两个进程的虚拟内存相同，在任意一个进程再尝试进行写入，就会创建新的页面，而私有空间的结构不会发生改变。

## hello进程execve时的内存映射

壳层在执行`execve`的系统调用的时候，内核会删除已存在的用户区域、映射新的私有区域、映射共享区域，最后再设置程序计数器。这样下一次调度这个进程的时候，就会从新的入口点执行，壳层的子进程也变成了hello。

## 缺页故障与缺页中断处理

![page_error](https://s2.ax1x.com/2019/12/24/l9oilT.png)

如图，在hello发生缺页异常的时候，缺页处理程序先会搜索区域结构的链表，如果发现这个虚拟地址是不合法的，就会产生段错误。如果虚拟地址合法，则会继续检查那内存的权限是否合法，如是否在只读页面尝试写入，如果没有操作权限，仍然会产生段错误。如果操作合法，则选择一个牺牲页面，若这个页面被修改过，就将其交换出去，再换入新的页面，返回。这样原来的指令就能正常地被内存管理单元翻译成物理地址，程序也能继续执行。

## 动态存储分配管理

在hello运行的时候，`printf`会调用`malloc`，就涉及到了动态内存的管理分配。

![heap](https://s2.ax1x.com/2019/12/24/l97SzV.png)

在使用`malloc`进行内存分配的时候，会从堆（如上图）中分配一块内存。具体的实现方式是使用隐式空间链表，即在要分配的内存空间的前部存入分配空间的大小。这样从堆中找出第一个可用的空闲块，进行内存分配，返回，就实现了内存的分配。

相反，在`free`的时候，对隐式链表进行修改，就表明不再使用这块内存，再下次进行`malloc`的时候就可以再进行分配。

## 本章小结

虚拟地址使得hello能够安全地访问内存，而页表缓存、多级页表与缓存能够极大地提高主存访问速度，使hello的内存访问加快。

# 第8章 hello的IO管理

## Linux的IO设备管理方法

在Linux中，所有的I/O设备都被模型化为文件，所有的输入输出都被模型化为对于文件的读取与写入。这样所有的输入输出都能以统一一致的方法执行。

## 简述Unix IO接口及其函数

在fcntl.h有以下定义

``` c
extern int open (const char *__file, int __oflag, ...) __nonnull ((1));
```

`open`函数的作用是打开用`__oflag`的方式打开`__file`，成功返回文件的描述数字。如果`__oflag`中指定了`O_CREAT`，则意为文件不存在时就创建，须要传入第三个参数表示创建文件的权限。

``` c
extern int creat (const char *__file, mode_t __mode) __nonnull ((1));
```

`creat`函数的作用是在`__file`以`__mode`创建一个新的的文件，成功时返回文件的描述数字，失败就返回-1。

在stat.h有以下定义

``` c
extern int mkdir (const char *__path, __mode_t __mode)
     __THROW __nonnull ((1));
```

`mkdir`函数的作用是在`__path`以`__mode`创建一个新的文件夹，成功时返回0，失败就返回-1。

在unistd.h有以下定义

``` c
extern int close (int __fd);
```

`close`函数的作用是关闭之前用`open`打开的文件，如果成功返回0,否则返回-1。

``` c
extern ssize_t read (int __fd, void *__buf, size_t __nbytes) __wur;
```

`read`函数的作用为从`__fd`的当前位置开始读取`__mbytes`个字节，并存入`__buf`所指定的内存区域中。成功则返回读取到的字节数，遇到文件尾返回0,错误返回-1。

``` c
extern ssize_t write (int __fd, const void *__buf, size_t __n) __wur;
```

`write`函数则是往`__fd`的当前位置从`__buf`数组里面取`__n`个字节写入，在成功的情况下返回读取的字节数 ，出错返回-1。

``` c
extern __off_t lseek (int __fd, __off_t __offset, int __whence) __THROW;
```

`lseek`函数用于修改已经打开文件的当前位置，从`__whence`处增加`__offset`个字节。

在进行I/O操作时以上函数较为常用，其余I/O相关函数这里就不一一介绍了。

## printf的实现分析

以下分析基于`glibc-2.30`，此版本的`glibc`即是hello链接到的库函数版本。

在`/stdio-common/printf.c`中

``` c
int
__printf (const char *format, ...)
{
  va_list arg;
  int done;

  va_start (arg, format);
  done = __vfprintf_internal (stdout, format, arg, 0);
  va_end (arg);

  return done;
}
```

`va_start`与`va_end`是对参数进行处理，先观察`__vfprintf_internal`。

`__vfprintf_internal`的实现在`/stdio-common/vprintf-internal.c`中。

为`__vfprintf_internal`传递了`stdout`，也就是说，处理过的内容将输出到标准输出中。

在`FILE`的输出实现中，调用了`write`的系统调用。在系统输出内容到标准输出后，终端读取到了更新了的标准输出，调用显卡对文字进行渲染，对屏幕的晶体管进行更新，这样我们就能在屏幕上看到`printf`的输出内容。

## getchar的实现分析

在`/libio/getchar.c`中

``` c
int
getchar (void)
{
  int result;
  if (!_IO_need_lock (stdin))
    return _IO_getc_unlocked (stdin);
  _IO_acquire_lock (stdin);
  result = _IO_getc_unlocked (stdin);
  _IO_release_lock (stdin);
  return result;
}
```

可以看出，如果`stdin`需要锁定，则在解锁后读取要重新锁定。

注意`result = _IO_getc_unlocked (stdin)`一行，宏展开后为

``` c
result = (__glibc_unlikely((stdin)->_IO_read_ptr >= (stdin)->_IO_read_end) ? __uflow(stdin) : *(unsigned char *)(stdin)->_IO_read_ptr++);
```

`__glibc_unlikely`与`__uflow`是与错误处理有关的宏，这里进行了对`stdin`结构体的`_IO_read_ptr`部分进行读取。

 根据`FILE`结构体的定义

``` c
char *_IO_read_ptr;	/* Current read pointer */
```

因此这里的操作就是在正常的情况下，读取标准输入中的一个字节，将当前读取的位置向前移，然后返回读取到的值。

而在`/libio/filesops.c`中对于`FILE`结构体的调用被转化为了对于`read`的系统调用。

也就是说，如果标准输入的缓冲区中有内容，则`getchar`会直接返回这个内容，并且将当前位置向前移动一个。如果缓冲区中没有内容，则产生中断，通过系统调用`read`从标准输入读取。然而在没有按回车之前，`read`不会返回，缓冲区也不会刷新。这就解释了为什么在按回车之前乱按键盘不会导致`hello`结束。

## 本章小结

有了系统级I/O以及C语言的库函数，我们的hello才能够进行输入输出（尽管只是使用了标准输入与标准输出），这对于计算机程序是十分重要的。

# 结论

经历了千辛万苦，终于将hello的源代码一步步地编译成了可执行运算，将其执行，又被回收，走完了其生命中的每一个步骤。走好！hello！虽然你被回收了，但是你的副本已经得到了保存，一个hello倒下了，千千万万个hello将会站起来！正是因为对hello的探究，本人对计算机系统的方方面面有了更深刻的理解。感谢hello！

# 参考文献

- [GCC Option Summary](https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html)
- [预处理器-维基百科](https://zh.wikipedia.org/wiki/预处理器)
- [编译器-维基百科](https://zh.wikipedia.org/wiki/%E7%B7%A8%E8%AD%AF%E5%99%A8)
- [System V Application Binary Interface AMD64 Architecture Processor Supplement](https://raw.githubusercontent.com/wiki/hjl-tools/x86-psABI/x86-64-psABI-1.0.pdf) H.J. Lu , Michael Matz , Milind Girkar , Jan Hubicka , Andreas Jaeger , Mark Mitchell
- [链接器-维基百科]([https://zh.wikipedia.org/wiki/%E9%93%BE%E6%8E%A5%E5%99%A8](https://zh.wikipedia.org/wiki/链接器))
- 深入理解计算机系统 第三版 兰德尔·布赖恩特
