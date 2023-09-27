#  Pojet AO Printemps 2021-2022
#  Date de rendu: 13/03/2022 23:59
#  Auteurs : FARID Yasmina-Ertekin Melissa

################################################################################################################################# 
##  Ce fichier contient un squelete de code pour le jeu du puissance 4.
##  L'ensemble des fonctions d'affichage est d�j� en place. L'affichage repose sur l'�criture de carr�s de 8x8px.
##  Les fonctions � compl�ter sont les suivantes :
##  
################################################################################################################################# 
.data
Grille: .word 0:42		#espace pour le tableau qui represente la grille du jeu 7colonnes*6lignes=42cases toutes initialisées a 0

Colors:	#  Contient les couleurs
 .word 0x0000FF # [0] Bleu   0x0000FF	Grille
 .word 0xFF0000 # [1] Rouge  0xFF0000	Jeton joueur 2
 .word 0xE5C420 # [2] Jaune  0xE5C420	Jeton joueur 1
 .word 0xFFFFFF # [3] Blanc  0xFFFFFF	Fond


Color_Options:
 .word 0x0000FF # [0] Bleu   	0x0000FF	
 .word 0xC76372 # [1] Dark Pink	0xC76372
 .word 0x5A3FFF # [2] Purple  	0x5A3FFF	
 .word 0x47B2FF # [3] Baby Blue	0x47B2FF 
 .word 0xE5C420 # [4] Yellow  	0xE5C420
 .word 0xFF0000 # [5] Red	0xFF0000


#  Un cercle est d�finit par une suite de lignes horizontales.
#  Chaque ligne est d�finie par un offset suivit d'une longeur (ex : 2, 4, on d�cale de deux carr�s et on d�ssine 4 carr�s
CircleDef: 
	.word 2, 4, 1, 6, 0, 8, 0, 8, 0, 8, 0, 8, 1, 6, 2, 4

displayStart: .asciiz "\nBienvenue dans ce jeu du puissance 4!\nC'est un jeu a deux joueurs.\nLe joueur 1 va commencer.\nEntrez un nombre entre 1 et 7 pour choisir la colonne ou jouer.\nUne fois qu'un joueur a joué, attendez que la console demande une nouvelle action pour jouer!\n\nBon Jeu!\n\n"
displayP1: .asciiz "\nTour du joueur 1 : "
displayP2: .asciiz "\nTour du joueur 2 : "
displayP1Win: .asciiz "Le joueur 1 a gagné !\n"
displayP2Win: .asciiz "Le joueur 2 a gagné !\n"
displayInstructions: .asciiz "Choisissez un nombre entre 1 et 7 (inclus)\n"
displayFull: .asciiz "la colonne choisit est pleine. Choisissez en une autre.\n"
displayTie: .asciiz "Il y a égalité !\n"

MsgErrorSup7: .asciiz "Vous avez saisit un nombre superieur a 7. \n Veuillez saisir un nombre entre 1 et 7\n"
MsgErrorInf1: .asciiz "Vous avez saisit un nombre inferieur a 1. \n Veuillez saisir un nombnre entre 1 et 7\n"
MsgErrorColPleine: .asciiz "Cette colonne est pleine. \n Veuillez choisir une autre colonne\n"
MsgRejouer: .asciiz "\nVoulez vous rejouer ? \n Saisir 1 pour lancer une nouvelle partie ou 0 pour quitter le jeu : \n"

Msg_Couleur: .asciiz "\nVoulez vous choisir les couleurs de votre jeu ? \n Saisir 1 pour choisir \n Saisir 0 pour prendre les couleurs par défaut \n - "
Opt_color: .asciiz "\n0) Bleu  \n 1) Dark Pink	\n 2) Purple \n 3) Baby Blue\n 4) Yellow \n 5) Red \n"
Col_grille: .asciiz  "\nSaisir le numero de couleur choisit pour la grille : "
Col_joueur1: .asciiz  "\nJoueur 1 saisir le numero de couleur choisit pour votre jeton : "
Col_joueur2: .asciiz  "\nJoueur 2 saisir le numero de couleur choisit pour votre jeton : "

.text

#  Debut du jeu
	la $a0, displayStart	
	li $v0, 4
	syscall

demande_couleur:
	la $a0 Msg_Couleur
	li $v0, 4
	syscall
	li $v0, 5
	syscall 
	
	beq $v0 1 ChoseColor

