# E-commerce Conversion Funnel & Cart Abandonment Analysis

**Where does an online store lose its customers, and which products should it fix first?**
An end-to-end analysis of real e-commerce clickstream data using **PostgreSQL, Excel and Power BI**.

![Dashboard preview](Images/overall_Funnel.png)

---

## 1. Business Problem

The Head of E-commerce at an online retailer notices that many visitors browse the store but few buy. They need to know where to focus their effort.

This project answers four questions:

1. Where in the funnel (view → add to cart → purchase) do we lose the most visitors?
2. Which product categories convert well, and which lose the most customers?
3. When do customers shop and buy (hour, weekday, week), and how long do they take to decide?
4. Which items get lots of traffic but few purchases, and how many extra purchases could fixing them bring?

---

## 2. Dataset

| Item | Details |
|---|---|
| **Name** | Retailrocket Recommender System Dataset |
| **Published by** | Retailrocket |
| **Source** | https://www.kaggle.com/retailrocket/ecommerce-dataset |
| **Type** | Real behavior data from an e-commerce website (values are anonymized) |
| **Period** | About 4.5 months |
| **Size** | About 2.7 million events: views, add-to-carts and transactions |
| **Files used** | `events.csv`, `item_properties_part1.csv`, `item_properties_part2.csv`, `category_tree.csv` |

> The raw data is **not included** in this repository. Please download it from the link above and check the license on that page before reusing it.

---

## 3. Tools Used

- **PostgreSQL**: data loading, cleaning, funnel metrics, window functions, CTEs
- **Excel**: reconciliation checks (pivot tables) and a what-if uplift model
- **Power BI**: 4-page interactive dashboard

---

## 4. Approach

**Step 1: Setup.** Wrote a problem brief and data dictionary, then loaded the four raw files into PostgreSQL and checked the row counts.

**Step 2: Cleaning.** Converted millisecond timestamps to proper dates and times, checked for exact duplicate rows, and checked that event types and transaction IDs made sense. Built the item-to-category mapping from the item properties file. Every issue found and every fix is recorded in a cleaning log.
- Duplicates: I removed 13,278 duplicates in total which makes up around 0.0048% of the whole dataset also includes transaction duplicates too.
- Categories with no parent: Cleaned up 25 categories having no parent.
- Items with no category: We brushed off 17,984 those items as we don't need it. 

**Step 3: Funnel metrics.** Built visitor-level KPIs: view-to-cart rate, cart-to-purchase rate, overall conversion, cart abandonment, time to purchase and purchase gaps for repeat buyers. Trended them by week, day of week, hour and month.

**Step 4: Category and item analysis.** Calculated the funnel for each category and item (with a minimum-views rule), used window functions to rank items and split them into traffic quartiles, and sorted every item into one of four groups:

| Segment | Traffic | Conversion vs its category |
|---|---|---|
| Star | High | At or above average |
| Problem item | High | Below average |
| Hidden gem | Low | At or above average |
| Long tail | Low | Below average |

Also ran a Pareto analysis (how few items drive most purchases) and estimated the **extra purchases** if each problem item matched its category average:
`extra purchases = views × (category rate − item rate)`

**Step 5: Excel.** Rebuilt key numbers with pivot tables to confirm they match the SQL results, and built a small what-if sheet where you can change the "share of the gap closed" and see the estimated extra purchases update.

**Step 6: Power BI.** Built a 4-page dashboard:
1. Funnel overview
2. When people shop (week, day, hour, time to purchase)??
3. Categories and items.
4. Problem items table.

---

## 5. Key Findings

1. **Biggest drop-off:** 3% of visitors who viewed items added one to the cart, but only 31% of those who added to cart went on to buy. The largest loss happens at the **view → cart** stage as we failed to convert 97% of viewers into carters.
2. **Cart abandonment:** 69% of visitors who added an item to their cart did not buy.
3. **Timing:** Conversion is highest on Tuesday and around 1pm, and lowest on Saturday. 76% of buyers purchase on the same day they first visit.
4. **Categories:** ID 105 converts exceptional at 4.1%, while ID 788 has the weakest conversion at 0.05%.
5. **Concentration:** About 34% of purchased items account for 80% of purchases.
6. **Opportunity:** 28.31% high-traffic items convert below their category average. If they closed just 25% of the gap, the store would gain roughly 588 purchases.

---

## 6. Recommendations

1. **Fix the top 10 problem items first.** They hold 80% of the estimated opportunity. Review their pages, pricing and stock.
2. **Reduce cart abandonment.** [For example: reminders, simpler checkout, or a clearer shipping and price display.]
3. **Time promotions** for the days and hours with the highest conversion, or test what happens in the weak periods.
4. **Give hidden gems more visibility** with higher placement, since they convert well but get little traffic.

---

## 7. Dashboard Preview

| Funnel overview | When people shop | Categories & items | Problem items list |
|---|---|---|---|
| ![Page 1](images/overall_funnel.png) | ![Page 2](images/purchase_stats.png) | ![Page 3](images/category_and_conversion_stats.png) | ![Page 4](images/problem_items_list.png) |

---

## 8. Limitations

- The data covers only about 4.5 months of a single store, so seasonal patterns can't be measured.
- Item and category IDs are anonymized, so there are no product names.
- There is no reliable price data, so results are in **purchases, not revenue**.
- There are no session IDs, so a visitor's view and a later purchase may not belong to the same shopping trip.
- The first and last weeks of the data are partial and should not be read as trends.
- The extra-purchase estimate assumes problem items could reach their category average. It shows the size of the gap, not its cause, and the real gain is likely smaller.
- The data is from 2015, so behavior today may differ.

---

## 9. How to Reproduce

1. Download the dataset from the Kaggle link above.
2. Create a PostgreSQL database and run the SQL files in order:
   - `sql/01_load_raw_data.sql`
   - `sql/02_cleaning.sql`
   - `sql/03_funnel_metrics.sql`
   - `sql/04_category_item_analysis.sql`
   - `sql/05_pareto_and_uplift.sql`
3. Open `excel/checks_and_whatif.xlsx` to see the checks and the what-if model.
4. Open `powerbi/funnel_dashboard.pbix` in Power BI Desktop and point it to your database or exported tables.

---

## 10. Repository Structure

```
ecommerce-funnel-analysis/
├── Cleaned Files/
├── Excel/
├── Images/
├── Power BI/
└── SQL stage/
└── README.md/
```

---

## 11. About Me

**Pronob**: aspiring data analyst

  Email: pronobbhatt@gmail.com
