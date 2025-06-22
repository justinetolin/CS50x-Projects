#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

bool validator(string key);
void encrypt(string text, string key, char cipher[]);

int main(int argc, string argv[])
{
    // VALIDATION
    if (argc == 2)
    {
        if (!validator(argv[1]))
        {
            return 1;
        }
    }
    else
    {
        printf("Usage: ./substitution key\n");
        return 1;
    }

    // ENCRYPTION
    string plain = get_string("plaintext: ");
    // string text = "HELLo!";

    char cipher[strlen(plain) + 1];

    encrypt(plain, argv[1], cipher);

    printf("ciphertext: %s\n", cipher);
}

bool validator(string key)
{
    if (strlen(key) != 26)
    {
        printf("Key must contain 26 characters.\n");
        return false;
    }
    if (strlen(key) == 26)
    {
        for (int i = 0; i < 26; i++)
        {
            if (!isalpha(key[i]))
            {
                printf("Key must be all alphabetic.\n");
                return false;
            }
        }
    }
    if (strlen(key) == 26)
    {
        int length = strlen(key);

        for (int i = 0; i < length; i++)
        {
            char one = toupper(key[i]);
            for (int k = i + 1; k < length; k++)
            {
                char two = toupper(key[k]);
                if (one == two)
                {
                    printf("Key characters must only occur once.\n");
                    return false;
                }
            }
        }
    }
    // printf("VALID\n");
    return true;
}

void encrypt(string text, string key, char cipher[])
{
    int len = strlen(text);
    char encryptChar;

    for (int i = 0; i < len; i++)
    {
        char c = text[i];
        int pos = 0;
        if (isalpha(c))
        {
            pos = toupper(c) - 'A';
            if (isupper(c))
            {
                encryptChar = toupper(key[pos]);
            }
            else
            {
                encryptChar = tolower(key[pos]);
            }
            cipher[i] = encryptChar;
        }
        else
        {
            cipher[i] = c;
        }
    }
    cipher[len] = '\0';
}
