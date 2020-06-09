#!/bin/bash
set -e

confd -onetime -backend env

exec "$@"
