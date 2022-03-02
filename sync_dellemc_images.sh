#!/bin/bash
set -m
ORG="dellemc"
REG_DEST="gcr.io/devcon-anthos"

REPO_LIST=$(curl -s https://hub.docker.com/v2/repositories/${ORG}/?page_size=100 | jq -r '.results|.[]|.name')

# output images & tags
echo
echo "Images and tags for organization: ${ORG}"
echo
for i in ${REPO_LIST}
do
  [[ ${i} =~ ^powerprotect ]] && continue
  # last three tags only
  IMAGE_TAGS=$(curl -s https://hub.docker.com/v2/repositories/${ORG}/${i}/tags/?page_size=3 | jq -r '.results|.[]|.name')
  for t in ${IMAGE_TAGS}
  do
    DOCKER_IMAGE="${i}:${t}"
    docker pull ${ORG}/${DOCKER_IMAGE} && docker tag ${ORG}/${DOCKER_IMAGE}  ${REG_DEST}/${DOCKER_IMAGE} && docker push ${REG_DEST}/${DOCKER_IMAGE}
  done
done

# Wait for all parallel jobs to finish
#while [ 1 ]; do fg 2> /dev/null; [ $? == 1 ] && break; done

