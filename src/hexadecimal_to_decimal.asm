	.text
	.globl hex_to_dec
	
# Obtém um inteiro sem sinal de uma string, em codificação ASCII e pré-validada, contendo valor hexadecimal.
#
# Parâmetros: 
#	- $a0: endereço do primeiro byte da string
#	- $a1: comprimento efetivo da string
#	- $ra: endereço de retorno para o local de chamada
# Retorno: 
#	- $v0: inteiro sem sinal de saída
hex_to_dec:

	# Posiciona-se ao final da string
	add $a0, $a0, $a1
	addi $a0, $a0, -1
	
	# Calculará o inteiro
	li $s0, 0
	
	# Farão a adaptação decimal
	li $s1, 1
	li $s2, 16
	
	hex_to_dec_start_loop:
	
		# Verifica a permanência na string
		beq $a1, $zero, hex_to_dec_exit_loop
	
		# Acessa o caractere atual
		lb $t0, 0 ($a0)
		
		# Nota: em ASCII, '0' < 'A' < 'a'
		bgt $t0, 'F', hex_to_dec_manage_lower_case
		bgt $t0, '9', hex_to_dec_manage_upper_case
		
		# Cálculo em caractere [0, 9]
		addi $t0, $t0, -48
		j hex_to_dec_exit_calculus
		
		# Cálculo em caractere [a, f]
		hex_to_dec_manage_lower_case:
			addi $t0, $t0, -87
			j hex_to_dec_exit_calculus
			
		# Cálculo em caractere [A, F]
		hex_to_dec_manage_upper_case:
			addi $t0, $t0, -55
			
		hex_to_dec_exit_calculus:
		
		# Término do cálculo
		mul $t0, $t0, $s1
		mul $s1, $s1, $s2
		add $s0, $s0, $t0
		
		# Avança na leitura
		addi $a0, $a0, -1
		addi $a1, $a1, -1
		
		# Volta para o início do laço
		j hex_to_dec_start_loop
	
	hex_to_dec_exit_loop:
	
	# Retorno
	move $v0, $s0
	jr $ra