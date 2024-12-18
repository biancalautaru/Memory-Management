.data
	mem: .space 4194304
	op: .space 4
	cnt: .long -1
	tip: .space 4
	n: .space 4
	desc: .space 4
	dim: .space 4
	lin: .space 4
	col: .space 4
	st: .space 4
	dr: .space 4
	stX: .space 4
	stY: .space 4
	endX: .space 4
	endY: .space 4
	fsScanf: .asciz "%ld"
	fs: .asciz "%d: ((%d, %d), (%d, %d))\n"
	fsGet: .asciz "((%d, %d), (%d, %d))\n"

.text

afisare_mem:
	pushl %ebp
	mov %esp, %ebp

	# parcurge memoria
	xor %ecx, %ecx

mem_loop:
	cmp $1048576, %ecx
	je afisare_mem_exit

	# daca ajunge la un element diferit de 0, cauta capatul din dreapta si face afisarea
	lea mem, %edi
	cmpl $0, (%edi, %ecx, 4)
	je continue_mem_loop

	movl (%edi, %ecx, 4), %ebx
	mov %ebx, desc

	pushl %ecx
	pushl %ecx
	call lin_col
	add $4, %esp
	popl %ecx

	mov lin, %eax
	mov %eax, stX
	mov col, %eax
	mov %eax, stY

	mov %ecx, %edx

file_loop:
	cmp $1048576, %edx
	je mem_loop_end

	lea mem, %edi
	mov desc, %ebx
	cmp %ebx, (%edi, %edx, 4)
	je continue_file_loop

	mov %edx, %eax
	dec %eax
	pushl %ecx
	pushl %edx
	pushl %eax
	call lin_col
	add $4, %esp
	popl %edx
	popl %ecx

	mov lin, %eax
	mov %eax, endX
	mov col, %eax
	mov %eax, endY

	pushl %ecx
	pushl %edx
	pushl endY
	pushl endX
	pushl stY
	pushl stX
	pushl desc
	pushl $fs
	call printf
	add $24, %esp
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
	movl $63, %eax

	pushl %eax
	call lin_col
	add $4, %esp

	mov lin, %eax
	mov %eax, endX
	mov col, %eax
	mov %eax, endY

	pushl endY
	pushl endX
	pushl stY
	pushl stX
	pushl desc
	pushl $fs
	call printf
	add $24, %esp

afisare_mem_exit:
	popl %ebp
	ret

lin_col:
	pushl %ebp
	mov %esp, %ebp

	# lin = edx / 1024, col = edx % 1024
	movl 8(%ebp), %eax
	xor %edx, %edx
	mov $1024, %ebx
	div %ebx
	mov %eax, lin
	mov %edx, col

	popl %ebp
	ret

.global main

main:
	# initializeaza memoria
	lea mem, %edi
	xor %ecx, %ecx

initializare:
	cmp $1048576, %ecx
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
	cmpl $1024, dim
	ja add_imposibil

	# parcurge memoria pana ajunge la un spatiu disponibil
	xor %edx, %edx

make_add:
	cmp $1048576, %edx
	je add_imposibil

	lea mem, %edi
	cmpl $0, (%edi, %edx, 4)
	jne continue_make_add

	# calculeaza linia si coloana la care se gaseste zeroul curent
	pushl %ecx
	pushl %edx
	pushl %edx
	call lin_col
	add $4, %esp
	popl %edx
	popl %ecx

	# verifica daca exista dim blocuri pe linia curenta
	mov col, %eax
	add dim, %eax
	dec %eax
	cmp $1024, %eax
	jae continue_make_add

	# verifica daca exista dim blocuri disponibile incepand cu cel curent
	mov %edx, %ebx

verif_add:
	cmp $1048576, %ebx
	je add_imposibil

	lea mem, %edi
	cmpl $0, (%edi, %ebx, 4)
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
	pushl %ecx
	pushl $0
	pushl $0
	pushl $0
	pushl $0
	pushl desc
	pushl $fs
	call printf
	add $24, %esp
	popl %ecx

	inc %ecx
	jmp add_loop

