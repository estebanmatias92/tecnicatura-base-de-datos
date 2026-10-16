CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17

all: java cpp docs

java:
	javac main.java
	java Main

cpp: lab
	./lab

lab: main.cpp
	$(CXX) $(CXXFLAGS) main.cpp -o lab

docs:
	plantuml -tsvg docs/persistencia-repositorio.puml

clean:
	rm -f *.class lab Main.class

.PHONY: all java cpp docs clean
