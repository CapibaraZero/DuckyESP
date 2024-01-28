all:
	bison -o parser.cpp -d parser.y
	flex -o lexer.cpp lexer.l
	g++ *.cpp -o duckuino

clean:
	rm -f *.cpp *.hpp *.o duckuino
