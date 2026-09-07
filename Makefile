all:
	@mkdir -p /home/adzahrao/data/mariadb /home/adzahrao/data/wordpress
	docker compose -f srcs/docker-compose.yml up --build -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans
	sudo rm -rf /home/adzahrao/data/mariadb/*
	sudo rm -rf /home/adzahrao/data/wordpress/*

fclean: clean

re: fclean all
.PHONY: all down clean fclean re