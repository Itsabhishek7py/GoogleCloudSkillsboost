# Writing LookML as a SQL Expert


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)]()


---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Dr Abhishek](https://www.youtube.com/@drabhishek.5460/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

## Create View `order_items`

```bash
view: order_items {
  sql_table_name: `cloud-training-demos.thelook_ecommerce.order_items` ;;
  drill_fields: [id]

  # ---------------------------
  # PRIMARY KEY
  # ---------------------------
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # ---------------------------
  # DATE DIMENSION GROUPS
  # ---------------------------
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.shipped_at ;;
  }

  # ---------------------------
  # OTHER DIMENSIONS
  # ---------------------------
  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  # ---------------------------
  # MEASURES
  # ---------------------------
  measure: count {
    label: "# of Order Items"
    type: count
    drill_fields: [id]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: customer_dividends {
    description: "Customers receive 10% of their total sales as a gift card for future purchases."
    type: number
    sql: 0.1 * ${total_sale_price} ;;
    value_format_name: usd
  }
}
```

## Open:  `qwiklabs-looker.model`
```bash
explore: order_items {
  label: "Ordered Items"

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}
```

## Update `order_items.view`

```bash
view: order_items {
  sql_table_name: `cloud-training-demos.thelook_ecommerce.order_items` ;;
  drill_fields: [id]

  # =========================
  # PRIMARY KEY
  # =========================
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # =========================
  # DATE DIMENSION GROUPS
  # =========================
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.shipped_at ;;
  }

  # =========================
  # OTHER DIMENSIONS
  # =========================
  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  # =========================
  # MEASURES
  # =========================
  measure: count {
    label: "# of Order Items"
    type: count
    drill_fields: [id]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: customer_dividends {
    description: "Customers receive 10% of their total sales as a gift card for future purchases."
    type: number
    sql: 0.1 * ${total_sale_price} ;;
    value_format_name: usd
  }
}
```

## Create View `top_100_users`

```bash
view: top_100_users {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: customer_dividends {}
      column: total_sale_price {}
      column: email { field: users.email }
    }
  }

  dimension: user_id {
    primary_key: yes
    type: number
  }

  dimension: customer_dividends {
    value_format: "$#,##0.00"
    type: number
  }

  dimension: total_sale_price {
    value_format: "$#,##0.00"
    type: number
  }

  dimension: email {
    type: string
  }
}
```

<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>

<a href="https://t.me/+gBcgRTlZLyM4OGI1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Channel"/>
</a>

<a href="https://t.me/+RujS6mqBFawzZDFl" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Group"/>
</a>

<a href="https://www.whatsapp.com/channel/0029VbCB6SpLo4hdpzFoD73f" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white&labelColor=25D366" alt="WhatsApp Channel"/>
</a>

<a href="https://www.youtube.com/@drabhishek.5460?sub_confirmation=1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Subscribe_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white&labelColor=FF0000" alt="YouTube"/>
</a>

<a href="https://www.instagram.com/drabhishek.5460/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white&labelColor=E4405F" alt="Instagram"/>
</a>

<a href="https://www.facebook.com/people/Dr-Abhishek/61580947955153/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white&labelColor=1877F2" alt="Facebook"/>
</a>

<a href="https://x.com/DAbhishek5460" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_X-000000?style=for-the-badge&logo=x&logoColor=white&labelColor=000000" alt="X (Twitter)"/>
</a>

</div>
