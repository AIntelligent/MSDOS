# 1CWATCH MS-DOS TSR CLOCK

![1CWATCH](https://github.com/AIntelligent/MSDOS/blob/ebaa74adf68421166e9397e195e6e2bfa1c0a197/1CWATCH/screenshots/1CWATCH_1.PNG)

# ANTI ISTANBUL-CCC BOOT SECTOR VIRUS

## TR
    Hakan Emre KARTAL tarafından İskenderun/HATAY'da 18/07/1998 tarihinde yazıldı,
    Borland Turbo C 3.0 ile derlendi.
    
    İSTANBUL-CCC boot sektör virüsünü diskten temizler.
    Eğer virüs bellekte aktifse önce pasifleştirir.

    Not: MS-DOS işletim sistemlerinin yerini MS-Windows aldığından beri, önyükleme sektörü 
    virüsleri de işlevini kaybetmiştir. Buradaki kodlar bilgilendirme amaçlı paylaşılmaktadır.
    Eğer yine de kullanmak isterseniz tüm sorumluluk size aittir.

## EN
    Written by Hakan Emre KARTAL in Iskenderun/HATAY on 18/07/1998,
    Compiled using Borland Turbo C 3.0.

    It cleans the ISTANBUL-CCC boot sector virus from the disk.
    If the virus is active in memory, it first passive it.

    Note: Since MS-DOS operatin system were replaced by MS-Windows, boot sector viruses
    have also lost their function. The codes here are shared for informational purposes.
    If you still want to use it, all responsibility lies with you.

# Ekran Alıntısı/Screenshot

![ANTI-CCC](https://github.com/AIntelligent/MSDOS/blob/67b94596f017f2fb15260b0b2d160adae3821ca3/ANTI-CCC/screenshots/ANTI-CCC_1.PNG)

# TPVOSIL/ANTI-TPVO.3783

## TR
    Hakan Emre KARTAL tarafından İskenderun/HATAY'da 19/10/1998 tarihinde yazıldı.
    Borland Turbo Pascal 6.0 ile derlendi.

    TPVO.3783 dosya virüsünü belirtilen sürücüdeki tüm dizin ve alt
    dizinlerde arar. Bulduğu virüslü dosyaları temizler. Eğer virüs
    bellekte aktif ise kullanıcıyı uyarır ve işlemi durdurur.

    Not: MS-DOS işletim sistemlerinin yerini MS-Windows aldığından beri, MS-DOS dosya 
    virüsleri de işlevini kaybetmiştir. Buradaki kodlar bilgilendirme amaçlı paylaşılmaktadır.
    Eğer yine de kullanmak isterseniz tüm sorumluluk size aittir.

## EN
    Written by Hakan Emre KARTAL in Iskenderun/HATAY on 19/10/1998.
    Compiled using Borand Turbo Pascal 6.0.

    It searches for the TPVO.3873 file virus in all directories and
    subdirectories on the target drive. It cleans the infected files
    it finds. If the virus is active in memory, it warns the user and
    stops the process.

    Note: Since MS-DOS operating system were replaced MS-Windows, MS-DOS file viruses
    have also lost their function. The codes here are shared for informational purposes.
    If you still want to use it, all responsibility lies with you.

# Ekran Alıntısı/Screenshot
![ANTI-TPVO.3783](https://github.com/AIntelligent/MSDOS/blob/8252148dde47e1b2807b12a93a086f4c64094456/ANTI-TPVO.3783/screenshots/TPVO_1.PNG)

# FILE FUNCTION TRACING AGENT

Version 1.0, 18-02-1998
Copyright 1998 by Hakan Emre Kartal. All Rights Reserved.
https://github.com/AInteligent, hek@nula.com.tr

This simple program; has been  written  to  explain  how  the  DOS
constructs the file functions and to give  and  idea  for how to get these
functions under control. Here,  I  have  added  my  code only a few names,
but it may be increased according to the request. It is up to your  talent
and knowledge. Now,  let  me  give  some  instructions  about  these  file
functions briefly:

## 1. CREATE A FILE WITH HANDLE (3Ch):
        Input:
                AH = 3Ch
                CX = File attributes
                DS:DX = ASCIIZ file name.
        Output:
                If there is an error CF=1 and AX=error no, else CF=0 and
                AX=file handle.

## 2. OPEN A FILE WITH HANDLE (3Dh):
        Input:
                AH = 3Dh
                AL = Open mode 
                DS:DX = ASCIIZ file name.
        Output:
                If there is an error CF=1 and AX=error no, else CF=0 and
                AX=file handle.

## 3. CLOSE A FILE WITH HANDLE (3Eh):
        Input:
                AH = 3Eh
                BX = File handle
        Output:
                If there is an error CF=1 and AX=error code.

## 4. READ A FILE WITH HANDLE (3Fh):
        Input:
                AH = 3Fh
                BX = File handle
                CX = Length
                DS:DX = Buffer
        Output:
                If there is an error CF=1 and AX=error code else
                CF=0 and AX=Length

## 5. WRITE A FILE WITH HANDLE (40h):
        Input:
                AH = 40h
                BX = File handle
                CX = Length
                DS:DX = Buffer
        Output:
                If there is an error CF=1 and AX=error code else
                CF=0 and AX=Length

If you pay attention,  it  will be seen that all are directed by a
"File handle". Well, we will form our program on this. Now, let me explain
how I construct it briefly:

        INVALID_HANDLE_VALUE       = 0FFFFh
        FILE_DATA        struc
                Handle      dw      INVALID_HANDLE_VALUE    #1
                Attrib      dw      0                       #2
                Mode        db      0                       #3
                TotalRead   dd      0                       #4
                TotalWrite  dd      0                       #5
        MAX_NAME            =       100
                Name        db      MAX_NAME dup (0), 0     #6
        FILE_DATA        ends

#1. Handle: This is the number  of  the  file  which  the  functions  will  be
constructed on. When you examine the source  code,  you will see that "Handle"
is work up if it is over  cartain  value.  The  reason  of  that  is,  DOS
hides the values which are inferior of the _INVALID_HANDLE  values for some
devices. For example; 0=CON represents the standart output device.

#2. Attrib: Characteristics of the created file. (Look: 3Ch)

#3. Mode: Manipulated characteristics of the opened file. (Look: 3Dh)

#4. TotalRead: Keeps the total knowledge which is read over the file.
I think this is more appropriate. (Look: 3Fh)

#5. TotalWrite: Keeps the total knowledge written on the file.    
I think this is more appropriate. (Look: 40h)

Well  I keep the file informations for using them afterwards by  a
structure like this. 
 
Now, let me tell you how I direct an  information  chain  that  is
defined under this type structure.

--------------------------------------------------------------------------

_Find(@@Handle): Finds any knowledge inside the FILE_DATA typed information
chain. If it finds CF=0 holds DX=Sequence number and DI=Offset address.

--------------------------------------------------------------------------

_Add(@@Handle, @@NamePtr, @@Attrib, @@Mode): Makes an addion to 
the FILE_DATA typed information chain. If it is successful CF becomes 
CF=0 and  DI holds the offset address (DI=offset address).

--------------------------------------------------------------------------

_Remove(@@Handle): Removes any  knowledge  from the FILE_DATA typed 
information chain.

--------------------------------------------------------------------------

_NullData( ): It unloads the FILE_DATA typed information chain and
gets them to their first values.

--------------------------------------------------------------------------

Because of the codes are easy, I think it is unnecessary  to  tell
the other lower programs. Now,  let's  see  how  I  have done the function
control:


       FUNCFILTER      struc
                Func     db      ?       #1
                Filter	dw      ?       #2
                Message	dw      ?       #3
       FUNCFILTER      ends

#1. Func: Holds the code of the function which will be controlled.

#2. Filter: Well, this holds the offset address of the lower program which
will be making the control. By this way if that function is called, we can
control  it  by  calling  with  an easy CALL. This  provides  us security,
simplicty and it allows us to increase the development of our code.

#3. Message: Holds  the  offset address of the message which is used to give
information about the function.

--------------------------------------------------------------------------

WELL, NOW THE EASY CODIFYING LOGIC LYING UNDER THE WHOLE CODE.

This code is codified by no errors to the utmost.

If you wish to ask question, to inform about the errors or to express your 
ideas about this code;

Please send me E-Mail.

Good luck...

## !!! WARNING !!!

        The copyright holder offers no warranty with this code whatsoever,
        including its fitness for any particular purpose. Neither shall  be liable
        for damages of any kind that may arise from its use.
        
        If you consider using all or parts of this code in your own
        product, you may get permission from the author.
        
        NOT: If an error occours, change the GEN_TIME value. If the error
        continues, please fill and send the error declaration form to me.

# HEK DİZİN AĞAÇ

    HEK DiZiN AGAC, uyarlama 1.0,1996
    Hakan Emre KARTAL, Iskenderun/HATAY,23/11/1996

## TR 
        Not: Kişisel bilgilerin bazıları güncel halleriyle değiştirildi ya da silindi.

## Ne Yapar?
    
        Bu program belirtilen dizin ve alt dizinlerin haritasını bağlantı ağacı şeklinde görüntüler.

## EN:    
        Note: Some of the personal information has been changed to its current form or deleted.
    
## What does it do?

        This program scans specified folders and subfolders, allowing the link to be visualized as a tree.

## Ekran Alıntıları/Screenshots
![HEKAGAC_1](https://github.com/AIntelligent/MSDOS/blob/f53ffdf2d8c3e36e170f99cb7b6f81538edca6b7/HEKAGAC/screenshots/HEKAGAC_1.PNG)
![HEKAGAC_1](https://github.com/AIntelligent/MSDOS/blob/f53ffdf2d8c3e36e170f99cb7b6f81538edca6b7/HEKAGAC/screenshots/HEKAGAC_2.PNG)
![HEKAGAC_1](https://github.com/AIntelligent/MSDOS/blob/f53ffdf2d8c3e36e170f99cb7b6f81538edca6b7/HEKAGAC/screenshots/HEKAGAC_3.PNG)
![HEKAGAC_1](https://github.com/AIntelligent/MSDOS/blob/f53ffdf2d8c3e36e170f99cb7b6f81538edca6b7/HEKAGAC/screenshots/HEKAGAC_4.PNG)
![HEKAGAC_1](https://github.com/AIntelligent/MSDOS/blob/f53ffdf2d8c3e36e170f99cb7b6f81538edca6b7/HEKAGAC/screenshots/HEKAGAC_5.PNG)

# YAZILIM KORUYUCU (YAZKOR) EKLEYİCİ YARDIMCI ARACI

## TR
    Hakan Emre KARTAL tarafından İskenderun/HATAY'da 25/07/2000 tarihinde yazıldı,
    Borland Turbo Pascal 6.0 ile derlendi.

    Bu yardımcı araç; geliştirdiğiniz programlarınızın izinsiz kopyalanmasını
    önleyen ve şifre ile kullanılmasını sağlayan YAZILIM KORUYUCU eklentisini,
    belirlediğiniz çalışabilir (EXE,COM) dosyalara kolayca eklemenizi sağlar.

    Not: Bahsedilen YAZILIM KORUYUCU eklentisi, MS-DOS işletim sistemi için
    geliştirilen programları korumaktadır. YAZILIM KORUYUCU, daha sonraki
    yıllarda MS-Windows 32bit ve 64bit işletim sistemleri için uyarlanmış
    ve halen kullanılabilir durumdadır. Bu sebeple bu kodlardan kasten 
    çıkartılmıştır.

## EN
    Written by Hakan Emre KARTAL in Iskenderun/HATAY on 25/07/2000,
    Compiled using Borland Turbo Pascal 6.0

    This helpful tool; It allows easily added the YAZILIM KORUYUCU plug-in,
    which prevents your developed programs from being copied without permission
    and allows them to be used with a password, to the executable (EXE,COM) files
    you specify.

    Note: YAZILIM KORUYUCU plug-in in question protects programs developed by
    MS-DOS operating system. YAZILIM KORUYUCU was adapted for MS-Windows 32bit
    and 64bit operating systems in later years and is still available. For this
    reason, it was deliberately omitted from these codes.

## Ekran Alıntıları/Screensohts

![YAZKOR_1](https://github.com/AIntelligent/MSDOS/blob/ad4eeae729f1ec299bc5ee1f7eb8e77a0c026ebc/YAZKOR/screenshots/YAZKOR_1.PNG)
![YAZKOR_2](https://github.com/AIntelligent/MSDOS/blob/ad4eeae729f1ec299bc5ee1f7eb8e77a0c026ebc/YAZKOR/screenshots/YAZKOR_2.PNG)
![YAZKOR_3](https://github.com/AIntelligent/MSDOS/blob/ad4eeae729f1ec299bc5ee1f7eb8e77a0c026ebc/YAZKOR/screenshots/YAZKOR_3.PNG)
![YAZKOR_4](https://github.com/AIntelligent/MSDOS/blob/ad4eeae729f1ec299bc5ee1f7eb8e77a0c026ebc/YAZKOR/screenshots/YAZKOR_4.PNG)
![YAZKOR_5](https://github.com/AIntelligent/MSDOS/blob/ad4eeae729f1ec299bc5ee1f7eb8e77a0c026ebc/YAZKOR/screenshots/YAZKOR_5.PNG)

## ANTI TPVO.3783 TRAKIA.561 OXANA, uyarlama 1.0

## TR
    Hakan Emre KARTAL tarafından İskenderun/HATAY'da 21/10/1998 tarihinde yazıldı,
    Borland Turbo Pascal 6.0 ile derlendi.

##EN 
    Written by Hakan Emre KARTAL in Iskenderun/HATAY on 21/10/1998, 
    Compiled using Borland Turbo Pascal 6.0

## Ekran Alıntıları/Screenshots
![ANTI3_1](https://github.com/AIntelligent/MSDOS/blob/12a613e61a7d55bb809779aa0ae2ed45e5a617ca/ANTI3/screenshots/ANTI3_1.PNG)
![ANTI3_2](https://github.com/AIntelligent/MSDOS/blob/12a613e61a7d55bb809779aa0ae2ed45e5a617ca/ANTI3/screenshots/ANTI3_2.PNG)
![ANTI3_3](https://github.com/AIntelligent/MSDOS/blob/12a613e61a7d55bb809779aa0ae2ed45e5a617ca/ANTI3/screenshots/ANTI3_3.PNG)
