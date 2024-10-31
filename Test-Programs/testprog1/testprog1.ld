/* Thanks https://github.com/darklife/darkriscv */
  __heap_size    = 0x10;  /* required amount of heap */
  __stack_size  = 0x20;  /* required amount of stack */

  MEMORY
  {
    ROM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x80000
    RAM (rwx) : ORIGIN = 0x00000080, LENGTH = 0x80000
  }
  SECTIONS
  {
    .text :
    {
      *(.boot)
      *(.text)
      *(.text)
      *(.rodata*)
    } > ROM
    .data :
    {
      *(.sbss)
      *(.data)
      *(.bss)
      *(.rela*)
      *(COMMON)
    } > RAM

    .heap :
    {
      . = ALIGN(4);
      PROVIDE ( end = . );
      _sheap = .;
      . = . + __heap_size;
      . = ALIGN(4);
      _eheap = .;
    } >RAM

    .stack :
    {
      . = ALIGN(4);
      _estack = .;
      . = . + __stack_size;
      . = ALIGN(4);
      _sstack = .;
    } >RAM
  }
                        
