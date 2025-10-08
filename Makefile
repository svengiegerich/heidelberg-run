all:
	@echo "make build         -> build site to .out folder"
	@echo "make checklinks    -> build site and check for broken links"
	@echo "make update-vendor -> download vendor files (bulma, leaflet, etc.)"
	@echo "make backup        -> download Google Sheets data to backup folder"

.phony: backup
backup:
	@mkdir -p backup-data
	@go run cmd/backup/main.go -config config.json -output backup-data/$(shell date +%Y-%m-%d).ods

.phony: update-vendor
update-vendor:
	@go run cmd/vendor-update/main.go -dir external-files
	@git status external-files
	@echo "Don't forget to commit if there are changes"

.bin/generate-linux: cmd/generate/main.go internal/events/*.go internal/generator/*.go internal/resources/*.go internal/config/*.go internal/utils/*.go go.mod
	mkdir -p .bin
	GOOS=linux GOARCH=amd64 go build -o .bin/generate-linux cmd/generate/main.go

.phony: build
build:
	rm -rf .out
	go run cmd/generate/main.go -config local.json -out .out -basepath $(PWD)/.out -hashfile .hashes

.phony: checklinks
checklinks:
	rm -rf .out
	go run cmd/generate/main.go -config local.json -out .out -hashfile .hashes -checklinks

.repo/.git/config:
	git clone https://github.com/svengiegerich/heidelberg-run.git .repo

.phony: lint
lint:
	go vet ./...

.phony: test
test:
	go test ./...

.phony: full-test
full-test: lint test .bin/generate-linux
