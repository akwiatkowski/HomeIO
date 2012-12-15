all:
	@gcc -Wall main.c -o ioserver.bin

clean:
	@rm -f ioserver.bin

run: clean all
	@./ioserver.bin /dev/ttyS0

dist: clean
        