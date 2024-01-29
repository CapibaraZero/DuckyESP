all:
	bison -o parser.cpp -d parser.y
	flex -o lexer.cpp lexer.l
clean:
	rm -f *.cpp *.hpp *.o duckuino
