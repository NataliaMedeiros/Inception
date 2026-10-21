include srcs/.env
export
# o Makefile lê o .env e usa o LOGIN dele. O ifeq para o make
# com uma mensagem clara se o LOGIN estiver vazio, para nunca
# apagar ou criar a pasta errada.

ifeq ($(LOGIN),)
$(error LOGIN is not set, check srcs/.env)
endif

#COMPOSE e DATA_DIR: atalhos, para não repetir o comando longo e o caminho dos dados.
COMPOSE  = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/$(LOGIN)/data

#all: up: Rodar só make equivale a make up.
all: up

#up: cria as pastas de dados e sobe tudo.
# O -d roda em segundo plano e o
# --build constrói as imagens a partir dos seus Dockerfiles.
up:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

#down: remove containers e rede. Os dados ficam, porque estão nas pastas do volume.
down:
	$(COMPOSE) down

# start e stop: param e retomam os containers sem removê-los.
start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

#ps e logs: ver o estado e as mensagens dos containers, úteis para depurar.
ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs

#clean: remove containers, rede, volumes Docker e imagens do projeto.
clean:
	$(COMPOSE) down -v --rmi all

#fclean: faz o clean e depois apaga o conteúdo das pastas de dados.
# Precisa de sudo, porque os arquivos pertencem aos usuários mysql
# e www-data. O find ... -mindepth 1 -delete esvazia as pastas mas
# mantém as pastas em si, e também apaga arquivos escondidos.
fclean: clean
	@sudo find $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress -mindepth 1 -delete

#re: fclean seguido de all, uma reconstrução do zero.
#É o que serve para o avaliador pedir uma reconstrução limpa.
re: fclean all

#.PHONY: avisa que esses nomes são ações, e não arquivos.
# Sem isso, uma pasta chamada up ou logs faria o make ignorar o alvo.
.PHONY: all up down start stop ps logs clean fclean re
