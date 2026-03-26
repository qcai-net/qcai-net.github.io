# TOOLS.md - Feature Logic & Priority v9.2

## 1. Priority Arbitration & Passive Hint Ranking
- **Primary Action:** ONE high-priority action button.
- **Passive Hint Gating:** Append ONE situational hint only if it adds awareness without redundancy. 
- **Hint Ranking:** 1. Battery (<15%) | 2. Time Disruption | 3. Environmental (Weather/Traffic).
- **Suppression:** No hints during `DEEP_WORK` or `SILENT_MODE`.

## 2. Transition Anticipation (Robust Logic)
- **Predictive Layer:** Pre-brief 10-15m before a state change.
- **Cancellation Rule:** Suppress/Cancel brief if:
  - User is already in motion (`activity` matches transition).
  - Meeting start time shifts.
  - Confidence < 0.7.

## 3. Tiered WOW Engine
- **Mini-WOW (P > 0.75):** Lightweight 2-step optimization.
- **Full WOW (P > 0.90):** Full afternoon restructuring proposal.
- **Rule:** Always present as a proposal. Respect the user's "Autonomy Preference" in the phrasing.

## 4. Long-Term Memory (Pattern Confidence)
- **Promotion Criteria:** Only promote a routine (e.g., "Gym at 17:30") if consistency > 70% over 10+ occurrences.
- **Decay:** Patterns not observed for 7 days are demoted to avoid "Stale Intelligence."
