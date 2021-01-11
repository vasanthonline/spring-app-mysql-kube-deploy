#!/usr/bin/env bash


AVAILABILITY_ZONE_1=us-east-2a
AVAILABILITY_ZONE_2=us-east-2b
DB_SUBNET_GROUP_NAME="<Name of the subnet group>"
DB_SUBNET_GROUP_DESCRIPTION="<Descrition of the subnet group>"
DB_VPC_SECURITY_GROUP_NAME="<Name of the VPC security group>"
DB_VPC_SECURITY_GROUP_DESCRIPTIOn="<Descrition of the VPC security group>"
DB_USERNAME="<Username for the DB>"
DB_PASSWORD="<Password for the DB>"

APPLICATION_ENVIRONMENT="<Environment of the application>"
APPLICATION_NAMESPACE="app-$APPLICATION_ENVIRONMENT"
DB_DATABASE="app_$APPLICATION_ENVIRONMENT"
DB_INSTANCE="Name of the DB instance"
DB_STORAGE=10
DB_INSTANCE_CLASS="db.t2.micro"

MYSQL_VERSION="5.7.31"

# 1. Create the VPC
# We will first create a VPC with the CIDR block 10.0.0.0/24 which accommodate 254 hosts in all. This is more than enough to host our RDS instance.
aws ec2 create-vpc --cidr-block 10.0.0.0/24 | jq '{VpcId:.Vpc.VpcId,CidrBlock:.Vpc.CidrBlock}'

