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

desc "Run some pods in a job"
run "cat $(relative job.yaml)"
run "kubectl -n=demo-job apply -f $(relative job.yaml)"

#desc "See what we did"
#run "kubectl --namespace=demo-job describe job jobs-demo"

#desc "See the job has at most 3 pods running in parallel"
while [ "$(kubectl -n=demo-job get job jobs-demo -o go-template='{{.status.succeeded}}')" != 10 ]; do
	#run "kubectl -n=demo-job get pods,jobs -l demo=jobs"
    :
done

desc "Now the job is completed"
run "kubectl -n=demo-job get jobs -l demo=jobs"

desc "No running pods"
run "kubectl -n=demo-job get pods -l demo=jobs"

desc "Finally, view all terminated pods"
run "kubectl -n=demo-job get pods --show-all -l demo=jobs"
