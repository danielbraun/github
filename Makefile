ENDPOINTS=api/{gists,issues,feeds,notifications,user{,/{subscriptions,starred}}}.csv

all: repos $(shell echo $(ENDPOINTS))

repos/%:
	git clone https://github.com/$*.git $@

repos: api/user/repos.json
	cat $< \
	    | jq -r 'map(.full_name) | @tsv' \
	    | xargs printf 'repos/%s\n' \
	    | xargs $(MAKE) -j

api/%.json: credentials
	@echo "Fetching $*"
	@mkdir -p $(@D)
	@curl -f -s -u "$(shell cat $<)" \
	    "https://api.github.com/$*?per_page=100&page=[1-5]" \
	    | jq -s "[.[][]]" \
	    > $@

clean:
	rm -r api

%.csv: %.json; json2csv < $< > $@

.PHONY: repos
