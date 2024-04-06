#if !defined(__CCCBELLEK__)

#define __CCCBELLEK__

#include <stdio.h>

#define  VIRUS_IMZA       0xC031
#define  VIRUS_SEG        0x9000
#define  VIRUS_OFS        0xF000
#define  VERI_OFS         0x8E

#define  ORJINAL_VERI_SEG 0x190

#define  YENI_IMZA        0x1977

#define  DOGRU            1
#define  YANLIS           !(DOGRU)

unsigned far *BellekAdres = (unsigned far *) 0x9000F000L;

int BellekKontrol() {
   char Kontrol;

   Kontrol = ((unsigned) *BellekAdres != VIRUS_IMZA) ? (DOGRU):(YANLIS);

   return(Kontrol);
}

#pragma inline

void Pasiflestir() {
   asm CLD
   asm PUSH     DS ES SI DI

   asm PUSH     VIRUS_SEG
   asm POP      ES

   asm MOV      DI,VIRUS_OFS
   asm MOV      AX,YENI_IMZA

   asm STOSW

   asm MOV      DI,VERI_OFS
   asm MOV      AL,0xEA

   asm STOSB

   asm PUSH     +0
   asm POP      DS

   asm MOV      SI,ORJINAL_VERI_SEG
   asm MOVSW
   asm MOVSW

   asm POP      DI SI ES DS
}

extern void far (*YenidenBaslat)() = (void far (*)) 0xF000FFF0L;

/*
void YenidenBaslat() {
   __emit__(
      0x5D,                             // POP  BP
      0xEA, 0xF0, 0xFF, 0x00, 0xF0      // JMP  DWORD PTR F000:FFF0
   );
}
*/

#endif