TOOLS     := ./tools
VENDOOR   := ./vendor

.PHONY: serve
serve:
	@ chmod +x ./.tools/spin_up.sh
	@ ./.tools/spin_up.sh

.PHONY: down
down:
	docker-compose -f ./.tools/docker-compose.yml down

.PHONY: dev
dev:
	@ chmod +x ./.tools/spin_up_dev.sh
	@ ./.tools/spin_up_dev.sh

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

.PHONY: resize-images
resize-images:
# set up Marathon https://github.com/JohnSundell/marathon
	@ chmod +x ./.tools/ensure-marathon.sh
	@ ./.tools/ensure-marathon.sh
	@ chmod +x ./.tools/ensure-imagemagick.sh
	@ ./.tools/ensure-imagemagick.sh
	@ marathon run ./.tools/ResizeImages.swift

.PHONY: install-newpost
install-newpost:
	@ chmod +x ./.tools/ensure-marathon.sh
	@ ./.tools/ensure-marathon.sh
	@ marathon install ./tools/NewBlogPost.swift

.PHONY: ensure-swift-sh
ensure-swift-sh:
	@./tools/ensure-swift-sh.sh
