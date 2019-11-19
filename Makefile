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

.PHONY: resize-images
resize-images: ensure-swift-sh
	@ chmod +x ./.tools/ensure-imagemagick.sh
	@ ./.tools/ensure-imagemagick.sh
	@ ./vendor/swift-sh ./.tools/ResizeImages.swift

.PHONY: newpost
newpost: ensure-swift-sh
	@ $(VENDOOR)/swift-sh $(TOOLS)/NewBlogPost.swift

.PHONY: publish
publish: ensure-swift-sh
	@ $(VENDOOR)/swift-sh $(TOOLS)/PublishWorkingCopy.swift

.PHONY: ensure-swift-sh
ensure-swift-sh:
	@./tools/ensure-swift-sh.sh
