NAME=streamers
TEST_CASE=$1

build: clean
	docker-compose up -d
	docker build -t $(NAME) .
	docker run --rm -t -i \
		--network=$(NAME)_back-tier \
		-v `pwd`:/app \
		--dns 8.8.8.8 \
		-w /app \
		$(NAME) \
		/bin/bash -c "mix deps.get"
.PHONY: build

clean:
	docker rmi --force $(NAME) || true
.PHONY: clean

test:
	docker run --rm -t -i \
		--network=$(NAME)_back-tier \
		-v `pwd`:/app \
		--dns 8.8.8.8 \
		-w /app \
		$(NAME) \
		/bin/bash -c "mix test $TEST_CASE"
.PHONY: test

console:
	docker run --rm -t -i \
		--network=$(NAME)_back-tier \
		-v `pwd`:/app \
		--dns 8.8.8.8 \
		-w /app \
		$(NAME) \
		/bin/bash
.PHONY: console
