const fs = require('fs');

/**
 * QCAI Decision Engine (Node.js)
 * Processes sensor JSON data and returns high-agency decisions.
 */
function calculate() {
    try {
        const input = fs.readFileSync(0, 'utf-8');
        const data = JSON.parse(input);
        
        const state = data.user_state || {};
        const stress = state.stress_score || 0.5;
        const distracted = (state.attention && state.attention.mode === "DISTRACTED");

        // Logic Gating: High stress or distraction triggers ALIGN
        if (stress > 0.75 || distracted) {
            console.log(JSON.stringify({ decision: "ALIGN", gap: 999 }));
        } else {
            console.log(JSON.stringify({ decision: "SILENCE", gap: 0 }));
        }
    } catch (e) {
        console.log(JSON.stringify({ decision: "SILENCE", gap: 0 }));
    }
}

calculate();
