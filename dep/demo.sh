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

desc "Create a service that fronts any version of this demo"
run "cat $(relative svc.yaml)"
run "kubectl -n=demo-dep apply -f $(relative svc.yaml)"

desc "Deploy v1.7.9 of our app"
run "cat $(relative deployment.yaml)"
run "kubectl -n=demo-dep apply -f $(relative deployment.yaml)"
#run "kubectl -n=demo-dep run nginx --image=nginx:1.7.9 -l demo=deployment --port 80 --expose"

kubectl create -f curl.yaml >/dev/null 2>&1
desc "We can access the app through http://nginx"
run "kubectl -n=demo-dep exec curl -- curl -sI http://nginx"

# The output of describe is too wide, uncomment the following if needed.
# desc "Check it"
# run "kubectl --namespace=demo-dep describe deployment deployment-demo"

desc "Look at the pods we just created"
run "kubectl -n=demo-dep get pods -l demo=deployment -L version"

LAST_POD=$(kubectl get pods --namespace=demo-dep | tail -1 | cut -f1 -d' ')
desc "Kill the last pod $LAST_POD" 
run "kubectl -n=demo-dep delete pod $LAST_POD"

desc "Check that a replacement is created automatically"
run "kubectl -n=demo-dep get pods -l demo=deployment -L version"

desc "Update our app from v1.7.9 to a broken version"
run "cat $(relative deployment.yaml) | sed 's/1.7.9/broken/g' | kubectl -n=demo-dep apply -f-"

desc "Broken rollout won't progress"
run "kubectl -n=demo-dep get pods -l demo=deployment -L version"

desc "We can still access the app through http://nginx"
run "kubectl -n=demo-dep exec curl -- curl -sI http://nginx"

desc "Update our app to v1.9.1. Previous broken rollout won't block updates."
run "cat $(relative deployment.yaml) | sed 's/1.7.9/1.9.1/g' | kubectl -n=demo-dep apply -f-"
#run "kubectl -n=demo-dep set image deployment/demo nginx=nginx:1.9.1"

desc "Look at the pods we just updated"
run "kubectl -n=demo-dep get pods -l demo=deployment -L version"

desc "Finally, access the app through http://nginx again"
run "kubectl -n=demo-dep exec curl -- curl -sI http://nginx"

#tmux new -d -s my-session \
    #"$(dirname $BASH_SOURCE)/split1_control.sh" \; \
    #split-window -v -p 66 "$(dirname ${BASH_SOURCE})/split1_hit_svc.sh" \; \
    #split-window -v "$(dirname ${BASH_SOURCE})/split1_watch.sh v1" \; \
    #split-window -h -d "$(dirname ${BASH_SOURCE})/split1_watch.sh v2" \; \
    #select-pane -t 0 \; \
    #attach \;

#https://github.com/kubernetes/contrib/tree/master/micro-demos
