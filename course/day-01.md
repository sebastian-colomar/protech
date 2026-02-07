# Day 01 – Environment Setup

This guide walks you through setting up a Linux environment, connecting to an AWS virtual machine, and accessing the OpenShift Hub cluster.

---

## 1. Get a Linux machine with public DNS access

You need a Linux system with outbound internet connectivity and public DNS resolution.

### Option A: Google Cloud Shell
Use your personal Google account:
- https://shell.cloud.google.com

### Option B: Killercoda Playground
Use your personal Google or GitHub account:
- https://killercoda.com/playgrounds/scenario/ubuntu

---

## 2. Prepare the SSH key

You will receive an SSH private key by email. The key is Base64-encoded and must be decoded before use.

### Decode the key

Since this is a test environment, you may use an online decoder:
- https://www.base64decode.org

Alternatively, decode it directly on a Linux machine:

```bash
echo ENCODED_TEXT | base64 -d
```

---

## 3. Create the SSH key file and set permissions

Create a file containing the decoded key:

```bash
vi ~/key.txt
```

Paste the decoded key content, save the file, then set the correct permissions:

```bash
chmod 600 ~/key.txt
```

> SSH will refuse to use the key if file permissions are too permissive.

---

## 4. Connect to the AWS virtual machine

Export the required environment variables:

```bash
export Domain=sebastian-colomar.com
export UnixUser=ec2-user
export YourName=me
export YourKey=~/key.txt
```

Connect to the virtual machine:

```bash
ssh protech-${YourName}.${Domain} -i ${YourKey} -l ${UnixUser}
```

---

## 5. Configure the virtual machine

Once connected, clone the repository and run the configuration script:

```bash
git clone https://github.com/sebastian-colomar/protech
source protech/bin/ec2-config-$(grep ^ID= /etc/os-release | cut -d'"' -f2).sh
```

---

## 6. Access the OpenShift Hub cluster

Open the OpenShift console using the link below and log in with the credentials provided in the chat.

When prompted, select the **HTPASSWD** identity provider.

* https://console-openshift-console.apps.hub.sebastian-colomar.com

---
