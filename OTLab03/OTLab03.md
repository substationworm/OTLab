# OTLab03

![](https://raw.githubusercontent.com/substationworm/OTLab/main/OTLab-SecondHeader.png "OTLab03")

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
    - *Hint: One of the devices is an automatic tank gauge (ATG) controller*.
- [ ] Identify open ports and available services on the OT-ICS host over both TCP and UDP protocols.
- [ ] Retrieve additional system information using vendor-specific `nmap` scripts.
- [ ] Identify the total number of publicly accessible OT-ICS devices using the same open port as `gas_station` through a specialized search engine such as [Shodan](https://www.shodan.io/) or [FOFA](https://en.fofa.info/).
- [ ] Determine the total number of publicly exposed OT-ICS devices that implement the same ATG-related functionality as the `gas_station` host by querying a specialized search engine such as [Shodan](https://www.shodan.io/) or [FOFA](https://en.fofa.info/).

## 🔖 Nomenclature

- ATG: Automatic tank gauge.
- ICS: Industrial control system.
- IP: Internet protocol.
- MAC: Media access control.
- OT: Operational technology.
- TCP: Transmission control protocol.
- UDP: User datagram protocol.