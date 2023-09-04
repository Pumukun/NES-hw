ASSEMBLER = ca65
LINKER = ld65

FLAGS = -t nes

SOURCE = demo.s
OUTPUT = demo.nes

all: $(OUTPUT)

$(OUTPUT): $(SOURCE)
	$(ASSEMBLER) -o $(OUTPUT:.nes=.o) $(SOURCE) $(FLAGS)

	$(LINKER) -o $(OUTPUT) $(OUTPUT:.nes=.o) -t nes

clean:
	rm -f $(OUTPUT) $(OUTPUT:.nes=.o)
