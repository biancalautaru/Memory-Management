.data
	mem: .space 4096
	op: .space 4
	cnt: .long -1
	tip: .space 4
	n: .space 4
	desc: .space 4
	dim: .space 4
	st: .space 4
	dr: .space 4
	zerouri: .space 4
	fsScanf: .asciz "%ld"
	fs: .asciz "%d: (%d, %d)\n"
	fsGet: .asciz "(%d, %d)\n"

.text

afisare_mem:
	pushl %ebp
	mov %esp, %ebp

	# parcurge memoria
	xor %ecx, %ecx

mem_loop:
	cmp $1024, %ecx
	je afisare_mem_exit

	# daca ajunge la un element diferit de 0, cauta capatul din dreapta si face afisarea
	lea mem, %edi
	cmpl $0, (%edi, %ecx, 4)
	je continue_mem_loop

	movl (%edi, %ecx, 4), %ebx
	mov %ebx, desc
	mov %ecx, st

	mov %ecx, %edx

file_loop:
	cmp $1024, %edx
	je mem_loop_end

	lea mem, %edi
	mov desc, %ebx
	cmp %ebx, (%edi, %edx, 4)
	je continue_file_loop

	mov %edx, dr
	subl $1, dr

	pushl %ecx
	pushl %edx
	pushl dr
	pushl st
	pushl desc
	pushl $fs
	call printf
	add $16, %esp
	popl %edx
	popl %ecx

	mov %edx, %ecx
	jmp mem_loop

continue_file_loop:
	inc %edx
	jmp file_loop

continue_mem_loop:
	inc %ecx
	jmp mem_loop

mem_loop_end:
	movl $1023, dr

	pushl dr
	pushl st
	pushl desc
	pushl $fs
	call printf
	add $16, %esp

afisare_mem_exit:
	popl %ebp
	ret

.global main

main:
	# initializeaza memoria
	lea mem, %edi
	xor %ecx, %ecx

initializare:
	cmp $1024, %ecx
	jmp start

	movl $0, (%edi, %ecx, 4)
	inc %ecx
	jmp initializare

start:
	# citeste op
	pushl $op
	pushl $fsScanf
	call scanf
	add $8, %esp

loop:
	# creste counterul de operatii
	addl $1, cnt

	# conditia de oprire a programului
	mov cnt, %eax
	cmpl op, %eax
	je exit

	# citeste tip
	pushl $tip
	pushl $fsScanf
	call scanf
	add $8, %esp

	# daca e operatia add
	mov $1, %eax
	cmp %eax, tip
	je add

	# daca e operatia get
	mov $2, %eax
	cmp %eax, tip
	je get

	# daca e operatia delete
	mov $3, %eax
	cmp %eax, tip
	je delete

	# daca e operatia defragmentation
	mov $4, %eax
	cmp %eax, tip
	je defragmentation

add:
	# citeste n
	pushl $n
	pushl $fsScanf
	call scanf
	add $8, %esp

	xor %ecx, %ecx

add_loop:
	cmp n, %ecx
	je loop

	# citeste descriptorul
	pushl %ecx
	pushl $desc
	pushl $fsScanf
	call scanf
	add $8, %esp
	popl %ecx

	# citeste dimensiunea
	pushl %ecx
	pushl $dim
	pushl $fsScanf
	call scanf
	add $8, %esp
	popl %ecx

	# dim /= 8
	mov dim, %eax
	xor %edx, %edx
	mov $8, %ebx
	div %ebx
	mov %eax, dim

	# rotunjeste in sus daca restul e diferit de 0
	cmp $0, %edx
	je minim

	addl $1, dim

minim:
	# fisierul trebuie sa ocupe minim 2 blocuri
	mov dim, %eax
	cmp $2, %eax
	ja start_add

	movl $2, dim

start_add:
	# parcurge memoria pana ajunge la un spatiu disponibil
	xor %edx, %edx

make_add:
	cmp $1024, %edx
	je add_imposibil

	lea mem, %edi
	cmpl $0, (%edi, %edx, 4)
	jne continue_make_add

	# verifica daca exista dim blocuri disponibile incepand cu cel curent
	mov %edx, %ebx

verif_add:
	cmp $1024, %ebx
	je add_imposibil

	lea mem, %edi
	cmpl $0, (%edi, %edx, 4)
	jne continue_make_add

	mov %ebx, %eax
	sub %edx, %eax
	inc %eax

	cmp dim, %eax
	je add_file

	inc %ebx
	jmp verif_add

