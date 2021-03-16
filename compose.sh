#!/usr/bin/env bash

MIN_DOCKER_VERSION='17.12.0'
MIN_DOCKER_COMPOSE_VERSION='1.21.0'
MIN_RAM_IN_MB=2048

# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash/37939589#37939589
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

DOCKER_VERSION=$(docker version --format '{{.Server.Version}}')
DOCKER_COMPOSE_VERSION=$(docker-compose --no-ansi --version | sed 's/docker-compose version \(.\{1,\}\),.*/\1/')
RAM_DOCKER_IN_MB=$(docker run --rm busybox free -m 2>/dev/null | awk '/Mem/ {print $2}');

if [ $(version $DOCKER_VERSION) -lt $(version $MIN_DOCKER_VERSION) ]; then
    echo "ERROR: Installed Docker version $DOCKER_VERSION <= $MIN_DOCKER_VERSION (expected)"
    exit 1
fi

if [ $(version $DOCKER_COMPOSE_VERSION) -lt $(version $MIN_DOCKER_COMPOSE_VERSION) ]; then
    echo "ERROR: Installed docker-compose version $DOCKER_COMPOSE_VERSION <= $MIN_DOCKER_COMPOSE_VERSION (expected) "
    exit 1
fi

if [ "$RAM_DOCKER_IN_MB" -lt "$MIN_RAM_IN_MB" ]; then
    echo "ERROR: Expected RAM available to Docker <= $MIN_RAM_IN_MB MB but found $RAM_DOCKER_IN_MB MB"
    exit 1
fi



COMPOSE_ENVIRONMENT_VARIABLES="CONFIGURATION_SIGNED=$(cat configuration_signed.xml | base64 -w0)"
COMPOSE_COMMAND_ACTION="up"
COMPOSE_COMMAND_FLAGS=""
COMPOSE_COMMAND_FILES="-f docker-compose.yml"
COMPOSE_COMMAND_PARAMETERS="--build"
COMPOSE_COMMAND_TARGETS=""
COMPOSE_START=true
UNKNOWN_PARAMETER=false

while test $# -gt 0
do
  case "$1" in

    # run in daemon mode
    "-d")
      echo "Running in daemon mode...";
      COMPOSE_COMMAND_FLAGS+=" -d"
      ;;

    # SPM 
    "spm")
      echo "Adding SPM..."
      COMPOSE_COMMAND_TARGETS+=" spm"
      ;;

    # HUB - velocity edition
    "hub")
      echo "Adding Collaboration Hub Velocity Edition..."
      COMPOSE_COMMAND_TARGETS+=" graphql user-mgmt hub"
      ;;

    # Solman
    "solman")
      echo "Adding Solman..."
      COMPOSE_COMMAND_TARGETS+=" solman"
      ;;

    # Apache for https
    "apache")
      echo "Starting Apache..."
      COMPOSE_COMMAND_TARGETS+=" apache"
      ;;

    # Pull SPM
    "spm-pull")
      echo "Pulling newest SPM image..."
      COMPOSE_COMMAND_TARGETS="spm"
      COMPOSE_COMMAND_PARAMETERS=""
      COMPOSE_COMMAND_FILES=""
      COMPOSE_COMMAND_ACTION="pull"
      COMPOSE_START=false
      ;;

    # Create log file
    "log")
      log_file="signavio_compose_`date +'%Y-%m-%d_%H-%M-%S'`.log"
      echo "Logging output to: $log_file"
      exec &> >(tee -a "$log_file")
      ;;

    # Shutdown cleaning containers
    "down")
      echo "Stopping setup..."
      COMPOSE_COMMAND_TARGETS=""
      COMPOSE_COMMAND_PARAMETERS="--remove-orphans"
      COMPOSE_COMMAND_ACTION="down"
      COMPOSE_START=false
      ;;

    *)
      echo "ERROR: Unknown parameter '$1'"
      UNKNOWN_PARAMETER=true
      ;;

  esac
  shift
done

if $UNKNOWN_PARAMETER ; then
  exit
fi

if [[ "$OSTYPE" != "WindowsNT" && ! "$OSTYPE" =~ .*darwin.* && $COMPOSE_START == true ]]; then
  COMPOSE_ENVIRONMENT_VARIABLES+=" USERID=$(id -u) GROUPID=$(id -g)"
fi

COMMAND_LINE="$COMPOSE_ENVIRONMENT_VARIABLES docker-compose $COMPOSE_COMMAND_FILES $COMPOSE_COMMAND_ACTION $COMPOSE_COMMAND_FLAGS $COMPOSE_COMMAND_PARAMETERS $COMPOSE_COMMAND_TARGETS"
echo "executing: $COMMAND_LINE"
eval $COMMAND_LINE

