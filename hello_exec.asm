
hello：     文件格式 elf64-x86-64


Disassembly of section .init:

0000000000401000 <_init>:
  401000:	f3 0f 1e fa          	endbr64 
  401004:	48 83 ec 08          	sub    rsp,0x8
  401008:	48 8b 05 e9 2f 00 00 	mov    rax,QWORD PTR [rip+0x2fe9]        # 403ff8 <__gmon_start__>
  40100f:	48 85 c0             	test   rax,rax
  401012:	74 02                	je     401016 <_init+0x16>
  401014:	ff d0                	call   rax
  401016:	48 83 c4 08          	add    rsp,0x8
  40101a:	c3                   	ret    

Disassembly of section .plt:

0000000000401020 <.plt>:
  401020:	ff 35 e2 2f 00 00    	push   QWORD PTR [rip+0x2fe2]        # 404008 <_GLOBAL_OFFSET_TABLE_+0x8>
  401026:	ff 25 e4 2f 00 00    	jmp    QWORD PTR [rip+0x2fe4]        # 404010 <_GLOBAL_OFFSET_TABLE_+0x10>
  40102c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401030 <printf@plt>:
  401030:	ff 25 e2 2f 00 00    	jmp    QWORD PTR [rip+0x2fe2]        # 404018 <printf@GLIBC_2.2.5>
  401036:	68 00 00 00 00       	push   0x0
  40103b:	e9 e0 ff ff ff       	jmp    401020 <.plt>

0000000000401040 <getchar@plt>:
  401040:	ff 25 da 2f 00 00    	jmp    QWORD PTR [rip+0x2fda]        # 404020 <getchar@GLIBC_2.2.5>
  401046:	68 01 00 00 00       	push   0x1
  40104b:	e9 d0 ff ff ff       	jmp    401020 <.plt>

0000000000401050 <exit@plt>:
  401050:	ff 25 d2 2f 00 00    	jmp    QWORD PTR [rip+0x2fd2]        # 404028 <exit@GLIBC_2.2.5>
  401056:	68 02 00 00 00       	push   0x2
  40105b:	e9 c0 ff ff ff       	jmp    401020 <.plt>

0000000000401060 <sleep@plt>:
  401060:	ff 25 ca 2f 00 00    	jmp    QWORD PTR [rip+0x2fca]        # 404030 <sleep@GLIBC_2.2.5>
  401066:	68 03 00 00 00       	push   0x3
  40106b:	e9 b0 ff ff ff       	jmp    401020 <.plt>

Disassembly of section .text:

0000000000401070 <_start>:
  401070:	f3 0f 1e fa          	endbr64 
  401074:	31 ed                	xor    ebp,ebp
  401076:	49 89 d1             	mov    r9,rdx
  401079:	5e                   	pop    rsi
  40107a:	48 89 e2             	mov    rdx,rsp
  40107d:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
  401081:	50                   	push   rax
  401082:	54                   	push   rsp
  401083:	49 c7 c0 b0 11 40 00 	mov    r8,0x4011b0
  40108a:	48 c7 c1 40 11 40 00 	mov    rcx,0x401140
  401091:	48 c7 c7 b0 10 40 00 	mov    rdi,0x4010b0
  401098:	ff 15 52 2f 00 00    	call   QWORD PTR [rip+0x2f52]        # 403ff0 <__libc_start_main@GLIBC_2.2.5>
  40109e:	f4                   	hlt    
  40109f:	90                   	nop

00000000004010a0 <_dl_relocate_static_pie>:
  4010a0:	f3 0f 1e fa          	endbr64 
  4010a4:	c3                   	ret    
  4010a5:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  4010ac:	00 00 00 
  4010af:	90                   	nop

