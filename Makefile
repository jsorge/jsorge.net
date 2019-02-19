.PHONY: serve
serve:
	@ chmod +x ./.tools/spin_up.sh
	@ ./.tools/spin_up.sh
	
.PHONY: down
down:
	docker-compose -f ./.tools/docker-compose.yml down

.PHONY: docker-logs
docker-logs:
	docker-compose logs maverick

# Setup git auto deploy
# https://github.com/olipo186/Git-Auto-Deploy
.PHONY: install-autodeploy
install-autodeploy:
	@ chmod +x ./.tools/install_gitautodeploy.sh
	@ ./.tools/install_gitautodeploy.sh

.PHONY: delete-autodeploy
delete-autodeploy:
	sudo rm -rf ./.tools/vendor/Git-Auto-Deploy

.PHONY: install-precommit
install-precommit:
# set up Marathon https://github.com/JohnSundell/marathon
	@ cp ./.tools/pre-commit.sh .git/hooks/pre-commit