#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

int scorer(string word);

int POINTS[26] = {1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10};

int main(void)
{
    string player1 = get_string("Player 1: ");
    string player2 = get_string("Player 2: ");

    int pl1scr = scorer(player1), pl2scr = scorer(player2);

    // Evaluator
    if (pl1scr > pl2scr)
    {
        printf("Player 1 wins!\n");
    }
    else if (pl1scr < pl2scr)
    {
        printf("Player 2 wins!\n");
    }
    else if (pl1scr == pl2scr)
    {
        printf("Tie!\n");
    }
}

int scorer(string word)
{
    int points = 0;
    for (int i = 0, len = strlen(word); i < len; i++)
    {
        if (isalpha(word[i]))
        {
            char upper = toupper(word[i]);
            // char is int, int is char
            points += POINTS[upper - 'A'];
        }
    }
    return points;
}
