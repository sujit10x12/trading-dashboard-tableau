
# 📈 Trading Dashboard in Tableau  
<img width="1584" height="396" alt="banner" src="/images/banner.png" />

---

## 🏢 **Organization**
**CFI Capital Partners** — *An investment bank specializing in trading U.S. stocks.*

**👨‍💼 Role:** Business Intelligence Analyst  
**🧭 Project Lead:** Kurt — Head of Sales & Trading  

---

## 🎯 **Objective**
As a **Business Intelligence Analyst** at **CFI Capital Partners**, I designed a **Trading Dashboard in Tableau** for the **Sales & Trading Team**.  
The goal was to create a **proof of concept** connecting Tableau to live trading data, showcasing **advanced visualization techniques**, and delivering **real-time market insights**.

---

## 📋 **Project Requirements**

**Requested by:** Kurt – Head of Sales & Trading  

### 🔌 Data & Connectivity  
- Connect Tableau to the **test trading database**  
- Extract **historical** and **intraday** stock prices using **SQL queries**

### 📊 Dashboard Features  
Showcase Tableau’s advanced capabilities through:  
- 📉 **Candlestick Chart**  
- 📊 **Dynamic Bollinger Bands**  
- 📈 **Volume Chart**  
- 🔺 **Previous Volume High Indicator**  
- 🌱 **Relative Growth Chart**  
- 📋 **Total Growth Table Slicer**  
- ⚙️ **Dynamic View Period & Ticker Selection**

---

## 🧠 **Interactive Features**
Enhancing user experience with dynamic Tableau features:
- 🪟 **Pop-up Containers** for:
  - Industry & Ticker Treemap  
  - Ticker Response News Feed  
- 🎛️ **Parameter Actions** for dynamic control  
- 🔥 **Heat Table as a Slicer** to filter and update related visuals  

---

## 🧩 **Case Study Approach**

| Step | Description |
|------|--------------|
| **1. Pull Historical Prices** | Connect to the database and import historical stock data into Tableau. |
| **2. Pull Intraday Prices** | Load live/intraday trading data for real-time monitoring. |
| **3. Create Visuals for Historical Data** | Build candlestick charts, Bollinger bands, and growth visuals. |
| **4. Create Visuals for Intraday Data** | Develop volume, growth, and ticker-based visuals for real-time analysis. |

---

## 🗃️ **Entity Relationship Diagram (ERD)**
> *(Visual representation of the database structure used for the dashboard)*  
> <img width="1045" height="407" alt="erd" src="/images/erd.png" />

---

## 🧮 **SQL Queries**

### 🔹 Historical Prices View
```sql
CREATE VIEW vHistoricalPricesReporting AS
SELECT 
    hist.FactID,
    hist.[Date],
    hist.[Open],
    hist.High,
    hist.Low,
    hist.[Close],
    hist.AdjClose,
    hist.Volume,
    sec.Company,
    sec.Symbol,
    sec.Industry,
    sec.IndexWeighting,
    exc.Symbol AS Exchange
FROM
    FactPrices_Daily AS hist 
    INNER JOIN dimSecurity AS sec ON hist.SecurityID = sec.ID 
    INNER JOIN dimExchange AS exc ON sec.ExchangeID = exc.ID
GO
```

### 🔹 Intraday Prices View
```sql
CREATE VIEW vIntraDayPricesReporting AS
SELECT
    attr.FactID,
    attr.[DateTime],
    attr.LastBid,
    attr.High,
    attr.Low,
    attr.[Open],
    attr.Volume,
    attr.Beta,
    sec.Company,
    sec.Symbol,
    exc.Symbol AS Exchange
FROM
    FactAttributes_Intraday attr
    JOIN dimSecurity AS sec ON attr.SecurityID = sec.ID
    JOIN dimExchange AS exc ON sec.ExchangeID = exc.ID
GO        
```

> ⚙️ **Note:**  
> Tableau Public (Free Version) doesn’t support direct connections to SQL Server.  
> To work around this, I connected **Excel to SQL Server**, imported the SQL views, and then used the Excel files as Tableau data sources.

---

## 🧩 **Key Tableau Calculations**

Here are the **core calculated fields** that made the dashboard dynamic, responsive, and visually powerful.

## 🕯️ Candlestick Chart

<img width="1875" height="1201" alt="Candlestick" src="/images/candlestick.png" />

---
| Calculation | Formula | Purpose |
|--------------|----------|----------|
| **RangeOpenClose** | `SUM([Close]) - SUM([Open])` | Defines candle body size |
| **RangeLowHigh** | `SUM([High]) - SUM([Low])` | Defines wick (shadow) size |
| **OpenCloseIncrease** | `[RangeOpenClose] > 0` | Identifies bullish (true) or bearish (false) candle color |
| **MaxDateContext** | `{MAX([Date])}` | Captures the most recent date in the dataset |
| **FirstDateVisible** | `[MaxDateContext] - ([View Period] - 1)` | Calculates first date of visible range |
| **DateFilter** | `[Date] >= [FirstDateVisible]` | Filters data for selected view period |

---

## 📈 Bollinger Bands

<img width="1875" height="1201" alt="Candlestick" src="/images/bollinger.png" />

