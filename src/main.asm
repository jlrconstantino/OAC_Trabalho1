	.data
	.align 0

# Strings de entrada
wellcomeMessage:	.asciiz "Wellcome to 32b Base Converter.\nWhen a base is requested, consider \'B\', \'D\' and \'H\' as binary, decimal and hexadecimal bases respectively.\n"
inputBaseRequest:	.asciiz "Enter input base: "
inputNumRequest:	.asciiz "Enter number: "
outputBaseRequest:      .asciiz "Enter output base: "

# Strings de sa�da
outputNumMessage:	.asciiz "Your final number is: "
invalidBaseMessage:	.asciiz "Informed base is invalid."
invalidNumMessage:	.asciiz "Informed number is invalid for the requested base."
tooBigNumMessage:	.asciiz "Informed number is too big for the requested base."

	.align 2
	
# Tamanho m�ximo de leitura
chunkSize:		.word 64

	.text
	.globl main

# Procedimento principal
main:
	# Prepara��o da pilha para as vari�veis utilizadas pela main: 
	# 2 strings de tamanho fixo = "chunkSize" + 1 palavra
	lw $t0, chunkSize
	mul $t0, $t0, -2
	addi $t0, $t0, -4
	add $sp, $sp, $t0

	# Impress�o da mensagem inicial
	li $v0, 4
	la $a0, wellcomeMessage
	syscall
	
	# Impress�o da solicita��o de base de entrada
	li $v0, 4
	la $a0, inputBaseRequest
	syscall
	
	# Obt�m o deslocamento de inser��o da string da base
	lw $t0, chunkSize
	mul $t0, $t0, 2
	addi $t0, $t0, 4
	
	# L� a base de entrada
	li $v0, 8
	add $a0, $t0, $sp
	lw $a1, chunkSize
	syscall
		
	# Salva o caractere em $s0
	lb $s0, ($a0)
	
	# Valida a base de entrada
	beq $s0, 'B', main_select_bin_input
	beq $s0, 'D', main_select_dec_input
	beq $s0, 'H', main_select_hex_input
	j invalid_base_exception
	
	# Sele��o do r�tulo a seguir para a base de entrada
	main_select_bin_input:
		la $s0, bin_input_base
		j main_exit_input_selection
	main_select_dec_input:
		la $s0, dec_input_base
		j main_exit_input_selection
	main_select_hex_input:
		la $s0, hex_input_base
	main_exit_input_selection:
	
	# Requisita a inser��o do n�mero
	li $v0, 4
	la $a0, inputNumRequest
	syscall
	
	# Obt�m o deslocamento de inser��o da string num�rica
	lw $t0, chunkSize
	addi $t0, $t0, 4
	
	# Obt�m a string do n�mero
	li $v0, 8
	add $a0, $t0, $sp
	lw $a1, chunkSize
	syscall
	
	# Chaveia em rela��o � base selecionada
	jr $s0
	
	# Base de entrada bin�ria
	bin_input_base:
	
		# Pr�-processamento da string
		lw $t0, chunkSize
		addi $t0, $t0, 4
		add $a0, $t0, $sp
		jal validate_and_preprocess_binary
		move $t0, $v0
		
		# Valida��o de formato
		bgt $t0, 0, main_start_bin_len_val
		j invalid_number_exception
		
		# Valida��o de tamanho
		main_start_bin_len_val:
			blt $t0, 33, main_exit_bin_len_val
			j too_big_number_exception
		main_exit_bin_len_val:
		
		# Gera o decimal intermedi�rio e o empilha
		lw $t1, chunkSize
		addi $t1, $t1, 4
		add $a0, $t1, $sp
		move $a1, $t0
		jal binary_to_decimal
		sw $v0, 0 ($sp)
		
		j main_output_base_select
	
	# Base de entrada decimal
	dec_input_base:
	
		# Pr�-processamento da string
		lw $t0, chunkSize
		addi $t0, $t0, 4
		add $a0, $t0, $sp
		jal validate_and_preprocess_decimal
		move $t0, $v0
	
		# Valida��o de formato
		bgt $t0, 0, main_start_dec_len_val
		j invalid_number_exception
		
		# Valida��o de tamanho e gera��o do n�mero correspondente
		main_start_dec_len_val:
		
			# Valida��o do tamanho
			bgt $t0, 10, too_big_number_exception
				
			# Sele��o da posi��o da string num�rica
			lw $t1, chunkSize
			addi $t1, $t1, 4
			
			# Gera��o e empilhamento do n�mero
			add $a0, $t1, $sp
			move $a1, $t0
			jal atoui
			sw $v0, 0 ($sp)
			
			j main_output_base_select
	
	# Base de entrada hexadecimal
	hex_input_base:
		
		# Pr�-processamento da string
		lw $t0, chunkSize
		addi $t0, $t0, 4
		add $a0, $t0, $sp
		jal validate_and_preprocess_hexadecimal
		move $t0, $v0
		move $t1, $v1
		
		# Valida��o de formato
		bgt $t0, 0, main_start_hex_len_val
		j invalid_number_exception
		
		# Valida��o de tamanho
		main_start_hex_len_val:
			blt $t0, 9, main_exit_hex_len_val
			j too_big_number_exception
		main_exit_hex_len_val:
		
		# Gera o decimal intermedi�rio e o empilha
		lw $t1, chunkSize
		addi $t1, $t1, 4
		add $a0, $t1, $sp
		move $a1, $t0
		jal hex_to_dec
		sw $v0, 0 ($sp)
		
		move $a0, $v0
		li $v0, 1
		syscall
	
	# Sele��o da base de sa�da
	main_output_base_select:
	
		# Impress�o da mensagem de solicita��o
		li $v0, 4
		la $a0, outputBaseRequest
		syscall
		
		# Obt�m o deslocamento de inser��o da string da base
		lw $t0, chunkSize
		mul $t0, $t0, 2
		addi $t0, $t0, 4
		
		# L� a base de sa�da
		li $v0, 8
		add $a0, $t0, $sp
		lw $a1, chunkSize
		syscall
		
		# Salva o caractere em $s0
		lb $s0, ($a0)
	
		# Impress�o da mensagem final
		li $v0, 4
		la $a0, outputNumMessage
		syscall
		
		# Chaveia em rela��o � base selecionada
		beq $s0, 'B', bin_output_base
		beq $s0, 'D', dec_output_base
		beq $s0, 'H', hex_output_base
		j invalid_base_exception
	
	# Base de sa�da bin�ria
	bin_output_base:
		lw $a0, 0 ($sp)
		li $a1, 2
		jal imprimir_inteiro_na_base
		j main_exit
	
	# Base de sa�da decimal
	dec_output_base:
		li $v0, 36
		lw $a0, 0 ($sp)
		syscall
		j main_exit
	
	# Base de sa�da hexadecimal
	hex_output_base:
		lw $a0, 0 ($sp)
		li $a1, 16
		jal imprimir_inteiro_na_base
		j main_exit
		
	# Exce��o de base inv�lida
	invalid_base_exception:
		li $v0, 4
		la $a0, invalidBaseMessage
		syscall
		j main_exit
		
	# Exce��o de n�mero com formata��o inv�lida
	invalid_number_exception:
		li $v0, 4
		la $a0, invalidNumMessage
		syscall
		j main_exit
	
	# Exce��o de n�mero com tamanho inv�lido
	too_big_number_exception:
		li $v0, 4
		la $a0, tooBigNumMessage
		syscall
		j main_exit
	
	# Sa�da do procedimento principal
	main_exit:
		lw $t0, chunkSize
		mul $t0, $t0, 2
		addi $t0, $t0, 4
		add $sp, $sp, $t0
		li $v0, 10
		syscall