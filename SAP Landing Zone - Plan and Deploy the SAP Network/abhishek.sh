#!/bin/bash
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' 

# Banner design
pattern=(
"**********************************************************"
"**             Welcome to Dr. Abhishek Cloud Tutorials  **"
"**                                                      **"
"**       █████╗ ██████╗ ██╗  ██╗██╗███████╗██╗  ██╗    **"
"**      ██╔══██╗██╔══██╗██║  ██║██║██╔════╝██║  ██║    **"
"**      ███████║██████╔╝███████║██║███████╗███████║    **"
"**      ██╔══██║██╔══██╗██╔══██║██║╚════██║██╔══██║    **"
"**      ██║  ██║██║  ██║██║  ██║██║███████║██║  ██║    **"
"**      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝    **"
"**                                                      **"
"**      Subscribe to our YouTube Channel:               **"
"**      ${CYAN}https://www.youtube.com/@drabhishek.5460${NC}       **"
"**                                                      **"
"**********************************************************"
)

# Print banner
for line in "${pattern[@]}"
do
    echo -e "${YELLOW}${line}${NC}"
done

# Get project and region details
PROJECT_ID=$(gcloud config get-value project)
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo -e "${YELLOW}Starting infrastructure setup in project: ${CYAN}$PROJECT_ID${NC}"
echo -e "${YELLOW}Using region: ${CYAN}$REGION${NC}\n"

# Network setup
echo -e "${YELLOW}Creating VPC network...${NC}"
gcloud compute networks create xall-vpc--vpc-01 \
    --description="Standard VPC network" \
    --project=$PROJECT_ID \
    --subnet-mode=custom \
    --bgp-routing-mode=global \
    --mtu=1460

# Subnet setup
echo -e "${YELLOW}Creating subnet for backend workloads...${NC}"
gcloud compute networks subnets create xgl-subnet--cerps-bau-nonprd--be1-01 \
    --description="Subnet for backend workloads" \
    --project=$PROJECT_ID \
    --network=xall-vpc--vpc-01 \
    --region=$REGION \
    --range=10.1.1.0/24 \
    --enable-private-ip-google-access \
    --enable-flow-logs

# Firewall rules setup
echo -e "${YELLOW}Configuring firewall rules...${NC}"

# Linux rules
gcloud compute firewall-rules create xall-vpc--vpc-01--xall-fw--user--a--linux--v01 \
    --description="Allow SSH & ICMP for Linux VMs" \
    --project=$PROJECT_ID \
    --network=xall-vpc--vpc-01 \
    --priority=1000 \
    --direction=ingress \
    --action=allow \
    --target-tags=xall-vpc--vpc-01--xall-fw--user--a--linux--v01 \
    --source-ranges=0.0.0.0/0 \
    --rules=tcp:22,icmp

# Windows rules
gcloud compute firewall-rules create xall-vpc--vpc-01--xall-fw--user--a--windows--v01 \
    --description="Allow RDP & ICMP for Windows VMs" \
    --project=$PROJECT_ID \
    --network=xall-vpc--vpc-01 \
    --priority=1000 \
    --direction=ingress \
    --action=allow \
    --target-tags=xall-vpc--vpc-01--xall-fw--user--a--windows--v01 \
    --source-ranges=0.0.0.0/0 \
    --rules=tcp:3389,icmp

# SAP GUI rules
gcloud compute firewall-rules create xall-vpc--vpc-01--xall-fw--user--a--sapgui--v01 \
    --description="Allow SAP GUI Ports" \
    --project=$PROJECT_ID \
    --network=xall-vpc--vpc-01 \
    --priority=1000 \
    --direction=ingress \
    --action=allow \
    --target-tags=xall-vpc--vpc-01--xall-fw--user--a--sapgui--v01 \
    --source-ranges=0.0.0.0/0 \
    --rules=tcp:3200-3299,tcp:3600-3699

# SAP Fiori rules
gcloud compute firewall-rules create xall-vpc--vpc-01--xall-fw--user--a--sap-fiori--v01 \
    --description="Allow SAP Fiori Ports" \
    --project=$PROJECT_ID \
    --network=xall-vpc--vpc-01 \
    --priority=1000 \
    --direction=ingress \
    --action=allow \
    --target-tags=xall-vpc--vpc-01--xall-fw--user--a--sap-fiori--v01 \
    --source-ranges=0.0.0.0/0 \
    --rules=tcp:80,tcp:8000-8099,tcp:443,tcp:4300-44300

