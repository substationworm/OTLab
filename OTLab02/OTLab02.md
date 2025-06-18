# OTLab02

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab02")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tasks

> [!WARNING]
> The tasks in this document are strictly educational, observational, and non-intrusive, and must fully comply with ethical and legal standards.

- [ ] Verify the IP address of the `otlab-student` workstation.
- [ ] Determine the subnet range of the network where the `otlab-student` workstation is deployed.
- [ ] Discover the IP address, MAC address, and vendor information of other active hosts within the network.
    - *Hint: It is a PLC*.
- [ ] Identify open ports and available services on the OT-ICS host over both TCP and UDP protocols.
- [ ] Determine the proprietary industrial communication protocol used by the PLC.
- [ ] Retrieve additional system information using vendor-specific `nmap` scripts.
- [ ] Execute a `plcscan` on the OT-ICS device detected on the network and collect further data.

> [!NOTE]
> On the `otlab-student` workstation, the `plcscan` tool ([meeas/plcscan](https://github.com/meeas/plcscan)) must be executed using `python2`.

## 🔖 Nomenclature

- ICS: Industrial control system.
- IP: Internet protocol.
- MAC: Media access control.
- OT: Operational technology.
- PLC: Programmable logic controller.
- TCP: Transmission control protocol.
- UDP: User datagram protocol.