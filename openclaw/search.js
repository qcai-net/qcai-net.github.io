const apiKey = process.env.PERPLEXITY_API_KEY || "YOUR_PERPLEXITY_KEY";
const query = process.argv.slice(2).join(' ') || "quiet cafes nearby";

async function search() {
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
                    { role: "system", content: "Summarize search results for a high-agency agent. Be concise." },
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
