all:
	bison -o parser.cpp -d parser.y
	flex -o lexer.c lexer.l
	gcc *.c *.cpp -o duckuino

clean:
	rm -f *.c *.cpp *.hpp *.h *.o duckuino
