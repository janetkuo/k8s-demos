#!/bin/bash
# Copyright 2017 The Kubernetes Authors.
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

desc "Create a Pod with init containers"
run "cat $(relative pod.yaml)"
run "kubectl -n demo-init apply -f $(relative pod.yaml)"

desc "Debug the Pod we just created"
run "kubectl -n demo-init describe -f $(relative pod.yaml)"

desc "Read logs from the first init container"
run "kubectl -n demo-init logs init -c init-mydb"

desc "Deploy mydb"
run "kubectl -n demo-init create -f $(relative mydb.yaml)"

desc "Debug the Pod again"
run "kubectl -n demo-init describe -f $(relative pod.yaml)"

desc "Read logs from the second init container"
run "kubectl -n demo-init logs init -c install"

desc "Correct init container image"
run "cat $(relative pod-correct.yaml)"
run "kubectl -n demo-init apply -f $(relative pod-correct.yaml)"

desc "See what happened by sending a GET request to the nginx server:"
desc "  apt-get update && apt-get install curl"
desc "  curl localhost"
run "kubectl -n demo-init exec -it init -- /bin/bash"

desc "Clean up"
run "kubectl -n demo-init delete -f $(relative pod.yaml) -f $(relative mydb.yaml)"
