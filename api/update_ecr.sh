aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 905418432534.dkr.ecr.us-east-1.amazonaws.com
docker build -t msif-api .
docker tag msif-api:latest 905418432534.dkr.ecr.us-east-1.amazonaws.com/msif-api:latest
docker push 905418432534.dkr.ecr.us-east-1.amazonaws.com/msif-api:latest