# Environment rules
gcloud compute firewall-rules create xall-vpc--vpc-01--xgl-fw--cerps-bau-dev--a-env--v01 \
    --description="Allow internal communication across environments" \
    --project=$PROJECT_ID \
    --network=xall-vpc--vpc-01 \
    --priority=1000 \
    --direction=ingress \
    --action=allow \
    --target-tags=xall-vpc--vpc-01--xgl-fw--cerps-bau-dev--a-env--v01 \
    --source-tags=xall-vpc--vpc-01--xgl-fw--cerps-bau-dev--a-env--v01 \
    --rules=tcp:3200-3299,tcp:3300-3399,tcp:4800-4899,tcp:80,tcp:8000-8099,tcp:443,tcp:44300-44399,tcp:3600-3699,tcp:8100-8199,tcp:44400-44499,tcp:50000-59999,tcp:30000-39999,tcp:4300-4399,tcp:40000-49999,tcp:1128-1129,tcp:5050,tcp:8000-8499,tcp:515,icmp

# DS4 system rules
gcloud compute firewall-rules create xall-vpc--vpc-01--xgl-fw--cerps-bau-dev--a-ds4--v01 \
    --description="Allow all TCP/UDP/ICMP for DS4 system" \
    --project=$PROJECT_ID \
    --network=xall-vpc--vpc-01 \
    --priority=1000 \
    --direction=ingress \
    --action=allow \
    --target-tags=xall-vpc--vpc-01--xgl-fw--cerps-bau-dev--a-ds4--v01 \
    --source-tags=xall-vpc--vpc-01--xgl-fw--cerps-bau-dev--a-ds4--v01 \
    --rules=tcp,udp,icmp

# IP Address reservations
echo -e "${YELLOW}Reserving IP addresses...${NC}"

gcloud compute addresses create xgl-ip-address--cerps-bau-dev--dh1--d-cerpshana1 \
    --description="Reserved IP for cerpshana1 VM" \
    --project=$PROJECT_ID \
    --region=$REGION \
    --subnet=xgl-subnet--cerps-bau-nonprd--be1-01 \
    --addresses=10.1.1.100

gcloud compute addresses create xgl-ip-address--cerps-bau-dev--ds4--d-cerpss4db \
    --description="Reserved IP for cerpss4db VM" \
    --project=$PROJECT_ID \
    --region=$REGION \
    --subnet=xgl-subnet--cerps-bau-nonprd--be1-01 \
    --addresses=10.1.1.101

gcloud compute addresses create xgl-ip-address--cerps-bau-dev--ds4--d-cerpss4scs \
    --description="Reserved IP for cerpss4scs VM" \
    --project=$PROJECT_ID \
    --region=$REGION \
    --subnet=xgl-subnet--cerps-bau-nonprd--be1-01 \
    --addresses=10.1.1.102

gcloud compute addresses create xgl-ip-address--cerps-bau-dev--ds4--d-cerpss4app1 \
    --description="Reserved IP for cerpss4app1 VM" \
    --project=$PROJECT_ID \
    --region=$REGION \
    --subnet=xgl-subnet--cerps-bau-nonprd--be1-01 \
    --addresses=10.1.1.103

# NAT Gateway setup
echo -e "${YELLOW}Setting up NAT Gateway...${NC}"

gcloud compute routers create xall-vpc--vpc-01--xall-router--shared-nat--de1-01 \
    --description="Router for Cloud NAT" \
    --project=$PROJECT_ID \
    --region=$REGION \
    --network=xall-vpc--vpc-01

gcloud compute routers nats create xall-vpc--vpc-01--xall-nat-gw--shared-nat--de1-01 \
    --project=$PROJECT_ID \
    --region=$REGION \
    --router=xall-vpc--vpc-01--xall-router--shared-nat--de1-01 \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges \
    --enable-logging 

# Completion banner
pattern=(
"**********************************************************"
"**             Infrastructure Setup Complete!           **"
"**                                                      **"
"**    Thank you for using Dr. Abhishek Cloud Tutorials  **"
"**                                                      **"
"**    For more tutorials, visit our YouTube Channel:    **"
"**    ${CYAN}https://www.youtube.com/@drabhishek.5460${NC}       **"
"**                                                      **"
"**    Don't forget to like, share, and subscribe!       **"
"**                                                      **"
"**********************************************************"
)

# Print completion banner
for line in "${pattern[@]}"
do
    echo -e "${YELLOW}${line}${NC}"
done
