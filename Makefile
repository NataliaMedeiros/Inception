include srcs/.env
export

ifeq ($(LOGIN),)
$(error LOGIN is not set, check srcs/.env)
endif

COMPOSE  = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/$(LOGIN)/data

all: up

up:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs

clean:
	$(COMPOSE) down -v --rmi all

fclean: clean
	@sudo find $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress -mindepth 1 -delete

re: fclean all

.PHONY: all up down start stop ps logs clean fclean re
