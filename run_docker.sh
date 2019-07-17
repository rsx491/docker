#!/bin/bash -e

# script to help with docker commands
# when building need path to ssh private key, ssh public key, and git of drupal installation
#ex: run_docker.sh build ~/.ssh/id_rsa ~/.ssh/id_rsa.pub git@github.com:USERNAME/drupal-private.git#8.8.x 8.8.x
#ex: run_docker.sh run

CMD=${1-.}
IDRSA=${2-.}
IDRSAPUB=${3-.}
GITPATH=${4-.}
GITBRANCH=${5-.}

echo "cmd $CMD $IDRSA $IDRSAPUB $GITPATH $GITBRANCH"

if [ "$CMD" == "build" ];then
	if [ "$IDRSA" != "." -a "$IDRSAPUB" != "." -a "$GITPATH" != "." -a "$GITBRANCH" != "." ];then
		echo "Running build with provided ssh keys and git path.. "
#		docker-compose build --build-arg id_rsa=\""$(cat $IDRSA | tail -n +2 | head -n -1 | tr -d '\n' )"\" --build-arg id_rsa_pub=\""$(cat $IDRSAPUB | tail -n +2 | head -n -1 | tr -d '\n' )"\" --build-arg git_path="$GITPATH" drupal
		BASERSA=$(basename $IDRSA)
		BASEPUB=$(basename $IDRSAPUB)
		cp $IDRSA ./$BASERSA
		cp $IDRSAPUB ./$BASEPUB
		chmod +rwx ./$BASERSA
		docker-compose build --no-cache --build-arg id_rsa="$BASERSA" --build-arg id_rsa_pub="$BASEPUB" --build-arg git_path="$GITPATH" --build-arg git_branch="$GITBRANCH" drupal
		docker-compose build --no-cache --build-arg id_rsa="$BASERSA" --build-arg id_rsa_pub="$BASEPUB" --build-arg git_path="$GITPATH" --build-arg git_branch="$GITBRANCH" db
		rm -f ./$BASERSA
		rm ./$BASEPUB
		docker-compose up -d db
		docker-compose up -d drupal
	else
		echo "In order to build the ssh files and git path must be provided"
		exit 1
	fi
elif [ "$CMD" == "run" ];then
	docker-compose run
else
	echo "Unsupported command"
	exit 1
fi	

