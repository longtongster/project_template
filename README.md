# Project_template_ml

## Objective 1
In a udemy course there is a three step relation from a Makefile via a docker-compose.yaml to a Dockerfile. In that course the whole setup was directy with very complex files and structures. In this repo I tried to make these files simpler where possible and also gave comments in these files to hopefully increase the understanding of what the steps of commands do. 

## Objective 2
There is a `project` folder that is created as part of the data versioning part of the course. I consists of basically all shell commands run via `subprocess` in python to create a dvc repo, setup remote storage and push data versions to github and push the data to a remote s3 location. This is run using the Makefile command `make version-data`. In order to use s3 for the storage of the actual data we needed to create an IAM user with programmatic access that has sufficient s3 permissions. In order to push to github we used need to be able to have permission from within the container.