00000000004010b0 <main>:
  4010b0:	55                   	push   rbp
  4010b1:	48 89 e5             	mov    rbp,rsp
  4010b4:	48 83 ec 20          	sub    rsp,0x20
  4010b8:	c7 45 ec 00 00 00 00 	mov    DWORD PTR [rbp-0x14],0x0
  4010bf:	89 7d f8             	mov    DWORD PTR [rbp-0x8],edi
  4010c2:	48 89 75 f0          	mov    QWORD PTR [rbp-0x10],rsi
  4010c6:	83 7d f8 03          	cmp    DWORD PTR [rbp-0x8],0x3
  4010ca:	74 1b                	je     4010e7 <main+0x37>
  4010cc:	48 bf 04 20 40 00 00 	movabs rdi,0x402004
  4010d3:	00 00 00 
  4010d6:	b0 00                	mov    al,0x0
  4010d8:	e8 53 ff ff ff       	call   401030 <printf@plt>
  4010dd:	bf 01 00 00 00       	mov    edi,0x1
  4010e2:	e8 69 ff ff ff       	call   401050 <exit@plt>
  4010e7:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
  4010ee:	83 7d fc 0a          	cmp    DWORD PTR [rbp-0x4],0xa
  4010f2:	7d 38                	jge    40112c <main+0x7c>
  4010f4:	48 8b 45 f0          	mov    rax,QWORD PTR [rbp-0x10]
  4010f8:	48 8b 70 08          	mov    rsi,QWORD PTR [rax+0x8]
  4010fc:	48 8b 45 f0          	mov    rax,QWORD PTR [rbp-0x10]
  401100:	48 8b 50 10          	mov    rdx,QWORD PTR [rax+0x10]
  401104:	48 bf 23 20 40 00 00 	movabs rdi,0x402023
  40110b:	00 00 00 
  40110e:	b0 00                	mov    al,0x0
  401110:	e8 1b ff ff ff       	call   401030 <printf@plt>
  401115:	8b 3c 25 3c 40 40 00 	mov    edi,DWORD PTR ds:0x40403c
  40111c:	e8 3f ff ff ff       	call   401060 <sleep@plt>
  401121:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
  401124:	83 c0 01             	add    eax,0x1
  401127:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
  40112a:	eb c2                	jmp    4010ee <main+0x3e>
  40112c:	e8 0f ff ff ff       	call   401040 <getchar@plt>
  401131:	31 c0                	xor    eax,eax
  401133:	48 83 c4 20          	add    rsp,0x20
  401137:	5d                   	pop    rbp
  401138:	c3                   	ret    
  401139:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000401140 <__libc_csu_init>:
  401140:	f3 0f 1e fa          	endbr64 
  401144:	41 57                	push   r15
  401146:	4c 8d 3d 03 2d 00 00 	lea    r15,[rip+0x2d03]        # 403e50 <_DYNAMIC>
  40114d:	41 56                	push   r14
  40114f:	49 89 d6             	mov    r14,rdx
  401152:	41 55                	push   r13
  401154:	49 89 f5             	mov    r13,rsi
  401157:	41 54                	push   r12
  401159:	41 89 fc             	mov    r12d,edi
  40115c:	55                   	push   rbp
  40115d:	48 8d 2d ec 2c 00 00 	lea    rbp,[rip+0x2cec]        # 403e50 <_DYNAMIC>
  401164:	53                   	push   rbx
  401165:	4c 29 fd             	sub    rbp,r15
  401168:	48 83 ec 08          	sub    rsp,0x8
  40116c:	e8 8f fe ff ff       	call   401000 <_init>
  401171:	48 c1 fd 03          	sar    rbp,0x3
  401175:	74 1f                	je     401196 <__libc_csu_init+0x56>
  401177:	31 db                	xor    ebx,ebx
  401179:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  401180:	4c 89 f2             	mov    rdx,r14
  401183:	4c 89 ee             	mov    rsi,r13
  401186:	44 89 e7             	mov    edi,r12d
  401189:	41 ff 14 df          	call   QWORD PTR [r15+rbx*8]
  40118d:	48 83 c3 01          	add    rbx,0x1
  401191:	48 39 dd             	cmp    rbp,rbx
  401194:	75 ea                	jne    401180 <__libc_csu_init+0x40>
  401196:	48 83 c4 08          	add    rsp,0x8
  40119a:	5b                   	pop    rbx
  40119b:	5d                   	pop    rbp
  40119c:	41 5c                	pop    r12
  40119e:	41 5d                	pop    r13
  4011a0:	41 5e                	pop    r14
  4011a2:	41 5f                	pop    r15
  4011a4:	c3                   	ret    
  4011a5:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  4011ac:	00 00 00 00 

00000000004011b0 <__libc_csu_fini>:
  4011b0:	f3 0f 1e fa          	endbr64 
  4011b4:	c3                   	ret    

Disassembly of section .fini:

00000000004011b8 <_fini>:
  4011b8:	f3 0f 1e fa          	endbr64 
  4011bc:	48 83 ec 08          	sub    rsp,0x8
  4011c0:	48 83 c4 08          	add    rsp,0x8
  4011c4:	c3                   	ret    
