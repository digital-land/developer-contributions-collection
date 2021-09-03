#!/usr/bin/env python3

from datetime import datetime
import csv

collection = "developer-contributions"
pipelines = [
 "developer-agreement",
 "developer-agreement-contribution",
 "developer-agreement-transaction",
]
source = {}

fieldnames = ["attribution", "collection", "documentation-url", "endpoint", "licence", "organisation", "pipelines", "entry-date", "start-date", "end-date"]

for row in csv.DictReader(open("collection/source.csv", newline="")):
    for pipeline in row["pipelines"].split(";"):
        source.setdefault(pipeline, {})
        source[pipeline][row["organisation"]] = row

w = csv.DictWriter(open("/tmp/source.csv", "w", newline=""), fieldnames=fieldnames)

for row in csv.DictReader(open("var/cache/organisation.csv", newline="")):
    organisation = row["organisation"]
    if organisation.split(":")[0] in ["local-authority-eng", "development-corporation", "national-park"]:
        if row["local-authority-type"] not in ["CTY", "COMB"]:
            for pipeline in pipelines:
                if organisation not in source[pipeline]:
                    o = {}
                    o["organisation"] = organisation
                    o["collection"] = collection
                    o["pipelines"] = pipeline
                    o["entry-date"] = datetime.utcnow().isoformat()[:-3]+'Z'
                    o["end-date"] = row["end-date"]
                    w.writerow(o)
