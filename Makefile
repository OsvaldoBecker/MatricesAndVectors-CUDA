# Name
NAME = main
 
# Compiler
CXX = nvcc
EXT = cu
FLAGS =
 
all:
	$(CXX) $(NAME).$(EXT) -o $(NAME) $(FLAGS)
 
clean:
	rm -rf *.o $(NAME)