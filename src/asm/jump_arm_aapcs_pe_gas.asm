    .syntax unified
    .text
    .align 4
    .global jump_fcontext

jump_fcontext:
    @ save LR as PC
    push    {lr}

    @ save hidden (a1), v1-v8, LR
    @ a1 == r0, a2 == r1, a3 == r2, a4 == r3, a5 == r4
    push    {r0, r4-r11, lr}

    @ load TIB to save/restore thread size and limit
    @ use r4 (v1) as in original
    mrc     p15, #0, r4, c13, c0, #2

    @ save current stack base
    ldr     r5, [r4, #0x04]
    push    {r5}

    @ save current stack limit
    ldr     r5, [r4, #0x08]
    push    {r5}

    @ save current deallocation stack
    ldr     r5, [r4, #0xe0c]
    push    {r5}

    @ store SP (pointing to context-data) in r0 (a1)
    mov     r0, sp

    @ restore SP (pointing to context-data) from r1 (a2)
    mov     sp, r1

    @ restore deallocation stack
    pop     {r5}
    str     r5, [r4, #0xe0c]

    @ restore stack limit
    pop     {r5}
    str     r5, [r4, #0x08]

    @ restore stack base
    pop     {r5}
    str     r5, [r4, #0x04]

    @ restore hidden (a4), v1-v8, LR
    @ original: pop {a4,v1-v8,lr}
    pop     {r3, r4-r11, lr}

    @ return transfer_t from jump
    @ original: str a1, [a4, #0]; str a3, [a4, #4]
    str     r0, [r3, #0]
    str     r2, [r3, #4]

    @ pass transfer_t as first arg in context function
    @ A1 == FCTX, A2 == DATA
    mov     r1, r2

    @ restore PC
    pop     {pc}
