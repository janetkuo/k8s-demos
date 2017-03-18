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

desc "Verify that each pod has a unique network address"
run "kubectl -n=demo-zoo exec zk-0 -- hostname -f"
run "kubectl -n=demo-zoo exec zk-1 -- hostname -f"
run "kubectl -n=demo-zoo exec zk-2 -- hostname -f"

desc "Read from pod zk-0, the value doesn't exist yet"
run "kubectl -n=demo-zoo exec zk-0 zkCli.sh get /hello | grep hello"

desc "Write to pod zk-0"
run "kubectl -n=demo-zoo exec zk-0 zkCli.sh create /hello world | grep Created"

desc "Read from pod zk-0 now succeeds"
run "kubectl -n=demo-zoo exec zk-0 zkCli.sh get /hello | grep world"

desc "Read from another pod zk-1 also succeeds"
run "kubectl -n=demo-zoo exec zk-1 zkCli.sh get /hello | grep world"

desc "Take down the ZooKeeper ensemble"
run "kubectl -n=demo-zoo delete -f $(relative zookeeper.yaml)"

desc "Make sure the pods are terminating or gone"
run "kubectl -n=demo-zoo get pods -l app=zk"

desc "Redeploy the ZooKeeper ensemble"
run "kubectl -n=demo-zoo apply -f $(relative zookeeper.yaml)"

desc "Make sure the pods are recreated"
run "kubectl -n=demo-zoo get pods -l app=zk"

desc "Finally, read from pod zk-2, the data we wrote is preserved"
run "kubectl -n=demo-zoo exec zk-2 zkCli.sh get /hello | grep world"
