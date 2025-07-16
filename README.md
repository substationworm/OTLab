# OTLab

![](OTLab-MainHeader.png "OTLab")

**OTLab** is a suite of scripts developed to emulate operational technologies (OT) and industrial control systems (ICS) using containerized environments powered by [Docker](https://www.docker.com/).

**OTLab** is part of the educational project "[CYBERENG001] Industrial Cybersecurity for Engineers" ([064306](https://portal.ufsm.br/projetos/publico/projetos/view.html?idProjeto=426877)), coordinated by [Prof. Dr. Luiz F. Freitas-Gutierres](https://www.linkedin.com/in/lffreitas-gutierres/) at the Federal University of Santa Maria ([UFSM](https://www.ufsm.br/)). The project aims to advance engineering education offering hands-on, container-based OT-ICS emulation environments that support experiential learning and training in the field of industrial cybersecurity.

The following animation illustrates the basic usage of an **OTLab** script, demonstrating its core functionalities:

<p align="center">
  <img src="OTLab-Usage.gif" title="OTLab basic usage">
  <br>
  <em>Figure 01. OTLab basic usage.</em>
</p>

```
Usage: ./OTLab01.sh -start [kali|ubuntu] | -stop | -clean | -run | -restart

  -start     Start the OTLab01 environment using the specified distro (default: ubuntu)
             Valid options: kali (rolling) or ubuntu (22.04)
  -run       Open a terminal inside the otlab-student container
  -clean     Remove containers, volumes, and network
  -stop      Stop all containers
  -restart   Restart previously stopped containers
```

This repository also provides **OTLab** scripts based on custom Docker images to facilitate offline use and minimize the need for downloads. For each case study, there is a corresponding script labeled with the `-Offline` suffix in its name. To use these offline-ready scripts, the images available in the [Dockerfiles](https://github.com/substationworm/OTLab/tree/main/Dockerfiles) directory must be built locally. For instance, to build the `ews-image-ubuntu01` image, execute the following command:

```
docker build -t ews-image-ubuntu01 -f ews-image-ubuntu01.ews .
```

In this example, the current directory (`.`) serves as the build context. Ensure that all files referenced within the Dockerfile are accessible from the specified context, and adjust the paths as needed to match your local directory structure.

Additionally, as outlined in [ThirdPartyDockerImages](https://github.com/substationworm/OTLab/blob/main/Dockerfiles/ThirdPartyDockerImages.md), certain third-party images must be pulled manually and saved locally to enable full offline functionality.

---

*Summary of case studies*:

- [OTLab01](https://github.com/substationworm/OTLab/tree/main/OTLab01): Basics of OT-ICS Device Discovery.
- [OTLab02](https://github.com/substationworm/OTLab/tree/main/OTLab02): Siemens S7 PLC Emulation.
- [OTLab03](https://github.com/substationworm/OTLab/tree/main/OTLab03): Emulation of a Gas Station Control System.
- [OTLab04](https://github.com/substationworm/OTLab/tree/main/OTLab04): Modbus/TCP Emulation and Register Access.
- [OTLab05](https://github.com/substationworm/OTLab/tree/main/OTLab05): Modbus/TCP Routing Between Subnets.
- [OTLab06](https://github.com/substationworm/OTLab/tree/main/OTLab06): Industrial Protocols and Web Interface Exposure.
- [OTLab07](https://github.com/substationworm/OTLab/tree/main/OTLab07): Default Password Exposure.

---

**OTLab** was tested on a host running Ubuntu 24.04.2 LTS, with Docker version 28.2.2 and Docker Compose version v2.36.2.

🚨 Warning: Docker Compose v1 may not correctly assign the MAC addresses specified in the scripts.