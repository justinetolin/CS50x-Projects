#include <cs50.h>
#include <stdio.h>

int main(void)
{
    // long OGnum = get_long("Number: ");
    // long num = OGnum;

    long num = 4012888888881881;
    long OGnum = num;
    int firsts[8] = {};
    int seconds[8] = {};
    int index1 = 0;
    int index2 = 0;
    int pos = 0;

    while (num > 0)
    {
        int digit = num % 10;

        if (pos % 2 == 0)
        {
            firsts[index1++] = digit;
        }
        else
        {
            seconds[index2++] = digit;
        }

        num /= 10;
        pos++;
    }

    int Sum = 0;

    for (int i = 0; i < index2; i++)
    {
        int dbl = seconds[i] * 2;
        if (dbl >= 10)
        {
            Sum += (dbl % 10) + (dbl / 10); // sum the digits of the 2-digit number
        }
        else
        {
            Sum += dbl;
        }
    }
    for (int i = 0; i < index1; i++)
    {
        Sum += firsts[i];
    }

    int sumLastDig = Sum % 10;

    // Checker For Card Service
    long FirstOne = OGnum;
    long FirstTwo = OGnum;
    // printf("%ld/n",OGnum);

    while (FirstOne >= 10)
    {
        FirstOne /= 10;
    }
    while (FirstTwo >= 100)
    {
        FirstTwo /= 10;
    }

    int cardLength = index1 + index2;

    if (sumLastDig == 0 && cardLength == 15 && (FirstTwo == 34 || FirstTwo == 37))
    {
        printf("AMEX\n");
    }
    else if (sumLastDig == 0 && cardLength == 16 && FirstTwo >= 51 && FirstTwo <= 55)
    {
        printf("MASTERCARD\n");
    }
    else if (sumLastDig == 0 && FirstOne == 4 && (cardLength == 13 || cardLength == 16))
    {
        printf("VISA\n");
    }
    else
    {
        printf("INVALID\n");
    }
}
