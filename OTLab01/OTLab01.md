# OTLab01

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab01")

[![Curriculum Lattes](https://img.shields.io/badge/Lattes-white)](http://lattes.cnpq.br/8846358506427099)
[![ORCID](https://img.shields.io/badge/ORCID-grey)](https://orcid.org/0000-0002-6254-7306)
[![SciProfiles](https://img.shields.io/badge/SciProfiles-black)](https://sciprofiles.com/profile/lffreitas-gutierres)
[![Scopus](https://img.shields.io/badge/Scopus-white)](https://www.scopus.com/authid/detail.uri?authorId=57195542368)
[![Web of Science](https://img.shields.io/badge/ResearcherID-grey)](https://www.webofscience.com/wos/author/record/Q-8444-2016)
[![substationworm](https://img.shields.io/badge/substationworm-black)](https://github.com/substationworm)
[![LFFreitasGutierres](https://img.shields.io/badge/LFFreitasGutierres-white)](https://github.com/LFFreitas-Gutierres)

## 📝 Tasks

> [!WARNING]
> When using specialized search engines or Google dorks to identify Internet-exposed OT devices, **do not interact with or attempt to access any real systems**. The tasks in this document are strictly educational, observational, and non-intrusive, and must fully comply with ethical and legal standards.

- [ ] Verify the IP address of the `otlab-student` workstation.
- [ ] Determine the subnet range of the network where the `otlab-student` workstation is deployed.
- [ ] Discover the IP address, MAC address, and vendor information of other active hosts within the network.
    - *Hint: It is a PLC*.
- [ ] Identify open ports and available services on the OT-ICS host over both TCP and UDP protocols.
- [ ] Determine the proprietary industrial communication protocol used by the PLC.
- [ ] Retrieve additional system information via the SNMP protocol.
- [ ] Identify the total number of publicly accessible OT-ICS devices using the same proprietary industrial protocol as `conpot-plc` through a specialized search engine such as [Shodan](https://www.shodan.io/) or [FOFA](https://en.fofa.info/).
- [ ] Locate a publicly exposed OT device using the same industrial protocol as `conpot-plc` through Google dorking.

> [!NOTE]
> The `conpot-plc` is based on [Conpot](http://conpot.org/), which remaps standard protocol and service ports to non-privileged ports. Refer to the [link](https://github.com/substationworm/OTLab/blob/main/OTLab01/ConpotDefaultPorts.md) for a list of some default and remapped ports.

## 🔖 Nomenclature

- ICS: Industrial control system.
- IP: Internet protocol.
- OT: Operational technology.
- PLC: Programmable logic controller.
- SNMP: Simple network management protocol.
- TCP: Transmission control protocol.
- UDP: User datagram protocol.