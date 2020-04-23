ENDPOINTS=api/{gists,issues,feeds,notifications,user{,/{subscriptions,starred}}}.json


repos/%:
	git clone https://github.com/$*.git $@

repos: api/user/repos.json
	cat $< \
	    | jq -r 'map(.full_name) | @tsv' \
	    | xargs printf 'repos/%s\n' \
	    | xargs $(MAKE) -j

api/%.json: credentials
	    | jq -s "[.[][]]" \
	    > $@

clean:
	rm repos.json

.PHONY: repos
.INTERMEDIATE: repos.json
