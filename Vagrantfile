# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  #config.vm.box = "jwd/debian-7.9.0-amd64"

  switcher = {
    :cassandra  => true,
    :flink      => false ,
    :kafka      => false,
    :zookeeper  => false,
    :spark      => false
  }

  cassandra_nodes = 2

  flink_slaves = 2
  flink_base_ip = "192.168.80.1"
  flink_master_ip = "192.168.80.11"
  flink_slave_ips = (1..flink_slaves).map {|i| "#{flink_base_ip}#{i+1}"}.join(',')

  kafka_nodes = 3
  kafka_base_ip = "192.168.70.2"
  kafka_host_ips = (1..kafka_nodes).map {|i| "#{kafka_base_ip}#{i}"}.join(',')

  zookeeper_nodes = 3
  zookeeper_base_ip = "192.168.70.1"
  zookeeper_host_ips = (1..zookeeper_nodes).map {|i| "#{zookeeper_base_ip}#{i}"}.join(',')

  spark_base_ip = "192.168.80.2"
  spark_master_ip = "192.168.80.21"
  spark_worker_nodes = 2

  if switcher[:cassandra]
    (1..cassandra_nodes).each do |i|
      config.vm.define "cassy-#{i}" do |c|
          c.vm.provision "shell", path: "environments/vagrant/oracle-jdk.sh"
          c.vm.provision "shell", path: "environments/vagrant/cassandra.sh", env: {'CASSANDRA_SEEDS' => '192.168.60.11'}
          c.vm.synced_folder ".", "/vagrant", type: "virtualbox"
          c.vm.provider "virtualbox" do |vb|
            vb.memory = 2048
            vb.cpus = 2
          end

        c.vm.hostname = "cassy#{i}"
          c.vm.network "private_network", ip: "192.168.60.1#{i}"

        c.vm.network "forwarded_port", guest: 9160, host: (9260 + i)
          c.vm.network "forwarded_port", guest: 8081, host: (8180 + i)
          c.vm.network "forwarded_port", guest: 9042, host: (9140 + i)
      end
    end
  end

  if switcher[:flink]
    (1..(flink_slaves+1)).each do |i|
      config.vm.define "flink-#{i}" do |c|
          #c.vm.provision "shell", path: "environments/vagrant/oracle-jdk.sh"
          c.vm.provision "shell", path: "apache-flink/flink-uninstall.sh"
          c.vm.provision "shell", path: "environments/vagrant/flink.sh", env: {'FLINK_MASTER' => flink_master_ip, 'FLINK_SLAVES' => flink_slave_ips, 'FLINK_IS_MASTER' => (i == 1)}
          #c.vm.synced_folder ".", "/vagrant", type: "virtualbox"
          c.vm.provider "virtualbox" do |vb|
            vb.memory = 2048
            vb.cpus = 2
          end

          c.vm.hostname = "flink-#{i}"
          c.vm.network "private_network", ip: "#{flink_base_ip}#{i}"

          c.vm.network "forwarded_port", guest: 6123, host: (6122 + i)
          c.vm.network "forwarded_port", guest: 8081, host: (8180 + i)
      end
    end
  end

  if switcher[:zookeeper]
    (1..zookeeper_nodes).each do |i|
      config.vm.define "zk-#{i}" do |c|

        c.vm.provision "shell", path: "environments/vagrant/oracle-jdk.sh"
        c.vm.provision "shell", path: "environments/vagrant/zookeeper.sh", env: {'ZOOKEEPER_SERVERS' => zookeeper_host_ips, 'ZOOKEEPER_MY_ID' => i}

        c.vm.provider "virtualbox" do |vb|
            vb.memory = 1024
            vb.cpus = 2
        end

        c.vm.hostname = "zookeeper-#{i}"
        c.vm.network "private_network", ip: "#{zookeeper_base_ip}#{i}"

        c.vm.network "forwarded_port", guest: 2181, host: (2180 + i)
      end
    end
  end

  if switcher[:kafka]
    (1..kafka_nodes).each do |i|
      config.vm.define "kafka-#{i}" do |c|
        c.vm.provision "shell", path: "environments/vagrant/oracle-jdk.sh"
        c.vm.provision "shell", path: "environments/vagrant/kafka.sh", env: {'KAFKA_ZOOKEEPER_SERVERS' => zookeeper_host_ips, 'KAFKA_BROKER_ID' => i}

        c.vm.provider "virtualbox" do |vb|
            vb.memory = 1024
            vb.cpus = 2
        end

        c.vm.hostname = "kafka-#{i}"
        c.vm.network "private_network", ip: "#{kafka_base_ip}#{i}"
        c.vm.network "forwarded_port", guest: 9092, host: (9091 + i)
      end
    end
  end

  if switcher[:spark]
    config.vm.define "spark-master" do |c|
      c.vm.provision "shell", path: "environments/vagrant/oracle-jdk.sh"
      c.vm.provision "shell", path: "environments/vagrant/spark.sh", env: { 'SPARK_MODE' => 'master', 'SPARK_MASTER_IP' => spark_master_ip }
    #       c.vm.provision "shell", path: "environments/vagrant/kafka.sh", env: {'KAFKA_ZOOKEEPER_SERVERS' => zookeeper_host_ips, 'KAFKA_BROKER_ID' => i}
      c.vm.provider "virtualbox" do |vb|
          vb.memory = 1024
          vb.cpus = 2
      end
      c.vm.hostname = "spark-master"
      c.vm.network "private_network", ip: spark_master_ip
      c.vm.network "forwarded_port", guest: 8080, host: 9090
      c.vm.network "forwarded_port", guest: 7077, host: 7077
    end

    (1..spark_worker_nodes).each do |i|
      config.vm.define "spark-#{i}" do |c|
        c.vm.provision "shell", path: "environments/vagrant/oracle-jdk.sh"
        c.vm.provision "shell", path: "environments/vagrant/spark.sh", env: { 'SPARK_MODE' => 'worker', 'SPARK_MASTER_IP' => spark_master_ip }
        c.vm.provider "virtualbox" do |vb|
            vb.memory = 1024
            vb.cpus = 2
        end
        c.vm.hostname = "spark-#{i}"
        c.vm.network "private_network", ip: "#{spark_base_ip}#{i+1}"
        c.vm.network "forwarded_port", guest: 8081, host: (9090+i)
        #c.vm.network "forwarded_port", guest: 7077, host: 7077
      end
    end
  end

end
