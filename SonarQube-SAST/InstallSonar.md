# SonarQube


## Installation Setup of SonarQube

## Prerequisites

1. **SonarQube Server:** Running on `http://<EC2-IP>:9000`
2. **Java & Maven:** Installed on the EC2 host.
3. **Project:** A Spring Boot application with a `pom.xml`.
4. Minimum Cloud Tier: t3.medium (2 vCPUs, 4GB RAM). SSD 20GB

### Running SonarQube as a Docker Container 

1. **Install Docker**: Follow the [Docker installation guide](https://docs.docker.com/get-docker/).
    ```bash
        sudo apt update -y && sudo apt install docker.io -y
        # Add your current user to the docker group
        sudo usermod -aG docker $USER && newgrp docker
    ```

3. **Run Container**:
    
    ```bash
    # newer version
    docker run -d --name sonarqube -p 9000:9000 sonarqube:community

    # older version
    docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community
    ```
   **Verify version**:
   ```bash
   http://<instance-public-ip>:9000/api/server/version
   ```

    
4. **Verify**: Use `docker ps` to confirm the container is running.
5. **Access**: Navigate to `http://<instance-public-ip>:9000`.

### Logging into SonarQube

1. **Default Credentials**:
    - Username: `admin`
    - Password: `admin`
        <img width="1268" height="793" alt="Image" src="https://github.com/user-attachments/assets/06ce799a-54ce-4b06-aa8f-6bd286155f02" />

2. **Change Password**: Prompted on first login.

3. **Dashboard**:

    ![Image](https://github.com/user-attachments/assets/a28caa7a-b75c-46dc-9522-33a69fbe6952)
---
## Quality Profile in SonarQube

A **Quality Profile** defines rules for code analysis, ensuring adherence to standards.

### Features

1. **Customizable Rules**: Enable/disable rules as needed.
2. **Language-Specific**: Profiles for each language.
3. **Default Profiles**: Predefined profiles for quick use.
4. **Inheritance**: Share rules across projects.

### Importance

- Ensures consistent code quality.
- Enforces coding standards.
- Detects issues early.

### Management

- Navigate to **Quality Profiles** in the dashboard.
- Create, edit, or delete profiles.
- Assign profiles to projects.

Refer to the [Quality Profiles Documentation](https://docs.sonarsource.com/latest/analysis/quality-profiles/).

## Quality Gate in SonarQube

A **Quality Gate** is a set of conditions a project must meet for acceptable quality.

### Features

1. **Customizable Conditions**: Define metrics like code coverage, bugs, and duplications.
2. **Pass/Fail Criteria**: Projects pass if all conditions are met.
3. **Default Gate**: "Sonar Way" for basic quality checks.
4. **CI/CD Integration**: Blocks builds if the gate fails.

### Importance

- Ensures consistent quality.
- Detects issues early.
- Reduces production risks.

### Management

- Navigate to **Quality Gates** in the dashboard.
- Create, edit, or delete gates.
- Assign gates to projects.

Refer to the [Quality Gates Documentation](https://docs.sonarsource.com/latest/analysis/quality-gates/).