afisare_add:
	mov lin, %eax
	mov %eax, stX
	mov %eax, endX
	mov col, %eax
	mov %eax, stY
	add dim, %eax
	dec %eax
	mov %eax, endY

	# afiseaza rezultatul operatiei add
	pushl %ecx
	pushl endY
	pushl endX
	pushl stY
	pushl stX
	pushl desc
	pushl $fs
	call printf
	add $24, %esp
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
	cmp $1048576, %ecx
	je get_imposibil

	lea mem, %edi
	mov desc, %ebx
	cmp %ebx, (%edi, %ecx, 4)
	je make_get

	inc %ecx
	jmp get_loop

make_get:
	mov %ecx, st

	pushl %ecx
	pushl %ecx
	call lin_col
	add $4, %esp
	popl %ecx

	mov lin, %eax
	mov %eax, stX
	mov col, %eax
	mov %eax, stY

	# cauta capatul din dreapta
	mov %ecx, %edx

verif_get:
	cmp $1048576, %edx
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

	pushl %ecx
	pushl %edx
	call lin_col
	add $4, %esp
	popl %edx

	mov lin, %eax
	mov %eax, endX
	mov col, %eax
	mov %eax, endY

	jmp afisare_get

get_imposibil:
	movl $0, stX
	movl $0, stY
	movl $0, endX
	movl $0, endY

afisare_get:
	# afiseaza rezultatul operatiei get
	pushl %ecx
	pushl endY
	pushl endX
	pushl stY
	pushl stX
	pushl $fsGet
	call printf
	add $20, %esp
	popl %ecx

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
	cmp $1048576, %ecx
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
	# cauta inceputul unei secvente de 0
	xor %ecx, %ecx

defragmentation_loop:
	cmp $1048576, %ecx
	je afisare_defragmentation

	lea mem, %edi
	cmpl $0, (%edi, %ecx, 4)
	jne continue_defragmentation_loop

	# cauta fisierul urmator
	mov %ecx, %edx

zero_loop:
	cmp $1048576, %edx
	je afisare_defragmentation

	lea mem, %edi
	cmpl $0, (%edi, %edx, 4)
	je continue_zero_loop

	# salveaza descriptorul fisierului curent
	movl (%edi, %edx, 4), %eax
	mov %eax, desc

	# cauta capatul din dreapta al fisierului desc
	mov %edx, %ebx

file_end_loop:
	cmp $1048576, %ebx
	je make_size

	mov desc, %eax
	cmp %eax, (%edi, %ebx, 4)
	jne make_size

	inc %ebx
	jmp file_end_loop

make_size:
	# salveaza dimensiunea fisierului curent
	dec %ebx
	mov %ebx, %eax
	sub %edx, %eax
	inc %eax
	mov %eax, dim

check_size:
	# verifica daca are loc pe linia curenta incepand de la coloana la care e ecx
	pushl %ebx
	pushl %ecx
	pushl %edx
	pushl %ecx
	call lin_col
	add $4, %esp
	popl %edx
	popl %ecx
	popl %ebx

	mov dim, %eax
	add col, %eax
	dec %eax
	cmp $1024, %eax
	jae check_again

	# pune zerouri de la edx la ebx, in locul fisierului desc
	mov %edx, %eax

fill_zerouri_loop:
	cmp %ebx, %eax
	ja move_file

	movl $0, (%edi, %eax, 4)

	inc %eax
	jmp fill_zerouri_loop

move_file:
	# pune fisierul curent intre ecx si ecx + dim - 1
	mov %ecx, %edx
	add dim, %edx
	dec %edx

move_file_loop:
	cmp %edx, %ecx
	ja move_file_loop_end

	mov desc, %eax
	mov %eax, (%edi, %ecx, 4)

	inc %ecx
	jmp move_file_loop

move_file_loop_end:
	dec %ecx
	jmp continue_defragmentation_loop

check_again:
	lea mem, %edi
	cmpl $0, (%edi, %ecx, 4)
	jne continue_defragmentation_loop

	inc %ecx
	jmp check_size

continue_zero_loop:
	inc %edx
	jmp zero_loop

continue_defragmentation_loop:
	inc %ecx
	jmp defragmentation_loop

afisare_defragmentation:
	# afiseaza memoria dupa defragmentation
	call afisare_mem

	jmp loop

exit:
	pushl $0
	call fflush
	add $4, %esp

	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
