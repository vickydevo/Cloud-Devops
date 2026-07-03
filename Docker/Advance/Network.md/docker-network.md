# Docker Networking Documentation

This documentation provides an overview of Docker networking, focusing on the default bridge network, user-defined networks, and macvlan networks. It includes use cases, steps to set up these networks, and commands to inspect and verify connectivity.

---
## Prerequisite: Check Network IP Address

Before working with Docker networks, it is essential to check the IP address of your host machine's network interfaces. This ensures that you configure Docker networks correctly and avoid IP conflicts.
### Inspect the Host’s Network from Outside the Container

To inspect the host's network from outside the container, you can use the following steps:

1. **List all network interfaces on the host:**
    ```bash
    ip link show
    ip addr
    ```

2. **Check the IP routing table to understand how traffic is routed:**
    ```bash
    ip route
    ```
![Image](https://github.com/user-attachments/assets/d7e5b3c3-9ed6-4e9c-a297-07aeb546e5f5)

CIDR Block: 172.31.80.0/20
Subnet Range: 172.31.80.0 — 172.31.95.255

| Address Type                   | Example             |
|--------------------------------|---------------------|
| Network Address                | 172.31.80.0         |
| Gateway (typically 2nd ip )    | 172.31.80.1         |
| Your EC2 IP                    | 172.31.88.220       |
| Broadcast Address last ip      | 172.31.95.255       |
|AmazonDNS server in your VPC    | 172.31.0.2          |  /etc/resolv.conf (Dhcp)

## What is DHCP?

**DHCP (Dynamic Host Configuration Protocol)** is a network protocol that automates the process of assigning network configuration details to devices on a network. When a device connects to a network, DHCP provides the following information:

- **IP Address**: A unique address for the device on the network.
- **Subnet Mask**: Defines the network and host portions of the IP address.
- **Gateway**: The default route for accessing external networks.
- **DNS Server**: Resolves domain names to IP addresses.




3. **Inspect the Docker bridge network on the host:**
    ```bash
    ip addr show docker0
    ```

4. **Verify connectivity to the host from an external machine:**
    - Use the `ping` command to test connectivity to the host's IP address.
    - Example:
        ```bash
        ping <host-ip-address>
        ```
### Notes
- Ensure that the subnet used for Docker networks does not overlap with the host's existing network.
- Use this information when creating custom networks like macvlan to avoid conflicts.
- If unsure, consult your network administrator for guidance.

## 1. Bridge Network

The **bridge network** is the default network that containers are connected to if no specific network is specified during container creation. It allows containers on the same host to communicate with each other while remaining isolated from external networks.

### Use Case
- Ideal for communication between containers on the same Docker host.
- Provides isolation from external networks.
### Steps to Inspect the Default Bridge Network

1. **List all Docker networks to identify the default bridge network:**
    ```bash
    docker network ls
    ```
![Image](https://github.com/user-attachments/assets/e964ad5e-e209-421e-812a-ac74a376f7a6)

2. **Inspect the default bridge network:**
    ```bash
    docker network inspect bridge
    ```
![Image](https://github.com/user-attachments/assets/f22edbf2-87a1-4f13-81d5-4c353af9b366) 



### Example: Using the Default Bridge Network

To create a container using the default bridge network, run the following command:

```bash
sudo docker run -dit --rm --name thor-cont busybox
sudo docker run -dit --rm --name mjolnir-cont busybox
sudo docker run -dit --rm --name stormbreaker nginx

```
![Image](https://github.com/user-attachments/assets/39283c99-a7b2-4d82-9e83-548a4bd3d3fe)

This starts a container named `thor-cont` using the default bridge network. You can verify its network settings with:

```bash  
sudo docker network inspect bridge

sudo docker exec -it thor-cont ip addr 
sudo docker exec -it thor-cont ip route
sudo bridge link
```
![Image](https://github.com/user-attachments/assets/c968355c-43df-4125-8aef-558be60913ce)

![Image](https://github.com/user-attachments/assets/51d179f6-5d1b-402a-8e3d-985d696aa7b0) 
### Verifying Communication Between Containers

To verify that the containers `thor-cont`, `mjolnir-cont`, and `stormbreaker` can communicate with each other on the default bridge network, follow these steps:
1. **Connect to `thor-cont` and check connectivity with `mjolnir-cont` using its IP address:**
    ```bash
    docker exec -it thor-cont sh
    ```

2. **Ping `mjolnir-cont` using its IP address:**
    ```bash
    ping <mjolnir-cont-ip>
    ```
![Image](https://github.com/user-attachments/assets/22ceb60c-aad8-4aa0-82bc-14cd2291d1b6) 


### Notes
- Ensure that all containers are running and attached to the same network.
- If the containers cannot communicate, verify the network configuration using `docker network inspect bridge`.
- Use container names as hostnames for communication within the same network.

## 2. User-Defined Network

A **user-defined network** is a custom network created by the user to provide more control over container communication. Containers on the same user-defined network can communicate using container names as DNS hostnames.

### Use Case
- Useful for organizing containers into logical groups.
- Provides better control over container communication.

### Steps to Create and Use User-Defined Network
1. **Create a user-defined network:**
    ```bash
    docker network create asgard
    ```
![Image](https://github.com/user-attachments/assets/21c67093-19f3-4a2e-921a-c28454e06fc2) 
2. **Run containers and attach them to the user-defined network:**
    ```bash
    docker run -itd --rm --network asgard --name loki busybox
    docker run -itd --rm --network asgard --name odin busybox
    ```
3. **Inspect the network:**
    ```bash
    docker network inspect asgard
    ```
![Image](https://github.com/user-attachments/assets/98c66667-5def-479b-9fd6-7337ebf4e626) 
![Image](https://github.com/user-attachments/assets/d6bba58e-5d9b-4a5d-b3c6-1e564be2579a) 
4. **Verify connectivity between containers:**
   
```bash
    docker exec -it loki ping odin
```

![Image](https://github.com/user-attachments/assets/615deca8-a879-4f57-84b2-12fa93718d5d)

### Notes
- User-defined networks provide automatic DNS resolution for container names.
- Containers on the same user-defined network can communicate directly.
## 4. Host Network

The **host network** allows a container to share the network stack of the host machine. This means the container does not get its own IP address but instead uses the host's IP address and ports.

### Use Case
- Useful for applications that require high network performance or need to bind to specific ports on the host.
- Ideal for scenarios where the containerized application needs direct access to the host's network.

### Steps to Use the Host Network


### Detach `stormbreaker` from the Default Bridge Network and Attach to the Host Network

1. **Stop and remove the `stormbreaker` container:**
    ```bash
    docker stop stormbreaker
    ```

2. **Run the `stormbreaker` container with the host network:**
    ```bash
    docker run -dit --rm --network host --name stormbreaker nginx
    ```
3. **Check the container's network configuration:**
    ```bash
    docker inspect stormbreaker 
    ```
![Image](https://github.com/user-attachments/assets/853375c3-e189-48fb-bd9b-4550b757efc7)

4. **Test connectivity to the container using the host's IP address:**
    - Access the Nginx server running in the container via the host's IP address and port 80.
### Notes
- When using the host network, port conflicts may occur if multiple containers or services try to bind to the same port.
- The host network is only available on Linux systems and is not supported on Docker Desktop for Mac or Windows.
- Use the host network cautiously, as it bypasses Docker's network isolation.
