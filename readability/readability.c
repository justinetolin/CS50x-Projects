#include <cs50.h>
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

int count_letters(string text);
int count_words(string text);
int count_sentences(string text);

int main(void)
{
    // Prompt the user for some text
    string text = get_string("Text: ");

    // Count the number of letters, words, and sentences in the text
    int letters = count_letters(text);
    int words = count_words(text);
    int sentences = count_sentences(text);

    // Compute the Coleman-Liau index
    // Formula: index = 0.0588 * L - 0.296 * S - 15.8
    float L = ((float) letters / words) * 100;
    float S = ((float) sentences / words) * 100;
    float index = 0.0588 * L - 0.296 * S - 15.8;
    int indexRnd = round(index);

    // printf("lt%i | wr%i | sn%i | L%f | S%f | index%f | indRND%i\n", letters, words, sentences, L,
    // S, index, indexRnd);

    // Print the grade level
    if (index < 1)
    {
        printf("Before Grade 1\n");
    }
    else if (index > 1 && index < 16)
    {
        printf("Grade %i\n", indexRnd);
    }
    else if (index >= 16)
    {
        printf("Grade 16+\n");
    }
}

int count_letters(string text)
{
    int ltrcnt = 0;
    for (int i = 0, n = strlen(text); i < n; i++)
    {
        if (isalpha(text[i]))
        {
            ltrcnt++;
        }
    }
    return ltrcnt;
}

int count_words(string text)
{
    int wrdcnt = 0;
    for (int i = 0, n = strlen(text); i < n; i++)
    {
        if (isspace(text[i]))
        {
            wrdcnt++;
        }
    }
    return wrdcnt + 1;
}

int count_sentences(string text)
{
    int sntcnt = 0;
    for (int i = 0, n = strlen(text); i < n; i++)
    {
        if (text[i] == '.' || text[i] == '!' || text[i] == '?')
        {
            sntcnt++;
        }
    }
    return sntcnt;
}
