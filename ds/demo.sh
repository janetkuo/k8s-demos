#!/bin/bash
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. $(dirname ${BASH_SOURCE})/../util.sh

# Clean up node color labels
for NODE in $(kubectl get nodes -o name | cut -f2 -d/); do
    kubectl label node $NODE color- --overwrite >/dev/null 2>&1
done

desc "Run our daemon"
run "cat $(relative daemon.yaml)"
run "kubectl -n=demo-ds apply -f $(relative daemon.yaml)"

desc "Look at the nodes"
run "kubectl get nodes"

desc "Check that there's one pod created on each node"
run "kubectl -n=demo-ds get pods -o wide"

RANDOM_NODE=$(kubectl get node | tail -1 | cut -f1 -d' ')
desc "Randomly label a node with red color" 
run "kubectl label node $RANDOM_NODE color=red"

desc "Check nodes color label"
run "kubectl get nodes -L color"

desc "Create another daemon that runs on nodes with red labels only"
run "cat $(relative daemon-red.yaml)"
run "kubectl -n=demo-ds apply -f $(relative daemon-red.yaml)"

desc "Finally, check that there's one pod from red daemon running on red node"
run "kubectl -n=demo-ds get pods -o wide"

# Clean up node color labels
for NODE in $(kubectl get nodes -o name | cut -f2 -d/); do
    kubectl label node $NODE color- --overwrite >/dev/null 2>&1
done
