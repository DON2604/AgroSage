# 🌾 AgroSage – AI-Powered Agricultural Advisory System

AgriSmart is an intelligent, end-to-end agricultural advisory system designed to empower farmers with real-time, data-driven insights. Built with Flask and powered by advanced AI agents and Large Language Models (LLMs), the platform automates decision-making across key agricultural domains—weather, sustainability, market trends, water usage, and carbon footprint.

---

## 🚀 Project Goals

- Automate and enhance traditional advisory roles like **Farmer Advisor** and **Market Researcher**
- Enable **data-backed crop decisions** and **eco-friendly farming**
- Provide **real-time, AI-generated recommendations** from multiple domains

---

## 🧠 How It Works
![wirefr](https://github.com/user-attachments/assets/fd7ccdde-b461-4ca3-bc8b-ec12aed2c03f)

1. **User Requests**  
   Farmers or systems send queries through REST API endpoints (e.g., `/sustainability`, `/market_trends`).

2. **AI Agent Activation**  
   Each request is routed to a specialized AI agent responsible for that domain.

3. **Data Processing**  
   - Agents use SQLite databases, real-time web searches, and LangChain LLMs.
   - Insights are generated, cleaned, and formatted by the `DecisionAgent`.

4. **Response Delivery**  
   Structured insights are returned to the user in JSON format for easy integration with frontends or dashboards.

---

## 🧩 Features

- 🌦 **Weather Agent** – Retrieves and processes weather data for crop planning  
- 🌱 **Sustainability Agent** – Evaluates crop sustainability and compares top alternatives  
- 💧 **Water Usage Agent** – Analyzes water use and recommends conservation strategies  
- ♻️ **Carbon Footprint Agent** – Estimates emissions and suggests reduction tactics  
- 📈 **Market Trend Agent** – Forecasts demand, pricing, and profitability  
- 🧠 **DecisionAgent** – Cleans, formats, and stores insights with memory support  
- 🗃️ **Persistent Memory (SQLite)** – Stores past insights for smarter future responses  
- 🔍 **Web Data Integration** – Uses DuckDuckGo Search to stay current with agri-trends  
- 🧩 **Modular & Scalable** – Plug-and-play AI agents built with LangChain

---

## 🏗️ Project Structure

```
don2604-accenture_hack/
├── backend/
│   ├── main.py                     # Entry point: defines API endpoints
│   ├── agents/                     # Domain-specific AI agents
│   ├── modules/                    # Utility modules like memory & fetchers
│   ├── db/                         # SQLite databases and init scripts
│   ├── data/                       # CSV datasets for advisory & market insights
│   └── requirements.txt            # Python dependencies
├── frontend/                       # (Optional) Placeholder for frontend app
├── docs/                           # Documentation files
└── .github/workflows/              # GitHub Actions for CI/CD
```

---

## 🛠️ Tech Stack

- **Backend**: Python + Flask  
- **AI Framework**: LangChain  
- **LLMs**: LLaMA3-70B, Qwen 2.5 (via Groq API)  
- **Database**: SQLite  
- **Web Scraping**: DuckDuckGoSearchRun  
- **Dataflow**: RunnableParallel, PromptTemplates, SQLDatabaseChain  

---

## 📦 Installation

```bash
git clone https://github.com/DON2604/don2604-accenture_hack.git
cd don2604-accenture_hack/backend
pip install -r requirements.txt
python main.py
```

---

## 📡 API Endpoints

- `/weather` – Get weather-based crop recommendations  
- `/sustainability` – Analyze and compare crop sustainability  
- `/market_trends` – View current market insights  
- `/carbon_footprint` – Understand and reduce emissions  
- `/water_usage` – Optimize water usage for selected crops  

---

## 📈 Impact & Benefits

✅ Reduces dependency on manual advisors  
✅ Helps farmers make profitable, sustainable choices  
✅ Promotes water conservation and eco-farming  
✅ Keeps farmers up-to-date with real-time agri-trends  
✅ Scalable and adaptable for smart farming platforms

---

## 👨‍🌾 Built For

- Farmers and agri-entrepreneurs  
- AgriTech platforms  
- Smart farming initiatives  
- Research and policy applications  

---

## 🤝 Contributors

- [@DON2604](https://github.com/DON2604)
- [@Nidhi Sikder](https://github.com/nidhisikder)
- Built for Accenture Hackathon 2025

---

## 📜 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
