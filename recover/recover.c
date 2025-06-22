#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

const int BLOCKSIZE = 512;

int main(int argc, char *argv[])
{
    // Accept a single command-line argument
    if (argc != 2)
    {
        printf("Usage: ./recover FILE\n");
        return 1;
    }

    // Open the memory card
    FILE *card = fopen(argv[1], "r");

    // Create a buffer for a block of data
    uint8_t buffer[BLOCKSIZE];
    int fileCount = 0;
    char filename[8];
    FILE *img = NULL;
    int activeFile = 0;

    // While there's still data left to read from the memory card
    while (fread(buffer, 1, 512, card) == 512)
    {
        // If start of new jpg then open if first, but if not, then close the current and open new
        // one and write bytes there
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff &&
            (buffer[3] & 0xf0) == 0xe0)
        {
            // if first file
            if (fileCount)
            {
                fclose(img);
            }
            activeFile = 1;

            sprintf(filename, "%03i.jpg", fileCount++);
            img = fopen(filename, "w");
            fwrite(buffer, 1, BLOCKSIZE, img);

        }
        else if (activeFile)
        {
            fwrite(buffer, 1, BLOCKSIZE, img);
        }

    }

    if (img != NULL)
    {
        fclose(img);
    }

    fclose(card);
    return 0;
}
