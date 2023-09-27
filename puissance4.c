#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 8
#define NAME 50

typedef char Grille[N][N];

void remplir_grille(Grille g)   // Pour creer une grille vide (Si il ya des etoiles => le case est vide)
{
    int i,j;
    for(i=0;i<N;i++)
    {
        for (j = 0; j < N; j++)
        {
            g[i][j] = '*';
        }
        
    }
}

void affiche_grille(Grille g)
{
    int i,j;
    for(i=0;i<N;i++)
    {
        for (j = 0; j < N; j++)
        {
           printf("%c", g[i][j]);
        }
        printf("\n");
        
    }
}

char * give_name()    // Pour donner leur noms au joueurs (FREE DANS LA FONCTION JEU)
{                       // On peut faire la meme chose pour les couleurs dans le code MIPS
    char * name = NULL;
    name = malloc(NAME * sizeof(char));
    printf("Saisir votre nom: \n ");
    scanf("%s",name);
    return name;
}

int test_full(Grille g){    // TESTER S'IL Y A DES PLACES RESTE
    int i,j;
    for(i=0;i<N;i++)
    {
        for (j = 0; j < N; j++)
        {
           if(g[i][j] == '*')
            return 1;
        }
    }
    return 0;
}

int vertical(Grille g,char c,int ligne, int colonne) // On cherche si X a gagné verticalement
{
    int count = 1;
    int count_up = 0;
    int count_down = 0;

    int i;
    for(i=1;i<4;i++)
    {
        if(g[ligne+i][colonne] == c)
            count_up ++;
        else
            break;
    }
    int j;
    for(j=1;j<4;j++)
    {
        if(g[ligne-j][colonne] == c)
            count_down ++;
        else
            break;
    }

    if(count_up + count + count_down == 4)
        return 1;
    else 
        return 0;
}

int horizontal(Grille g,char c,int ligne,int colonne) // On cherche si X a gagné horizontalement
{
    int count = 1;
    int count_up = 0;
    int count_down = 0;

    int i;
    for(i=1;i<4;i++)
    {
        if(g[ligne][colonne + i] == c)
            count_up ++;
        else
            break;
    }
    int j;
    for(j=1;j<4;j++)
    {
        if(g[ligne][colonne - j] == c)
            count_down ++;
        else
            break;
    }

    if(count_up + count + count_down == 4)
        return 1;
    else 
        return 0;
}

int diagonale_gauche(Grille g,char c,int ligne,int colonne)  // Diagonale de bas vers haut
{
    int count = 1;
    int count_up = 0;
    int count_down = 0;

    int i;
    for(i=1;i<4;i++)
    {
        if(g[ligne+i][colonne + i] == c)
            count_up ++;
        else
            break;
    }
    int j;
    for(j=1;j<4;j++)
    {
        if(g[ligne-j][colonne - j] == c)
            count_down ++;
        else
            break;
    }

    if(count_up + count + count_down == 4)
        return 1;
    else 
        return 0;
     
}

int diagonale_droite(Grille g,char c,int ligne,int colonne)// Diagonale de haut en bas
{
    int count = 1;
    int count_up = 0;
    int count_down = 0;

    int i;
    for(i=1;i<4;i++)
    {
        if(g[ligne - i][colonne + i] == c)
            count_up ++;
        else
            break;
    }
    int j;
    for(j=1;j<4;j++)
    {
        if(g[ligne + j][colonne - j] == c)
            count_down ++;
        else
            break;
    }

    if(count_up + count + count_down == 4)
        return 1;
    else 
        return 0;
     
}

int gagne(Grille g,char j, int ligne,int colonne)   // On test toutes les 4 fonctions precedent pour voir si X a gagné
{
    if(vertical(g,j,ligne,colonne) || horizontal(g,j,ligne,colonne) || diagonale_droite(g,j,ligne,colonne) || diagonale_gauche(g,j,ligne,colonne))
        return 1;
    else 
        return 0;
}

int test_case(Grille g,int col) // Renvoi -1 s'il n'y a plus de place dans la colonne choisi. Renvoi l'indice de ligne s'il y a des place
{
    int i;
    for(i = N-1;i>=0;i--)
    {
        if(g[i][col] == '*')
        {
            printf("%d\n",i);
            return i;
        }    
    }
    return -1;
}

void jeu()
{
    char *joueur1 = give_name();    // Donne leur noms aux joueurs
    char *joueur2 = give_name();
    Grille jeu;
    remplir_grille(jeu);    // On creer une grille vide
    printf("Saisir un nombre negatif pour quitter le jeu !");
    printf("----------------------------------------------");
    while(1)    // On commence le jeu avec un boucle infini
    {
        int move1,move2;
        if(move1 < 0 || move2 < 0) break;   // Si l'un des utilisateurs veut arreter le jeu,  il est suffit de saisir un nombre negatif
        printf("%s saisir le colonne: \n",joueur1);
        scanf("%d",&move1);
        move1 --;       // les joueurs vont saisir le colonne entre 1 et 7 mais les indices sont de 0 à 7
        
        int t1 = test_case(jeu,move1);
        if(t1 < 0)  // si la colonne est complete
            printf("Le colone choisi est complet. Choisir une nouvelle colonne: \n");
        else    // s'il y a des places dans la colonne
        {
            jeu[t1][move1] = 'A';   // sur mips on va changer ça aux pions colorée
            if(gagne(jeu,jeu[t1][move1],t1,move1))  // On teste si joueur a gagné 
            {
                printf("%s a gagné ! \n",joueur1);
                affiche_grille(jeu);
                break; // on sorte de jeu
            }
            affiche_grille(jeu);
            printf("%s saisir le colonne: \n",joueur2);
            scanf("%d",&move2);
            move2 --;    // les joueurs vont saisir le colonne entre 1 et 7 mais les indices sont de 0 à 7
            int t2 = test_case(jeu,move2);
            if(t2 < 0)   // si la colonne est complete
                printf("Le colone choisi est complet. Choisir une nouvelle colonne: \n");
            else    // s'il y a des places dans la colonne
            {
                jeu[t2][move2] = 'B';   // sur mips on va changer ça aux pions colorée
                if(gagne(jeu,jeu[t2][move2],t2,move2)) // On teste si joueur a gagné
                {
                    printf("%s a gagné ! \n",joueur2);
                    break;  // on sorte de jeu
                }
                affiche_grille(jeu);
            }
        }
        if(!test_full(jeu)) // Si toute le jeu est complete, on déclare l'egalite et on sorte de jeu
        {
            printf("Egalité");
            break;
        }
    }
    printf("GAME EXIT\n");
    free(joueur1);  
    free(joueur2);
}

int main()
{
   jeu();
   return 0;

}