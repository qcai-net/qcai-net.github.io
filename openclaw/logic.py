import sys
import json
from datetime import datetime

def calculate():
    try:
        # Read from stdin
        input_data = sys.stdin.read()
        data = json.loads(input_data)
        
        # --- 1. State Extraction ---
        state = data.get("user_state", {})
        stress = state.get("stress_score", 0.5)
        distracted = (state.get("attention", {}).get("mode") == "DISTRACTED")
        
        # --- 2. Logic Gating ---
        if stress > 0.75 or distracted:
            out("ALIGN", 999)
        else:
            out("SILENCE", 0)
            
    except Exception as e:
        out("SILENCE", 0)

def out(decision, gap):
    print(json.dumps({"decision": decision, "gap": gap}))

if __name__ == "__main__":
    calculate()
