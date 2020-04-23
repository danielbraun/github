all: repos

repos/%:
	git clone https://github.com/$*.git $@

repos: repos.json
	cat $< \
	    | jq -r 'map(.full_name) | @tsv' \
	    | xargs printf 'repos/%s\n' \
	    | xargs $(MAKE) -j

repos.json: credentials
	curl -s -u "$(shell cat $<)" \
	    "https://api.github.com/user/repos?per_page=100&page=[1-5]" \
	    | jq -s "[.[][]]" \
	    > $@

clean:
	rm repos.json

.PHONY: repos
.INTERMEDIATE: repos.json
