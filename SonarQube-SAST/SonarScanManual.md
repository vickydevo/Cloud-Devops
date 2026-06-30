
# Guide: Scanning Spring Boot App with SonarQube

This guide explains how to perform Static Application Security Testing (SAST) on a Java Spring Boot project using Maven and a Dockerized SonarQube server.

## Prerequisites

1. **SonarQube Server:** Running on `http://<EC2-IP>:9000`
2. **Java & Maven:** Installed on the EC2 host.
3. **Project:** A Spring Boot application with a `pom.xml`.

---

# Check the version of SonarQube in Browser

```bash
http://<EC2_PUBLIC_IP>:9000/api/server/version

```

## Step 1: Configure the SonarQube Maven Plugin

For Maven to recognize the `sonar:sonar` command, you must define the **sonar-maven-plugin** in your `pom.xml` file. This plugin is responsible for analyzing the source code and sending the data to the SonarQube server.

Add the following block inside the `<build><plugins>` section of your `pom.xml`:

```xml
            <plugin>
                <groupId>org.sonarsource.scanner.maven</groupId>
                <artifactId>sonar-maven-plugin</artifactId>
                <version>${sonar.maven.plugin.version}</version>
            </plugin>

```

---

## Step 2: Generate a SonarQube Analysis Token

To send results to the server, you need an authentication token.

1. Log in to SonarQube (`admin` / `admin`).
2. Go to **My Account** (top right icon) > **Security**.
3. Under **Generate Tokens**, give it a name (e.g., `workshop-token`).
4. Select Type: **User Token**.
5. Click **Generate** and **COPY THE TOKEN**. (You won't see it again!)

---

## Step 3: Configure SonarQube URL

You need to tell Maven where the SonarQube server is located. You can do this by adding a `<properties>` section in your `pom.xml` or by passing it in the command line (Recommended for workshops).

---

## Step 4: Run the Scan (The Command)

Navigate to your project root (where `pom.xml` is) and run the following command.

```bash
# New version of Sonarqube with token
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=my-spring-boot-app \
  -Dsonar.projectName='My Spring Boot App' \
  -Dsonar.host.url=http://<EC2_PUBLIC_IP>:9000 \
  -Dsonar.token=<YOUR_TOKEN> \
  -Ddependency-check.skip=true

  

 # This command is used when we use sonar legacy version like LTS version
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=Java-spring \
  -Dsonar.host.url=http://100.27.199.152:9000 \
  -Dsonar.login=squ_79b071bacfedf38f2174b9322b2103d73c4b 

# manual way
sonar-scanner \
  -Dsonar.projectKey=JavaProject \
  -Dsonar.sources=src/main/java \
  -Dsonar.host.url=http://32.192.4.168:9000 \
  -Dsonar.token=squ_665886081f6aa9068c4c1b4530ee2e53580748a4


```

> **Note:** Replace `<YOUR_TOKEN>` and `<EC2_PUBLIC_IP>` with your actual details.

### Why we use these flags:

* `clean verify`: Ensures the code is compiled and tests pass before scanning (Sonar needs the binaries/classes).
* `sonar:sonar`: Triggers the SonarQube analysis via the plugin added in Step 1.
* `sonar.projectKey`: A unique ID for your project in SonarQube.
* `sonar.token`: Authenticates the scanner so it can upload the report.

---

## Step 5: View the Results in SonarQube Dashboard

1. Wait for the terminal to show `BUILD SUCCESS`.
2. Go to your browser: `http://<EC2_IP>:9000/projects`.
3. Click on **My Spring Boot App** to see the:

* **Bugs** & **Vulnerabilities** (SAST).
* **Security Hotspots** (Code that needs review).
* **Code Smells** (Maintainability issues).

<img width="1845" height="742" alt="Image" src="[https://github.com/user-attachments/assets/02f789ba-755e-4313-8659-60fb34767d14](https://github.com/user-attachments/assets/02f789ba-755e-4313-8659-60fb34767d14)" />

---

Would you like me to show you how to set up a Quality Gate in SonarQube to automatically fail builds that don't meet security standards?

### Key Teaching Points for your Workshop



* **SAST vs. DAST:** Explain that this scan is **SAST** (Static) because we are analyzing the source code without running the application.
* **The "Secret" Catch:** Since you intentionally added **AWS Secrets** earlier, show the students the **Security Hotspots** or **Vulnerabilities** tab. SonarQube will flag the dummy AWS keys you pushed!
* **Quality Gates:** Show them the "Passed" or "Failed" status. Explain that in a real CI/CD pipeline (like Jenkins or GitHub Actions), a "Failed" Quality Gate would stop the code from being deployed to production.
