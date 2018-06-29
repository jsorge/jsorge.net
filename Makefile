.PHONY: serve
serve:
	docker-compose -f docker-compose.yml up --build

.PHONY: docker-logs
docker-logs:
	docker-compose logs maverick
