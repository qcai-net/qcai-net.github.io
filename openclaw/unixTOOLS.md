# TOOLS: Momentum Execution (Unix)

## 1. Momentum Engine (Internal)
- **Engine Path:** `~/.openclaw/skills/momentum/logic.js`
- **Command:** `node ~/.openclaw/skills/momentum/logic.js`
- **Input:** Standard Input (stdin) redirected from the iOS JSON sync.

## 2. Discovery Tools (External)
- **Trigger:** Only if `logic.js` returns `{"decision": "ALIGN"}` or `{"decision": "ENHANCE"}`.
- **Action A (Search):** `node ~/.openclaw/skills/momentum/search.js`
- **Action B (Maps):** `google_places_search` (using `goplaces` skill)

## 3. Return Safety Check (Calculated)
- **Formula:** `Remaining_Time = gap_min - (travel_time * 2) - 15`
- **Constraint:** If `Remaining_Time < 20`, force `decision = "SILENCE"`.

## 4. Response Synthesis
- **Format:** Combine `logic_result` + `place_result` + `SOUL_Tone`.
- **Constraint:** No lists. Single opinionated sentence. Max 200 characters.
- **Delivery:** Push final response back to iOS app via Gateway session.
