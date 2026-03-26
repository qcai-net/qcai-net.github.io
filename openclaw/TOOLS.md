# TOOLS: Execution & Enrichment

## 1. Momentum Engine (Internal)
- **Tool:** `python3 logic.py`
- **Input:** Full `user_state` + `temporal_intelligence` JSON.
- **Output:** `{decision: "PROTECT/ALIGN/ENHANCE/SILENCE", gap: min}`.

## 2. Discovery Tool (External)
- **Trigger:** Only if `decision == ENHANCE`.
- **Action:** `google_places_search`
- **Params:** - `query`: "quiet cafe" OR "park" OR "library" (based on weather).
    - `radius`: 0.5 miles from `current_location`.
- **Filtering:** Pick the TOP result with a "Quiet" or "Wi-Fi" tag.

## 3. Return Safety Check (Calculated)
- **Formula:** `Usable_Time = gap_min - (travel_time * 2) - 15`.
- **Constraint:** If `Usable_Time < 20`, downgrade to `SILENCE`. 

## 4. Response Synthesis
- Combine `decision` + `Discovery_Result` + `SOUL_Tone`.
- **Example ENHANCE:** "You've got a clean window before that webinar. 7th Street Market is a 3-min walk—better spot to reset than the lobby."
- **Example ALIGN:** "You're redlining. Skip the next task and take 5 minutes to reset before your 4 PM."
