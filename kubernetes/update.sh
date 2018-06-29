#!/bin/sh

set -xeu

kubectl apply -f presetup/*.yaml
helmfile sync
kubectl apply -f postsetup/*.yaml