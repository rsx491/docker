# docker
Docker container for welkgroup; Dev and QA.

The folder includes a .bat file. The following commands needs the SSH keys (public/private) to execute the build process and pull from GITHUB. 

So, all developers need to create a public/private key pair and I need their public key to add them to the repository. 

The developers would substitute the .SH file for the .BAT file and you will need the docker tools installed; docker-compose and docker.

./run_docker.sh build /Users/$(username)/.ssh/github_rsa /Users/$(username)/.ssh/github_rsa.pub git@github.com:$(username)/welkresorts.git master

https://docs.docker.com/docker-for-windows/ 
