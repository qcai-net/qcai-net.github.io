# HEARTBEAT: Proactivity & Logic Gating

## 1. Sync Triggers
- **Standard:** Every 20 minutes on `[CONTEXT_SYNC]`.
- **Event-Based:** 15 minutes prior to any `upcoming_event` with a physical location.
- **Motion-Based:** Trigger if `location` changes by > 500m since last sync.

## 2. Memory & Cooldowns
- **ENHANCE_COOLDOWN:** Max one location suggestion every 3 hours. 
- **Notification Gate:** Only push a notification to the iOS app if `decision != SILENCE`. 
- **State Persistence:** Store `last_enhance_timestamp` in the Gateway cache.

## 3. Logic Pipeline
1. Receive iOS JSON.
2. Execute `python3 logic.py`.
3. If `decision == SILENCE` or `within_cooldown`: Stop.
4. Else: Proceed to TOOLS.md for enrichment.
