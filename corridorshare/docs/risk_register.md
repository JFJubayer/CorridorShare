# Comprehensive Risk Register
## CorridorShare — P2P Crowd-Shipping Platform

**Subproject**: `corridorshare/`  
**Evaluation Context**: CSE-3102 Software Engineering  
**Version**: 1.0.0  
**Date**: 2026-10-13  

---

### 1. Risk Evaluation Matrix

| Likelihood / Impact | Minor (1) | Moderate (2) | Major (3) | Critical (4) |
|:---|:---:|:---:|:---:|:---:|
| **High (3)** | Medium | High | Critical | **Catastrophic (R1)** |
| **Medium (2)** | Low | Medium | High | **Critical (R2, R3)** |
| **Low (1)** | Low | Low | Medium | **High (R4, R5)** |

---

### 2. Identified Risks & Mitigation Strategies

| ID | Risk Description | Category | Severity | Likelihood | Mitigation Strategy | Owner |
|:---|:---|:---|:---:|:---:|:---|:---:|
| **R1** | **Contraband / Illegal Items Transport**: Sender posts illicit narcotics, weapons, or prohibited substances under BD law. | Legal / Safety | Critical | Medium | Mandatory legal declaration checkbox at parcel creation, automated keyword filtering, inspection photo proof before handover, and NID identity verification for account accountability. | Product / Compliance |
| **R2** | **Client-Side Balance Tampering**: Malicious actor exploits client memory to inject demo funds or force premature payout. | Financial / Security | Major | Medium | Zero client trust on ledger balances. Wallet writes strictly locked down in `firestore.rules`. Balance changes execute exclusively inside server-authoritative Firebase Cloud Functions via ACID transactions. | Backend Lead |
| **R3** | **Handover PIN Fraud / Social Engineering**: Sender or receiver claims parcel was never delivered after PIN disclosure. | Operational | Major | Low | 4-digit numeric PIN is delivered only to recipient and verified server-side. Pre-transit inspection checklist and timestamped photo proof establish condition baseline. | Operations |
| **R4** | **Off-Platform Payment Disintermediation**: Users arrange cash handovers via chat to circumvent platform escrow. | Business | Moderate | High | In-app messaging safety banners, automated detection of external contact patterns, and escrow release protections tied to platform PIN entry. | Product |
| **R5** | **Intercity Transit Delays / Missed Handover**: Traveller misses train/bus or recipient is unreachable at destination. | Logistical | Moderate | Medium | Mandatory travel notes field, real-time message stream, and structured dispute escalation queue with Admin refund/payout arbitration. | Support |
| **R6** | **Network Drop / Offline Sync Failures**: Cellular disconnection during rural corridor rail or highway travel. | Technical | Moderate | High | Local state persistence with optimistic caching and clear connectivity indicators for graceful degradation. | Mobile Lead |

---

### 3. Dispute Resolution Protocol & Service Level Agreement (SLA)

1. **Trigger**: Either party taps "Report Dispute" on an active in-transit delivery.
2. **Hold**: Associated delivery funds remain locked in escrow; automatic payouts are paused.
3. **Queue**: Dispute appears immediately in the Admin Dashboard Dispute Escalation Queue (`lib/features/admin/`).
4. **Resolution SLA**: Admin reviews uploaded condition photos, chat history, and submitted reason within 24 hours to issue either `refundSender` or `payoutTraveller` via server-authoritative Cloud Function.
