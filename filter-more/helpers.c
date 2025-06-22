#include "helpers.h"
#include <math.h>

// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    for (int h = 0; h < height; h++)
    {
        for (int w = 0; w < width; w++)
        {
            // calc pixel average
            int r = image[h][w].rgbtRed;
            int g = image[h][w].rgbtGreen;
            int b = image[h][w].rgbtBlue;

            int avgint = round((r + g + b) / 3.0);
            // int avgint = round(avgFlt);

            // assign avg to pixelw
            image[h][w].rgbtRed = avgint;
            image[h][w].rgbtGreen = avgint;
            image[h][w].rgbtBlue = avgint;
        }
    }
    return;
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    for (int h = 0; h < height; h++)
    {
        for (int w = 0; w < floor(width / 2); w++)
        {
            // store current pixel to temp
            RGBTRIPLE temp;
            temp.rgbtRed = image[h][w].rgbtRed;
            temp.rgbtGreen = image[h][w].rgbtGreen;
            temp.rgbtBlue = image[h][w].rgbtBlue;

            // reassign current to last
            image[h][w].rgbtRed = image[h][width - w - 1].rgbtRed;
            image[h][w].rgbtGreen = image[h][width - w - 1].rgbtGreen;
            image[h][w].rgbtBlue = image[h][width - w - 1].rgbtBlue;

            // reassign last to temp
            image[h][width - w - 1].rgbtRed = temp.rgbtRed;
            image[h][width - w - 1].rgbtGreen = temp.rgbtGreen;
            image[h][width - w - 1].rgbtBlue = temp.rgbtBlue;
        }
    }
    return;
}

// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    // create RGBTRIPLE copy
    RGBTRIPLE copy[height][width];
    for (int x = 0; x < height; x++)
    {
        for (int y = 0; y < width; y++)
        {
            copy[x][y] = image[x][y];
        }
    }

    // loop thrugh per pixel, select the surrounding pixels of the copy, average, reassign the
    // values to original loop to select an working pixel
    for (int h = 0; h < height; h++)
    {
        for (int w = 0; w < width; w++)
        {
            int redSum = 0, greenSum = 0, blueSum = 0;
            int pixelcount = 0;

            // loop to select surrounding pixel
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {
                    int crtY = h + y;
                    int crtX = w + x;

                    if (crtY >= 0 && crtY < height && crtX >= 0 && crtX < width)
                    {
                        redSum += copy[crtY][crtX].rgbtRed;
                        greenSum += copy[crtY][crtX].rgbtGreen;
                        blueSum += copy[crtY][crtX].rgbtBlue;
                        pixelcount++;
                    }
                }
            }

            image[h][w].rgbtRed = round((float) redSum / pixelcount);
            image[h][w].rgbtGreen = round((float) greenSum / pixelcount);
            image[h][w].rgbtBlue = round((float) blueSum / pixelcount);
        }
    }

    return;
}

// Detect edges
void edges(int height, int width, RGBTRIPLE image[height][width])
{
    // create RGBTRIPLE copy
    RGBTRIPLE copy[height][width];
    for (int x = 0; x < height; x++)
    {
        for (int y = 0; y < width; y++)
        {
            copy[x][y] = image[x][y];
        }
    }

    // compute for Gx
    int Gx[3][3] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
    int Gy[3][3] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};

    // loop to select an working pixel
    for (int h = 0; h < height; h++)
    {
        for (int w = 0; w < width; w++)
        {
            int matXrgb[3] = {0, 0, 0};

            int matYrgb[3] = {0, 0, 0};

            // loop to select surrounding pixel to compute for Gx
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {

                    int crtY = h + y;
                    int crtX = w + x;

                    int multiplier = Gx[y + 1][x + 1];

                    if (crtY >= 0 && crtY < height && crtX >= 0 && crtX < width)
                    {
                        matXrgb[0] += copy[crtY][crtX].rgbtRed * multiplier;
                        matXrgb[1] += copy[crtY][crtX].rgbtGreen * multiplier;
                        matXrgb[2] += copy[crtY][crtX].rgbtBlue * multiplier;
                    }
                }
            }

            // loop to select surrounding pixel to compute for Gy
            for (int y = -1; y <= 1; y++)
            {
                for (int x = -1; x <= 1; x++)
                {

                    int crtY = h + y;
                    int crtX = w + x;

                    int multiplier = Gy[y + 1][x + 1];

                    if (crtY >= 0 && crtY < height && crtX >= 0 && crtX < width)
                    {
                        matYrgb[0] += copy[crtY][crtX].rgbtRed * multiplier;
                        matYrgb[1] += copy[crtY][crtX].rgbtGreen * multiplier;
                        matYrgb[2] += copy[crtY][crtX].rgbtBlue * multiplier;
                    }
                }
            }

            // compute the new channel values
            int rootPixVal[3] = {0, 0, 0};
            for (int i = 0; i < 3; i++)
            {
                int val = round(sqrt(matXrgb[i] * matXrgb[i] + matYrgb[i] * matYrgb[i]));
                if (val <= 0)
                {
                    rootPixVal[i] = 0;
                }
                else if (val >= 255)
                {
                    rootPixVal[i] = 255;
                }
                else
                {
                    rootPixVal[i] = val;
                }
            }

            // reassign the new pixel to the image
            image[h][w].rgbtRed = rootPixVal[0];
            image[h][w].rgbtGreen = rootPixVal[1];
            image[h][w].rgbtBlue = rootPixVal[2];
        }
    }

    return;
}
