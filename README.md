
# 📈 Trading Dashboard in Tableau  
<img width="1584" height="396" alt="banner" src="/banner.png" />

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
> <img width="1045" height="407" alt="erd" src="https://github.com/user-attachments/assets/85e0da0a-fa94-4482-9083-1d8cd1ddff85" />

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

### 📉 Candlestick Chart
<img width="1584" height="396" alt="banner" src="/candlestick.png" />  
---
```text
RangeOpenClose = SUM([Close]) - SUM([Open])
RangeLowHigh = SUM([High]) - SUM([Low])
OpenCloseIncrease = [RangeOpenClose] > 0

MaxDateContext = {MAX([Date])}
FirstDateVisible = [MaxDateContext] - ([View Period] - 1)
DateFilter = [Date] >= [FirstDateVisible]
```

### 📊 Bollinger Bands
<img width="1584" height="396" alt="banner" src="/bollinger.png" />  
---
```text
CloseMA = WINDOW_AVG(SUM([Close]), -19, 0)
CloseSD = WINDOW_STDEV(SUM([Close]), -([Lookback Period (MA)]-1), 0)
BollingerUpper = [CloseMA] + [# of STDEV]*[CloseSD]
BollingerLower = [CloseMA] - [# of STDEV]*[CloseSD]

IF SUM([Close]) > [Bollinger Upper] THEN 'UP'
ELSEIF SUM([Close]) < [Bollinger Lower] THEN 'DOWN'
ELSE 'NO' END
```

### 📈 Traded Volume
```text
CountPreviousDays = RUNNING_SUM([CountDays]) - 1
PreviousVolumeHigh = WINDOW_MAX(SUM([Volume]), -[CountPreviousDays], 0)
```

### 🌱 Relative Growth
<img width="1584" height="396" alt="banner" src="/pctgrowth.png" />  
---
```text
CloseOnFirstDateVisible = WINDOW_MAX(
    IF MAX([Date]) = WINDOW_MIN(MIN([Date])) THEN SUM([Close]) END
)
%Growth = (SUM([Close]) - [CloseOnFirstDateVisible]) / [CloseOnFirstDateVisible]
Ticker Is Selected = [Symbol] = [Ticker Selection]
```

### 🔥 Total Growth Heat Table
<img width="1584" height="396" alt="banner" src="/heatmap.png" />  
---
```text
CloseOnMaxDateContext = SUM(IF [Date] = [MaxDateContext] THEN [Close] END)
MinDateContext = {MIN([Date])}
CloseOnMinDateContext = SUM(IF [Date] = [MinDateContext] THEN [Close] END)
%GrowthTotal = ([CloseOnMaxDateContext] - [CloseOnMinDateContext]) / [CloseOnMinDateContext]
```

### ⏱️ Intraday Summary Measures
```text
MinDateTime = {MIN([Date Time])}
MaxDateTime = {MAX([Date Time])}
Beta (5Y Monthly) = SUM(IF [Date Time] = [MaxDateTime] THEN [Beta] END)
Latest Bid = SUM(IF [Date Time] = [MaxDateTime] THEN [Last Bid] END)
Market Cap (MM) = SUM(IF [Date Time] = [MaxDateTime] THEN [Market Cap] END)
Today’s High = {MAX([High])}
Today’s Low = {MIN([Low])}
Today’s Open = SUM(IF [Date Time] = [MinDateTime] THEN [Open] END)
```

---

## 🪄 **Treemap Calculations & Data Blending**
<img width="1584" height="396" alt="banner" src="/treemap.png" />  
---
Both datasets were used separately due to **different grains**:
- **Historical Prices:** Ticker Price by *Day*  
- **Intraday Prices:** Ticker Price by *Minute*

Since Tableau Public doesn’t allow joining these directly, **Data Blending** was used to integrate both datasets within the dashboard.

---

---

## 📸 **Dashboard Preview**
<img width="1584" height="396" alt="dashboard-preview" src="/dashboard1.png" />
---
<img width="1584" height="396" alt="dashboard-preview" src="/dashboard2.png" />

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
