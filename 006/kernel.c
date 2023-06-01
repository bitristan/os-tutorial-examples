typedef unsigned short uint16_t;

void printk(char *str) {
    static uint16_t *video_buffer = (uint16_t *)0xb8000;

    for (int i = 0; str[i] != '\0'; i++) {
        video_buffer[i] = str[i] | 0x0400; // 黑底白字
    }
}

void kernel_main(unsigned int magic) {
    printk("Hello OS!");
}
