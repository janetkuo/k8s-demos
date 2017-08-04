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

desc "Create a ZooKeeper ensemble"
run "kubectl -n=demo-zoo apply -f $(relative zookeeper.yaml)"

desc "Look at the pods we just created"
run "kubectl -n=demo-zoo get pods -l app=zk"

desc "Verify that each pod has a stable and unique network identity"
run "kubectl -n=demo-zoo exec zk-0 -- hostname -f"
run "kubectl -n=demo-zoo exec zk-1 -- hostname -f"
run "kubectl -n=demo-zoo exec zk-2 -- hostname -f"

desc "Verify that each pod has a stable and unique storage"
run "kubectl -n-demo-zoo get pv"

#desc "From pod zk-0, list existing directories"
#run "kubectl -n=demo-zoo exec zk-0 zkCli.sh ls / | grep 'zookeeper.*\]'"

desc "Write to pod zk-0: create '/hello' with data 'world'"
run "kubectl -n=demo-zoo exec zk-0 zkCli.sh create /hello world | grep Created"

#desc "From pod zk-0, list existing directories again"
#run "kubectl -n=demo-zoo exec zk-0 zkCli.sh ls / | grep hello"

#desc "Read data in '/hello' from pod zk-0 "
#run "kubectl -n=demo-zoo exec zk-0 zkCli.sh get /hello | grep world"

desc "Read data in '/hello' from another pod zk-1"
run "kubectl -n=demo-zoo exec zk-1 zkCli.sh get /hello | grep world"

#LAST_PET=$(kubectl get pods -n=demo-zoo | tail -1 | cut -f1 -d' ')
#desc "Kill the last pod $LAST_PET"
#run "kubectl -n=demo-zoo delete pod $LAST_PET"

#desc "Make sure the pods are recreated"
#run "kubectl -n=demo-zoo get pods -l app=zk"

#desc "Finally, read from pod zk-2, the data we wrote to '/hello' is preserved"
#run "kubectl -n=demo-zoo exec zk-2 zkCli.sh get /hello | grep world"

desc "Take a look at zookkeeper current CPU request and update strategy"
run "kubectl -n=demo-zoo get statefulsets -o=custom-columns-file=template-sts.txt"

desc "Take a look at current CPU request of each pod"
run "kubectl -n=demo-zoo get pods -l app=zk -o=custom-columns-file=template.txt"

desc "Rolling update CPU request from 1 to 500m"
run "cat $(relative zookeeper.yaml) | sed 's/cpu\:\ \"1\"/cpu\:\ \"500m\"/g' | kubectl -n=demo-zoo apply -f-"

desc "Take a look at zookkeeper updated CPU request"
run "kubectl -n=demo-zoo get statefulsets -o=custom-columns-file=template-sts.txt"

desc "Take a look at pod CPU request after the update"
run "kubectl -n=demo-zoo get pods -l app=zk -o=custom-columns-file=template.txt"

FIRST_PET=$(kubectl get pods -n=demo-zoo | head -2 | tail -1 | cut -f1 -d' ')
desc "Kill the first pod $FIRST_PET"
run "kubectl -n=demo-zoo delete pod $FIRST_PET"

desc "CPU request of the first pod $FIRST_PET is not updated"
run "kubectl -n=demo-zoo get pods -l app=zk -o=custom-columns-file=template.txt"

desc "Finally, read from the first pod $FIRST_PET, the data we wrote to '/hello' is preserved"
run "kubectl -n=demo-zoo exec $FIRST_PET zkCli.sh get /hello | grep world"
