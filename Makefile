.PHONY: serve
serve:
	docker-compose -f docker-compose.yml up --build
	
.PHOY: down
down:
	docker-compose down

.PHONY: docker-logs
docker-logs:
	docker-compose logs maverick

# Setup git auto deploy
# https://github.com/olipo186/Git-Auto-Deploy
.PHONY: install-autodeploy
install-autodeploy:
	./.tools/install_gitautodeploy.sh

.PHONY: delete-autodeploy
delete-autodeploy:
	sudo apt-get remove git-auto-deploy