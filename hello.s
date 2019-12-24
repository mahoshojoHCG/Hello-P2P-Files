	.text
	.intel_syntax noprefix
	.file	"hello.c"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 32
	mov	dword ptr [rbp - 4], 0
	mov	dword ptr [rbp - 8], edi
	mov	qword ptr [rbp - 16], rsi
	cmp	dword ptr [rbp - 8], 3
	je	.LBB0_2
# %bb.1:
	lea	rdi, [rip + .L.str]
	mov	al, 0
	call	printf@PLT
	mov	edi, 1
	mov	dword ptr [rbp - 24], eax # 4-byte Spill
	call	exit@PLT
.LBB0_2:
	mov	dword ptr [rbp - 20], 0
.LBB0_3:                                # =>This Inner Loop Header: Depth=1
	cmp	dword ptr [rbp - 20], 10
	jge	.LBB0_6
# %bb.4:                                #   in Loop: Header=BB0_3 Depth=1
	mov	rax, qword ptr [rbp - 16]
	mov	rsi, qword ptr [rax + 8]
	mov	rax, qword ptr [rbp - 16]
	mov	rdx, qword ptr [rax + 16]
	lea	rdi, [rip + .L.str.1]
	mov	al, 0
	call	printf@PLT
	mov	edi, dword ptr [rip + sleepsecs]
	mov	dword ptr [rbp - 28], eax # 4-byte Spill
	call	sleep@PLT
# %bb.5:                                #   in Loop: Header=BB0_3 Depth=1
	mov	eax, dword ptr [rbp - 20]
	add	eax, 1
	mov	dword ptr [rbp - 20], eax
	jmp	.LBB0_3
.LBB0_6:
	call	getchar@PLT
	xor	ecx, ecx
	mov	dword ptr [rbp - 32], eax # 4-byte Spill
	mov	eax, ecx
	add	rsp, 32
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	sleepsecs,@object       # @sleepsecs
	.data
	.globl	sleepsecs
	.p2align	2
sleepsecs:
	.long	2                       # 0x2
	.size	sleepsecs, 4

	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"Usage: Hello \345\255\246\345\217\267 \345\247\223\345\220\215\357\274\201\n"
	.size	.L.str, 31

	.type	.L.str.1,@object        # @.str.1
.L.str.1:
	.asciz	"Hello %s %s\n"
	.size	.L.str.1, 13


	.ident	"clang version 9.0.0 (tags/RELEASE_900/final)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym printf
	.addrsig_sym exit
	.addrsig_sym sleep
	.addrsig_sym getchar
	.addrsig_sym sleepsecs
