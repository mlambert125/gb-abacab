./bin/hello-world.gb: ./obj/hello-world.o
	mkdir -p ./bin 
	rgblink -o ./bin/hello-world.gb ./obj/hello-world.o
	rgbfix -v -p 0xFF ./bin/hello-world.gb

./obj/hello-world.o: ./src/hello-world.asm
	mkdir -p ./obj
	rgbasm -L -o ./obj/hello-world.o ./src/hello-world.asm 

clean:
	rm -r bin
	rm -r obj
