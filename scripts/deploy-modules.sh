#!/bin/bash

# Shorebird Module Update Script
# This script enables independent deployment of Flutter modules

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MODULES=("home_module" "profile_module" "jobs_module")
NATIVE_MODULES=("camera_native" "payment_native" "biometric_native")

# Function to display usage
usage() {
    echo -e "${BLUE}Usage: $0 [COMMAND] [MODULE] [OPTIONS]${NC}"
    echo ""
    echo "Commands:"
    echo "  deploy-module    Deploy a specific module"
    echo "  deploy-all       Deploy all modules"
    echo "  rollback         Rollback a module to previous version"
    echo "  status           Check deployment status"
    echo "  ab-test          Start A/B testing for a module"
    echo ""
    echo "Modules:"
    echo "  home_module, profile_module, jobs_module"
    echo "  camera_native, payment_native, biometric_native"
    echo ""
    echo "Examples:"
    echo "  $0 deploy-module home_module --staging"
    echo "  $0 deploy-all --production"
    echo "  $0 rollback profile_module"
    echo "  $0 ab-test jobs_module --variant new_design"
}

# Function to validate module name
validate_module() {
    local module=$1
    local all_modules=("${MODULES[@]}" "${NATIVE_MODULES[@]}")

    for valid_module in "${all_modules[@]}"; do
        if [[ "$module" == "$valid_module" ]]; then
            return 0
        fi
    done

    echo -e "${RED}Error: Invalid module '$module'${NC}"
    echo -e "${YELLOW}Valid modules: ${all_modules[*]}${NC}"
    exit 1
}

# Function to deploy a specific module
deploy_module() {
    local module=$1
    local environment=${2:-staging}

    echo -e "${BLUE}🚀 Deploying module: $module (Environment: $environment)${NC}"

    validate_module "$module"

    # Check if it's a native module
    if [[ " ${NATIVE_MODULES[@]} " =~ " ${module} " ]]; then
        deploy_native_module "$module" "$environment"
    else
        deploy_flutter_module "$module" "$environment"
    fi
}

# Function to deploy Flutter module
deploy_flutter_module() {
    local module=$1
    local environment=$2

    echo -e "${YELLOW}📦 Building Flutter module: $module${NC}"

    # Navigate to module directory
    cd "modules/$module"

    # Verify module configuration
    if [[ ! -f "shorebird.yaml" ]]; then
        echo -e "${RED}❌ No shorebird.yaml found for $module${NC}"
        exit 1
    fi

    # Build and create patch
    echo -e "${YELLOW}🔨 Creating Shorebird patch...${NC}"
    shorebird patch android --channel "$module" --dry-run

    if [[ "$environment" == "production" ]]; then
        echo -e "${GREEN}🎯 Deploying to production...${NC}"
        shorebird patch android --channel "$module"
    else
        echo -e "${BLUE}🧪 Deploying to staging...${NC}"
        shorebird patch android --channel "$module" --staging
    fi

    # Return to root directory
    cd ../..

    echo -e "${GREEN}✅ Module $module deployed successfully!${NC}"
}

# Function to deploy native module
deploy_native_module() {
    local module=$1
    local environment=$2

    echo -e "${YELLOW}⚙️ Building native module: $module${NC}"

    # Navigate to native module directory
    cd "native_modules/$module"

    # Build Android AAR if exists
    if [[ -d "android" ]]; then
        echo -e "${BLUE}🤖 Building Android AAR...${NC}"
        cd android
        ./gradlew assembleRelease
        cd ..
    fi

    # Build iOS XCFramework if exists
    if [[ -d "ios" ]]; then
        echo -e "${BLUE}🍎 Building iOS XCFramework...${NC}"
        cd ios
        xcodebuild -workspace "${module}.xcworkspace" -scheme "$module" -configuration Release
        cd ..
    fi

    # Deploy using Shorebird
    shorebird patch android --channel "$module" --native-module

    # Return to root directory
    cd ../..

    echo -e "${GREEN}✅ Native module $module deployed successfully!${NC}"
}

# Function to deploy all modules
deploy_all() {
    local environment=${1:-staging}

    echo -e "${BLUE}🚀 Deploying all modules (Environment: $environment)${NC}"

    # Deploy Flutter modules
    for module in "${MODULES[@]}"; do
        deploy_module "$module" "$environment"
        sleep 2  # Brief pause between deployments
    done

    # Deploy native modules
    for module in "${NATIVE_MODULES[@]}"; do
        deploy_module "$module" "$environment"
        sleep 2
    done

    echo -e "${GREEN}🎉 All modules deployed successfully!${NC}"
}

# Function to rollback a module
rollback_module() {
    local module=$1

    echo -e "${YELLOW}⏪ Rolling back module: $module${NC}"

    validate_module "$module"

    # Navigate to module directory
    if [[ " ${NATIVE_MODULES[@]} " =~ " ${module} " ]]; then
        cd "native_modules/$module"
    else
        cd "modules/$module"
    fi

    # Perform rollback
    shorebird patch android --channel "$module" --rollback

    # Return to root directory
    cd ../..

    echo -e "${GREEN}✅ Module $module rolled back successfully!${NC}"
}

# Function to check deployment status
check_status() {
    echo -e "${BLUE}📊 Checking deployment status...${NC}"

    echo -e "${YELLOW}Flutter Modules:${NC}"
    for module in "${MODULES[@]}"; do
        echo -e "  📱 $module: $(shorebird releases list --channel "$module" | head -1)"
    done

    echo -e "${YELLOW}Native Modules:${NC}"
    for module in "${NATIVE_MODULES[@]}"; do
        echo -e "  ⚙️ $module: $(shorebird releases list --channel "$module" | head -1)"
    done
}

# Function to start A/B testing
start_ab_test() {
    local module=$1
    local variant=${2:-variant_b}

    echo -e "${BLUE}🧪 Starting A/B test for module: $module${NC}"

    validate_module "$module"

    # Navigate to module directory
    if [[ " ${NATIVE_MODULES[@]} " =~ " ${module} " ]]; then
        cd "native_modules/$module"
    else
        cd "modules/$module"
    fi

    # Create A/B test patch
    shorebird patch android --channel "$module" --ab-test --variant "$variant" --percentage 20

    # Return to root directory
    cd ../..

    echo -e "${GREEN}✅ A/B test started for $module with variant: $variant${NC}"
}

# Main script logic
case "$1" in
    "deploy-module")
        if [[ -z "$2" ]]; then
            echo -e "${RED}Error: Module name required${NC}"
            usage
            exit 1
        fi

        environment="staging"
        if [[ "$3" == "--production" ]]; then
            environment="production"
        fi

        deploy_module "$2" "$environment"
        ;;

    "deploy-all")
        environment="staging"
        if [[ "$2" == "--production" ]]; then
            environment="production"
        fi

        deploy_all "$environment"
        ;;

    "rollback")
        if [[ -z "$2" ]]; then
            echo -e "${RED}Error: Module name required${NC}"
            usage
            exit 1
        fi

        rollback_module "$2"
        ;;

    "status")
        check_status
        ;;

    "ab-test")
        if [[ -z "$2" ]]; then
            echo -e "${RED}Error: Module name required${NC}"
            usage
            exit 1
        fi

        variant="variant_b"
        if [[ "$3" == "--variant" && -n "$4" ]]; then
            variant="$4"
        fi

        start_ab_test "$2" "$variant"
        ;;

    *)
        usage
        ;;
esac
