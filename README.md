# FILE FUNCTION TRACING AGENT

--------------------------------------------------------------------------

Version 1.0, 18-02-1998
Copyright 1998 by Hakan Emre Kartal. All Rights Reserved.
https://github.com/AInteligent, hek@nula.com.tr

        This simple program; has been  written  to  explain  how  the  DOS
constructs the file functions and to give  and  idea  for how to get these
functions under control. Here,  I  have  added  my  code only a few names,
but it may be increased according to the request. It is up to your  talent
and knowledge. Now,  let  me  give  some  instructions  about  these  file
functions briefly:

# 1. CREATE A FILE WITH HANDLE (3Ch):

        Input:
                AH = 3Ch
                CX = File attributes
                DS:DX = ASCIIZ file name.
        Output:
                If there is an error CF=1 and AX=error no, else CF=0 and
                AX=file handle.

# 2. OPEN A FILE WITH HANDLE (3Dh):
        Input:
                AH = 3Dh
                AL = Open mode 
                DS:DX = ASCIIZ file name.
        Output:
                If there is an error CF=1 and AX=error no, else CF=0 and
                AX=file handle.

# 3. CLOSE A FILE WITH HANDLE (3Eh):
        Input:
                AH = 3Eh
                BX = File handle
        Output:
                If there is an error CF=1 and AX=error code.

# 4. READ A FILE WITH HANDLE (3Fh):
        Input:
                AH = 3Fh
                BX = File handle
                CX = Length
                DS:DX = Buffer
        Output:
                If there is an error CF=1 and AX=error code else
                CF=0 and AX=Length

# 5. WRITE A FILE WITH HANDLE (40h):
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

--------------------------------------------------------------------------

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


        This code is codified
     by no errors to the utmost.

            If you wish
          to ask question,
     to inform about the errors
      or to express your ideas
          about this code;

        Please send me E-Mail.

        Good luck...

        !!! WARNING !!!

        The copyright holder offers no warranty with this code whatsoever,
including its fitness for any particular purpose. Neither shall  be liable
for damages of any kind that may arise from its use.

        If you consider using all or parts of this code in your own
product, you may get permission from the author.

NOT: If an error occours, change the GEN_TIME value. If the error
continues, please fill and send the error declaration form to me.

                                                       Hakan Emre Kartal
                                                       hek@nula.com.tr
