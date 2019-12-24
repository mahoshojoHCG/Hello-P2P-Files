
hello.o：     文件格式 elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:	55                   	push   rbp
   1:	48 89 e5             	mov    rbp,rsp
   4:	48 83 ec 20          	sub    rsp,0x20
   8:	c7 45 ec 00 00 00 00 	mov    DWORD PTR [rbp-0x14],0x0
   f:	89 7d f8             	mov    DWORD PTR [rbp-0x8],edi
  12:	48 89 75 f0          	mov    QWORD PTR [rbp-0x10],rsi
  16:	83 7d f8 03          	cmp    DWORD PTR [rbp-0x8],0x3
  1a:	74 1b                	je     37 <main+0x37>
  1c:	48 bf 00 00 00 00 00 	movabs rdi,0x0
  23:	00 00 00 
			1e: R_X86_64_64	.rodata.str1.1
  26:	b0 00                	mov    al,0x0
  28:	e8 00 00 00 00       	call   2d <main+0x2d>
			29: R_X86_64_PLT32	printf-0x4
  2d:	bf 01 00 00 00       	mov    edi,0x1
  32:	e8 00 00 00 00       	call   37 <main+0x37>
			33: R_X86_64_PLT32	exit-0x4
  37:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
  3e:	83 7d fc 0a          	cmp    DWORD PTR [rbp-0x4],0xa
  42:	7d 38                	jge    7c <main+0x7c>
  44:	48 8b 45 f0          	mov    rax,QWORD PTR [rbp-0x10]
  48:	48 8b 70 08          	mov    rsi,QWORD PTR [rax+0x8]
  4c:	48 8b 45 f0          	mov    rax,QWORD PTR [rbp-0x10]
  50:	48 8b 50 10          	mov    rdx,QWORD PTR [rax+0x10]
  54:	48 bf 00 00 00 00 00 	movabs rdi,0x0
  5b:	00 00 00 
			56: R_X86_64_64	.rodata.str1.1+0x1f
  5e:	b0 00                	mov    al,0x0
  60:	e8 00 00 00 00       	call   65 <main+0x65>
			61: R_X86_64_PLT32	printf-0x4
  65:	8b 3c 25 00 00 00 00 	mov    edi,DWORD PTR ds:0x0
			68: R_X86_64_32S	sleepsecs
  6c:	e8 00 00 00 00       	call   71 <main+0x71>
			6d: R_X86_64_PLT32	sleep-0x4
  71:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
  74:	83 c0 01             	add    eax,0x1
  77:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
  7a:	eb c2                	jmp    3e <main+0x3e>
  7c:	e8 00 00 00 00       	call   81 <main+0x81>
			7d: R_X86_64_PLT32	getchar-0x4
  81:	31 c0                	xor    eax,eax
  83:	48 83 c4 20          	add    rsp,0x20
  87:	5d                   	pop    rbp
  88:	c3                   	ret    
