#!/usr/bin/env python3

from datetime import datetime
import csv

source = {}

# assumes there's one set of pipelines per collection ..
pipelines = {}

fieldnames = ["attribution", "collection", "documentation-url", "endpoint", "licence", "organisation", "pipelines", "entry-date", "start-date", "end-date"]

for row in csv.DictReader(open("collection/source.csv", newline="")):
    collection = row["collection"]
    source.setdefault(collection, {})
    source[collection][row["organisation"]] = row
    pipelines[collection] = row["pipelines"]

w = csv.DictWriter(open("/tmp/source.csv", "w", newline=""), fieldnames=fieldnames)

for row in csv.DictReader(open("var/cache/organisation.csv", newline="")):
    organisation = row["organisation"]
    if organisation.split(":")[0] in ["local-authority-eng", "development-corporation", "national-park"]:
        if row["local-authority-type"] not in ["CTY", "COMB"]:
            for collection in source:
                if organisation not in source[collection]:
                    o = {}
                    o["organisation"] = organisation
                    o["collection"] = collection
                    o["pipelines"] = pipelines[collection]
                    o["entry-date"] = datetime.utcnow().isoformat()[:-3]+'Z'
                    o["end-date"] = row["end-date"]
                    w.writerow(o)
