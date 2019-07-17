
SET CMD = %1
SET IDRSA = %2
SET IDRSAPUB = %3
SET GITBRANCH = %4

IF "%CMD%"=="build" (
	ECHO "running build with provided ssh and git path .. "
	SET basersa = %%~nx%IDRSA%
	SET basepub = %%~nx%IDRSAPUB%
	copy %IDRSA% %basersa%
	copy %IDRSAPUB% %basepub%
	docker-compose build --no-cache --build-arg id_rsa="%BASERSA%" --build-arg id_rsa_pub="%BASEPUB%" --build-arg git_path="%GITPATH%" --build-arg git_branch="%GITBRANCH%" drupal

	docker-compose build --no-cache --build-arg id_rsa="%BASERSA%" --build-arg id_rsa_pub="%BASEPUB%" --build-arg git_path="%GITPATH%" --build-arg git_branch="%GITBRANCH%" db

	rm %BASERSA

	rm %BASEPUB

	docker-compose up -d db

	docker-compose up -d drupal
)

IF "%CMD%"=="run" (
	docker-compose run
)
