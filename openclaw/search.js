/**
 * QCAI Discovery Tool: Perplexity Search (Node.js)
 */
const apiKey = process.env.PERPLEXITY_API_KEY;
const query = process.argv.slice(2).join(' ') || "quiet cafes nearby";

async function search() {
    if (!apiKey) {
        console.error("Error: PERPLEXITY_API_KEY not found in environment.");
        return;
    }

    try {
        const response = await fetch("https://api.perplexity.ai/chat/completions", {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${apiKey}`,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                model: "sonar",
                messages: [
                    { role: "system", content: "You are a high-agency agent. Provide a single, concise recommendation based on search results." },
                    { role: "user", content: query }
                ]
            })
        });
        const data = await response.json();
        console.log(data.choices[0].message.content);
    } catch (e) {
        console.error("Search failed:", e.message);
    }
}

search();
