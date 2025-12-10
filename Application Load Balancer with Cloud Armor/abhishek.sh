#!/bin/bash
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
clear

# ----------------------------
# Spinner utilities
# ----------------------------
SPINNER_PID=""

start_spinner() {
    # Usage: start_spinner "Short message..."
    local msg="$1"
    local delay=0.08
    local spinstr='|/-\'
    printf "%s" "  ${YELLOW_TEXT}${BOLD_TEXT}${msg}${RESET_FORMAT} "
    # spinner loop runs in background
    (
        while true; do
            for ((i=0; i<${#spinstr}; i++)); do
                printf "%s" "${spinstr:$i:1}"
                sleep "$delay"
                printf "\b"
            done
        done
    ) &
    SPINNER_PID=$!
    disown
}

stop_spinner() {
    # kill spinner if running and print subscribe message
    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" >/dev/null 2>&1 || true
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
    fi
    printf " %s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
}

echo
echo "${CYAN_TEXT}${BOLD_TEXT}=========================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   DR ABHISHEK SUBSCRIBE FOR MORE     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}=========================================${RESET_FORMAT}"
echo

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the first REGION: ${RESET_FORMAT}" REGION1
echo "${GREEN_TEXT}${BOLD_TEXT}First REGION set to:${RESET_FORMAT} ${CYAN_TEXT}${BOLD_TEXT}$REGION1${RESET_FORMAT}"
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the second REGION: ${RESET_FORMAT}" REGION2
echo "${GREEN_TEXT}${BOLD_TEXT}Second REGION set to:${RESET_FORMAT} ${CYAN_TEXT}${BOLD_TEXT}$REGION2${RESET_FORMAT}"
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

# Export variables after collecting input
export REGION1 REGION2

export INSTANCE_NAME=$REGION1-mig
export INSTANCE_NAME_2=$REGION2-mig

echo "${YELLOW_TEXT}${BOLD_TEXT}Configuring firewall rule to permit incoming HTTP traffic...${RESET_FORMAT}"
start_spinner "Creating firewall rule: default-allow-http..."
gcloud compute --project=$DEVSHELL_PROJECT_ID firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server
stop_spinner
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}Setting up firewall rule to allow health check probes...${RESET_FORMAT}"
start_spinner "Creating firewall rule: default-allow-health-check..."
gcloud compute --project=$DEVSHELL_PROJECT_ID firewall-rules create default-allow-health-check --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp --source-ranges=130.211.0.0/22,35.191.0.0/16 --target-tags=http-server
stop_spinner
echo

echo "${MAGENTA_TEXT}${BOLD_TEXT}Generating instance template for the first region: ${CYAN_TEXT}${BOLD_TEXT}$REGION1${RESET_FORMAT}${MAGENTA_TEXT}${BOLD_TEXT}...${RESET_FORMAT}"
start_spinner "Creating instance template: $REGION1-template..."
gcloud compute instance-templates create $REGION1-template --project=$DEVSHELL_PROJECT_ID --machine-type=e2-micro --network-interface=network-tier=PREMIUM,subnet=default --metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --region=$REGION1 --tags=http-server,https-server --create-disk=auto-delete=yes,boot=yes,device-name=$REGION1-template,image=projects/debian-cloud/global/images/debian-12-bookworm-v20251111,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
stop_spinner
echo

echo "${MAGENTA_TEXT}${BOLD_TEXT}Generating instance template for the second region: ${CYAN_TEXT}${BOLD_TEXT}$REGION2${RESET_FORMAT}${MAGENTA_TEXT}${BOLD_TEXT}...${RESET_FORMAT}"
start_spinner "Creating instance template: $REGION2-template..."
gcloud compute instance-templates create $REGION2-template --project=$DEVSHELL_PROJECT_ID --machine-type=e2-micro --network-interface=network-tier=PREMIUM,subnet=default --metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --region=$REGION2 --tags=http-server,https-server --create-disk=auto-delete=yes,boot=yes,device-name=$REGION2-template,image=projects/debian-cloud/global/images/debian-12-bookworm-v20251111,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
stop_spinner
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Establishing managed instance group and enabling autoscaling for region: ${CYAN_TEXT}${BOLD_TEXT}$REGION1${RESET_FORMAT}${BLUE_TEXT}${BOLD_TEXT}...${RESET_FORMAT}"
start_spinner "Creating MIG and enabling autoscaling for $REGION1..."
gcloud beta compute instance-groups managed create $REGION1-mig --project=$DEVSHELL_PROJECT_ID --base-instance-name=$REGION1-mig --size=1 --template=$REGION1-template --region=$REGION1 --target-distribution-shape=EVEN --instance-redistribution-type=PROACTIVE --list-managed-instances-results=PAGELESS --no-force-update-on-repair && gcloud beta compute instance-groups managed set-autoscaling $REGION1-mig --project=$DEVSHELL_PROJECT_ID --region=$REGION1 --cool-down-period=45 --max-num-replicas=2 --min-num-replicas=1 --mode=on --target-cpu-utilization=0.8
stop_spinner
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Establishing managed instance group and enabling autoscaling for region: ${CYAN_TEXT}${BOLD_TEXT}$REGION2${RESET_FORMAT}${BLUE_TEXT}${BOLD_TEXT}...${RESET_FORMAT}"
start_spinner "Creating MIG and enabling autoscaling for $REGION2..."
gcloud beta compute instance-groups managed create $REGION2-mig --project=$DEVSHELL_PROJECT_ID --base-instance-name=$REGION2-mig --size=1 --template=$REGION2-template --region=$REGION2 --target-distribution-shape=EVEN --instance-redistribution-type=PROACTIVE --list-managed-instances-results=PAGELESS --no-force-update-on-repair && gcloud beta compute instance-groups managed set-autoscaling $REGION2-mig --project=$DEVSHELL_PROJECT_ID --region=$REGION2 --cool-down-period=45 --max-num-replicas=2 --min-num-replicas=1 --mode=on --target-cpu-utilization=0.8
stop_spinner
echo

# NOTE: script originally sets DEVSHELL_PROJECT_ID later; keeping same ordering as original
DEVSHELL_PROJECT_ID=$(gcloud config get-value project)
TOKEN=$(gcloud auth application-default print-access-token)

echo "${GREEN_TEXT}${BOLD_TEXT}Defining a global TCP health check for the load balancer...${RESET_FORMAT}"
start_spinner "Creating health check: http-health-check..."
# Create TCP Health Check
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "checkIntervalSec": 5,
        "description": "",
        "healthyThreshold": 2,
        "logConfig": {
            "enable": false
        },
        "name": "http-health-check",
        "tcpHealthCheck": {
            "port": 80,
            "proxyHeader": "NONE"
        },
        "timeoutSec": 5,
        "type": "TCP",
        "unhealthyThreshold": 2
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/healthChecks"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for health check creation to complete...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}Configuring backend services and associating instance groups...${RESET_FORMAT}"
start_spinner "Creating backend service: http-backend..."
# Create Backend Services
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "backends": [
            {
                "balancingMode": "RATE",
                "capacityScaler": 1,
                "group": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION1"'/instanceGroups/'"$REGION1-mig"'",
                "maxRatePerInstance": 50
            },
            {
                "balancingMode": "UTILIZATION",
                "capacityScaler": 1,
                "group": "projects/'"$DEVSHELL_PROJECT_ID"'/regions/'"$REGION2"'/instanceGroups/'"$REGION2-mig"'",
                "maxRatePerInstance": 80,
                "maxUtilization": 0.8
            }
        ],
        "cdnPolicy": {
            "cacheKeyPolicy": {
                "includeHost": true,
                "includeProtocol": true,
                "includeQueryString": true
            },
            "cacheMode": "CACHE_ALL_STATIC",
            "clientTtl": 3600,
            "defaultTtl": 3600,
            "maxTtl": 86400,
            "negativeCaching": false,
            "serveWhileStale": 0
        },
        "compressionMode": "DISABLED",
        "connectionDraining": {
            "drainingTimeoutSec": 300
        },
        "description": "",
        "enableCDN": true,
        "healthChecks": [
            "projects/'"$DEVSHELL_PROJECT_ID"'/global/healthChecks/http-health-check"
        ],
        "loadBalancingScheme": "EXTERNAL",
        "logConfig": {
            "enable": true,
            "sampleRate": 1
        },
        "name": "http-backend"
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/backendServices"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for backend service creation to complete...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Setting up the URL map to direct traffic to the backend service...${RESET_FORMAT}"
start_spinner "Creating URL map: http-lb..."
# Create URL Map
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "defaultService": "projects/'"$DEVSHELL_PROJECT_ID"'/global/backendServices/http-backend",
        "name": "http-lb"
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/urlMaps"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for URL map creation to complete...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Creating the primary target HTTP proxy for the load balancer...${RESET_FORMAT}"
start_spinner "Creating target HTTP proxy: http-lb-target-proxy..."
# Create Target HTTP Proxy
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "http-lb-target-proxy",
        "urlMap": "projects/'"$DEVSHELL_PROJECT_ID"'/global/urlMaps/http-lb"
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/targetHttpProxies"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for target proxy creation to complete...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Establishing the primary global forwarding rule (IPv4)...${RESET_FORMAT}"
start_spinner "Creating forwarding rule: http-lb-forwarding-rule..."
# Create Forwarding Rule (FIXED: use PREMIUM networkTier for global forwarding rule)
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "IPProtocol": "TCP",
        "ipVersion": "IPV4",
        "loadBalancingScheme": "EXTERNAL",
        "name": "http-lb-forwarding-rule",
        "networkTier": "PREMIUM",
        "portRange": "80",
        "target": "projects/'"$DEVSHELL_PROJECT_ID"'/global/targetHttpProxies/http-lb-target-proxy"
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/forwardingRules"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for forwarding rule creation to complete...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Creating the secondary target HTTP proxy...${RESET_FORMAT}"
start_spinner "Creating target HTTP proxy: http-lb-target-proxy-2..."
# Create another Target HTTP Proxy
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "name": "http-lb-target-proxy-2",
        "urlMap": "projects/'"$DEVSHELL_PROJECT_ID"'/global/urlMaps/http-lb"
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/targetHttpProxies"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for second target proxy creation...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}Establishing the secondary global forwarding rule (IPv6)...${RESET_FORMAT}"
start_spinner "Creating forwarding rule: http-lb-forwarding-rule-2..."
# Create another Forwarding Rule (FIXED: use PREMIUM networkTier for global forwarding rule)
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "IPProtocol": "TCP",
        "ipVersion": "IPV6",
        "loadBalancingScheme": "EXTERNAL",
        "name": "http-lb-forwarding-rule-2",
        "networkTier": "PREMIUM",
        "portRange": "80",
        "target": "projects/'"$DEVSHELL_PROJECT_ID"'/global/targetHttpProxies/http-lb-target-proxy-2"
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/forwardingRules"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for second forwarding rule creation...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}Assigning named port 'http:80' to the instance group in region: ${CYAN_TEXT}${BOLD_TEXT}$REGION2${RESET_FORMAT}${YELLOW_TEXT}${BOLD_TEXT}...${RESET_FORMAT}"
start_spinner "Setting named ports for $REGION2 instance group..."
# Set Named Ports for $REGION2 Instance Group
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "namedPorts": [
            {
                "name": "http",
                "port": 80
            }
        ]
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION2/instanceGroups/$INSTANCE_NAME_2/setNamedPorts"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for named port configuration...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}Assigning named port 'http:80' to the instance group in region: ${CYAN_TEXT}${BOLD_TEXT}$REGION1${RESET_FORMAT}${YELLOW_TEXT}${BOLD_TEXT}...${RESET_FORMAT}"
start_spinner "Setting named ports for $REGION1 instance group..."
# Set Named Ports for $REGION1 Instance Group
curl -X POST -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "namedPorts": [
            {
                "name": "http",
                "port": 80
            }
        ]
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/regions/$REGION1/instanceGroups/$INSTANCE_NAME/setNamedPorts"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for named port configuration...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}Retrieving the IP address of the load balancer...${RESET_FORMAT}"
start_spinner "Retrieving LB IP..."
LB_IP_ADDRESS=$(gcloud compute forwarding-rules describe http-lb-forwarding-rule --global --format="value(IPAddress)")
stop_spinner
echo "${GREEN_TEXT}${BOLD_TEXT}Load Balancer IP Address:${RESET_FORMAT} ${CYAN_TEXT}${BOLD_TEXT}$LB_IP_ADDRESS${RESET_FORMAT}"
echo

# ================= MANUAL VM CREATION - USER PROVIDES EXTERNAL IP =================
echo "${MAGENTA_TEXT}${BOLD_TEXT}=================================================================${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}    MANUAL VM CREATION INSTRUCTIONS                          ${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}=================================================================${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Please manually create a VM for load testing with the following specifications:${RESET_FORMAT}"
echo "${CYAN_TEXT}• Name: siege-vm${RESET_FORMAT}"
echo "${CYAN_TEXT}• Machine type: e2-micro${RESET_FORMAT}"
echo "${CYAN_TEXT}• Network tier: STANDARD (not premium)${RESET_FORMAT}"
echo "${CYAN_TEXT}• OS: Debian 12${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}After creating the VM, please enter its external IP address below:${RESET_FORMAT}"
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the EXTERNAL IP address of your siege VM: ${RESET_FORMAT}" EXTERNAL_IP
echo "${GREEN_TEXT}${BOLD_TEXT}External IP set to:${RESET_FORMAT} ${CYAN_TEXT}${BOLD_TEXT}$EXTERNAL_IP${RESET_FORMAT}"
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

# ================= ADDITIONAL: ASK FOR VM ZONE =================
echo "${YELLOW_TEXT}${BOLD_TEXT}For SSH connection purposes, please also provide the zone where you created the siege VM:${RESET_FORMAT}"
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the ZONE of your siege VM (e.g., us-central1-a): ${RESET_FORMAT}" VM_ZONE
echo "${GREEN_TEXT}${BOLD_TEXT}VM Zone set to:${RESET_FORMAT} ${CYAN_TEXT}${BOLD_TEXT}$VM_ZONE${RESET_FORMAT}"
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

# ================= STEP 1: LOAD TESTING INSTRUCTIONS (BEFORE ARMOR) =================
echo "${BLUE_TEXT}${BOLD_TEXT}=================================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}    STEP 1: PERFORM LOAD TESTING (BEFORE CLOUD ARMOR)          ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=================================================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Now, BEFORE creating the Cloud Armor policy, perform load testing:${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}1. Connect to your siege VM:${RESET_FORMAT}"
echo "${CYAN_TEXT}   - Go to Google Cloud Console → Compute Engine → VM instances${RESET_FORMAT}"
echo "${CYAN_TEXT}   - Find 'siege-vm' and click the 'SSH' button${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}2. In the SSH terminal, run the following commands:${RESET_FORMAT}"
echo "${CYAN_TEXT}   sudo apt-get -y install siege${RESET_FORMAT}"
echo "${CYAN_TEXT}   export LB_IP=$LB_IP_ADDRESS${RESET_FORMAT}"
echo "${CYAN_TEXT}   siege -c 150 -t120s http://\$LB_IP${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}3. Alternative: Connect via gcloud command:${RESET_FORMAT}"
echo "${CYAN_TEXT}   gcloud compute ssh siege-vm --zone=$VM_ZONE${RESET_FORMAT}"
echo "${CYAN_TEXT}   Then run the commands above inside the SSH session${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Note: This load test should show SUCCESSFUL responses (200 OK).${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}Press Enter AFTER you have completed the load testing...${RESET_FORMAT}"
read -p ""
echo "${GREEN_TEXT}${BOLD_TEXT}Load testing completed!${RESET_FORMAT}"
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

# ================= STEP 2: CLOUD ARMOR POLICY CREATION =================
echo "${RED_TEXT}${BOLD_TEXT}=================================================================${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}    STEP 2: CREATE CLOUD ARMOR SECURITY POLICY                ${RESET_FORMAT}"
echo "${RED_TEXT}${BOLD_TEXT}=================================================================${RESET_FORMAT}"
echo

echo "${RED_TEXT}${BOLD_TEXT}Creating a Cloud Armor security policy named 'denylist-siege' to block the siege VM's IP...${RESET_FORMAT}"
start_spinner "Creating Cloud Armor security policy: denylist-siege..."
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" \
    -d '{
        "adaptiveProtectionConfig": {
            "layer7DdosDefenseConfig": {
                "enable": false
            }
        },
        "description": "",
        "name": "denylist-siege",
        "rules": [
            {
                "action": "deny(403)",
                "description": "",
                "match": {
                    "config": {
                        "srcIpRanges": [
                             "'"${EXTERNAL_IP}"'"
                        ]
                    },
                    "versionedExpr": "SRC_IPS_V1"
                },
                "preview": false,
                "priority": 1000
            },
            {
                "action": "allow",
                "description": "Default rule, higher priority overrides it",
                "match": {
                    "config": {
                        "srcIpRanges": [
                            "*"
                        ]
                    },
                    "versionedExpr": "SRC_IPS_V1"
                },
                "preview": false,
                "priority": 2147483647
            }
        ],
        "type": "CLOUD_ARMOR"
    }' \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/securityPolicies"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for security policy creation...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

echo "${RED_TEXT}${BOLD_TEXT}Attaching the 'denylist-siege' security policy to the 'http-backend' service...${RESET_FORMAT}"
start_spinner "Attaching security policy to backend service..."
curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" \
    -d "{
        \"securityPolicy\": \"projects/$DEVSHELL_PROJECT_ID/global/securityPolicies/denylist-siege\"
    }" \
    "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/backendServices/http-backend/setSecurityPolicy"
stop_spinner
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for security policy attachment...${RESET_FORMAT}"
sleep 60
printf "%s\n" "${GREEN_TEXT}${BOLD_TEXT}✔ Done! Subscribe to Dr Abhishek ❤️${RESET_FORMAT}"
echo

# ================= STEP 3: VERIFICATION LOAD TESTING (AFTER ARMOR) =================
echo "${BLUE_TEXT}${BOLD_TEXT}=================================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}    STEP 3: VERIFY CLOUD ARMOR POLICY IS WORKING              ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=================================================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Now, AFTER creating the Cloud Armor policy, verify it's working:${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}1. Connect to your siege VM again (same as before)${RESET_FORMAT}"
echo "${CYAN_TEXT}   gcloud compute ssh siege-vm --zone=$VM_ZONE${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}2. Run the load test again:${RESET_FORMAT}"
echo "${CYAN_TEXT}   siege -c 150 -t120s http://\$LB_IP${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}This time, the load test should show 403 FORBIDDEN errors${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}because the Cloud Armor policy is now blocking traffic from IP: $EXTERNAL_IP${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}Welcome to Dr. Abhishek Cloud Tutorials${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}Subscribe for more cloud content: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
