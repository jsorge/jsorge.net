.PHONY: serve
serve:
	@ chmod +x .tools/spin_up.sh
	./.tools/spin_up.sh
	
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
	sudo rm -rf ./.tools/vendor
