#!/usr/bin/env python3

import json
import requests
import re

builds_url: str = 'https://api.github.com/repos/UCLOrengoGroup/cath-tools/releases'


def summary_of_release_data(release_data) -> str:
	body         = release_data[ 'body'         ]
	html_url     = release_data[ 'html_url'     ]
	name         = release_data[ 'name'         ]
	published_at = release_data[ 'published_at' ]
	tag_name     = release_data[ 'tag_name'     ]

	if body is None:
		body = ''
	if name is None:
		name = ''

	body         = re.sub( r'#(\d+)\b', r'[\1](https://github.com/UCLOrengoGroup/cath-tools/issues/\1)', body )
	body         = re.sub( r'\b(\w{40})\b', r'[\1](https://github.com/UCLOrengoGroup/cath-tools/commit/\1)', body )
	published_at = re.sub( r'T\d{2}:\d{2}:\d{2}Z', '', published_at )

	return f"### [{ tag_name }]({ html_url }) { name }\n\n{ published_at } &nbsp; { body }\n\n"


print(
	"# Summary of changes in cath-tools releases\n\n\n"
	+ "\n".join(map(
		summary_of_release_data,
		requests.get(builds_url).json()
	)),
	end=''
)
