mov 	esp, 0x10000000
push	dword 0x800000B0
mov 	esp, 0x10000000	
push	dword 0x0300000B0	
mov eax, 0
loop1:
add eax, 1									
push eax
loop2:
mov 	esp, 0x10000005
pop ebx
and ebx, 0x20
cmp	ebx, 0
ja 	loop1
jmp	loop2