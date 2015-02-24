#include "../lib/storm_core.h"
#include "../lib/storm_soc_basic.h"
#include "../lib/io_driver.c"
#include "../lib/utilities.c"
#include "../lib/uart.c"

// +------------------------------+
// |    Simple Program Demo       |
// +------------------------------+

// This program uses the system timer to toggle LED(0) of the System IO
// port every second. Also a demo output to the terminal is made.
// Received UART transmission are echoed.


/* ---- IRQ: Timer ISR ---- */
void __attribute__ ((interrupt("IRQ"))) timer0_isr(void)
{
	static unsigned long gpio = 0;
	static unsigned int count = 0;
	static unsigned int count2 = 0;

	if (count++ > 8) {
		count = 0;
		// toggle status blue led
		gpio = gpio ^ 0x0001;	
		io_set_gpio0_port(gpio);
		//io_uart0_send_byte('*');
	}
//	if (count == 4 || count == 0) {
	if (count2++ > 4) {
		count2 = 0;
		// toggle status red led
		gpio = gpio ^ 0x0004;	
		io_set_gpio0_port(gpio);
	}
	int shift = 1 << count;
	set_syscpreg((get_syscpreg(SYS_IO) ^ shift), SYS_IO);

	// acknowledge interrupt
	VICVectAddr = 0;
}


/* ---- Main function ---- */
int main(void)
{
	char line[256];
	int cur = 0;
	int ch;

	// Intro
	uart0_printf("\r\n\r\nSTORM SoC Basic Configuration\r\n");
	uart0_printf(">>> Tourlou Demo program <<<\r\n\r\n");

	uart0_printf("Enter commands :\r\n");

	// echo received char
	while(1){
		ch = io_uart0_read_byte();
		if (ch != -1) {
			line[cur++] = ch;
			io_uart0_send_byte(ch);
			if (ch == '\r') {
				line[cur] = 0;
				cur = 0;
				uart0_printf(line);
				uart0_printf("\r\n");
//				if (strcmp(line, "dump") == 0) {
				if (string_cmpc(line, "dump", 4) != 0) {
					char buf[16];
					unsigned char *ptr = 0x00000000;
					for (int j = 0; j < 16; j++) {
						char str[20];
						str[16] = 0;
						long_to_hex_string(ptr + j * 16, buf, 8);
						buf[8] = ':';
						buf[9] = 0;
						uart0_printf(buf);
						for (int i = 0; i < 16; i++) {
							char c = *(ptr + j * 8 + i);
							if (c >= 32)
								str[i] = c;
							else
								str[i] = '.';
							long_to_hex_string(c, buf, 2);
							buf[2] = ' ';
							buf[3] = 0;
							uart0_printf(buf);
						}
						uart0_printf("  ");
						uart0_printf(str);
						uart0_printf("\r\n");
					}
				}
				if (string_cmpc(line, "hdump", 5) != 0) {
					char buf[16];
					unsigned long *ptr = 0x10000000;
					for (int j = 0; j < 16; j++) {
						long_to_hex_string(ptr + j * 8, buf, 8);
						buf[8] = ':';
						buf[9] = 0;
						uart0_printf(buf);
						for (int i = 0; i < 8; i++) {
							long_to_hex_string(*(ptr + j * 8 + i), buf, 8);
							buf[8] = ' ';
							buf[9] = 0;
							uart0_printf(buf);
						}
						uart0_printf("\r\n");
					}
				}
				else
					uart0_printf("Error !\r\n");
			}
			
			if (ch == '2')
				set_syscpreg((get_syscpreg(SYS_IO) ^ 0x02), SYS_IO);
			if (ch == '3')
				set_syscpreg((get_syscpreg(SYS_IO) ^ 0x04), SYS_IO);
			if (ch == '4')
				set_syscpreg((get_syscpreg(SYS_IO) ^ 0x08), SYS_IO);
			if (ch == '5')
				set_syscpreg((get_syscpreg(SYS_IO) ^ 0x10), SYS_IO);
			if (ch == '6')
				set_syscpreg((get_syscpreg(SYS_IO) ^ 0x20), SYS_IO);
			if (ch == '7')
				set_syscpreg((get_syscpreg(SYS_IO) ^ 0x40), SYS_IO);
			if (ch == '8')
				set_syscpreg((get_syscpreg(SYS_IO) ^ 0x80), SYS_IO);
			if (ch == 'c')
				set_syscpreg(0x00, SYS_IO);
			if (ch == 'f')
				set_syscpreg(0xFF, SYS_IO);
			if (ch == 'z')
				io_set_gpio0_port(0x0000000);
			if (ch == 'x')
				io_set_gpio0_port(0xFFFFFFF);
			if (ch == 'a')
				set_syscpreg((get_syscpreg(SYS_IO) ^ 0x100), SYS_IO);
			if (ch == 'q') {
				char buf[16];
				unsigned long *ptr = 0x10000000;
				unsigned long val = 0xAA550000;
				for (int j = 0; j < 32; j++) {
					*(ptr++) = val++;
				}
			}
			if (ch == 'w') {
				char buf[16];
				unsigned long *ptr = 0x10000080;
				unsigned long val = 0x55AA0000;
				for (int j = 0; j < 32; j++) {
					*(ptr++) = val++;
				}
			}
			if (ch == 'e') {
				char buf[16];
				unsigned long *ptr = 0x10000100;
				unsigned long val = 0x5A5A0000;
				for (int j = 0; j < 32; j++) {
					*(ptr++) = val++;
				}
			}
			if (ch == 'r') {
				char buf[16];
				unsigned long *ptr = 0x10000000;
				for (int j = 0; j < 16; j++) {
					long_to_hex_string(ptr, buf, 8);
					buf[8] = ':';
					buf[9] = 0;
					uart0_printf(buf);
					for (int i = 0; i < 8; i++) {
						long_to_hex_string(*(ptr++), buf, 8);
						buf[8] = ' ';
						buf[9] = 0;
						uart0_printf(buf);
					}
					uart0_printf("\r\n");
				}
			}
			if (ch == 'o') {
				char buf[16];
				unsigned long *ptr = 0xFFF00000;
				for (int j = 0; j < 16; j++) {
					long_to_hex_string(ptr, buf, 8);
					buf[8] = ':';
					buf[9] = 0;
					uart0_printf(buf);
					for (int i = 0; i < 8; i++) {
						long_to_hex_string(*(ptr++), buf, 8);
						buf[8] = ' ';
						buf[9] = 0;
						uart0_printf(buf);
					}
					uart0_printf("\r\n");
				}
			}
			if (ch == 't') {
				// timer init
				STME0_CNT  = 0;
				STME0_VAL  = 5000000; // threshold value for 0.1s ticks
				STME0_CONF = (1<<2) | (1<<1) | (1<<0); // interrupt en, auto reset, timer enable
				VICVectAddr0 = (unsigned long)timer0_isr;
				VICVectCntl0 = (1<<5) | 0; // enable and channel select = 0 (timer0)
				VICIntEnable = (1<<0); // enable channel 0 (timer0)
				io_enable_xint(); // enable IRQ
			}
		}	
	}

}
