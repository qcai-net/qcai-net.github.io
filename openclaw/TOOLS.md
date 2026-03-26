# TOOLS: Momentum Execution (Windows)

## 1. Momentum Engine (Internal)
- **Engine Path:** `.\logic.py`
- **Command:** `type input.json | python logic.py` 
- **Instruction:** Use `python` (standard Windows alias) to execute the logic script.
- **Input:** Standard Input (stdin) redirected from the iOS JSON sync.

## 2. Discovery Tool (External)
- **Trigger:** Only if `logic.py` returns `{"decision": "ENHANCE"}`.
- **Action:** `google_places_search`
- **Parameters:** - `query`: "quiet cafe" OR "park" OR "library"
    - `location`: `current_location` from JSON
    - `radius`: 800 (meters)

## 3. Return Safety Check (Calculated)
- **Formula:** `Remaining_Time = gap_min - (travel_time * 2) - 15`
- **Constraint:** If `Remaining_Time < 20`, force `decision = "SILENCE"`.

## 4. Response Synthesis
- **Format:** Combine `logic_result` + `place_result` + `SOUL_Tone`.
- **Constraint:** No lists. Single opinionated sentence. Max 200 chars.
