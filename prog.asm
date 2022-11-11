#Ryan Braz Tintore Viana, 11846690
#Gustavo Barbosa Sanchez, 11802440

#Feito no MARS em ambiente Windows.

#Antes de rodar o programa, por favor, se atente ao caminho do "fileName" e "binaryFileName"
#que pode alterar de acordo com a maquina utilizada.
.data

	fileName: .asciiz "D:/road100x100bin.pgm"
	binaryFileName: .asciiz "D:/road-100x100-limiar-version.pgm"
	buffer: .space 10038
	histogram: .space 256
	blackPixels: .word 0
	whitePixels: .word 0
	thresholdMsg: .asciiz "Please enter the threshold value for binarize the image: "
	newHistogramMsg: .asciiz "The histogram of the binarized image is: "
	rightParenthesis: .asciiz "("
	twoDots: .asciiz ":"
	leftParenthesis: .asciiz ")"
	newLine: .asciiz "\n"
	space: .asciiz " "

.text

	main:	

		#syscall para abrir o arquivo
		li $v0, 13 	  
		la $a0, fileName  #arquivo que sera aberto
		li $a1, 0 	  
		li $a2, 0         
		syscall		
			

		move $s6, $v0   #salva o descritor do arquivo
		li $v0, 14      #le do arquivo aberto
		move $a0, $s6   
		la $a1, buffer  #endereco do buffer em que os dados serao lidos
		li $a2, 10038	
		syscall
		
        addiu $t0, $zero, 38  #inicializa a variavel para ler os bits (pula os dados iniciais)	
		jal createHistogram   #rotina que cria o histograma.
		
		addi $t0, $zero, 0    #inicializa o contador.
		jal printHistogram    #rotina que printa o histograma.
		
		
		li $v0, 4
		la $a0, thresholdMsg
		syscall

		#leitura do limiar.
		li $v0, 5      
		syscall

		#salva o limiar.
		move $s1, $v0  
		
		addi $t0, $zero, 38   
		jal binarizeLoop     #rotina que vai binarizar a imagem de acordo com o limiar lido.
		
		
		li $v0, 4
		la $a0, newHistogramMsg
		syscall
		
		jal printBlackAndWhite  #imprime o histograma da imagem binarizada.
		
		
		#cria um novo arquivo para a imagem binarizada.
		#usa uma syscall para abrir um arquivo e como ele nao existe, eh criado.
		li   $v0, 13              
		la   $a0, binaryFileName  
		li   $a1, 1               #flag para abrir no modo de escrita
		li   $a2, 0         	  
		syscall

		move $s0, $v0      	  #salva o descritor do arquivo. 
		
		#escreve no arquivo binarizado por meio de uma syscall.
		li   $v0, 15      
		move $a0, $s0      
		la   $a1, buffer  
		li   $a2, 10038   
		syscall           
		
		#fecha o arquivo da imagem binarizada.
		li   $v0, 16       
		move $a0, $s6      
		syscall  


		#fecha o arquivo original.
		li $v0, 16
		move $a0, $s6
		syscall
		
		#END PROGRAM
		li $v0, 10
		syscall
		
		##FUNCTIONS##
		
		createHistogram:
			beq $t0, 10038, finishCreateHistogram  #se tivermos lido todos os bytes vamos para o proximo passo.	
		
			lbu $t1, buffer($t0)	     	       #load byte da posicao 38 < $t0 < 10038 do buffer
			lbu $t2, histogram($t1)                #load byte do histograma na posicao correspondente ao valor do byte (0 ~ 255)
			addiu $t2, $t2, 1                      #somar 1 significa que temos mais 1 byte de valor igual a posicao do histograma.    
			sb $t2, histogram($t1)                 #salva o novo valor no "vetor" histograma.
			
			addi $t0, $t0, 1                       #incrementa o contador
			
			j createHistogram	               #repete
			finishCreateHistogram:
			jr $ra
			
		printHistogram:	
			beq $t0, 256, finishPrintHistogram  #loop	
			
			li $v0, 4			    #apenas imprimindo o valor de todas posicoes do histograma.
			la $a0, rightParenthesis
			syscall		
			
			li $v0, 1
			move $a0, $t0
			syscall		
			
			li $v0, 4
			la $a0, twoDots
			syscall	
			
			lbu $t1, histogram($t0)
			li $v0, 1
			move $a0, $t1
			syscall	
			
			li $v0, 4
			la $a0, leftParenthesis
			syscall

			li $v0, 4
			la $a0, newLine
			syscall				
		
			addi $t0, $t0, 1	
			
			j printHistogram
			finishPrintHistogram:
			jr $ra
			

		binarizeLoop:
			beq $t0, 10038, finishBinarizeLoop	
		
			lbu $t1, buffer($t0)  # le todos os bytes do buffer
			bge $t1, $s1, white   # se e maior ou igual o limiar, vira branco.
			blt $t1, $s1, black   # caso contrario, vira preto.
		
			white:
				move $t1, $zero
				addiu $t1, $t1, 255
				sb $t1, buffer($t0)  #guarda o byte branco no buffer.
				
				lw $t3, whitePixels  #aumenta o contador de pixels brancos para criar o novo histograma.
				add $t3, $t3, 1
				sw $t3 whitePixels
				
				addi $t0, $t0, 1		
				j binarizeLoop
		
			black: #mesmo procedimento mas agora para os pixels pretos.
				move $t1, $zero
				addiu $t1, $t1, 0
				sb $t1, buffer($t0)
				
				lw $t3, blackPixels
				add $t3, $t3, 1
				sw $t3 blackPixels
				
				addi $t0, $t0, 1		
				j binarizeLoop
			
			finishBinarizeLoop:
			jr $ra
		
		printBlackAndWhite:  #imprime o novo histograma.
			li $v0, 4
			la $a0, rightParenthesis
			syscall
		
			li $v0, 1
			li $a0, 0
			syscall
			
			li $v0, 4
			la $a0, twoDots
			syscall
		
			li $v0, 1
			lw $a0, blackPixels
			syscall		
			
			li $v0, 4
			la $a0, leftParenthesis
			syscall
		
			li $v0, 4
			la $a0, space			
			syscall		
		
			li $v0, 4
			la $a0, rightParenthesis
			syscall
		
			li $v0, 1
			li $a0, 255
			syscall		
			
			li $v0, 4
			la $a0, twoDots
			syscall
			
			li $v0, 1
			lw $a0, whitePixels
			syscall
			
			li $v0, 4
			la $a0, leftParenthesis
			syscall	
		
			jr $ra
			
			
			
