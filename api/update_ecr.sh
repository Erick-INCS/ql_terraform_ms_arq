aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 905418432534.dkr.ecr.us-east-1.amazonaws.com
docker build -t fgms-dev .
docker tag fgms-dev:latest 905418432534.dkr.ecr.us-east-1.amazonaws.com/fgms-dev:latest
docker push 905418432534.dkr.ecr.us-east-1.amazonaws.com/fgms-dev:latest