#!/bin/bash

# Helper function for error handling
check_error() {
    if [ $? -ne 0 ]; then
        echo "$1"
        exit 1
    fi
}

simple_hummingbot() {
    # Path to your Docker compose file
    compose_file="deploy-examples/simple_hummingbot/hummingbot-compose.yml"

    # Prompt user for instance name and image tag
    read -p "Enter instance name: " instance_name
    read -p "Enter image tag: " tag

    # Use sed to replace the variables in the Docker compose file
    sed -i "s/\$(instance_name)/$instance_name/g" "$compose_file"
    check_error "Error replacing instance_name in Docker compose file."

    sed -i "s/\$(tag)/$tag/g" "$compose_file"
    check_error "Error replacing tag in Docker compose file."

    echo "Docker compose file updated!"
    
    docker compose -f "$compose_file" up -d
    check_error "Error starting Docker compose."

    sudo chmod -R a+rw ./$instance_name
    check_error "Error changing permissions."

    docker cp $instance_name:/home/hummingbot/scripts-copy/. ./$instance_name/scripts/
    check_error "Error copying scripts from Docker container."

    docker attach $instance_name
    check_error "Error attaching to Docker container."
}



# Check for deploy-examples directory
if [ ! -d "deploy-examples" ]; then
    echo "deploy-examples directory not found. Cloning the repository..."
    git clone https://github.com/david-hummingbot/deploy-examples
    echo "deploy-examples downloaded."
fi

# Present the user with options
echo "Choose an option:"
echo "1. Install Hummingbot"
echo "2. Update Hummingbot"
read -p "Enter your choice (1/2): " choice

case $choice in
    1)
        echo "Choose an installation option:"
        echo "1. autostart_hummingbot_compose"
        echo "2. hummingbot_gateway_broker_compose"
        echo "3. hummingbot_gateway_compose"
        echo "4. hummingbot_with_dashboard"
        echo "5. multiple_hummingbot_gateway_compose"
        echo "6. simple_hummingbot_compose"
        read -p "Enter your choice (1-6): " install_choice

        case $install_choice in
            1) autostart ;;
            2) gateway_broker ;;
            3) gateway_compose ;;
            4) dashboard ;;
            5) multiple_hummingbot ;;
            6) simple_hummingbot ;;
            *) echo "Invalid choice." ;;
        esac
        ;;

    2)
        echo "Choose an update option:"
        echo "1. latest"
        echo "2. development"
        echo "3. specify version"
        read -p "Enter your choice (1-3): " update_choice

        case $update_choice in
            1) docker pull hummingbot/hummingbot:latest ;;
            2) docker pull hummingbot/hummingbot:development ;;
            3) 
                read -p "Specify the version: " version
                docker pull hummingbot/hummingbot:$version
                ;;
            *) echo "Invalid choice." ;;
        esac
        ;;

    *)
        echo "Invalid choice."
        ;;
esac
