.data
intro: .asciiz "Bem vindo ao Guessing Game!\n" 
nome_digitado: .asciiz "Por favor jogador, digite seu nome aqui:\n"
saudacao: .asciiz "Opa, "
digitar_numero: .asciiz "Para lhe ajudar nesta jornada, digite um numero de 100 à 200 para facilitar as casas que o numero será sorteado :\n"
explicacao: .asciiz "Numero sorteado, tente adivinhar. Boa sorte!\n"
prox_numero: .asciiz "Digite o número:\n"
alto: .asciiz "Muito alto, talvez mais baixo. \n"
baixo: .asciiz "Muito baixo, talvez mais alto. \n"
end1: .asciiz "Parabens! "
end2: .asciiz "Você venceu o desafio. "
end3: .asciiz " foi o total de tentativas para acertar o número."

.macro assign_constant (%destination, %constant)
li %destination, %constant
.end_macro

.macro set_syscall (%syscall_number)
assign_constant($v0, %syscall_number)
.end_macro

#Salva o valor / destino
.macro assign (%destination, %value_address)
add %destination, %value_address, $zero
.end_macro 

#Finaliza o programa
.macro exit(%exit_status)
li $a0, %exit_status
set_syscall(17)
syscall #Faz a exeução e puxa.
.end_macro

#Status de saida "0"
.macro exit
exit (0) #Retorna o status de saida
.end_macro

.macro print_a0
set_syscall(4) #Retorna o valor de a0 apartir do syscall
syscall #Retorna o valor a0
.end_macro

#Faz print da string com a chamada gpr
.macro print(%string_gpr)
la $a0, (%string_gpr)
print_a0
.end_macro 

.macro print_name
print($t1)
.end_macro

#Faz o print da string
.macro print_variable (%string_reference)
la $a0, %string_reference #Faz load do dado digitado em a0
print_a0
.end_macro 

.macro print_int (%int_address)
set_syscall(1) #Chama syscall printada em a0
assign($a0, %int_address) 
syscall
.end_macro 

.macro print_attempts
print_int($t4)
.end_macro

.macro input_string (%string_reference, %destination)
print_variable(%string_reference)
set_syscall(8)
assign_constant($a1, 15)
syscall
la %destination, ($a0)
.end_macro

.macro input_int (%string_reference, %destination)
print_variable(%string_reference)
set_syscall(5) #Seta o input do syscall
syscall #Executa o syscal, mas armazenado no valor V0
assign(%destination, $v0) #Guarda o valor de x no destino.
.end_macro

.macro greet
print_variable(saudacao)
print_name
.end_macro

.macro endscreen
print_variable(end1)
print_name
print_variable(end2)
print_attempts
print_variable(end3)
.end_macro

.macro transform_number
addi $t5, $t2, 69
mul $t2, $t2, $t5
addi $t2, $t2, 420 
.end_macro

# t1 - Nome
# t2 - Numero Principal
# t3 - Numeros tentados
# t4 - Numero de tentativas
.text 
main:
print_variable(intro)
input_string(nome_digitado, $t1)
greet
input_int(digitar_numero, $t2)
transform_number
print_variable(explicacao)

assign_constant($t4, 0)
loop:
    input_int(prox_numero, $t3)
    addiu $t4, $t4, 1 #Implementa a contagem
    sub $t3, $t3, $t2 #t3 = t3 - t2 (calculo de subtração)
    beq $t3,$0, endloop #Para o loop se for diferente de 0
    bgez $t3, greater #Se for diferente > 0, executa.
    print_variable(baixo)
    j loop
	greater:
    	print_variable(alto)
    	j loop
endloop:

endscreen
exit
