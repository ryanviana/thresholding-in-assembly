#Created using MARS on WINDOWS.

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

		#syscall to open file
		
		li $v0, 13 	  
		la $a0, fileName		#file to be open
		li $a1, 0 	  
		li $a2, 0         
		syscall		
			

		move $s6, $v0			#save file descriptor
		li $v0, 14      		#read from open file
		move $a0, $s6   
		la $a1, buffer  		#buffer address to read files
		li $a2, 10038	
		syscall
		
        addiu $t0, $zero, 38  #initialize variable to read the byts (skip initial ones)	
		jal createHistogram   
		
		addi $t0, $zero, 0    		#initialize the counter.
		jal printHistogram    
		
		
		li $v0, 4
		la $a0, thresholdMsg
		syscall

		#leitura do limiar.
		li $v0, 5      
		syscall

		#salva o limiar.
		move $s1, $v0  
		
		addi $t0, $zero, 38   
		jal binarizeLoop     		
		
		
		li $v0, 4
		la $a0, newHistogramMsg
		syscall
		
		jal printBlackAndWhite
		
		
		#cria um novo arquivo para a imagem binarizada.
		#usa uma syscall para abrir um arquivo e como ele nao existe, eh criado.
		li   $v0, 13              
		la   $a0, binaryFileName  
		li   $a1, 1               	#flag to open in write mode
		li   $a2, 0         	  
		syscall

		move $s0, $v0      	  	#save file descriptor 
		
		#write on binary file
		li   $v0, 15      
		move $a0, $s0      
		la   $a1, buffer  
		li   $a2, 10038   
		syscall           
		
		#close binary file
		li   $v0, 16       
		move $a0, $s6      
		syscall  


		#close the original file
		li $v0, 16
		move $a0, $s6
		syscall
		
		#END PROGRAM
		li $v0, 10
		syscall
		
		##FUNCTIONS##
		
		createHistogram:
			beq $t0, 10038, finishCreateHistogram  #if all bytes are read, we go to the next step.	
		
			lbu $t1, buffer($t0)	     	       #load byte from position 38 < $t0 < 10038 of the buffer
			lbu $t2, histogram($t1)                
			addiu $t2, $t2, 1                      #add byte to histogram    
			sb $t2, histogram($t1)                 #save the new value in the histogram vector
			
			addi $t0, $t0, 1                       
			
			j createHistogram	               
			finishCreateHistogram:
			jr $ra
			
		printHistogram:	
			beq $t0, 256, finishPrintHistogram 	
			
			li $v0, 4			    
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
		
			lbu $t1, buffer($t0)  # read all bytes from bufffer
			bge $t1, $s1, white   
			blt $t1, $s1, black   
		
			white:
				move $t1, $zero
				addiu $t1, $t1, 255
				sb $t1, buffer($t0) 
				
				lw $t3, whitePixels 
				add $t3, $t3, 1
				sw $t3 whitePixels
				
				addi $t0, $t0, 1		
				j binarizeLoop
		
			black: 
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
		
		printBlackAndWhite:  
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
			
			
			