export RDS_VPC_ID=$(aws ec2 describe-vpcs | jq '.Vpcs[] | select(.CidrBlock=="10.0.0.0/24") | .VpcId' | tr -d \")

# 2. Create the subnets
# RDS instances launched in a VPC must have a DB subnet group. DB subnet groups are a collection of subnets within a VPC. Each DB subnet group should have subnets in at least two Availability Zones in a given AWS Region.
# We will divide the RDS VPC (RDS_VPC_ID) into two equal subnets: 10.0.0.0/25 and 10.0.0.128/25.
# So, let's create the first subnet in the given availability zone:
aws ec2 create-subnet --availability-zone $AVAILABILITY_ZONE_1 --vpc-id ${RDS_VPC_ID} --cidr-block 10.0.0.0/25 | jq '{SubnetId:.Subnet.SubnetId,AvailabilityZone:.Subnet.AvailabilityZone,CidrBlock:.Subnet.CidrBlock,VpcId:.Subnet.VpcId}'
aws ec2 create-subnet --availability-zone $AVAILABILITY_ZONE_2 --vpc-id ${RDS_VPC_ID} --cidr-block 10.0.0.128/25 | jq '{SubnetId:.Subnet.SubnetId,AvailabilityZone:.Subnet.AvailabilityZone,CidrBlock:.Subnet.CidrBlock,VpcId:.Subnet.VpcId}'

export SUBNET_1=$(aws ec2 describe-subnets | jq --arg RDS_VPC_ID "$RDS_VPC_ID" '[.Subnets[] | select(.VpcId==$RDS_VPC_ID)][0] | .SubnetId' | tr -d \")
export SUBNET_2=$(aws ec2 describe-subnets | jq --arg RDS_VPC_ID "$RDS_VPC_ID" '[.Subnets[] | select(.VpcId==$RDS_VPC_ID)][1] | .SubnetId' | tr -d \")

# 3. Associate subnet to VPC's route table.
# Each VPC has an implicit router which controls where network traffic is directed. Each subnet in a VPC must be explicitly associated with a route table, which controls the routing for the subnet.
# Let's go ahead and associate these two subnet that we created, to the VPC's route table:
export RDS_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=${RDS_VPC_ID} | jq '.RouteTables[0].RouteTableId' | tr -d \")

aws ec2 associate-route-table --route-table-id $RDS_ROUTE_TABLE_ID  --subnet-id $SUBNET_1
aws ec2 associate-route-table --route-table-id $RDS_ROUTE_TABLE_ID  --subnet-id $SUBNET_2

# 4. Create DB Subnet Group
# Now that we have two subnets spanning two availability zones, we can go ahead and create the DB subnet group.
aws rds create-db-subnet-group --db-subnet-group-name  "$DB_SUBNET_GROUP_NAME" --db-subnet-group-description "$DB_SUBNET_GROUP_DESCRIPTION"  --subnet-ids "$SUBNET_1" "$SUBNET_1"  | jq '{DBSubnetGroupName:.DBSubnetGroup.DBSubnetGroupName,VpcId:.DBSubnetGroup.VpcId,Subnets:.DBSubnetGroup.Subnets[].SubnetIdentifier}'

# 5. Create a VPC Security Group
# The penultimate step to creating the DB instance is creating a VPC security group, an instance level virtual firewall with rules to control inbound and outbound traffic.
aws ec2 create-security-group --group-name "$DB_VPC_SECURITY_GROUP_NAME" --description "$DB_VPC_SECURITY_GROUP_DESCRIPTIOn" --vpc-id ${RDS_VPC_ID}

export RDS_VPC_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups | jq  --arg RDS_VPC_ID "$RDS_VPC_ID" --arg DB_VPC_SECURITY_GROUP_NAME "$DB_VPC_SECURITY_GROUP_NAME" '.SecurityGroups[] | select(.VpcId==$RDS_VPC_ID and .GroupName==$DB_VPC_SECURITY_GROUP_NAME) | .GroupId' | tr -d \")

# 6. Create a DB Instance in the VPC
aws rds create-db-instance \
  --db-name "$DB_DATABASE" \
  --db-instance-identifier "$DB_INSTANCE" \
  --allocated-storage $DB_STORAGE \
  --db-instance-class $DB_INSTANCE_CLASS \
  --engine mysql \
  --engine-version $MYSQL_VERION \
  --master-username $DB_USERNAME \
  --master-user-password $DB_PASSWORD \
  --no-publicly-accessible \
  --vpc-security-group-ids "$RDS_VPC_SECURITY_GROUP_ID" \
  --db-subnet-group-name "$DB_SUBNET_GROUP_NAME" \
  --availability-zone "$AVAILABILITY_ZONE_2" \
  --port 3306 | jq '{DBInstanceIdentifier:.DBInstance.DBInstanceIdentifier,Engine:.DBInstance.Engine,DBName:.DBInstance.DBName,VpcSecurityGroups:.DBInstance.VpcSecurityGroups,EngineVersion:.DBInstance.EngineVersion,PubliclyAccessible:.DBInstance.PubliclyAccessible}'


# 7. Create a VPC Peering Connection to facilitate communication between the EKS VPC and RDS VPC.
# To create a VPC peering connection, navigate to:
# VPC console: https://console.aws.amazon.com/vpc/
# Select Peering Connections and click on Create Peering Connection.
# Configure the details as follows (select the EKS VPC as the Requester and the RDS VPC as the Accepter).
# Click on Create Peering Connection.
# Select the Peering Connection that we just created. Click on Actions => Accept. Again, in the confirmation dialog box, click on Yes, Accept
export VPC_PEERING_CONNECTION_ID=$(aws ec2 describe-vpc-peering-connections | jq --arg RDS_VPC_ID "$RDS_VPC_ID" '.VpcPeeringConnections[] | select(.AccepterVpcInfo.VpcId==$RDS_VPC_ID) | .VpcPeeringConnectionId' | tr -d \")


# 8. Update the EKS cluster VPC's route table
export EKS_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters Name="tag:aws:cloudformation:logical-id",Values="PublicRouteTable" | jq '.RouteTables[0].RouteTableId' | tr -d \")
aws ec2 create-route --route-table-id ${EKS_ROUTE_TABLE_ID} --destination-cidr-block 10.0.0.0/24 --vpc-peering-connection-id ${VPC_PEERING_CONNECTION_ID}

# 9. Update the RDS VPC's route table
aws ec2 create-route --route-table-id ${RDS_ROUTE_TABLE_ID} --destination-cidr-block 192.168.0.0/16 --vpc-peering-connection-id ${VPC_PEERING_CONNECTION_ID}

# 10. Update the RDS instance's security group
# Allow all ingress traffic from the EKS cluster to the RDS instance on port 3306:
aws ec2 authorize-security-group-ingress --group-id ${RDS_VPC_SECURITY_GROUP_ID} --protocol tcp --port 3306 --cidr 192.168.0.0/16


# Inspired from https://dev.to/bensooraj/accessing-amazon-rds-from-aws-eks-2pc3#setup-the-mysql-database.



