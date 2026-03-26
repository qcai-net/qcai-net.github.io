import sys, json
from datetime import datetime

def calculate():
    try:
        data = json.load(sys.stdin)
        now = datetime.fromisoformat(data["metadata"]["current_timestamp"].replace("Z",""))
        
        # --- 1. Temporal & Event Awareness ---
        events = data.get("temporal_intelligence", {}).get("upcoming_events", [])
        gap_min, is_remote, is_low_effort = 999, True, False

        if events:
            e = events[0]
            start = datetime.fromisoformat(e["start_date"].replace("Z",""))
            gap_min = (start - now).total_seconds() / 60
            loc = e.get("location", "").lower()
            title = e.get("title", "").lower()
            
            is_remote = any(k in loc for k in ["http", "zoom", "teams"])
            # New: Awareness of event 'weight'
            is_low_effort = any(k in title for k in ["webinar", "lecture", "sync", "listen"])

        # --- 2. State Extraction ---
        state = data.get("user_state", {})
        stress = state.get("stress_score", 0.5)
        distracted = state.get("attention", {}).get("mode") == "DISTRACTED"
        battery = state.get("device", {}).get("battery_level", 1.0)

        # --- 3. The Priority Stack ---
        if gap_min < 20:
            return out("PROTECT", gap_min)

        if (distracted and stress > 0.5) or stress > 0.75:
            return out("ALIGN", gap_min)

        # --- 4. Enhanced Confidence Scoring ---
        conf = 0.0
        if gap_min > 60: conf += 0.4
        if is_remote:   conf += 0.2
        if is_low_effort: conf += 0.1 # Boost for low-stakes meetings
        if stress < 0.5: conf += 0.2
        if battery > 0.3: conf += 0.1

        if conf >= 0.8:
            return out("ENHANCE", gap_min)

        return out("SILENCE", gap_min)
    except:
        return out("SILENCE", 0)

def out(decision, gap):
    print(json.dumps({"decision": decision, "gap": gap}))

if __name__ == "__main__":
    calculate()
