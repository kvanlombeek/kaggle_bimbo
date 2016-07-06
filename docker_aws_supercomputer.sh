# Create an EBS instance on AWS, Frankfurt is eu-central-1a
# Name it docker-notebook !!

# Create the EC2 spot instance.
docker-machine create supercomputer \
    --driver amazonec2 \
    --amazonec2-region eu-central-1 \
    --amazonec2-zone a \
    --amazonec2-security-group docker-notebook \
    --amazonec2-request-spot-instance \
    --amazonec2-spot-price 2.0 \
    --amazonec2-instance-type c4.8xlarge

# Activate the spot instance as our current docker machine.
eval "$(docker-machine env supercomputer)"

# Attach the persistent EBS volume to the instance, check with echo and $variable
EC2_INSTANCE_ID="`docker-machine ssh supercomputer wget -q -O - http://instance-data/latest/meta-data/instance-id`"
EBS_VOLUME_ID="`aws ec2 describe-volumes --query "Volumes[*].[VolumeId]" --filters "Name=tag:Name,Values=docker-notebook" --region eu-central-1 --output text`"
aws ec2 attach-volume --volume-id $EBS_VOLUME_ID --instance-id $EC2_INSTANCE_ID --device /dev/xvdf --region eu-central-1

# Only once, Create file system on EBS volume
docker-machine ssh supercomputer sudo mkfs -t ext4 /dev/xvdf

# Give sudo write rights etc
docker-machine ssh supercomputer "sudo mkdir /data && sudo mount /dev/xvdf /data && sudo chmod a+w /data"

# Security group open zetten 8888, is normaal al gebeurd

# Continue
export DOCKER_API_VERSION=1.23

# Run the Jupyter notebook.
docker run -d -p 8888:8888 -v /data:/home/jovyan/work -e PASSWORD=forespell forespell/docker-notebook
docker-machine ip supercomputer

# Visit
http://52.59.48.50:8888

# Download data
# Get coockies with Google chrome, and create a file cookies.txt with vim
# Go to the data folder fore ease
# In the home folder of the notebook, which is data, create another directory data,
# Either via mkdir data or in the notebook browser interface
sudo apt-get install wget
wget --load-cookies cookies.txt -O data/sample_submission.csv.zip -p https://www.kaggle.com/c/grupo-bimbo-inventory-demand/download/sample_submission.csv.zip
wget --load-cookies cookies.txt -O data/train.csv.zip -p https://www.kaggle.com/c/grupo-bimbo-inventory-demand/download/train.csv.zip
wget --load-cookies cookies.txt -O data/test.csv.zip -p https://www.kaggle.com/c/grupo-bimbo-inventory-demand/download/test.csv.zip
wget --load-cookies cookies.txt -O data/town_state.csv.zip -p https://www.kaggle.com/c/grupo-bimbo-inventory-demand/download/town_state.csv.zip
wget --load-cookies cookies.txt -O data/cliente_tabla.csv.zip -p https://www.kaggle.com/c/grupo-bimbo-inventory-demand/download/cliente_tabla.csv.zip
wget --load-cookies cookies.txt -O data/producto_tabla.csv.zip -p https://www.kaggle.com/c/grupo-bimbo-inventory-demand/download/producto_tabla.csv.zip

# Unzip files
sudo apt-get install unzip
unzip "*.zip"
rm *.zip