Init:
	la $a0, ($sp)
	li $v0, 1
	syscall

#  Dessine le plateau
	jal DrawGameBoard

################################  Fonction Main  ################################  
main:
	la $t0 Grille	# $t0 = Grille[0] 

#  Récupère l'instruction du joueur 1
playerOne:
	la $a0, displayP1
	li $v0, 4
	syscall
	li $v0, 5
	syscall


#  Place le jeton choisit par le joueur 1
	li $a0, 1
	jal UpdateRecord 	#au retour de la fonction UpdateRecord $v0 vaut le numero de la case de la grille ou il faut mettre le jeton
				#la fonction UpdateRecord prend en charge les erreurs de saisie possibles

#  Déssine ce jeton

	li $a0, 1
	jal DrawPlayerChip	#dessine le jeton dans la case de numero donnée par UpdateRecord dans $v0

	la $t0 Grille		# $t0 = Grille[0] 
	li $a0, 1
	
#  Test si le joueur 1 à gagne sinon on reviens et on passe à la suite (instruction "playerTwo:")
	jal WinCheck


#  Recupere l'instruction du joueur 2
playerTwo:
	la $a0, displayP2
	li $v0, 4
	syscall
	li $v0, 5
	syscall

#  Place le jeton choisit par le joueur 2
	li $a0, 2
	jal UpdateRecord

#  Dessine ce jeton
	li $a0, 2
	jal DrawPlayerChip

	li $a0, 2
#  Test si le joueur 2 à gagne sinon on passe à la suite (instruction "j main")
	jal WinCheck


	j main

