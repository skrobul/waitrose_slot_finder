#!/bin/sh
docker run \
    --name=trose_slot_checker \
    --restart=always \
    -d \
    -e TROSE_USER=example@example.com \
    -e TROSE_PASSWORD=very_secret \
    -e GOTIFY_APP_TOKEN=AX1234 \
    -e GOTIFY_URL=https://example.com/gotify \
    -e PUSHOVER_APP_TOKEN=acd6pcunf7bv9z8noe2a63zo12345 \
    -e PUSHOVER_USER_KEY=uw14zr312jhdjahj1 \
    -e CHECK_EVERY_MINUTES=60 \
    -e NOTIFIER=gotify \
    skrobul/wrose-slot-checker
