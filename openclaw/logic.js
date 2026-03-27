const fs = require('fs');

function calculate() {
    try {
        const input = fs.readFileSync(0, 'utf-8');
        const data = JSON.parse(input);
        
        // --- 1. Temporal & Event Awareness ---
        const now = new Date(data.metadata.current_timestamp);
        const events = (data.temporal_intelligence && data.temporal_intelligence.upcoming_events) || [];
        let gapMin = 999;
        let isRemote = true;
        let isLowEffort = false;

        if (events.length > 0) {
            const e = events[0];
            const start = new Date(e.start_date);
            gapMin = (start - now) / 1000 / 60;
            const loc = (e.location || "").toLowerCase();
            const title = (e.title || "").toLowerCase();
            
            isRemote = ["http", "zoom", "teams"].some(k => loc.includes(k));
            isLowEffort = ["webinar", "lecture", "sync", "listen"].some(k => title.includes(k));
        }

        // --- 2. State Extraction ---
        const state = data.user_state || {};
        const stress = state.stress_score || 0.5;
        const distracted = (state.attention && state.attention.mode === "DISTRACTED");
        const battery = (state.device && state.device.battery_level) || 1.0;

        // --- 3. The Priority Stack ---
        if (gapMin < 20) {
            return out("PROTECT", gapMin);
        }

        if ((distracted && stress > 0.5) || stress > 0.75) {
            return out("ALIGN", gapMin);
        }

        // --- 4. Enhanced Confidence Scoring ---
        let conf = 0.0;
        if (gapMin > 60) conf += 0.4;
        if (isRemote) conf += 0.2;
        if (isLowEffort) conf += 0.1;
        if (stress < 0.5) conf += 0.2;
        if (battery > 0.3) conf += 0.1;

        if (conf >= 0.8) {
            return out("ENHANCE", gapMin);
        }

        return out("SILENCE", gapMin);
    } catch (e) {
        return out("SILENCE", 0);
    }
}

function out(decision, gap) {
    console.log(JSON.stringify({ decision, gap }));
}

calculate();