################################   Fin de la fonction Main ################################  
################################   Debut des procedures d'affichage ################################  
##################### Il n'est pas obligatoire de comprendre ce qu'elles font. ##################### 
# Procedure: DrawPlayerChip
# Input: $a0 - Numero du joueur
# Input: $v0 - Position (entre 0 et 41)
DrawPlayerChip:
	move $t7 $v0		# Pour n'est pas perdre la valeur de $v0
	
	addiu $sp, $sp, -12
	sw $ra, ($sp)
	sw $a0, 4($sp)
	sw $v0, 8($sp)
	
	#  place la couleur du jeton en argument
	move $a2, $a0
	
	#  On calcul la position
	li $t0, 7
	div $v0, $t0
	mflo $t0		# Division (Y)
	mfhi $t1		# Reste (X)

	#  Y-Position = 63-[(Y+1)*9+4] = 50-9Y (dans $t0)
	li $t2, 50
	mul $t0, $t0, 9
	mflo $t0
	sub $t0, $t2, $t0 
	
	# X-Position = [X*9]+1 (dans $t1)
	mul $t1, $t1, 9
	addi $t1, $t1, 1
	
	#  Copie les positions dans les registres d'arguments
	move $a0, $t1
	move $a1, $t0
	
	jal DrawCircle
	
	lw $v0, 8($sp)
	lw $a0, 4($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	
	move $v0 $t7		# Repredre la valeur de $v0
	
	jr $ra

# Procedure: DrawGameBoard
# Affiche la grille
DrawGameBoard:
	addiu $sp, $sp, -4
	sw $ra, ($sp)
	
	#  Fond en blanc
	li $a0, 0
	li $a1, 0
	li $a2, 3	
	li $a3, 64
	jal DrawSquare		 # Affiche un carre blanc de 64x64 en position 0,0)
	
	#  Ligne du haut
	li $a0, 0	
	li $a1, 0	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 1
	jal DrawHorizontalLine
	li $a1, 2	
	jal DrawHorizontalLine
	li $a1, 3	
	jal DrawHorizontalLine
	li $a1, 4	
	jal DrawHorizontalLine
	
	#  Ligne du bas
	li $a0, 0	
	li $a1, 58	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 59
	jal DrawHorizontalLine
	li $a1, 60	
	jal DrawHorizontalLine
	li $a1, 61	
	jal DrawHorizontalLine
	li $a1, 62	
	jal DrawHorizontalLine
	li $a1, 63	
	jal DrawHorizontalLine


	#  Lignes verticales
	li $a0, 0	
	li $a1, 0	
	li $a2, 0	
	li $a3, 64	
	jal DrawVerticalLine	
	li $a0, 9	# (X = 9)
	jal DrawVerticalLine
	li $a0, 18	# (X = 18)
	jal DrawVerticalLine
	li $a0, 27	# (X = 27)
	jal DrawVerticalLine
	li $a0, 36	# (X = 36)
	jal DrawVerticalLine
	li $a0, 45	# (X = 45)
	jal DrawVerticalLine
	li $a0, 54	# (X = 54)
	jal DrawVerticalLine
	li $a0, 63	# (X = 63)
	jal DrawVerticalLine

	#  Lignes horizontales
	li $a0, 0	
	li $a1, 13	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 22
	jal DrawHorizontalLine
	li $a1, 31	
	jal DrawHorizontalLine
	li $a1, 40	
	jal DrawHorizontalLine
	li $a1, 49	
	jal DrawHorizontalLine

	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra


# Procedure: DrawCircle
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Affiche le Jeton
DrawCircle:
	#  Fait de a place sur la pile
	addiu $sp, $sp, -28 	
	#  Y ajoute les arguments suivants $ra, $s0, $a0, $a2
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	li $s2, 0	#  Initaitllise le compteur et on passe dans la boucle de la fonction
	
CircleLoop:
	la $t1, CircleDef
	#  Utilise le compteur pour recupeer le bon indice dans CircleDef
	addi $t2, $s2, 0	
	mul $t2, $t2, 8		
	add $t2, $t1, $t2	
	lw $t3, ($t2)		
	add $a0, $a0, $t3	
	
	#  On d�ssine la ligne
	addi $t2, $t2, 4	
	lw $a3, ($t2)		
	sw $a1, 4($sp)		
	sw $a3, 0($sp)		
	sw $s2, 24($sp)		
	jal DrawHorizontalLine
	
	#  On remet en place les arguments
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	lw $s2, 24($sp)
	addi $a1, $a1, 1	#  Incremente Y value
	addi $s2, $s2, 1	#  Incremente le compteur
	bne $s2, 8, CircleLoop	#  On boucle pour ecrire les 8 lignes
	
	
	#  R�staure les valeurs de $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 28
	jr $ra
	
# Procedure: DrawSquare
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W 
# D�ssine un carr� de taille WxW en position (X, Y)
DrawSquare:
	addiu $sp, $sp, -24 	# Sauvegarde $ra, $s0, $a0, $a2
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	move $s0, $a3		
	
BoxLoop:
	sw $a1, 4($sp)	
	sw $a3, 0($sp)	
	jal DrawHorizontalLine
	
	# R�staure $a0-3
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	addi $a1, $a1, 1	# Incremente Y 
	addi $s0, $s0, -1	# Decremente le nombre de ligne
	bne $zero, $s0, BoxLoop	# Jusqu'a ce que le compteur soit a zero
	
	# R�staure $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 24	# Reset $sp
	jr $ra
	
# Procedure: DrawHorizontalLine
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W
# D�ssine une ligne horizontale de longueur W en position (X, Y)
DrawHorizontalLine:
	addiu $sp, $sp, -28 	
	# Sauvegarde $ra, $a1, $a2
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	
HorizontalLoop:
	# Sauvegarde $a0, $a3 
	sw $a0, 4($sp)
	sw $a3, 0($sp)
	jal DrawPixel
	# R�staure tout sauf $ra
	lw $a0, 4($sp)
	lw $a1, 12($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1		# Decremente la longueur W
	addi $a0, $a0, 1		# Incremente X 
	bnez $a3, HorizontalLoop	# Boucle tant que W > 0 	
	lw $ra, 16($sp)			# Restaure $ra
	lw $a0, 20($sp)
	lw $a3, 24($sp)
	addiu $sp, $sp, 28		# Restaure $sp
	jr $ra
	
# Procedure: DrawVerticalLine
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W
# D�ssine une ligne verticale de longeur W en position (X, Y)
DrawVerticalLine:
	addiu $sp, $sp, -28
	# Sauvegarde $ra, $a1, $a2
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	
VerticalLoop:
	# Save $a0, $a3 (changes with next procedure call)
	sw $a1, 4($sp)
	sw $a3, 0($sp)
	jal DrawPixel
	# Restore all but $ra
	lw $a1, 4($sp)
	lw $a0, 20($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1		# Decremente la longueur W
	addi $a1, $a1, 1		# Incremente Y 
	bnez $a3, VerticalLoop		# Boucle tant que W > 0 	
	lw $ra, 16($sp)			# Restaure $ra
	lw $a1, 12($sp)
	lw $a3, 24($sp)
	addiu $sp, $sp, 28		# Restaure $sp
	jr $ra
	
# Procedure: DrawPixel
# Input - $a0 = X
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# D�ssine un pixel sur la Bitmap en ecrivant au bon endroit sur la memoire (sur le tas/heap) via la fonction GetAddress
DrawPixel:
	addiu $sp, $sp, -8
	# Save $ra, $a2
	sw $ra, 4($sp)
	sw $a2, 0($sp)
	jal GetAddress			# Calcule l'adresse memoire
	lw $a2, 0($sp)		
	sw $v0, 0($sp)		
	jal GetColor			# Recupere la couleur
	lw $v0, 0($sp)		
	sw $v1, ($v0)			# Ecrit la couleur en memoire
	lw $ra, 4($sp)		
	addiu $sp, $sp, 8	
	jr $ra


# Procedure: GetAddress
# Input - $a0 = X
# Input - $a1 = Y
# Output - $v0 = l'adresse memoire exacte ou ecrire le pixel
GetAddress:
	sll $t0, $a0, 2			# Multiplie X par 4
	sll $t1, $a1, 8			# Multiplie Y par 64*4 (512/8= 64 * 4 words)
	add $t2, $t0, $t1		# Additionne les deux 
	addi $v0, $t2, 0x10040000	# Ajout de l'adresse point� par Bitmap (heap) 
	jr $ra

# Procedure: GetColor
# Input - $a2 = Index dans Colors (0-5)
# Output - $v1 = valeur Hexadécimale
# Retourne la valeur Hexadécimale de la couleur demandée
GetColor:
	la $t0, Colors		
	sll $a2, $a2, 2		
	add $a2, $a2, $t0	
	lw $v1, ($a2)		
	jr $ra

################################   Fin des procédures d'affichage ################################


#---------------Les Fonctions à écrire----------------


################################ Début UpdateRecord ################################ 
# Procedure: UpdateRecord
# Input: Index donne par l'utilisateur - $v0
# Input: Numero du joueur (1 ou 2) - $a0
# Output: numero du carre ($v0)
# Détermine la position exacte où placer le jeton et met à jour l'état du jeu en mémoire, puis renvoit la position de jeton
UpdateRecord: 
	
	bgt $v0 7 ErrorSup7		#test si index > 7
	blt $v0 1 ErrorInf1		#test si index < 1
	
	addi $v0 $v0 -1			#convertit le nombre entré par le joueur 1->7(numero colonne) à 0->6(indice colonne)
	
	la $t0 Grille			# load la grille dans $t0 , $t0 = Grille[0] 
	
	move $t1 $v0			# on utilise le registe temporaire t1 pour ne pas ecraser $v0 qu'on va utiliser pour tester si la colonne est pleine
	sll $t1 $t1 2			# $t1 = $t1 * 4 car on a une grille des int
	add $t0 $t0 $t1			# compteur de ligne en mémoire , $t0 = &Grille[$t1]
	
UpdateLoop:
	lw $t3 ($t0)			# $t3 = Grille[$t0]
	bge $v0 42  ErrorColPleine	# Test si la colonne est pleine
	beq $t3 0 EndUpdateLoop		# Test si la case libre est trouvé  
	addi $t0 $t0 28			# Saute à ligne prochaine (4 * 7 = 28) en memoire
	addi $v0 $v0 7			# Compteur de ligne pour tester si la colonne est pleine avec $s0
	
	j UpdateLoop	

EndUpdateLoop:
	# La case a retourner est dans $v0
	sw $a0 ($t0)			# On met la valeur de $a0 (soit 1, soit 0 selon le joueur) à Grille (Grille[$t0] = $a0 en C)
	jr $ra				    # On retourne à la fonction d'ou on est appelee




#3 cas d'erreurs possibles :
 
#colonne choisit pleine
ErrorColPleine:
	move $t0, $a0
	la $a0, MsgErrorColPleine	#affiche le message "Cette colonne est pleine , veuillez choisir une autre colonne "
	li $v0, 4
	syscall
	move $a0, $t0
	beq $a0 1 playerOne
	j  playerTwo
	
#colonne choisit >7
ErrorSup7:
	move $t1 $a0			#sauvegarde dans $a0 dans $t1 pour ne pas perdre le nuùmero joueur dans $a0
	la $a0 MsgErrorSup7		#affichage du message d'erreur "Vous avez saisit un nombre superieur a 7 , veuillez saisir un nombnre entre 1 et 7"
	li $v0 4
	syscall
	move $a0, $t1			#recuperer le numero joueur sauvergarde dans $t1
	beq $a0 1 playerOne		# pour voir à laquelle joueur on va redemander
	j  playerTwo			
#colonne choisit <1 
ErrorInf1:
	move $t1 $a0			#sauvegarde dans $a0 dans $t1 pour ne pas perdre le nuùmero joueur dans $a0
	la $a0 MsgErrorInf1		#affichage du message d'erreur "Vous avez saisit un nombre inferieur a 1, veuillez saisir un nombnre entre 1 et 7"
	li $v0 4
	syscall
	move $a0, $t1			#recuperer le numero joueur sauvegarde dans $t1
	beq $a0 1 playerOne		# pour voir à laquelle joueur on va redemander
	j  playerTwo
	
################################ Fin UpdateRecord ################################ 
	
			
################################ Debut WinCheck ################################  
# Procedure: WinCheck
# Input: $a0 - Player Number
# Input: $v0 - Last location offset chip was placed
# Determine si le dernier jeton joue a permis de gagner

WinCheck: 
    	j  Vertical			# 1. la ligne verticale
res_vertical:
	j Horizontal			# 2. la ligne horizontale
res_horizontal:
	j Diagonale1			# 3. la diagonale avant du Sud-Ouest vers Nord-Est 
res_diagonale1:
	j Diagonale2			# 4. la diagonale derriere de Nord-Ouest vers Sud-Est
res_diagonale2:
	j Remplit			# 5. si tout le plateau est remplit (Egalite)
res_remplit:
	jr $ra
     	
     	 
     	
# 1. ########verification sur la ligne horizontale##############################
 
Horizontal:
	la $t0 Grille
	move $t1 $v0
	sll $t1 $t1 2			# $t1 = $t1 * 4 car on a une grille des int
	add $t0 $t0 $t1			# $t0 = &Grille[$t1]
	li $a1 1				# Count total
	li $a2 0				# Count left
	li $a3 0				# Count Right
	li $t2 1				# i = 1
horizonal_left:
	bge $t2 4 end_horizontal_left
	addi $t0 $t0 -4			# On deplace à la colonne gauche
	lw $t3 ($t0)			#$t3 = Grille[$t0]
	bne $t3 $a0 end_horizontal_left	# Test if Grille[$t0] == $a0
	addi $a2 $a2 1			# On increment le count down
	addi $t2 $t2 1			# on incremente l'indice de boucle , i++
	j horizonal_left
	   	
end_horizontal_left:    	
	la $t0 Grille
	move $t1 $v0
	sll $t1 $t1 2			# $t1 = $t1 * 4 car on a une grille des int
	add $t0 $t0 $t1			# $t0 = &Grille[$t1]
	li $t2 1				# i = 1
	j horizontal_right
	
horizontal_right:
	bge  $t2 4 horizontal_test
	addi $t0 $t0 4			# On deplace à la colonne droite
	lw $t3 ($t0)			#$t3 = Grille[$t0]
	bne $t3 $a0 horizontal_test	# Test if Grille[$t0] == $a0
	addi $a3 $a3 1			# On incremente le count down
	addi $t2 $t2 1			# on incremente l'indice de boucle, i++
	j horizontal_right

horizontal_test:
	add $a1 $a1 $a2			# Count  += Count left  
	add $a1 $a1 $a3			# Count  += Count right  
	bge $a1 4 PlayerWon		# Condition de gagner
	j res_horizontal	    # Retour à la fonction WinCheck	
     	
################################################################################     	

# 2. verification sur la ligne verticale

Vertical:

	la $t0 Grille
	move $t1 $v0
	sll $t1 $t1 2			# $t1 = $t1 * 4 car on a une grille des int
	add $t0 $t0 $t1			# $t0 = &Grille[$t1]
	li $a1 1				# Count
	li $t2 0	
vertical_boucle:
	bge $t2 4 vertical_test
	addi $t0 $t0 -28		# Deplacement vers la ligne bas
	lw $t3 ($t0)			#$t3 = Grille[$t0]
	bne $t3 $a0 vertical_test	# Test if Grille[$t0] == $a0
	addi $a1 $a1 1			# On incremente le count down
	addi $t2 $t2 1			# On incremente l'indice du boucle
	b vertical_boucle

vertical_test: 
	bge $a1 4 PlayerWon		# Condition de gagner
	j res_vertical			# Retour à la fonction WinCheck	

	
################################################################################     	
# 3. verification sur la diagonale avant 

# ------ Diagonale 1: Du Sud-Ouest Vers Nord-Est
 
Diagonale1:
	la $t0 Grille
	move $t1 $v0
	sll $t1 $t1 2			# $t1 = $t1 * 4 car on a une grille des int
	add $t0 $t0 $t1			# $t0 = &Grille[$t1]
	li $a1 1				# Count total
	li $a2 0				# Count up
	li $a3 0				# Count down
	li $t2 1				# i = 1
diagonale1_up:
	bge   $t2 4 end_diagonale1_up  
	addi $t0 $t0 32			# Deplacement vers la colonne droite et la linge haut
	lw $t3 ($t0)			#$t3 = Grille[$t0]
	bne $t3 $a0 end_diagonale1_up	# Test if Grille[$t0] == $a0
	addi $a2 $a2 1			# On incremente le count up
	addi $t2 $t2 1			# On incremente l'indice de boucle, i++
	b diagonale1_up
	   	
end_diagonale1_up:    	
	la $t0 Grille
	move $t1 $v0
	sll $t1 $t1 2			# $t1 = $t1 * 4 car on a une grille des int
	add $t0 $t0 $t1			# $t0 = &Grille[$t1]
	li $t2 1				# i = 1
diagonale1_down:
	bge $t2 4 diagonale1_test
	addi $t0 $t0 -32		# Deplacement vers la colonne gauche et la linge bas
	lw $t3 ($t0)			# $t3 = Grille[$t0]
	bne $t3 $a0 diagonale1_test	# Test if Grille[$t0] == $a0
	addi $a3 $a3 1			# On incremente le count down
	addi $t2 $t2 1			# On incremente l'indice de boucle, i++
	b diagonale1_down

diagonale1_test:
	add $a1 $a1 $a2			# Count  += Count left  
	add $a1 $a1 $a3			# Count  += Count right  
	bge $a1 4 PlayerWon		# Condition de gagner
	j res_diagonale1		# Retour a la fonction WinCheck


################################################################################     	

# 4. verification sur la diagonale arrière  

# ------ Diagonale 2: Du Nord-Ouest Vers Sud-Est

Diagonale2:
	la $t0 Grille
	move $t1 $v0
	sll $t1 $t1 2			# $t1 = $t1 * 4 car on a une grille des int
	add $t0 $t0 $t1			# $t0 = &Grille[$t1]
	li $a1 1				# Count total
	li $a2 0				# Count up
	li $a3 0				# Count down
	li $t2 1				# i = 0				
diagonale2_up:
	bge $t2 4 end_diagonale2_up  
	addi $t0 $t0 24			# Deplacement vers la colonne gauche et la ligne haut
	lw $t3 ($t0)			# $t3 = Grille[$t0]
	bne $t3 $a0 end_diagonale2_up	# Test if Grille[$t0] == $a0
	addi $a2 $a2 1			# On incremente le count up
	addi $t2 $t2 1			# On incremente l'indice de boucle, i++
	b diagonale2_up
	   	
end_diagonale2_up:    	
	la $t0 Grille
	move $t1 $v0
	sll $t1 $t1 2			# $t1 = $t1 * 4 car on a une grille des int
	add $t0 $t0 $t1			# $t0 = &Grille[$t1]
	li $t2 1				# i = 1	
diagonale2_down:
	bge $t2 4 diagonale2_test
	addi $t0 $t0 -24		# Deplacement vers la colonne droite et la ligne bas
	lw $t3 ($t0)			# $t3 = Grille[$t0]
	bne $t3 $a0 diagonale2_test	# Teste si Grille[$t0] == $a0
	addi $a3 $a3 1			# On incremente le count down
	addi $t2 $t2 1			# On incremente l'indice de boucle, i++
	b diagonale2_down

diagonale2_test:
	add $a1 $a1 $a2			# Count  += Count up  
	add $a1 $a1 $a3			# Count  += Count down  
	bge $a1 4 PlayerWon		# Condition de gagner
	j res_diagonale2		# Retour a la fonction WinCheck
 	
 	 	
################################################################################     		 	 	

# 5. verifie si tout le plateau est remplit (Egalité)

Remplit:
	la $t0 Grille
	li $t2 41
boucle_remplit:
	beqz $t2 GameTie		# Si on parcours toutes les cases
	addi $t0 $t0 4
	lw $t1 ($t0)			# 0 : il y a une case n'est pas remplit 
	beqz $t1 res_remplit	# Retour à WinCheck
	addi $t2 $t2 -1
	j boucle_remplit

################################  Fin WinCheck ################################  

# Procedure: #################GameTie###################
# Affiche legalité 
GameTie:
	la $a0 displayTie
	li $v0 4			#affiche la chaine de caractères : "Il y a égalité ! \n"
	syscall

	j TestRejouer

# Procedure: #################PlayerWon#################
# Input: $a0 - Player Number
# Affiche le gagnant

PlayerWon:

	beq $a0, 1 joueur1gagne		#si c'est le joueur 1 qui a gagné($a0=1) on jump a joueur1gagne sinon on continue et c'est joueur 2 qui gagne($a0=2)
		
	la $a0 displayP2Win
	li $v0 4			#on affiche la chaine de caractères : "Le joueur 2 a gagné ! \n "
	syscall

	j TestRejouer
	
joueur1gagne:

	la $a0 displayP1Win
	li $v0, 4			#on affiche la chaine de caractères : "Le joueur 1 a gagné ! \n"
	syscall

	j TestRejouer


TestRejouer: # Cette fonction demande a lutilisateur s'il veut rejouer ou quitter le jeu et apelle la fonction correspondante a son choix

	la $a0 MsgRejouer
	li $v0 4
	syscall 
	
	li $v0 5
	syscall 
	
	beq $v0 1 NouvellePartie
	beqz $v0 Exit
	


NouvellePartie:	#cette fonction reintialise toutes les cases de la grille a 0 pour pouvoir jouer une nouvelle partie

	li $t1 0

VideGrille:
	beq $t1 168,EndVideGrille		# 42 cases * 4octet = 168
	sw $zero Grille($t1)
	addi $t1 $t1 4
	j VideGrille

	EndVideGrille:
	j Init


Exit:	
	li $v0 10
	syscall 


# ---------------- Pour les options de couleur ----------------------
	
ChoseColor: #Cette fonction permet au joueurs de choisir la couleur de la grille ainsi que choisir les couleurs de leur jetons.

#Choix pour la couleur de la grille
	la $a0 Col_grille	
	li $v0 4
	syscall 
	la $a0 Opt_color
	li $v0 4
	syscall
	li $v0, 5
	syscall
	
	
	la $t0 Colors
	la $t1 Color_Options
	move $t2 $v0	
	sll $t2 $t2 2				# $t2 = $t2 * 4 
	add $t1 $t1 $t2				# $t0 = &Grille[$t1]
	lw $t3 ($t1)
	sw $t3 0($t0)

#Choix pour la couleur du joueur 1
	la $a0 Col_joueur1	
	li $v0 4
	syscall 
	la $a0 Opt_color
	li $v0 4
	syscall
	li $v0, 5
	syscall
	

	la $t0 Colors
	la $t1 Color_Options
	move $t2 $v0
	sll $t2 $t2 2				# $t2 = $t2 * 4 
	add $t1 $t1 $t2				# $t0 = &Grille[$t1]
	lw $t3 ($t1)
	sw $t3 4($t0)
	
#Choix pour la couleur du joueur 2
	la $a0 Col_joueur2	
	li $v0 4
	syscall 
	la $a0 Opt_color
	li $v0 4
	syscall
	li $v0, 5
	syscall
	

	la $t0 Colors
	la $t1 Color_Options
	move $t2 $v0
	sll $t2 $t2 2				# $t2 = $t2 * 4 
	add $t1 $t1 $t2				# $t0 = &Grille[$t1]
	lw $t3 ($t1)
	sw $t3 8($t0)
	
	j Init	
	
	






