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

#watch "kubectl -n=demo-ds get pods" "2"
desc "Watch for pods updates..."
run "kubectl -n=demo-ds get pods -o wide -w"

#target="$1"

#while true; do
  #kubectl --namespace=demo-ds get rs -l demo=deployment \
      #-o go-template='{{range .items}}{{.metadata.name}} {{.metadata.labels}}{{"\n"}}{{end}}' \
      #| while read NAME LABELS; do
    #if echo "$LABELS" | grep -q "$target"; then
      #trap "exit" INT
      #while true; do
        #kubectl --namespace=demo-ds get rs "$NAME" \
            #-o go-template="$target Desired: {{.spec.replicas}} Running: {{.status.replicas}}{{\"\n\"}}"
        #sleep 0.3
      #done
      #exit 0
    #fi
  #done
#done