---
| Calculation | Formula | Purpose |
|--------------|----------|----------|
| **CloseMA** | `WINDOW_AVG(SUM([Close]), -19, 0)` | 20-day moving average of close price |
| **CloseSD** | `WINDOW_STDEV(SUM([Close]), -([Lookback Period (MA)]-1), 0)` | Rolling standard deviation of close price |
| **BollingerUpper** | `[CloseMA] + [# of STDEV]*[CloseSD]` | Upper Bollinger Band |
| **BollingerLower** | `[CloseMA] - [# of STDEV]*[CloseSD]` | Lower Bollinger Band |
| **DateVisibility** | `LOOKUP(MAX([Date]) >= MAX([FirstDateVisible]),0)` | Ensures proper date filtering in chart |

**Color Code for Breakouts**
```text
IF SUM([Close]) > [Bollinger Upper] THEN 'UP'
ELSEIF SUM([Close]) < [Bollinger Lower] THEN 'DOWN'
ELSE 'NO'
END
```

---

## 📊 Traded Volume
| Calculation | Formula | Purpose |
|--------------|----------|----------|
| **CountPreviousDays** | `RUNNING_SUM([CountDays]) - 1` | Counts elapsed trading days |
| **PreviousVolumeHigh** | `WINDOW_MAX(SUM([Volume]), -[CountPreviousDays], 0)` | Detects highest volume over previous days |

---

## 📈 Relative Growth

<img width="1875" height="1201" alt="Candlestick" src="/images/pctgrowth.png" />

---
| Calculation | Formula | Purpose |
|--------------|----------|----------|
| **CloseOnFirstDateVisible** | `WINDOW_MAX(IF MAX([Date]) = WINDOW_MIN(MIN([Date])) THEN SUM([Close]) END)` | Captures the first visible close price |
| **%Growth** | `(SUM([Close]) - [CloseOnFirstDateVisible]) / [CloseOnFirstDateVisible]` | Calculates growth relative to first visible date |
| **Ticker Is Selected** | `[Symbol] = [Ticker Selection]` | Highlights selected ticker dynamically |

---

## 🔥 Total Growth Heat Table

<img width="1875" height="1201" alt="Candlestick" src="/images/heatmap.png" />

---
| Calculation | Formula | Purpose |
|--------------|----------|----------|
| **CloseOnMaxDateContext** | `SUM(IF [Date] = [MaxDateContext] THEN [Close] END)` | Latest close price |
| **MinDateContext** | `{MIN([Date])}` | First available date in dataset |
| **CloseOnMinDateContext** | `SUM(IF [Date] = [MinDateContext] THEN [Close] END)` | First close price |
| **%GrowthTotal** | `([CloseOnMaxDateContext] - [CloseOnMinDateContext]) / [CloseOnMinDateContext]` | Total growth over the entire date range |

---

## 🕒 Intraday Summary Measures
| Metric | Formula | Description |
|---------|----------|-------------|
| **MinDateTime** | `{MIN([Date Time])}` | Captures earliest intraday record |
| **MaxDateTime** | `{MAX([Date Time])}` | Captures latest intraday record |
| **Beta (5Y Monthly)** | `SUM(IF [Date Time] = [MaxDateTime] THEN [Beta] END)` | Latest Beta value |
| **Latest Bid** | `SUM(IF [Date Time] = [MaxDateTime] THEN [Last Bid] END)` | Most recent bid price |
| **Market Cap (MM)** | `SUM(IF [Date Time] = [MaxDateTime] THEN [Market Cap] END)` | Latest market capitalization |
| **Today’s High** | `{MAX([High])}` | Current day’s highest price |
| **Today’s Low** | `{MIN([Low])}` | Current day’s lowest price |
| **Today’s Open** | `SUM(IF [Date Time] = [MinDateTime] THEN [Open] END)` | Opening price of the day |

---

## 🪄 **Treemap Calculations & Data Blending**

<img width="1875" height="1201" alt="Candlestick" src="/images/treemap.png" />

---
Both datasets were used separately due to **different grains**:
- **Historical Prices:** Ticker Price by *Day*  
- **Intraday Prices:** Ticker Price by *Minute*

Since Tableau Public doesn’t allow joining these directly, **Data Blending** was used to integrate both datasets within the dashboard.

---

## 📸 **Dashboard Preview**

<img width="1584" height="396" alt="dashboard-preview" src="/images/dashboard1.png" />

---

<img width="1584" height="396" alt="dashboard-preview" src="/images/dashboard2.png" />

---

### 🧭 **Interactive Features**
- Filter tickers directly from the **Heat Table**
- Hover over candlestick bars for **price + volume tooltips**
- Adjust **View Period** dynamically via a **parameter control**
- Watch **Bollinger Band breakouts** and **relative growth** update instantly

---

## 🌐 Live Dashboards

- 🌍 **[Trading Dashboard](https://public.tableau.com/shared/R97WXKBDZ?:display_count=n&:origin=viz_share_link)**

---


## 🚀 **Result**
✅ Built a **fully interactive Tableau Trading Dashboard** combining historical and real-time data.  
✅ Implemented **advanced analytics** like Bollinger Bands, growth calculations, and dynamic filtering.  
✅ Delivered a **proof of concept** to demonstrate Tableau’s potential in **equity trading analytics**.

---

## 🧰 **Tech Stack**
- **Tools:** Tableau, Excel, SQL Server  
- **Skills:** Data Modeling, Data Blending, Advanced Tableau Calculations, Parameter Actions, Interactive Visualization  

--- 
