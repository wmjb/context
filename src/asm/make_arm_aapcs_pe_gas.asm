    .syntax unified
    .text
    .align 4
    .global make_fcontext
    .extern _exit

    @ first arg of make_fcontext() == top of context-stack
    @ AAPCS: r0 = a1, r1 = a2, r2 = a3
    @ use r3 as the saved top-of-stack (base)

make_fcontext:
    @ save top of context-stack (base) in r3
    mov     r3, r0

    @ shift address in r0 to lower 16 byte boundary
    bic     r0, r0, #0x0f

    @ reserve space for context-data on context-stack
    sub     r0, r0, #0x48

    @ save top address of context_stack as 'base'
    str     r3, [r0, #0x8]

    @ second arg of make_fcontext() == size of context-stack
    @ compute bottom address of context-stack (limit)
    sub     r3, r3, r1

    @ save bottom address of context-stack as 'limit'
    str     r3, [r0, #0x4]

    @ save bottom address of context-stack as 'deallocation stack'
    str     r3, [r0, #0x0]

    @ third arg of make_fcontext() == address of context-function
    str     r2, [r0, #0x34]

    @ compute address of returned transfer_t
    add     r1, r0, #0x38
    mov     r2, r1
    str     r2, [r0, #0xc]

    @ compute abs address of label finish
    adr     r1, finish

    @ save address of finish as return-address for context-function
    @ will be entered after context-function returns
    str     r1, [r0, #0x30]

    @ return pointer to context-data in r0
    bx      lr

finish:
    @ exit code is zero
    mov     r0, #0

    @ exit application
    bl      _exit
