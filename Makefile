NAME = inception

all:
	cd srcs && docker compose up --build -d

down:
	cd srcs && docker compose down

clean: down
	cd srcs && docker compose down --rmi all -v

re: clean all

.PHONY: all down clean re