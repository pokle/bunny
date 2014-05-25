# bunny

A minimal Clojure project that connects to a RabbitMQ cluster using the Java RabbitMQ client libraries

## Usage

First fire up the cluster with:

    vagrant up

While the VMs are coming up, add their IP addresses to your /etc/hosts

    #vms
    192.168.168.168 bunny1
    192.168.168.169 bunny2

When they are up, you can visit their management consoles (bunny/wabbit)

- http://bunny1:15672
- http://bunny2:15672

And then poke around with the Clojure code!