continue_make_add:
	inc %edx
	jmp make_add

add_file:
	mov %edx, st
	mov %ebx, dr

	# adauga fisierul in memorie
	lea mem, %edi
	mov st, %edx

update_add:
	cmp dr, %edx
	ja afisare_add

	mov desc, %eax
	movl %eax, (%edi, %edx, 4)

	inc %edx
	jmp update_add

add_imposibil:
	movl $0, st
	movl $0, dr

afisare_add:
	# afiseaza rezultatul operatiei add
	pushl %ecx
	pushl dr
	pushl st
	pushl desc
	pushl $fs
	call printf
	add $16, %esp
	popl %ecx

	inc %ecx
	jmp add_loop

get:
	# citeste descriptorul
	pushl $desc
	pushl $fsScanf
	call scanf
	add $8, %esp

	# parcurge memoria pana ajunge la un element desc
	xor %ecx, %ecx

get_loop:
	cmp $1024, %ecx
	je get_imposibil

	lea mem, %edi
	mov desc, %ebx
	cmp %ebx, (%edi, %ecx, 4)
	je make_get

	inc %ecx
	jmp get_loop

make_get:
	mov %ecx, st

	# cauta capatul din dreapta
	mov %ecx, %edx

verif_get:
	cmp $1024, %edx
	je update_get

	lea mem, %edi
	mov desc, %ebx
	cmp %ebx, (%edi, %edx, 4)
	jne update_get

	inc %edx
	jmp verif_get

update_get:
	dec %edx
	mov %edx, dr
	jmp afisare_get

get_imposibil:
	movl $0, st
	movl $0, dr

afisare_get:
	# afiseaza rezultatul operatiei get
	pushl dr
	pushl st
	pushl $fsGet
	call printf
	add $12, %esp

	jmp loop

delete:
	# citeste descriptorul
	pushl $desc
	pushl $fsScanf
	call scanf
	add $8, %esp

	# inlocuieste cu 0 unde apare desc in memorie
	xor %ecx, %ecx

delete_loop:
	cmp $1024, %ecx
	je afisare_delete

	lea mem, %edi
	mov desc, %ebx
	cmp %ebx, (%edi, %ecx, 4)
	jne continue_delete_loop

	movl $0, (%edi, %ecx, 4)

continue_delete_loop:
	inc %ecx
	jmp delete_loop

afisare_delete:
	# afiseaza memoria dupa delete
	call afisare_mem

	jmp loop

defragmentation:
	movl $0, zerouri

	# cauta inceputul unei secvente de 0
	xor %ecx, %ecx

defragmentation_loop:
	cmp $1024, %ecx
	je adauga_zerouri

	lea mem, %edi
	cmpl $0, (%edi, %ecx, 4)
	jne continue_defragmentation_loop

	# cauta capatul din dreapta al secventei de 0
	mov %ecx, %edx
	
zero_loop:
	cmp $1024, %edx
	je adauga_zerouri

	lea mem, %edi
	cmpl $0, (%edi, %edx, 4)
	je continue_zero_loop

	# muta elementele de la edx pana la final incat sa inceapa la ecx
	mov %edx, %ebx
	pushl %ecx

move_loop:
	cmp $1024, %ebx
	je after_move

	movl (%edi, %ebx, 4), %eax
	movl %eax, (%edi, %ecx, 4)

	inc %ecx
	inc %ebx
	jmp move_loop

continue_zero_loop:
	addl $1, zerouri
	inc %edx
	jmp zero_loop

after_move:
	popl %ecx
	
continue_defragmentation_loop:
	inc %ecx
	jmp defragmentation_loop

adauga_zerouri:
	# scade din totalul de zerouri pe cele de la finalul memoriei
	add %ecx, zerouri
	subl $1024, zerouri

	# adauga atatea zerouri la finalul memoriei cate au fost sterse
	mov $1024, %ecx
	sub zerouri, %ecx

adauga_zerouri_loop:
	cmp $1024, %ecx
	je afisare_defragmentation

	lea mem, %edi
	movl $0, (%edi, %ecx, 4)

	inc %ecx
	jmp adauga_zerouri_loop

afisare_defragmentation:
	# afiseaza memoria dupa defragmentation
	call afisare_mem

	jmp loop

exit:
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80

