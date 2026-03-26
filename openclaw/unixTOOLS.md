# TOOLS: Momentum Execution (Linux/macOS)

## 1. Momentum Engine (Internal)
- **Engine Path:** `./logic.py`
- **Command:** `cat input.json | python3 logic.py` 
- **Instruction:** Use `python3` (Unix standard) to execute the logic script.
- **Input:** Standard Input (stdin) piped from the iOS JSON sync.

## 2. Discovery Tool (External)
- **Trigger:** Only if `logic.py` returns `{"decision": "ENHANCE"}`.
- **Action:** `google_places_search`
- **Parameters:** - `query`: "quiet cafe" OR "park" OR "library"
    - `location`: `current_location` from incoming JSON
    - `radius`: 800 (meters)

## 3. Return Safety Check (Calculated)
- **Formula:** `Remaining_Time = gap_min - (travel_time * 2) - 15`
- **Constraint:** If `Remaining_Time < 20`, force `decision = "SILENCE"`.

## 4. Response Synthesis
- **Format:** Combine `logic_result` + `place_result` + `SOUL_Tone`.
- **Constraint:** One opinionated sentence. No lists. Max 200 chars.
