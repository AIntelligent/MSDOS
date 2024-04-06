#if !defined(__CCCDISK__)

#define __CCCDISK__

#include <ctype.h>
#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <ctype.h>
#include <string.h>

#define  BUYUK_HARF(c)(((c)>=('a'))||((c)<=('z')))?((c)-32):((c))
#define  ISARET_BOY        14
#define  ISARET_BASLA(X, Y)(((((int)(X)*(256))+((int)(Y)))/(256)))

#define  HDSECTOR          9
#define  HDTRACK           0
#define  HDSIDE            0

#define  DKSECTOR          9
#define  DKTRACK           79
#define  DKSIDE            1

#define  FCARRY            1

#define  SONLANDIR         0
#define  TEKRARLA          1

#define  H_YAZMA           3
#define  H_SEKTOR          4
#define  H_BOZUK_SEKTOR    10
#define  H_CRC             16
#define  H_DRV_YOK         128
#define  H_DSK_DRV_YOK     122

#define  HATAYOK           0

#define  DOGRU             1
#define  YANLIS            !(DOGRU)

static  char VirusImza[]   = "¸\0ŽØ¡\0ð=1Àt\13¸";
extern  int  DiskCevrim    = HATAYOK;

int Surucu(char Ch) {
   if ((Ch == 'A') || (Ch == 'B')) return((int) (Ch - 'A'));
   if ((Ch >= 'C') || (Ch <= 'Z')) return((int) ((Ch - 'C') + 128));
   return(-1);
}

int SurucuDegistir(int Surucu) {
   _AH = 0x0E;
   _DL = Surucu;
   __int__(0x21);

   return((int) _AL);
}

int AktifSurucu() {
   _AH = 0x19;
   __int__(0x21);
   return((int) _AL);
}

int SektorKontrol(char *Sektor) {
   int Cikis;

   Sektor += (ISARET_BASLA(Sektor[1], Sektor[2]) + 2);
   Cikis = strncmp(Sektor, VirusImza, ISARET_BOY);

   return((Cikis == NULL) ? (DOGRU):(YANLIS));
}

int BasilanMesaj(const char *Mesaj) {
   char TusKod;

   printf(Mesaj);

   while (DOGRU) {
      TusKod = getch();
      TusKod = BUYUK_HARF(TusKod);
      if (TusKod == 'T') {
         TusKod = TEKRARLA;
         break;
      }
      if (TusKod == 'V') {
         TusKod = SONLANDIR;
         break;
      }
   }
   return((int) TusKod);
}

int Hatalar() {
   switch (DiskCevrim) {
      case H_YAZMA:
         printf("\rDisk(et) yazma karŸ korumal.");
         break;
      case H_SEKTOR:
         printf("\rSekt”r bulunamyor");
         break;
      case H_BOZUK_SEKTOR:
         printf("\rSekt”r bozuk");
         break;
      case H_CRC:
         printf("\rDisk(et)te CRC hatas giderilemedi");
         break;
      case H_DRV_YOK:
         printf("\rHard disk src yuvas boŸ...");
         break;
      case H_DSK_DRV_YOK:
         printf("\rDisket src yuvas boŸ...");
         break;
      default:
         printf("\rBelirsiz bir hata oluŸtu.");
         break;
   }
   return(BasilanMesaj("(T)ekrar - (V)azge‡: "));
}

int Algila(int C, int D, int H, int T, int S, void *Alan) {
   int            Cevrim,
                  Flag;

   Cevrim = 3;

   Flag = FCARRY;

   while ((Cevrim != 0) && ((Flag & FCARRY) == FCARRY)) {
      _BX = FP_OFF(Alan);
      _ES = FP_SEG(Alan);
      _CX = ((T << 8) + S);
      _DX = ((H << 8) + D);
      _AX = ((C << 8) + 1);
      geninterrupt(0x13);
      Flag = _FLAGS;
      Cevrim--;
   }

   if (Cevrim == 0)
      return(_AH);
   else
      return(0);
}

#endif
