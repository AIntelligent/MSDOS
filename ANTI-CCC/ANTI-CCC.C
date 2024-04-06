/*
 * ANTI-CCC
 * Hakan Emre KARTAL
 * hek@nula.com.tr
 * Iskenderun/HATAY
 * 18/07/1998
 *
 * ISTANBUL-CCC boot sektîr virÅsÅnÅ diskten temizler.
 * Eßer virÅs bellekte aktifse înce pasifleütirir.
 *
 * It cleans the ISTANBUL-CCC boot sector vrius from the disk.
 * If the virus is active in memory, it first passive it.
 *
 * Written by Hakan Emre KARTAL in Iskenderun/HATAY on 18/07/1998.
 *
 */
#include <ctype.h>
#include <string.h>
#include <conio.h>

#include "cccdisk.h"
#include "cccbllk.h"

static char Ch, X;
static int  Cevrim = 0, I;
static char Boot[512];

int HataDuzelt() {
   if (DiskCevrim != 0) {
      Cevrim++;
      if (Cevrim >= 4) {
	 printf("\nÄevrimsel hata taümasç...\n");
	 return(-1);
      }
      if (Hatalar() == SONLANDIR) {
	 printf("\nAlgçlanan hata sebebiyle program durduruldu.\n\n");
	 SurucuDegistir(Surucu(X));
	 return(-1);
      }
   }

   return(0); // Hatasçz
}


int main() {

  while (1) {

     textattr(LIGHTGRAY);
     clrscr();

     printf("ANTi iSTANBUL-CCC, Uyarlama 1.01/1998\n\n\r");

     printf("Hakan Emre KARTAL, òskenderun/HATAY, 18/07/1998\n\r");
     printf("hek@nula.com.tr\n\n\r" );

     Cevrim = BellekKontrol();
     printf("\n\nBellek testi: %s", (Cevrim) ? ("TAMAM"):("VòRöSLö"));

     if (!Cevrim) {
	printf("\nVirÅs bellekte pasif hale getirildi...");
	Pasiflestir();
     }

     X = (char)(AktifSurucu() + 'A');

     do {
	printf("\r\n\nSÅrÅcÅ: ");

	Ch = getch();

	if (Ch == 27) {
	   SurucuDegistir(Surucu(X));
	   return(0);
	}

	Ch = BUYUK_HARF(Ch);

     } while ((Ch < 'A') || (Ch > 'Z'));

     printf( "%c", Ch );

     SurucuDegistir(Surucu(Ch));

     printf("\n\n\n");

     while (1) {
	DiskCevrim = Algila(2, 0, 0, 0, 1, Boot);

	if (HataDuzelt() == -1)
	   break;

	if (SektorKontrol(Boot)) {

	   printf("\rSÅrÅcÅde òSTANBUL-CCC virÅsÅ bulundu; ", Ch);

	   if (BasilanMesaj("(T)emizle - (V)azgeá: ") == SONLANDIR) {
	      printf("\nSÅrÅcÅden virÅs temizlenmedi !!!\n\n\7");

	      break;
	   } else {
	      I = ((Ch >= 'C') || (Ch <= 'Z')) ? (1):(0);

	      DiskCevrim = (
		 Algila(
		    2,
		    0,
		    (I)?(HDSIDE):(DKSIDE),
		    (I)?(HDTRACK):(DKTRACK),
		    (I)?(HDSECTOR):(DKSECTOR),
		    Boot
		 )
	      );

	      if (HataDuzelt() == -1)
		 break;
	   }
	}
     }

     break;
  }

  return(0);
}