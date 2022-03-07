#!/bin/bash -x

ORG=${ORG:-dellemc}
GCP_PROJECT=${GCP_PROJECT:-devcon-anthos}
TAG=${TAG:-latest}
FILTER=${FILTER:-}
curl -s https://hub.docker.com/v2/repositories/$ORG/ | jq '.[]' | grep name\":.*$FILTER | awk -F'"' -v ORG=$ORG -v GCP_PROJECT=$GCP_PROJECT -v TAG=$TAG '{system("docker pull docker.io/"ORG"/"$4":"TAG" && docker tag docker.io/"ORG"/"$4":"TAG" gcr.io/"GCP_PROJECT"/"ORG"/"$4":"TAG" && docker push gcr.io/"GCP_PROJECT"/"ORG"/"$4":"TAG)}'

