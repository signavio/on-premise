$COMPOSE_COMMAND_ACTION = "up"
$COMPOSE_COMMAND_FLAGS = ""
$COMPOSE_COMMAND_FILES = "-f docker-compose.yml"
$COMPOSE_COMMAND_PARAMETERS = "--build"
$COMPOSE_COMMAND_TARGETS = ""
$COMPOSE_START = [bool]1
$UNKNOWN_PARAMETER = [bool]0

foreach ($param in $args) {
    switch ($param) {
        # run in daemon mode
        "-d" {
            echo "Running in daemon mode...";
            $COMPOSE_COMMAND_FLAGS += " -d"
        }

        # SPM
        "spm" {
            echo "Adding SPM..."
            $COMPOSE_COMMAND_TARGETS += " spm"
        }

        # HUB - velocity edition
        "hub" {
            echo "Adding Collaboration Hub Velocity Edition..."
            $COMPOSE_COMMAND_TARGETS += " graphql user-mgmt hub"
        }

        # Solman
        "solman" {
            echo "Adding Solman..."
            $COMPOSE_COMMAND_TARGETS += " solman"
        }

        # Apache for https
        "apache" {
            echo "Starting apache..."
            $COMPOSE_COMMAND_TARGETS += " apache"
        }

        # Pull SPM
        "spm-pull" {
            echo "Pulling newest SPM image..."
            $COMPOSE_COMMAND_TARGETS = "spm"
            $COMPOSE_COMMAND_PARAMETERS = ""
            $COMPOSE_COMMAND_FILES = ""
            $COMPOSE_COMMAND_ACTION = "pull"
            $COMPOSE_START = [bool]0
        }

        # Shutdown cleaning containers
        "down" {
            echo "Stopping setup..."
            $COMPOSE_COMMAND_TARGETS = ""
            $COMPOSE_COMMAND_PARAMETERS = "--remove-orphans"
            $COMPOSE_COMMAND_ACTION = "down"
            $COMPOSE_START = [bool]0
        }

        default {
            echo "ERROR: Unknown parameter '$param'"
            $UNKNOWN_PARAMETER = [bool]1
        }
    }
}

if ($UNKNOWN_PARAMETER -eq $true) {
    echo "aborted"
    exit
}

$CONFIG_BYTES = [System.Text.Encoding]::UTF8.GetBytes($(get-content configuration_signed.xml -Encoding UTF8 -Raw))
$ENCODED_CONFIG = [System.Convert]::ToBase64String($CONFIG_BYTES)
$env:CONFIGURATION_SIGNED = "$ENCODED_CONFIG"

$COMMAND_LINE = "docker-compose $COMPOSE_COMMAND_FILES $COMPOSE_COMMAND_ACTION $COMPOSE_COMMAND_FLAGS $COMPOSE_COMMAND_PARAMETERS $COMPOSE_COMMAND_TARGETS"
echo "executing: $COMMAND_LINE"
Invoke-Expression $COMMAND_LINE
