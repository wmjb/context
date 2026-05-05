    .syntax unified
    .text
    .align 4
    .global ontop_fcontext

ontop_fcontext:
    @ save LR as PC
    push    {lr}

    @ save hidden (a1=r0), v1-v8 (r4-r11), LR
    push    {r0, r4-r11, lr}

    @ load TIB to save/restore thread size and limit
    @ use r4 (v1) as in original
    mrc     p15, #0, r4, c13, c0, #2

    @ save current stack base
    ldr     r0, [r4, #0x04]
    push    {r0}

    @ save current stack limit
    ldr     r0, [r4, #0x08]
    push    {r0}

    @ save current deallocation stack
    ldr     r0, [r4, #0xe0c]
    push    {r0}

    @ store SP (pointing to context-data) in r0 (A1)
    mov     r0, sp

    @ restore SP (pointing to context-data) from r1 (A2)
    mov     sp, r1

    @ restore stack base
    pop     {r0}
    str     r0, [r4, #0x04]

    @ restore stack limit
    pop     {r0}
    str     r0, [r4, #0x08]

    @ restore deallocation stack
    pop     {r0}
    str     r0, [r4, #0xe0c]

    @ store parent context in r1 (A2)
    mov     r1, r0

    @ restore hidden (a1=r0), v1-v8 (r4-r11), LR
    pop     {r0, r4-r11, lr}

    @ return transfer_t from jump
    @ original: str a2, [a1, #0]; str a3, [a1, #4]
    str     r1, [r0, #0]
    str     r2, [r0, #4]

    @ skip PC
    add     sp, sp, #4

    @ jump to ontop-function (a4 = r3)
    bx      r3
