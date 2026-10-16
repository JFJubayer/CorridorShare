# Software Quality Assurance Plan (SQAP)
## CorridorShare — Quality Engineering and Verification Specification

**Standard**: IEEE Std 730-2014  
**Subproject**: `corridorshare/`  
**Team**: Fahmid Hasan Taohid, JFJubayer, Fahim Abir  
**Course**: CSE-3102 Software Engineering  
**Version**: 1.0.0  
**Date**: 2026-10-13  

---

### 1. Purpose and Scope
This document defines the quality assurance standards, verification methodologies, and metrics enforced across the CorridorShare codebase. It guarantees that all deliverables satisfy functional requirements (FR1–FR17), adhere to architectural constraints, and achieve zero static analyzer defects.

---

### 2. Quality Metrics and Quality Gates

| Metric | Target Standard | Measured Result | Status |
|:---|:---:|:---:|:---:|
| **Static Analyzer Defects** | 0 warnings, 0 errors | 0 warnings, 0 errors | **PASS** |
| **Domain Layer Line Coverage** | $\ge 80.0\%$ | **91.89%** (306/333 lines) | **PASS** |
| **Overall Test Pass Rate** | 100% | 100% (119/119 unit & widget tests) | **PASS** |
| **Basis Path Coverage (Complex Functions)** | 100% | 100% of basis paths tested | **PASS** |
| **Bilingual Localizations** | 100% user-facing strings | 100% (0 hardcoded UI strings) | **PASS** |
| **CI Automation Gate** | Automated lint & test on push/PR | Enforced via `.github/workflows/corridorshare-ci.yml` | **PASS** |

---

### 3. White-Box Testing & Cyclomatic Complexity

#### 3.1 McCabe's Cyclomatic Complexity & Basis Path Analysis

McCabe's formula:
$$V(G) = P + 1$$
Where $P$ is the number of predicate (decision) nodes in the control flow graph.

1. **`hasNoCarryCollision`** (`matching/domain/entities/match_check.dart`):
   - Decision Predicates ($P$): 6
   - Cyclomatic Complexity: $V(G) = 6 + 1 = 7$
   - Independent Basis Paths: 4
   - Coverage: 100% validated across `match_check_test.dart`.

2. **`ParcelStatus.canTransitionTo`** (`parcels/domain/entities/parcel_status.dart`):
   - Decision Predicates ($P$): 9
   - Cyclomatic Complexity: $V(G) = 9 + 1 = 10$
   - Independent Basis Paths: 10 (identity, 4 valid forward paths, 4 invalid illegal skips, 1 terminal)
   - Coverage: 100% validated across `parcel_status_test.dart`.

3. **`InMemoryWalletDataSource.holdEscrow`** (`wallet/data/datasources/in_memory_wallet_datasource.dart`):
   - Decision Predicates ($P$): 1
   - Cyclomatic Complexity: $V(G) = 1 + 1 = 2$
   - Independent Basis Paths: 2 (insufficient balance throws `ValidationFailure`, sufficient balance locks funds)
   - Coverage: 100% validated across `wallet_usecases_test.dart`.

---

### 4. Black-Box Equivalence Partitioning & Boundary Value Analysis (BVA)

| Input Domain | Equivalence Classes | Boundary Values Tested | Outcome |
|:---|:---|:---|:---:|
| **Reward Price (BDT)** | Valid: $> 0$<br>Invalid: $\le 0$ | $0.00$ (Rejected), $0.01$ (Accepted), $-50.0$ (Rejected) | **PASS** |
| **Parcel Weight (kg)** | Valid: $0 < w \le \text{Capacity}$<br>Invalid: $w \le 0$, $w > \text{Capacity}$ | $0.0$ (Rejected), $0.1$ (Accepted), Capacity (Accepted), Exceeded (Rejected) | **PASS** |
| **Handover PIN** | Valid: 4-digit exact match<br>Invalid: $\ne 4$ digits, mismatch, alpha | `'123'` (Rejected), `'12345'` (Rejected), `'9999'` (Mismatch rejected), `'4821'` (Match accepted) | **PASS** |
| **Wallet Top-Up (BDT)** | Valid: $0 < x \le 50,000$<br>Invalid: $\le 0$, $> 50,000$ | $0$ (Rejected), $1$ (Accepted), $50,000$ (Accepted), $50,001$ (Rejected) | **PASS** |

---

### 5. Automated CI/CD Pipeline
Continuous Integration is automated using GitHub Actions (`.github/workflows/corridorshare-ci.yml`):
- Triggers on all pushes and PRs touching `corridorshare/**`.
- Executes `flutter pub get`, `flutter analyze --fatal-infos`, and `flutter test --coverage`.
- Merging is blocked if any unit/widget test fails or static analyzer raises warnings.
