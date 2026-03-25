import{r as c,j as e}from"./index-CDnMNBoT.js";import{a as A,b as g}from"./aiService-jtlWA29D.js";const m=4326;async function I(s){const a=`https://gis.charlottenc.gov/arcgis/rest/services/Geocoding/AddressLocator/GeocodeServer/findAddressCandidates?Street=${encodeURIComponent(s)}&City=Charlotte&State=NC&outSR=${m}&f=json`;try{return((await g.get(a)).data?.candidates||[])[0]||null}catch{return null}}async function C(s,t){const a=`https://gis.charlottenc.gov/arcgis/rest/services/CountyData/Parcels/FeatureServer/0/query?geometry=${s},${t}&geometryType=esriGeometryPoint&inSR=${m}&spatialRel=esriSpatialRelIntersects&outFields=*&f=json`;try{return(await g.get(a)).data?.features?.[0]?.attributes||null}catch{return null}}async function b(s,t){const a=`https://gis.charlottenc.gov/arcgis/rest/services/CountyData/SchoolAttendance/FeatureServer/0/query?geometry=${s},${t}&geometryType=esriGeometryPoint&inSR=${m}&spatialRel=esriSpatialRelIntersects&outFields=*&f=json`;try{return(await g.get(a)).data?.features?.[0]?.attributes||null}catch{return null}}function R(s){if(!s)return`No official parcel record found.
`;let t="";const a=s.OWNER_NAME||s.OWN_NAME||s.NAME||s.LEGAL_OWNER;return a&&(t+=`- Owner: ${a}
`),s.PIN&&(t+=`- Parcel ID (PIN): ${s.PIN}
`),s.TOTAL_VALUE&&(t+=`- Assessed Value: $${s.TOTAL_VALUE.toLocaleString()}
`),s.YEAR_BUILT&&(t+=`- Year Built: ${s.YEAR_BUILT}
`),s.ZONING&&(t+=`- Zoning: ${s.ZONING}
`),s.LANDUSE&&(t+=`- Land Use: ${s.LANDUSE}
`),t||`Parcel found but no detailed attributes.
`}function E(s){return s?Object.entries(s).filter(([,t])=>t&&t!=="N/A").map(([t,a])=>`- ${t}: ${a}`).join(`
`)+`
`:`School zone info not found.
`}const G=()=>{const[s,t]=c.useState(""),[a,r]=c.useState(null),[i,f]=c.useState(!1),[p,o]=c.useState(""),S=async d=>{if(d.preventDefault(),!!s.trim()){f(!0),r(null),o("🔍 Geocoding address...");try{const l=await I(s);let n=`
【OFFICIAL MECKLENBURG COUNTY GIS DATA】
Source: charlottenc.gov
`;if(l){const{x:u,y:h}=l.location;n+=`Coordinates: ${u}, ${h}
`,o("📦 Fetching parcel & school data...");const[v,j]=await Promise.all([C(u,h),b(u,h)]);n+=`
[Property Details]
`+R(v),n+=`
[School & Zone Info]
`+E(j),n+=`
INSTRUCTIONS: Use the above OFFICIAL values to populate the required fields (Owner, Value, Year, Schools). Do not hallucinate different values if these are present.
`}else n+=`
Note: Could not geocode this address via Mecklenburg GIS. Address may be outside Charlotte/Mecklenburg County.
`;o("🤖 Generating AI report...");const N=`Provide a comprehensive real‑estate analysis for the address "${s}". Include estimated market value, rent ranges for 1BR/2BR, school zone information, key neighborhood factors, and any relevant GIS data.`,x=`You are a real estate expert for Charlotte, NC with access to official county records.
${n}
USER REQUEST: ${N}
Use the official GIS data above to ground your response. Be specific, data-driven, and concise.`,y=await A.queryChat({question:s,topic:"real_estate",language:"en",customPrompt:x});r(y.answer?.split("MATCH_SCORE_JSON")[0]?.trim()||y.answer),o("")}catch(l){console.error("Real Estate Analysis Error:",l),r("Unable to generate report. Please check the address and try again."),o("")}finally{f(!1)}}};return e.jsxs("div",{className:"real-estate-container animate-fade-in",children:[e.jsxs("header",{className:"re-header",children:[e.jsx("h1",{children:"Property Analyst"}),e.jsx("p",{className:"subtitle",children:"AI-powered neighborhood valuation & ROI — grounded in Mecklenburg County GIS data"})]}),e.jsxs("section",{className:"re-search-card glass",children:[e.jsx("p",{className:"re-description",children:"Enter an address to get a comprehensive real‑estate analysis, including valuation, rent estimates, school zones, and neighborhood insights."}),e.jsxs("form",{onSubmit:S,children:[e.jsxs("div",{className:"input-group",children:[e.jsx("span",{className:"icon",children:"📍"}),e.jsx("input",{type:"text",placeholder:"Street, City, State... (e.g. 123 Main St, Charlotte, NC)",value:s,onChange:d=>t(d.target.value)})]}),e.jsx("button",{type:"submit",disabled:i,className:"primary-btn",children:e.jsxs("div",{className:"btn-content",children:[i?e.jsx("span",{className:"spinner"}):null,i?p||"Analyzing...":"Start Deep Analysis"]})})]})]}),a&&e.jsxs("article",{className:"analysis-report glass animate-slide-up",children:[e.jsxs("div",{className:"report-header",children:[e.jsx("span",{className:"icon",children:"📝"}),e.jsx("h2",{children:"Analysis Report"})]}),e.jsx("div",{className:"report-body",children:e.jsx("p",{children:a})}),e.jsx("div",{className:"disclaimer",children:"* Property data sourced from Mecklenburg County GIS. AI analysis should be verified with a local real estate professional."})]}),e.jsxs("section",{className:"re-guidelines",children:[e.jsx("h3",{children:"Market Factors"}),e.jsxs("div",{className:"guideline-grid",children:[e.jsxs("div",{className:"guide-item glass",children:[e.jsx("h4",{children:"Walk Score"}),e.jsx("p",{children:"High impact on urban rent premiums."})]}),e.jsxs("div",{className:"guide-item glass",children:[e.jsx("h4",{children:"School Zones"}),e.jsx("p",{children:"Primary driver for long-term value."})]}),e.jsxs("div",{className:"guide-item glass",children:[e.jsx("h4",{children:"Transit Pulse"}),e.jsx("p",{children:"Correlates with future development growth."})]})]})]})]})};export{G as default};
