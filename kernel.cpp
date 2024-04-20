#include "types.h"

void printf(char* str)
{
    static uint16_t* VideoMemory = (uint16_t*)0xb8000;

    for (int i=0; str[i] != '\0'; i++) 
    {
        VideoMemory[i] = (VideoMemory[i] & 0xFF00) | str[i]; // (VideoMemory[i] & 0xFF00) copies original hi-byte (color info)
    }
}

typedef void (*constructor)();
extern "C" constructor start_ctors;
extern "C" constructor end_ctors;
extern "C" void callConstructors()
{
    for (constructor* i = &start_ctors; i != &end_ctors; i++) 
    {
        (*i)();
    }
}

extern "C" void kernelMain(const void* multiboot_structure, uint32_t magic_number)
{
    printf("Hello World, Welcome to TSL OS!");

    while(1);
}


/*
    PRINT F - How it works:
        0xb8000 - writing to this memory adress tells the GPU to write the text to the screen.

        bits 0-7   - character
        bits 8-11  - foreground color
        bits 12-14 - background color
        bit 15     - blink
*/