.PHONY: \
	collect\
	collection\
	commit-collection\
	clobber-today

ifeq ($(COLLECTION_DIR),)
COLLECTION_DIR=collection/
endif

ifeq ($(RESOURCE_DIR),)
RESOURCE_DIR=$(COLLECTION_DIR)resource/
endif

ifeq ($(DATASTORE_URL),)
DATASTORE_URL=https://$(COLLECTION_DATASET_BUCKET_NAME).s3.eu-west-2.amazonaws.com/
endif


# data sources
SOURCE_CSV=$(COLLECTION_DIR)source.csv
ENDPOINT_CSV=$(COLLECTION_DIR)endpoint.csv

# collection log
LOG_DIR=$(COLLECTION_DIR)log/
LOG_FILES_TODAY:=$(LOG_DIR)$(shell date +%Y-%m-%d)/

# collection index
COLLECTION_INDEX=\
	$(COLLECTION_DIR)/log.csv\
	$(COLLECTION_DIR)/resource.csv

first-pass:: collect

second-pass:: collection

collect:: $(SOURCE_CSV) $(ENDPOINT_CSV)
	@mkdir -p $(RESOURCE_DIR)
	digital-land collect $(ENDPOINT_CSV)

collection::
	digital-land collection-save-csv

clobber-today::
	rm -rf $(LOG_FILES_TODAY) $(COLLECTION_INDEX)

makerules::
	curl -qfsL '$(SOURCE_URL)/makerules/main/collection.mk' > makerules/collection.mk

commit-collection::
	git add collection
	git diff --quiet && git diff --staged --quiet || (git commit -m "Collection $(shell date +%F)"; git push origin $(BRANCH))

load-resources::
	aws s3 sync s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(RESOURCE_DIR) $(RESOURCE_DIR) --no-progress

save-resources::
	aws s3 sync $(RESOURCE_DIR) s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(RESOURCE_DIR) --no-progress

save-collection::
	aws s3 cp $(COLLECTION_DIR)log.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)resource.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)source.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
	aws s3 cp $(COLLECTION_DIR)endpoint.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
ifneq ($(wildcard $(COLLECTION_DIR)old-resource.csv),)
	aws s3 cp $(COLLECTION_DIR)old-resource.csv s3://$(COLLECTION_DATASET_BUCKET_NAME)/$(REPOSITORY)/$(COLLECTION_DIR) --no-progress
endif

collection/resource/%:
	@mkdir -p collection/resource/
	curl -qfsL '$(DATASTORE_URL)$(REPOSITORY)/$(RESOURCE_DIR)$(notdir $@)' > $@
