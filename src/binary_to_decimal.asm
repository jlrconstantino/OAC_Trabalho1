	.data
	.align 0
#aux: .asciiz "00010001"

	.text
	.globl binary_to_decimal
	
# Parâmetros: 
#	- $a0: endereço do primeiro byte da string binaria
#	- $a1: comprimento da string binaria
#	- $ra: endereço de retorno para o local de chamada
#
# Retorno:
#	- $v0: valor do decimal

binary_to_decimal :
	#la $a0, aux
	#li $a1, 8

	addi $sp, $sp, -8
	sw $a0, 0 ($sp)
	sw $a1, 4 ($sp)
	
	add $t0, $a0, $a1
	addi $t0, $t0, -1#t0 agora armazena o endereço do ultimo caractere da string binaria ja validada
	addi $t1, $0, 1#armazena a potencia de 2 atual
	addi $t2, $0, 2#armazena o 2 para a potencia, ja que nao existe "multiply immediate"	
	addi $t3, $0, 0
	
	startLoop:
	beqz $a1, endLoop
	lb $t4, 0($t0)#t4 recebe o ultimo caractere da string
	addi $t4, $t4, -48#dele e subtraido 48, para alinhar a tabela ascii com os valores numericos
	mul $t4, $t4, $t1#esse caractere e multiplicado pela potencia de 2 atual
	add $t3, $t3, $t4#e somado ao registrador que acumula o valor final do decimal
	
	mul $t1, $t1, $t2#atualiza-se a potencia de 2
	addi $a1, $a1, -1#subtrai-se 1 do comprimento da string, para saber quando ela acaba
	addi $t0, $t0, -1#decrementa-se o endereco de t0
	j startLoop
	endLoop:
	
	addi $v0, $t3, 0
	lw $a1, 4 ($sp)
	lw $a0, 0 ($sp)
	addi $sp, $sp, 8
	jr $ra
	#li $v0, 10
	#syscall